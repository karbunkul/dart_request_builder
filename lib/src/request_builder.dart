import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'cache/cache_manager.dart';
import 'cache/storage.dart';
import 'http_provider.dart';
import 'interceptor.dart';
import 'isolation_error.dart';
import 'request_body.dart';
import 'request_context.dart';
import 'request_provider.dart';
import 'request_response.dart';
import 'types.dart';

class RequestBuilder {
  final String? endpoint;
  final String? debugLabel;
  final Duration? timeout;

  final bool debugMode;
  final List<Interceptor>? interceptors;
  late final RequestProvider _provider;

  RequestBuilder({
    this.timeout,
    this.debugMode = false,
    this.endpoint,
    this.debugLabel,
    this.interceptors,
    RequestProvider? provider,
  }) : _provider = provider ?? HttpProvider();

  final _headers = <String, String>{};
  final _queries = <String, Set<String>>{};
  RequestBody? _body;
  CacheManager? _cacheOptions;

  RequestBuilder header({required String header, required String value}) {
    final key = header.toLowerCase();

    _headers.putIfAbsent(key, () => value);
    return this;
  }

  /// Adds caching functionality to the request builder.
  ///
  /// [ttl] - The time-to-live (TTL) duration for the cache.
  /// [storage] - The storage solution used to persist cached data.
  RequestBuilder withCache({
    required Duration ttl,
    required CacheStorage storage,
  }) {
    // Assigns the provided TTL and storage to the cache options.
    _cacheOptions = CacheManager(ttl: ttl, storage: storage);

    // Returns the updated RequestBuilder instance with cache options.
    return this;
  }

  /// Added query parameter by [key].
  ///
  /// If [value] == null, then addition will be skipped.
  /// Else for value, method [toString] will be called.
  ///
  /// If [key] already exists and [value] has not been added. This will add this [value],
  /// which will be parsed as:
  ///
  /// `?key=value1&key=value2`
  ///
  /// If [value] already exists, then addition for the new value will be skipped.
  /// (Works under the hood [Set])
  RequestBuilder query(String key, Object? value) {
    if (value == null) {
      return this;
    }

    if (_queries.containsKey(key)) {
      _queries[key]!.add(value.toString());
    } else {
      _queries[key] = {value.toString()};
    }

    return this;
  }

  /// Added query [values] parameter by [key].
  ///
  /// If [key] already exists, then will be added new [values].
  ///
  /// Example:
  ///
  /// `?key=value1&key=value2`
  RequestBuilder queryList(String key, Set<Object>? values) {
    if (values == null) {
      return this;
    }

    if (_queries.containsKey(key)) {
      _queries[key]!.addAll(values.map((e) => e.toString()));
    } else {
      _queries[key] = values.map((e) => e.toString()).toSet();
    }

    return this;
  }

  /// Sets the body of the request.
  ///
  /// [body] - The request body to be sent with the request.
  RequestBuilder body(RequestBody body) {
    // Assigns the provided body to the _body field.
    _body = body;

    // Returns the updated RequestBuilder instance with the body set.
    return this;
  }

  Uri _uri(String url) {
    final baseUri = Uri.parse(url);
    if (endpoint?.isEmpty == true || baseUri.scheme.startsWith('http')) {
      return Uri.parse(url);
    }

    final cleanEndpoint = endpoint!.endsWith('/')
        ? endpoint!.substring(0, endpoint!.length - 1)
        : endpoint!;

    final cleanUrl =
        url.length > 1 && url.startsWith('/') ? url.substring(1) : url;

    final fullUrl = '$cleanEndpoint/$cleanUrl';

    return Uri.parse(fullUrl);
  }

  Future<RequestContext> _requestContext({
    required String method,
    required String url,
  }) async {
    Uri newUri = _uri(url);
    if (newUri.hasQuery || _queries.isNotEmpty) {
      newUri = newUri.replace(
        queryParameters: _queries
          ..addAll(
            newUri.queryParametersAll.map(
              (key, value) => MapEntry(key, value.toSet()),
            ),
          ),
      );
    }

    if (_body != null) {
      _headers[HttpHeaders.contentTypeHeader] = _body!.mimeType();
    }

    final context = RequestContext(
      method: method.toUpperCase(),
      uri: newUri,
      headers: _headers.map((key, value) => MapEntry(key.toLowerCase(), value)),
      body: _body,
    );

    final requestInterceptors =
        interceptors?.whereType<RequestInterceptor>().toList(growable: false) ??
            [];
    requestInterceptors.sort();

    return requestInterceptors.fold(
      context,
      (prev, element) async => await element.request(await prev),
    );
  }

