import 'dart:typed_data';

import 'package:request_builder/src/request_context.dart';

import 'response_header.dart';

typedef Bytes = List<int>;

final class RequestResponse {
  final RequestContext request;
  final int statusCode;
  final Uint8List bytes;
  final List<ResponseHeader> headers;

  const RequestResponse({
    required this.request,
    required this.statusCode,
    required this.bytes,
    required this.headers,
  });

  RequestResponse copyWith({List<ResponseHeader>? headers}) {
    return RequestResponse(
      request: request,
      statusCode: statusCode,
      bytes: bytes,
      headers: headers ?? this.headers,
    );
  }

  /// If request is successfully done
  ///
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  bool get isFail => !isSuccess;
}
