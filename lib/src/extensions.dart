import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:request_builder/src/exceptions.dart';
import 'package:request_builder/src/isolation_json_decoder.dart';

import 'request_response.dart';
import 'types.dart';

extension RequestResponseExt on RequestResponse {
  Future<Json> get json async {
    if (bytes.isEmpty) {
      return {};
    }
    try {
      return IsolationJsonDecoder.fromBytes(bytes);
    } on FormatException catch (err, stackTrace) {
      throw Error.throwWithStackTrace(
        ResponseDecodeError(err.source),
        stackTrace,
      );
    }
  }

  Future<List<Json>> get jsonList async {
    if (bytes.isEmpty) {
      return [];
    }
    try {
      return IsolationJsonDecoder.listFromBytes(bytes);
    } on FormatException catch (err, stackTrace) {
      throw Error.throwWithStackTrace(
        ResponseDecodeError(err.source),
        stackTrace,
      );
    }
  }

  Future<String> get text async {
    if (bytes.isEmpty) {
      return '';
    }
    return utf8.decode(bytes);
  }
}

extension CastOf on Json {
  T of<T>(ImportCallback<T> import) {
    try {
      return import(this);
    } catch (error, stackTrace) {
      throw Error.throwWithStackTrace(JsonImportError(), stackTrace);
    }
  }
}

extension AsyncCastOf on Future<Json> {
  Future<T> of<T>(ImportCallback<T> import) async {
    try {
      return import(await this);
    } catch (error, stackTrace) {
      throw Error.throwWithStackTrace(JsonImportError(), stackTrace);
    }
  }
}

extension CastListOf on List<Json> {
  List<T> of<T>(ImportCallback<T> import) {
    try {
      return map(import).toList();
    } catch (error, stackTrace) {
      throw Error.throwWithStackTrace(JsonImportError(), stackTrace);
    }
  }
}

extension AsyncCastListOf on Future<List<Json>> {
  Future<List<T>> of<T>(ImportCallback<T> import) async {
    try {
      final data = await this;
      return data.map(import).toList();
    } catch (error, stackTrace) {
      throw Error.throwWithStackTrace(JsonImportError(), stackTrace);
    }
  }
}
