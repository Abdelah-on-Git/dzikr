import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_khulasah_al_hasna/models/azkar_category.dart';
import 'package:al_khulasah_al_hasna/providers/azkar_provider.dart';
import 'package:al_khulasah_al_hasna/screens/category_screen.dart';
import 'package:al_khulasah_al_hasna/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auto-Advance in Carousel Mode', () {
    late StorageService storage;
    late AzkarProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = StorageService(prefs);
      provider = AzkarProvider(storage);
      await provider.loadData();
    });

    testWidgets(
        'Card auto-advances to next card 300ms after reaching target count (1/1)',
        (WidgetTester tester) async {
      await provider.toggleViewMode();

      final category = provider.book!.categories.first;
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AzkarProvider>.value(
            value: provider,
            child: CategoryScreen(category: category),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially on card 1
      expect(find.textContaining('الذكر 1 من'), findsOneWidget);

      // Card 1 has repeatCount = 1
      final counterFinder = find.text('0 / 1').first;
      expect(counterFinder, findsOneWidget);

      // Tap to increment (0 -> 1)
      await tester.tap(counterFinder);
      await tester.pump();

      // Counter should show completed 1/1, but still on card 1 immediately
      expect(find.text('تم الإنجاز (1 / 1)'), findsOneWidget);
      expect(find.textContaining('الذكر 1 من'), findsOneWidget);

      // Advance by 150ms: pause has not expired yet
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.textContaining('الذكر 1 من'), findsOneWidget);

      // Advance another 160ms (total > 300ms): timer triggers nextPage animation
      await tester.pump(const Duration(milliseconds: 160));
      await tester.pumpAndSettle();

      // Now auto-advanced to card 2!
      expect(find.textContaining('الذكر 2 من'), findsOneWidget);
    });

    testWidgets(
        'Auto-advance triggers only on the milestone tap for multi-repeat items (3/3)',
        (WidgetTester tester) async {
      final category = provider.book!.categories.first;
      await provider.toggleViewMode();

      final itemIndex = category.items.indexWhere((it) => it.repeatCount == 3);
      expect(itemIndex, isNonNegative);

      final customCategory = AzkarCategory(
        categoryId: 'test_3',
        categoryName: 'تجربة',
        timeWindow: 'وقت التجربة',
        items: [
          category.items[itemIndex],
          category.items[0],
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AzkarProvider>.value(
            value: provider,
            child: CategoryScreen(category: customCategory),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('الذكر 1 من 2'), findsOneWidget);
      expect(find.text('0 / 3'), findsOneWidget);

      // Tap 1: 0 -> 1
      await tester.tap(find.text('0 / 3'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.textContaining('الذكر 1 من 2'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);

      // Tap 2: 1 -> 2
      await tester.tap(find.text('1 / 3'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.textContaining('الذكر 1 من 2'), findsOneWidget);
      expect(find.text('2 / 3'), findsOneWidget);

      // Tap 3: 2 -> 3 (Milestone reached!)
      await tester.tap(find.text('2 / 3'));
      await tester.pump();
      expect(find.text('تم الإنجاز (3 / 3)'), findsOneWidget);
      expect(find.textContaining('الذكر 1 من 2'), findsOneWidget);

      // Wait 300ms pause
      await tester.pump(const Duration(milliseconds: 310));
      await tester.pumpAndSettle();

      // Now auto-advanced to card 2!
      expect(find.textContaining('الذكر 2 من 2'), findsOneWidget);
    });

    testWidgets('Does not attempt to advance past the last card',
        (WidgetTester tester) async {
      await provider.toggleViewMode();
      final lastItem = provider.book!.categories.first.items.first;

      final singleItemCategory = AzkarCategory(
        categoryId: 'test_single',
        categoryName: 'تجربة بطاقة وحيدة',
        timeWindow: 'وقت',
        items: [lastItem],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AzkarProvider>.value(
            value: provider,
            child: CategoryScreen(category: singleItemCategory),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('الذكر 1 من 1'), findsOneWidget);
      final btn = find.text('0 / 1');
      await tester.tap(btn);
      await tester.pump();

      expect(find.text('تم الإنجاز (1 / 1)'), findsOneWidget);

      // Wait past 300ms
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Still on card 1 of 1, no exception
      expect(find.textContaining('الذكر 1 من 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Scholarly note item auto-advances at 100, but subsequent taps beyond 100 do not auto-advance',
        (WidgetTester tester) async {
      await provider.toggleViewMode();
      final exceedItem = provider.book!.categories.first.items.firstWhere(
        (it) => provider.canExceedRepeatCount(it),
      );
      final dummyNextItem = provider.book!.categories.first.items.firstWhere(
        (it) => it.id != exceedItem.id,
      );

      final category = AzkarCategory(
        categoryId: 'test_exceed',
        categoryName: 'تجربة الاستزادة',
        timeWindow: 'وقت',
        items: [exceedItem, dummyNextItem],
      );

      // Pre-set count to 99
      await storage.setCount(exceedItem.id, 99);
      await provider.loadData();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AzkarProvider>.value(
            value: provider,
            child: CategoryScreen(category: category),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('الذكر 1 من 2'), findsOneWidget);
      expect(find.text('99 / 100'), findsOneWidget);

      // Tap 1: reaches 100 (milestone)
      await tester.tap(find.text('99 / 100'));
      await tester.pump();

      expect(find.text('تم الإنجاز (100 / 100)'), findsOneWidget);

      // Wait 300ms
      await tester.pump(const Duration(milliseconds: 310));
      await tester.pumpAndSettle();

      // Should auto-advance to card 2
      expect(find.textContaining('الذكر 2 من 2'), findsOneWidget);

      // Now navigate back to card 1 using the previous button
      final prevBtn = find.byTooltip('الذكر السابق');
      await tester.tap(prevBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('الذكر 1 من 2'), findsOneWidget);
      expect(find.text('تم الإنجاز (100 / 100)'), findsOneWidget);

      // Tap again to exceed to 101
      await tester.tap(find.text('تم الإنجاز (100 / 100)'));
      await tester.pump();

      expect(find.text('تم الإنجاز (101 / 100)'), findsOneWidget);

      // Wait past 300ms
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Should NOT auto-advance! Still on card 1
      expect(find.textContaining('الذكر 1 من 2'), findsOneWidget);
    });

    testWidgets('Manual swipe or reset cancels pending auto-advance cleanly',
        (WidgetTester tester) async {
      await provider.toggleViewMode();
      final category = AzkarCategory(
        categoryId: 'test_cancel',
        categoryName: 'تجربة الإلغاء',
        timeWindow: 'وقت',
        items: [
          provider.book!.categories.first.items[0],
          provider.book!.categories.first.items[1],
          provider.book!.categories.first.items[2],
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AzkarProvider>.value(
            value: provider,
            child: CategoryScreen(category: category),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('الذكر 1 من 3'), findsOneWidget);

      // Tap to complete item 1 (0/1 -> 1/1)
      await tester.tap(find.text('0 / 1'));
      await tester.pump();

      // Within 100ms, user resets the item
      await tester.pump(const Duration(milliseconds: 100));
      final resetBtn = find.byTooltip('إعادة التعيين');
      await tester.tap(resetBtn);
      await tester.pump();

      // Wait past 300ms
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Auto-advance should be cancelled, still on card 1
      expect(find.textContaining('الذكر 1 من 3'), findsOneWidget);
      expect(find.text('0 / 1'), findsOneWidget);
    });
  });
}
