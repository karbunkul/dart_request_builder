import 'dart:async';
import 'dart:convert';

import 'package:request_builder/src/request_context.dart';

import 'request_response.dart';
import 'types.dart';

abstract interface class RequestProvider {
  Future<RequestResponse> request(RequestContext context);
}

extension BytesToJsonAsync on Future<RequestResponse> {
  Future<Json> toJson([String? path]) async {
    final response = await this;
    if (response.bytes.isEmpty) {
      return {};
    } else {
      final str = utf8.decode(response.bytes);
      return jsonDecode(str);
    }
  }
}

extension BytesToJson on RequestResponse {
  Json toJson([String? path]) {
    if (bytes.isEmpty) {
      return {};
    } else {
      final str = utf8.decode(bytes);
      return jsonDecode(str);
    }
  }
}

extension BytesToJsonList on RequestResponse {
  List<Json> toJsonList([String? path]) {
    if (bytes.isEmpty) {
      return [];
    } else {
      final str = utf8.decode(bytes);
      return (jsonDecode(str) as List).cast<Json>();
    }
  }
}

extension BytesToTextAsync on Future<RequestResponse> {
  Future<String> toText() async {
    final response = await this;
    if (response.bytes.isEmpty) {
      return '';
    } else {
      return utf8.decode(response.bytes);
    }
  }
}

extension BytesToText on RequestResponse {
  String toText() {
    if (bytes.isEmpty) {
      return '';
    } else {
      return utf8.decode(bytes);
    }
  }
}
