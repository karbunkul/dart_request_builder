part of '../interceptor.dart';

final class DebugInterceptor extends ResponseInterceptor {
  final bool headers;

  DebugInterceptor({this.headers = true, super.weight});

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
