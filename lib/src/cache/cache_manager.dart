import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:request_builder/request_builder.dart';
import 'package:request_builder/src/cache/key_options.dart';

@internal
@immutable
final class CacheManager {
  /// The duration for which the cached data is considered valid.
  /// After this time, the cache will be considered expired.
  final Duration ttl;

  /// The storage to use for persisting the cached data.
  /// This can be in-memory, database, or any custom storage solution.
  final CacheStorage storage;

  final List<String>? keyQueries;
  final List<String>? keyHeaders;
  final bool withBody;

  /// Creates a new [CacheManager] with the specified [ttl] and [storage].
  const CacheManager({
    required this.ttl,
    required this.storage,
    this.keyQueries,
    this.keyHeaders,
    this.withBody = false,
  });

  Future<CacheData?> validate(RequestContext context) async {
    final key = CacheKeyOptions(
      withBody: withBody,
      headers: keyHeaders,
      queries: keyQueries,
    ).buildKey(context);

    final cached = await storage.fetch(key);
    if (cached == null) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final createdAt = cached.createdAt;
    if (!now.isAfter(createdAt.add(ttl))) {
      return cached;
    }

    return null;
  }

  /// Updates the cache with the provided response data.
  ///
  /// [response] - The response data that will be cached.
  /// This method constructs a cache key, validates the status code, and then
  /// stores the response data (headers, content, and status code) if valid.
  Future<void> update(RequestResponse response) async {
    // Build the cache key based on the request's body, headers, and query parameters
    final key = CacheKeyOptions(
      withBody: withBody,
      headers: keyHeaders,
      queries: keyQueries,
    ).buildKey(response.request);

    // Define a list of allowed status codes for caching
    const allowStatusCodes = [200, 201, 204];

    // If the response status code is not in the allowed list, do not cache
    if (!allowStatusCodes.contains(response.statusCode)) {
      return;
    }

    // Prepare the cache data, including the key, timestamp, response headers, content, and status code
    final cacheData = CacheData(
      key: key,
      createdAt: DateTime.now().toUtc(),
      headers: Uint8List.fromList([]),
      // You can add headers if needed in the future
      content: response.bytes,
      // Cache the actual response body content
      statusCode: response.statusCode, // Store the HTTP status code
    );

    // Save the cache data to storage
    await storage.save(cacheData);
  }

  Duration? _parseMaxAge(String value) {
    final pattern = RegExp(r'(\d+)');
    if (pattern.hasMatch(value)) {
      final maxAge = int.tryParse(pattern.stringMatch(value) ?? '0');
      if (maxAge != null && maxAge > 0) {
        return Duration(seconds: maxAge);
      }
    }
    return null;
  }
}
