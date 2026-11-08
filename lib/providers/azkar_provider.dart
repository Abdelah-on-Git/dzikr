import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/azkar_book.dart';
import '../models/azkar_category.dart';
import '../models/zikr_item.dart';
import '../data/azkar_repository.dart';
import '../services/storage_service.dart';

class AzkarProvider extends ChangeNotifier {
  final StorageService _storage;
  AzkarBook? _book;
  bool _isLoading = true;
  final Map<int, int> _counts = {};
  double _fontScale = 1.0;
  bool _isSwipeMode = false;

  AzkarProvider(this._storage);

  AzkarBook? get book => _book;
  bool get isLoading => _isLoading;
  double get fontScale => _fontScale;
  bool get isSwipeMode => _isSwipeMode;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    // Check calendar date for daily reset
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastDate = _storage.getLastDate();

    if (lastDate != null && lastDate != today) {
      // New day: reset daily counters so user can recite anew today
      await _storage.resetAll();
      await _storage.setLastDate(today);
    } else if (lastDate == null) {
      await _storage.setLastDate(today);
    }

    _fontScale = _storage.getFontScale();
    _isSwipeMode = _storage.getViewMode() == 'swipe';

    _book = await AzkarRepository.getBook();
    for (final category in _book!.categories) {
      for (final item in category.items) {
        _counts[item.id] = _storage.getCount(item.id);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  int getCount(int zikrId) {
    return _counts[zikrId] ?? 0;
  }

  bool isCompleted(ZikrItem item) {
    return getCount(item.id) >= item.repeatCount;
  }

  bool canExceedRepeatCount(ZikrItem item) {
    return item.note != null && item.note!.contains('وَتَزِيدُ');
  }

  Future<void> increment(ZikrItem item) async {
    final current = getCount(item.id);
    final allowsExceed = canExceedRepeatCount(item);

    if (current >= item.repeatCount && !allowsExceed) {
      // Bounded item already reached target count
      HapticFeedback.selectionClick();
      return;
    }

    final next = current + 1;
    _counts[item.id] = next;
    notifyListeners();

    if (next == item.repeatCount) {
      // Milestone reached
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    await _storage.setCount(item.id, next);
  }

  Future<void> decrement(ZikrItem item) async {
    final current = getCount(item.id);
    if (current <= 0) return;

    final next = current - 1;
    _counts[item.id] = next;
    notifyListeners();
    HapticFeedback.selectionClick();

    await _storage.setCount(item.id, next);
  }

  Future<void> resetZikr(int zikrId) async {
    _counts[zikrId] = 0;
    notifyListeners();
    HapticFeedback.mediumImpact();
    await _storage.resetZikr(zikrId);
  }

  Future<void> resetCategory(AzkarCategory category) async {
    final ids = category.items.map((i) => i.id).toList();
    for (final id in ids) {
      _counts[id] = 0;
    }
    notifyListeners();
    HapticFeedback.heavyImpact();
    await _storage.resetMultiple(ids);
  }

  Future<void> resetAll() async {
    _counts.clear();
    notifyListeners();
    HapticFeedback.heavyImpact();
    await _storage.resetAll();
  }

  int getCompletedCount(AzkarCategory category) {
    return category.items.where((i) => isCompleted(i)).length;
  }

  double getCategoryProgress(AzkarCategory category) {
    if (category.items.isEmpty) return 0.0;
    final completed = getCompletedCount(category);
    return completed / category.items.length;
  }

  void changeFontScale(double scale) {
    _fontScale = scale.clamp(0.85, 1.4);
    notifyListeners();
    _storage.setFontScale(_fontScale);
  }

  Future<void> toggleViewMode() async {
    _isSwipeMode = !_isSwipeMode;
    notifyListeners();
    await _storage.setViewMode(_isSwipeMode ? 'swipe' : 'list');
  }
}