  Future<RequestResponse> _isolationRequest({
    required String method,
    required String url,
    Duration? timeout,
  }) async {
    final receivePort = ReceivePort(
      debugLabel != null ? '$debugLabel (request isolate)' : '',
    );
    final isolate = await Isolate.spawn<SendPort>(
      _onIsolate(method: method, url: url, timeout: timeout),
      receivePort.sendPort,
      onError: receivePort.sendPort,
    );

    final completer = Completer<RequestResponse>();
    // listen receive port
    receivePort.listen(
      (message) {
        if (message is IsolationError) {
          completer.completeError(message.error, message.stackTrace);
        } else {
          completer.complete(message);
        }
        isolate.kill(priority: Isolate.immediate);
        receivePort.close();
      },
    );

    return completer.future;
  }

  IsolateEntryPointCallback _onIsolate({
    required String method,
    required String url,
    Duration? timeout,
  }) {
    return (SendPort sendPort) async {
      try {
        final stopwatch = Stopwatch()..start();

        var context = await _requestContext(method: method, url: url);
        if (context.hasBody) {
          final headers = context.headers;
          headers['content-type'] = context.body!.mimeType();
          context = context.copyWith(headers: headers);
        }

        var response = (timeout != null)
            ? await _provider.request(context).timeout(timeout)
            : await _provider.request(context);

        final responseInterceptors = interceptors
                ?.whereType<ResponseInterceptor>()
                .toList(growable: false) ??
            [];

        if (responseInterceptors.isNotEmpty) {
          responseInterceptors.sort();
          response = await responseInterceptors.fold(
            response,
            (prev, element) async => await element.response(await prev),
          );
        }

        if (debugMode) {
          print('Request time: ${stopwatch.elapsedMilliseconds} ms');
        }
        sendPort.send(response);
      } catch (error, stackTrace) {
        sendPort.send(IsolationError(error: error, stackTrace: stackTrace));
      }
    };
  }

  Future<RequestResponse> requestOld({
    required String method,
    required String url,
    Duration? timeout,
  }) async {
    final stopwatch = Stopwatch()..start();

    /// build request context with request interceptors
    var context = await _requestContext(method: method, url: url);

    final timeLimit = timeout ?? this.timeout;

    /// cache validate
    final cached = await _cacheOptions?.validate(context);

    RequestResponse response;
    if (cached != null) {
      response = RequestResponse(
        request: context,
        statusCode: cached.statusCode,
        bytes: cached.content,
        headers: [],
      );
    } else {
      response = (timeLimit != null)
          ? await _provider.request(context).timeout(timeLimit)
          : await _provider.request(context);
    }

    final responseInterceptors = interceptors
            ?.whereType<ResponseInterceptor>()
            .toList(growable: false) ??
        [];

    if (responseInterceptors.isNotEmpty) {
      responseInterceptors.sort();
      response = await responseInterceptors.fold(
        response,
        (prev, element) async => await element.response(await prev),
      );
    }

    if (debugMode) {
      print('Request time: ${stopwatch.elapsedMilliseconds} ms');
    }

    if (response.statusCode == 200 && cached == null) {
      await _cacheOptions?.update(response);
    }

    return response;
  }

  Future<RequestResponse> request({
    required String method,
    required String url,
    Duration? timeout,
  }) async {
    final timeLimit = timeout ?? this.timeout;
    return _isolationRequest(method: method, url: url, timeout: timeLimit);
  }

  Future<RequestResponse> get(String url, {Duration? timeout}) async {
    return await requestOld(method: 'GET', url: url, timeout: timeout);
  }

  Future<RequestResponse> getWithIsolate(String url,
      {Duration? timeout}) async {
    return await request(method: 'GET', url: url, timeout: timeout);
  }

  Future<RequestResponse> post(String url, {Duration? timeout}) async {
    return await requestOld(method: 'POST', url: url, timeout: timeout);
  }

  Future<RequestResponse> put(String url, {Duration? timeout}) async {
    return await requestOld(method: 'PUT', url: url, timeout: timeout);
  }

  Future<RequestResponse> delete(String url, {Duration? timeout}) async {
    return await requestOld(method: 'DELETE', url: url, timeout: timeout);
  }

  Future<RequestResponse> patch(String url, {Duration? timeout}) async {
    return await requestOld(method: 'PATCH', url: url, timeout: timeout);
  }

  Future<RequestResponse> head(String url, {Duration? timeout}) async {
    return await requestOld(method: 'HEAD', url: url, timeout: timeout);
  }

  Future<RequestResponse> options(String url, {Duration? timeout}) async {
    return await requestOld(method: 'OPTIONS', url: url, timeout: timeout);
  }
}
