import 'dart:typed_data';

import 'package:meta/meta.dart';

@immutable
final class CacheData {
  /// The key associated with the cached data
  final String key;

  /// The timestamp when the cached data was created
  final DateTime createdAt;

  /// The headers of the cached response in binary form
  final Uint8List headers;

  /// The content of the cached response in binary form
  final Uint8List content;

  /// The HTTP status code of the cached response
  final int statusCode;

  /// Constructor to initialize the cache data with provided values
  const CacheData({
    required this.key,
    required this.createdAt,
    required this.headers,
    required this.content,
    required this.statusCode,
  });
}
