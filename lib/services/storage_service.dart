import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyPrefix = 'zikr_count_';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  static const String _keyLastDate = 'zikr_last_date';
  static const String _keyFontScale = 'zikr_font_scale';
  static const String _keyViewMode = 'zikr_view_mode';
  static const String _keyIsDarkMode = 'zikr_is_dark_mode';


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

  String? getLastDate() {
    return _prefs.getString(_keyLastDate);
  }

  Future<void> setLastDate(String date) async {
    await _prefs.setString(_keyLastDate, date);
  }

  double getFontScale() {
    return _prefs.getDouble(_keyFontScale) ?? 1.0;
  }

  Future<void> setFontScale(double scale) async {
    await _prefs.setDouble(_keyFontScale, scale);
  }

  String getViewMode() {
    return _prefs.getString(_keyViewMode) ?? 'list';
  }

  Future<void> setViewMode(String mode) async {
    await _prefs.setString(_keyViewMode, mode);
  }

  bool getIsDarkMode() {
    return _prefs.getBool(_keyIsDarkMode) ?? true;
  }

  Future<void> setIsDarkMode(bool isDark) async {
    await _prefs.setBool(_keyIsDarkMode, isDark);
  }
}

