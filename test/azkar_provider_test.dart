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
}
