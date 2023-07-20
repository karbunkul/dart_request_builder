import 'dart:async';

import 'package:request_builder/src/request_context.dart';
import 'package:request_builder/src/request_response.dart';

part 'interceptors/debug_interceptor.dart';
part 'interceptors/user_agent_interceptor.dart';

abstract interface class Interceptor {}

abstract interface class RequestInterceptor implements Interceptor {
  FutureOr<RequestContext> request(RequestContext context);
}

abstract interface class ResponseInterceptor implements Interceptor {
  FutureOr<RequestResponse> response(RequestResponse response);
}
