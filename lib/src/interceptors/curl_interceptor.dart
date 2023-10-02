part of '../interceptor.dart';

typedef CurlCallback = void Function(String curl);

final class CurlInterceptor extends RequestInterceptor {
  final CurlCallback? onCurl;

  CurlInterceptor({this.onCurl, super.weight = -999999999999999999});

  @override
  FutureOr<RequestContext> request(RequestContext context) async {
    final String method = context.method;
    final String url = context.uri.toString();
    String curl = 'curl --location --request $method \'$url\'';

    if (context.headers.isNotEmpty) {
      curl += " \\\n";
    }

    for (final header in context.headers.keys) {
      final value = context.headers[header];
      curl += '--header \'$header: $value\'';
    }

    if (context.hasBody) {
      curl += " \\\n";
      if (context.body!.sourceType == BodySourceType.binary) {
        curl = 'CurlInterceptor doesn`t support -binary-data option';
      } else {
        final bodyBytes = await context.body!.content();
        final body = utf8.decode(bodyBytes);
        curl += '--data \'$body\'';
      }
    }

    if (onCurl != null) {
      onCurl!.call(curl);
    } else {
      Logger('request_builder:curl').info(curl);
    }

    return context;
  }
}
