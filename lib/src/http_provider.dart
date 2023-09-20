import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:request_builder/src/request_context.dart';
import 'package:request_builder/src/request_provider.dart';
import 'package:request_builder/src/request_response.dart';

import 'response_header.dart';

class HttpProvider implements RequestProvider {
  @override
  Future<RequestResponse> request(RequestContext context) async {
    final request = http.Request(context.method, context.uri);
    request.headers.addAll(context.headers);

    if (context.body != null) {
      final body = context.body!;
      request.bodyBytes = await body.content();
    }

    final res = await IOClient().send(request);

    final headers = <ResponseHeader>[];
    res.headers.forEach((name, value) {
      headers.add(ResponseHeader(name: name, values: value.split(',')));
    });

    return RequestResponse(
      statusCode: res.statusCode,
      bytes: await res.stream.toBytes(),
      headers: headers,
    );
  }
}
