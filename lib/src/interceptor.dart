import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:request_builder/request_builder.dart';

part 'interceptors/curl_interceptor.dart';
// part 'interceptors/debug_interceptor.dart';
part 'interceptors/user_agent_interceptor.dart';

abstract interface class Interceptor {
  final int weight;

  const Interceptor({this.weight = 0});
}

abstract base class RequestInterceptor extends Interceptor
    implements Comparable<RequestInterceptor> {
  const RequestInterceptor({super.weight});

  FutureOr<RequestContext> request(RequestContext context);

  @override
  int compareTo(Interceptor other) {
    return other.weight.compareTo(weight);
  }
}

abstract base class ResponseInterceptor extends Interceptor
    implements Comparable<ResponseInterceptor> {
  const ResponseInterceptor({super.weight});
  FutureOr<RequestResponse> response(RequestResponse response);

  @override
  int compareTo(Interceptor other) {
    return other.weight.compareTo(weight);
  }
}
