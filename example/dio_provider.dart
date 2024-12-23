import 'package:dio/dio.dart';
import 'package:request_builder/request_builder.dart';

class DioProvider implements RequestProvider {
  @override
  Future<RequestResponse> request(RequestContext context) async {
    final dio = Dio();
    //
    // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (client) {
    //   client.findProxy = (uri) {
    //     return 'PROXY 127.0.0.1:8080'; // Укажи прокси Fiddler
    //   };
    //
    //   // Пропускаем проверки сертификатов
    //   client.badCertificateCallback = (cert, host, port) => true;
    //
    //   return client;
    // };

    final response = await dio.requestUri(
      context.uri,
      data: await context.body?.content(),
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
      request: context,
      statusCode: response.statusCode!,
      bytes: response.data,
      headers: headers,
    );
  }
}
