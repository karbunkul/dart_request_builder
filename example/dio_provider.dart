import 'package:dio/dio.dart';
import 'package:request_builder/request_builder.dart';
import 'package:request_builder/src/request_context.dart';
import 'package:request_builder/src/request_response.dart';
import 'package:request_builder/src/response_header.dart';

class DioProvider implements RequestProvider {
  @override
  Future<RequestResponse> request(RequestContext context) async {
    final dio = Dio();

    final response = await dio.requestUri(
      context.uri,
      data: context.body?.content(),
      options: Options(
        headers: context.headers,
        method: context.method,
        responseType: ResponseType.bytes,
        validateStatus: (status) => status != null,
      ),
    );

    final headers = <ResponseHeader>[];
    response.headers.forEach((name, value) {
      headers.add(ResponseHeader(name: name, values: value));
    });

    return RequestResponse(
      statusCode: response.statusCode!,
      bytes: response.data,
      headers: headers,
    );
  }
}
