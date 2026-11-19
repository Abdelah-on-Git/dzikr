import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_khulasah_al_hasna/services/storage_service.dart';
import 'package:al_khulasah_al_hasna/providers/azkar_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;
  late AzkarProvider provider;

  setUp(() async {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    SharedPreferences.setMockInitialValues({
      'zikr_count_1': 1,
      'zikr_count_5': 2,
      'zikr_last_date': today,
    });
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(prefs);
    provider = AzkarProvider(storage);
    await provider.loadData();
  });

  test('Initial state loads correctly from storage', () {
    expect(provider.book, isNotNull);
    expect(provider.getCount(1), 1);
    expect(provider.getCount(5), 2);
    expect(provider.getCount(2), 0);
  });

  test('Increment and isCompleted work properly for bounded items', () async {
    final morning = provider.book!.categories.first;
    final item5 = morning.items.firstWhere((i) => i.id == 5); // repeatCount: 3

    expect(provider.isCompleted(item5), false);
    await provider.increment(item5);
    expect(provider.getCount(5), 3);
    expect(provider.isCompleted(item5), true);

    // Bounded item stops at repeatCount
    await provider.increment(item5);
    expect(provider.getCount(5), 3);
  });

  test('Open-ended item (#8 with note وَتَزِيدُ) can exceed 100 repetitions',
      () async {
    final morning = provider.book!.categories.first;
    final item8 = morning.items.firstWhere((i) => i.id == 8); // repeatCount: 100

    expect(provider.canExceedRepeatCount(item8), true);

    // Fast-forward to 100
    await storage.setCount(item8.id, 100);
    await provider.loadData();
    expect(provider.getCount(8), 100);
    expect(provider.isCompleted(item8), true);

    // Increment beyond 100
    await provider.increment(item8);
    expect(provider.getCount(8), 101);
    expect(provider.isCompleted(item8), true);
  });

  test('Decrement and reset work properly', () async {
    final morning = provider.book!.categories.first;
    final item5 = morning.items.firstWhere((i) => i.id == 5);

    await provider.decrement(item5);
    expect(provider.getCount(5), 1);

    await provider.resetZikr(5);
    expect(provider.getCount(5), 0);
  });

  test('Category progress calculations', () async {
    final morning = provider.book!.categories.first;
    // item 1 is completed (1/1)
    expect(provider.getCompletedCount(morning), 1);
    final expectedProgress = 1 / morning.items.length;
    expect(
        provider.getCategoryProgress(morning), closeTo(expectedProgress, 0.001));

    await provider.resetCategory(morning);
    expect(provider.getCompletedCount(morning), 0);
    expect(provider.getCategoryProgress(morning), 0.0);
  });

  test('Font scale and view mode are modified and persisted', () async {
    provider.changeFontScale(1.15);
    expect(provider.fontScale, 1.15);
    expect(storage.getFontScale(), 1.15);

    expect(provider.isSwipeMode, false);
    await provider.toggleViewMode();
    expect(provider.isSwipeMode, true);
    expect(storage.getViewMode(), 'swipe');
  });

  test('Daily auto-reset activates when last_date is from a previous day',
      () async {
    SharedPreferences.setMockInitialValues({
      'zikr_count_1': 1,
      'zikr_count_5': 3,
      'zikr_last_date': '2020-01-01', // Outdated date
    });
    final prefs = await SharedPreferences.getInstance();
    final localStore = StorageService(prefs);
    final localProvider = AzkarProvider(localStore);
    await localProvider.loadData();

    // Should have reset counts because of the new day
    expect(localProvider.getCount(1), 0);
    expect(localProvider.getCount(5), 0);
  });

  test('Theme mode toggles and is persisted in storage', () async {
    // Default is dark mode
    expect(provider.isDarkMode, true);

    await provider.toggleThemeMode();
    expect(provider.isDarkMode, false);
    expect(storage.getIsDarkMode(), false);

    await provider.toggleThemeMode();
    expect(provider.isDarkMode, true);
    expect(storage.getIsDarkMode(), true);
  });

  test('Haptic feedback: heavyImpact on completing multi-repetition azkar, mediumImpact for repeatCount == 1', () async {
    final hapticCalls = <String?>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
      if (methodCall.method == 'HapticFeedback.vibrate') {
        hapticCalls.add(methodCall.arguments as String?);
      }
      return null;
    });

    final morning = provider.book!.categories.first;
    // item 2 has repeatCount == 1 and initial count is 0
    final item2 = morning.items.firstWhere((i) => i.id == 2);
    expect(item2.repeatCount, 1);
    expect(provider.getCount(2), 0);

    // Increment item 2 to 1 (completes single-repetition item)
    await provider.increment(item2);
    expect(hapticCalls.last, 'HapticFeedbackType.mediumImpact');

    // item 5 has repeatCount == 3 and initial count is 2 (from setUp)
    final item5 = morning.items.firstWhere((i) => i.id == 5);
    expect(item5.repeatCount, 3);
    // Reset to test intermediate taps
    await provider.resetZikr(5);
    hapticCalls.clear();

    // 0 -> 1 (interim tap)
    await provider.increment(item5);
    expect(hapticCalls.last, 'HapticFeedbackType.lightImpact');

    // 1 -> 2 (interim tap)
    await provider.increment(item5);
    expect(hapticCalls.last, 'HapticFeedbackType.lightImpact');

    // 2 -> 3 (completion of multi-repetition zikr)
    await provider.increment(item5);
    expect(hapticCalls.last, 'HapticFeedbackType.heavyImpact');
  });

  test('getFirstIncompleteIndex and getRemainingIncompleteCount calculate correctly', () async {
    final morning = provider.book!.categories.first;
    await provider.resetCategory(morning);

    expect(provider.getFirstIncompleteIndex(morning), 0);
    expect(provider.getRemainingIncompleteCount(morning), morning.items.length);

    // Complete item 0
    await provider.increment(morning.items[0]);
    expect(provider.isCompleted(morning.items[0]), true);

    // Now first incomplete should be index 1
    expect(provider.getFirstIncompleteIndex(morning), 1);
    expect(provider.getRemainingIncompleteCount(morning), morning.items.length - 1);

    // Skip item 1, complete all other items
    for (int i = 2; i < morning.items.length; i++) {
      final item = morning.items[i];
      for (int count = 0; count < item.repeatCount; count++) {
        await provider.increment(item);
      }
    }

    // Item 1 is still incomplete, all others are complete
    expect(provider.getFirstIncompleteIndex(morning), 1);
    expect(provider.getRemainingIncompleteCount(morning), 1);

    // Complete item 1 as well
    final item1 = morning.items[1];
    for (int count = 0; count < item1.repeatCount; count++) {
      await provider.increment(item1);
    }

    // All items completed
    expect(provider.getFirstIncompleteIndex(morning), isNull);
    expect(provider.getRemainingIncompleteCount(morning), 0);
  });
}

