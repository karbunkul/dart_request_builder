part of '../interceptor.dart';

final class DebugInterceptor
    implements RequestInterceptor, ResponseInterceptor {
  final bool headers;

  DebugInterceptor({this.headers = true});

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
${headers ? '| Headers:\n|| ${response.headers.join('\n|| ')}' : ''}
| Response:

${utf8.decode(response.bytes)}
''';
    print(message);

    return response;
  }
}
