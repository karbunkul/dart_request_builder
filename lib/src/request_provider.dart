import 'dart:async';

import 'package:request_builder/src/request_context.dart';

import 'request_response.dart';

abstract interface class RequestProvider {
  Future<RequestResponse> request(RequestContext context);
}
