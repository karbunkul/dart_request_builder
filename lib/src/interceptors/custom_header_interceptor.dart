part of '../interceptor.dart';

final class CustomHeaderInterceptor extends RequestInterceptor {
  final String key;
  final String value;

  CustomHeaderInterceptor({required this.key, required this.value});

  @override
  FutureOr<RequestContext> request(RequestContext context) {
    final headers = context.headers;
    headers[key] = value;

    return context.copyWith(headers: headers);
  }
}
