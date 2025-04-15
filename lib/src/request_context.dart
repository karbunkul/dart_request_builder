import 'package:request_builder/src/types.dart';

import 'request_body.dart';

final class RequestContext {
  final String method;
  final PlatformType platform;
  final Uri uri;
  final Map<String, String> headers;
  final RequestBody? body;

  const RequestContext({
    required this.method,
    required this.platform,
    required this.uri,
    required this.headers,
    this.body,
  });

  RequestContext copyWith({Uri? uri, Map<String, String>? headers}) {
    return RequestContext(
      method: method,
      platform: platform,
      uri: uri ?? this.uri,
      headers: (headers ?? this.headers).map(
        (key, value) => MapEntry(key.toLowerCase(), value),
      ),
      body: body,
    );
  }

  bool hasHeader(String header) => headers.containsKey(header);

  bool get hasBody => body != null;

  @override
  String toString() {
    return "(method=$method, uri=$uri, headers=$headers)";
  }
}
