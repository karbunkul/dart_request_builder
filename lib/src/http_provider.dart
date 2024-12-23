import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:request_builder/src/request_context.dart';
import 'package:request_builder/src/request_provider.dart';
import 'package:request_builder/src/request_response.dart';

import 'response_header.dart';

class HttpProvider implements RequestProvider {
  final ProxyOptions? proxyOptions;

  const HttpProvider({this.proxyOptions});

  @override
  Future<RequestResponse> request(RequestContext context) async {
    final client = await _createHttpClient();

    final request = http.Request(context.method, context.uri);
    request.headers.addAll(context.headers);

    if (context.body != null) {
      final body = context.body!;
      request.bodyBytes = await body.content();
    }

    final res = await client.send(request);

    final headers = <ResponseHeader>[];
    res.headers.forEach((name, value) {
      headers.add(ResponseHeader(name: name, values: value.split(',')));
    });

    return RequestResponse(
      request: context,
      statusCode: res.statusCode,
      bytes: await res.stream.toBytes(),
      headers: headers,
    );
  }

  Future<http.Client> _createHttpClient() async {
    final httpClient = HttpClient();

    if (proxyOptions != null) {
      httpClient.findProxy = (uri) => proxyOptions!.proxy;
      httpClient.badCertificateCallback = (cert, host, port) => true;
    }

    return IOClient(httpClient);
  }
}

final class ProxyOptions {
  final int port;
  final String? host;

  const ProxyOptions({required this.port, this.host});

  String get proxy => 'PROXY ${host ?? '127.0.0.1'}:$port';
}
