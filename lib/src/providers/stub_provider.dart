import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../request_builder.dart';

final class StubProvider implements RequestProvider {
  final bool enabled;
  final RequestProvider _provider;
  final StubRegistry _registry;

  StubProvider({
    required List<StubEntry> entries,
    required RequestProvider provider,
    required this.enabled,
  })  : _registry = StubRegistry(entries),
        _provider = provider;

  @override
  Future<RequestResponse> request(RequestContext context) async {
    final stub = await _registry.match(context);

    if (stub != null) {
      if (stub.response.responseTime > 0) {
        await Future.delayed(
          Duration(milliseconds: stub.response.responseTime),
        );
      }
      return stub.toResponse(context);
    }

    return _provider.request(context);
  }
}

@internal
@visibleForTesting
final class StubRegistry {
  final List<StubCase> items = [];
  final Set<String> _paths = {};

  StubRegistry(List<StubEntry> entries) {
    for (final entry in entries) {
      _processEntry(entry);
    }
  }

  Future<StubCase?> match(RequestContext context) async {
    final uri = context.uri;
    final key = _makePath(
      path: '${uri.origin}${uri.path}',
      method: context.method,
    );

    if (!_paths.contains(key)) {
      return null;
    }

    final candidates = items.where((stub) {
      final requestKey = _makePath(
        path: stub.request.path,
        method: stub.request.method,
      );
      return key == requestKey;
    });

    for (final stub in candidates) {
      if (_matchesQueries(stub, context) &&
          _matchesHeaders(stub, context) &&
          await _matchesBody(stub, context)) {
        return stub;
      }
    }

    return null;
  }

  bool _matchesQueries(StubCase stub, RequestContext context) {
    final stubQueries = stub.request.queries;
    if (stubQueries == null || stubQueries.isEmpty) {
      return true;
    }

    final actualQueries = context.uri.queryParameters;

    for (final entry in stubQueries.entries) {
      if (actualQueries[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  bool _matchesHeaders(StubCase stub, RequestContext context) {
    final stubHeaders = stub.request.headers;
    if (stubHeaders == null || stubHeaders.isEmpty) {
      return true;
    }

    final actualHeaders = context.headers;

    for (final entry in stubHeaders.entries) {
      final actualValue = actualHeaders[entry.key.toLowerCase()];
      if (actualValue != entry.value) {
        return false;
      }
    }
    return true;
  }

  void _processEntry(StubEntry entry) {
    for (final stubCase in entry.cases()) {
      _paths.add(_makePath(
        path: stubCase.request.path,
        method: stubCase.request.method,
      ));

      items.add(stubCase);
    }
  }

  String _makePath({required String path, required String method}) {
    return '${method.toUpperCase()}|$path';
  }

  Future<bool> _matchesBody(StubCase stub, RequestContext context) async {
    if (stub.request.body == null) {
      return true;
    }

    if (context.body == null) {
      return false;
    }

    final expected = await stub.request.body!.call();
    final actual = await context.body!.content();

    return _listEquals(expected, actual);
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

abstract base class StubEntry {
  List<StubCase> cases();
}

final class StubCase {
  final StubRequest request;
  final StubResponse response;

  const StubCase({
    required this.request,
    required this.response,
  });

  RequestResponse toResponse(RequestContext request) {
    final headers = response.headers?.entries
        .map((e) => ResponseHeader(name: e.key, values: [e.value]))
        .toList();

    return RequestResponse(
      request: request,
      statusCode: response.statusCode,
      bytes: Uint8List.fromList(response.content),
      headers: headers ?? [],
    );
  }
}

typedef OnBodyCallback = FutureOr<List<int>> Function();

@immutable
final class StubRequest {
  final String method;
  final String path;
  final Map<String, String>? headers;
  final Map<String, String>? queries;
  final OnBodyCallback? body;

  const StubRequest({
    required this.method,
    required this.path,
    this.headers,
    this.queries,
    this.body,
  });

  factory StubRequest.fromRequestBody({
    required String method,
    required String path,
    required RequestBody body,
    Map<String, String>? headers,
    Map<String, String>? queries,
  }) {
    return StubRequest(
      method: method,
      path: path,
      body: () => body.content(),
    );
  }
}

@immutable
base class StubResponse {
  final int statusCode;
  final Map<String, String>? headers;
  final String contentType;
  final List<int> content;
  final int _responseTime;

  const StubResponse({
    required this.statusCode,
    required this.content,
    this.headers,
    this.contentType = 'application/json',
    int? responseTime,
  }) : _responseTime = responseTime ?? 200;

  int get responseTime => _responseTime;

  factory StubResponse.text({
    required int statusCode,
    required String content,
    Map<String, String>? headers,
    int? responseTime,
  }) {
    return StubResponse(
      statusCode: statusCode,
      content: utf8.encode(content),
      headers: headers,
      contentType: 'plain/text',
      responseTime: responseTime,
    );
  }

  factory StubResponse.json({
    required int statusCode,
    required Map<String, dynamic> content,
    Map<String, String>? headers,
    int? responseTime,
  }) {
    return StubResponse(
      statusCode: statusCode,
      content: utf8.encode(jsonEncode(content)),
      headers: headers,
      contentType: 'application/json',
      responseTime: responseTime,
    );
  }
}
