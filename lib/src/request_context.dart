import 'request_body.dart';

final class RequestContext {
  final String method;
  final Uri uri;
  final Map<String, String> headers;
  final RequestBody? body;

  const RequestContext({
    required this.method,
    required this.uri,
    required this.headers,
    this.body,
  });

  RequestContext copyWith({Uri? uri, Map<String, String>? headers}) {
    return RequestContext(
      method: method,
      uri: uri ?? this.uri,
      headers: headers ?? this.headers,
      body: body,
    );
  }

  @override
  String toString() {
    return "(method=$method, uri=$uri, headers=$headers)";
  }
}
