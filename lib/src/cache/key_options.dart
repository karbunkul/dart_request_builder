import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

import '../../request_builder.dart';

enum _CacheKeyType {
  query('q'),
  header('h'),
  body('b');

  final String id;

  const _CacheKeyType(this.id);
}

@internal
@immutable
final class CacheKeyOptions {
  final Set<String>? _queries;
  final Set<String>? _headers;
  final bool? withBody;

  CacheKeyOptions({
    List<String>? queries,
    List<String>? headers,
    this.withBody,
  })  : _queries = queries?.map((e) => e.toLowerCase()).toSet(),
        _headers = headers?.map((e) => e.toLowerCase()).toSet();

  FutureOr<String> buildKey(RequestContext context) async {
    final strHeaders = _pairs(
      context.headers,
      _CacheKeyType.header,
    ).join(',');

    final strQueries = _pairs(
      context.uri.queryParameters,
      _CacheKeyType.query,
    ).join(',');

    final httpMethod = context.method;
    final url = context.uri.toString();

    var str = 'm-$httpMethod;u-$url;$strQueries;$strHeaders';

    if (context.hasBody && (withBody == null || withBody == true)) {
      final body = base64.encode(await context.body!.content());
      str = '$str;${_CacheKeyType.body.id}-$body';
    }

    return _hashKey(str);
  }

  Iterable<String> _pairs(Map<String, String> value, _CacheKeyType type) {
    final common = _commonFields(value, type).toList(growable: false);
    common.sort();
    return common.map((e) => '${type.id}-$e:${value[e]}');
  }

  Iterable<String> _commonFields(
      Map<String, String> value, _CacheKeyType type) {
    if (_queries == null && _headers == null) {
      return value.keys;
    }

    if (type == _CacheKeyType.query && _queries != null) {
      return value.keys.toSet().intersection(_queries!);
    }

    if (type == _CacheKeyType.header && _headers != null) {
      return value.keys.toSet().intersection(_headers!);
    }

    return value.keys;
  }

  String _hashKey(String key) {
    final bytes = utf8.encode(key);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
