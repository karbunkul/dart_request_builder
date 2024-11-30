import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'request_context.dart';
import 'response_header.dart';

typedef Bytes = List<int>;

@immutable
final class RequestResponse {
  final RequestContext request;
  final int statusCode;
  final Uint8List bytes;
  final _HeaderWrapper _headerWrapper;

  RequestResponse({
    required this.request,
    required this.statusCode,
    required this.bytes,
    required List<ResponseHeader> headers,
  }) : _headerWrapper = _HeaderWrapper(headers);

  RequestResponse copyWith({List<ResponseHeader>? headers}) {
    return RequestResponse(
      request: request,
      statusCode: statusCode,
      bytes: bytes,
      headers: headers ?? this.headers,
    );
  }

  List<ResponseHeader> get headers => _headerWrapper.headers;
  ResponseHeader? header(String name) => _headerWrapper.header(name);

  /// If request is successfully done
  ///
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
  bool get isSuccess => _isStatusInRange(200, 299);
  bool get isRedirect => _isStatusInRange(300, 399);
  bool get isClientError => _isStatusInRange(400, 499);
  bool get isServerError => _isStatusInRange(500, 599);

  bool _isStatusInRange(int start, int end) =>
      statusCode >= start && statusCode <= end;

  bool get isFail => !isSuccess;
}

final class _HeaderWrapper {
  final List<ResponseHeader> headers;
  _HeaderWrapper(this.headers);

  late final Map<String, ResponseHeader> _headers = {
    for (final header in headers) header.name.toLowerCase(): header,
  };

  ResponseHeader? header(String name) {
    return _headers[name.toLowerCase()];
  }
}
