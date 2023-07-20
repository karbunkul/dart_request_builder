import 'package:request_builder/src/http_provider.dart';
import 'package:request_builder/src/request_body.dart';
import 'package:request_builder/src/request_context.dart';

import 'interceptor.dart';
import 'request_provider.dart';
import 'request_response.dart';

class RequestBuilder {
  final String? endpoint;
  final String? debugLabel;
  final Duration timeout;
  final bool debugMode;
  final List<Interceptor>? interceptors;
  late final RequestProvider _provider;

  RequestBuilder({
    this.timeout = const Duration(seconds: 1),
    this.debugMode = false,
    this.endpoint,
    this.debugLabel,
    this.interceptors,
    RequestProvider? provider,
  }) : _provider = provider ?? HttpProvider();

  final _headers = <String, String>{};
  final _queries = <String, String>{};
  RequestBody? _body;

  RequestBuilder header({required String header, required String value}) {
    final key = header.toLowerCase();

    _headers.putIfAbsent(key, () => value);
    return this;
  }

  RequestBuilder query(String query, Object value) {
    _queries.putIfAbsent(query, () => value.toString());
    return this;
  }

  RequestBuilder body(RequestBody body) {
    _body = body;
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
        queryParameters: _queries..addAll(newUri.queryParameters),
      );
    }

    final context = RequestContext(
      method: method.toUpperCase(),
      uri: newUri,
      headers: _headers,
      body: _body,
    );

    Iterable<RequestInterceptor> requestInterceptors =
        interceptors?.whereType<RequestInterceptor>() ?? [];

    return requestInterceptors.fold(
      context,
      (prev, element) async => await element.request(await prev),
    );
  }

  Future<RequestResponse> request({
    required String method,
    required String url,
    Duration? timeout,
  }) async {
    final stopwatch = Stopwatch()..start();

    var context = await _requestContext(method: method, url: url);
    if (context.body != null) {
      final headers = context.headers;
      headers['content-type'] = context.body!.mimeType();
      context = context.copyWith(headers: headers);
    }
    final timeLimit = timeout ?? this.timeout;

    var response = await _provider.request(context).timeout(timeLimit);

    Iterable<ResponseInterceptor> responseInterceptors =
        interceptors?.whereType<ResponseInterceptor>() ?? [];

    if (responseInterceptors.isNotEmpty) {
      response = await responseInterceptors.fold(
        response,
        (prev, element) async => await element.response(await prev),
      );
    }

    if (debugMode) {
      print('Request time: ${stopwatch.elapsedMilliseconds} ms');
    }

    return response;
  }

  Future<RequestResponse> get(String url, {Duration? timeout}) async {
    return await request(method: 'GET', url: url, timeout: timeout);
  }

  Future<RequestResponse> post(String url, {Duration? timeout}) async {
    return await request(method: 'POST', url: url, timeout: timeout);
  }
}
