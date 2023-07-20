part of '../interceptor.dart';

final class UserAgentInterceptor implements RequestInterceptor {
  final String userAgent;

  UserAgentInterceptor(this.userAgent);

  @override
  FutureOr<RequestContext> request(RequestContext context) {
    final headers = context.headers;
    headers['user-agent'] = userAgent;

    return context.copyWith(headers: headers);
  }
}
