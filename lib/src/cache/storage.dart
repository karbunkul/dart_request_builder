import 'package:meta/meta.dart';

import 'cache_data.dart';

@immutable
abstract base class CacheStorage {
  const CacheStorage();

  /// Store new binary data in the cache
  ///
  /// [data] - The binary data to cache
  Future<void> save(CacheData data);

  /// Retrieve cached binary data by key. Returns null if data does not exist.
  ///
  /// [key] - The key associated with the cached data
  Future<CacheData?> fetch(String key);

  /// Remove cached binary data associated with the specified key
  ///
  /// [key] - The key of the cached data to remove
  Future<void> remove(String key);
}
