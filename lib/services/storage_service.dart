import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyPrefix = 'zikr_count_';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  int getCount(int zikrId) {
    return _prefs.getInt('$_keyPrefix$zikrId') ?? 0;
  }

  Future<void> setCount(int zikrId, int count) async {
    await _prefs.setInt('$_keyPrefix$zikrId', count);
  }

  Future<void> resetZikr(int zikrId) async {
    await _prefs.remove('$_keyPrefix$zikrId');
  }

  Future<void> resetMultiple(List<int> zikrIds) async {
    for (final id in zikrIds) {
      await _prefs.remove('$_keyPrefix$id');
    }
  }

  Future<void> resetAll() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_keyPrefix)).toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
