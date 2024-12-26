import 'package:request_builder/request_builder.dart';

final class MemoryCacheStorage extends CacheStorage {
  final Map<String, CacheData> _storage = {};

  @override
  Future<CacheData?> fetch(String key) async {
    return _storage.containsKey(key) ? _storage[key] : null;
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> save(value) async {
    _storage[value.key] = value;
  }
}
