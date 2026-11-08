import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_khulasah_al_hasna/services/storage_service.dart';
import 'package:al_khulasah_al_hasna/providers/azkar_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;
  late AzkarProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'zikr_count_1': 1,
      'zikr_count_5': 2,
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

  test('Increment and isCompleted work properly', () async {
    final morning = provider.book!.categories.first;
    final item5 = morning.items.firstWhere((i) => i.id == 5); // repeatCount: 3

    expect(provider.isCompleted(item5), false);
    await provider.increment(item5);
    expect(provider.getCount(5), 3);
    expect(provider.isCompleted(item5), true);

    // Try incrementing past max count
    await provider.increment(item5);
    expect(provider.getCount(5), 3);
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
    expect(provider.getCategoryProgress(morning), closeTo(expectedProgress, 0.001));

    await provider.resetCategory(morning);
    expect(provider.getCompletedCount(morning), 0);
    expect(provider.getCategoryProgress(morning), 0.0);
  });
}
