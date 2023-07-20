part of '../interceptor.dart';

final class DebugInterceptor
    implements RequestInterceptor, ResponseInterceptor {
  @override
  FutureOr<RequestContext> request(RequestContext context) {
    final message = '''
== REQUEST ==
| Method: ${context.method};
| Uri: ${context.uri}
''';
    print(message);
    return context;
  }

  @override
  FutureOr<RequestResponse> response(RequestResponse response) {
    final message = '''
== RESPONSE ==
| Status code: ${response.statusCode};
| Headers:
|| ${response.headers.join('\n|| ')}
''';
    print(message);

    return response;
  }
}
