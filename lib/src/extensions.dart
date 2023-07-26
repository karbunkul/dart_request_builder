import 'dart:convert';

import 'package:request_builder/src/exceptions.dart';

import 'request_response.dart';
import 'types.dart';

extension BytesTo on RequestResponse {
  Json get json {
    if (bytes.isEmpty) {
      return {};
    }
    try {
      final str = utf8.decode(bytes);
      return jsonDecode(str);
    } on FormatException catch (err, stackTrace) {
      throw Error.throwWithStackTrace(
        ResponseDecodeError(err.source),
        stackTrace,
      );
    }
  }

  List<Json> get jsonList {
    if (bytes.isEmpty) {
      return [];
    }
    try {
      final str = utf8.decode(bytes);
      return (jsonDecode(str) as List).cast<Json>();
    } on FormatException catch (err, stackTrace) {
      throw Error.throwWithStackTrace(
        ResponseDecodeError(err.source),
        stackTrace,
      );
    }
  }

  String get text {
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

extension CastListOf on List<Json> {
  List<T> of<T>(ImportCallback<T> import) {
    try {
      return map(import).toList();
    } catch (error, stackTrace) {
      throw Error.throwWithStackTrace(JsonImportError(), stackTrace);
    }
  }
}
