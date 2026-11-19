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

    testWidgets(
        'Tapping to exceed (101) within the 300ms pause cancels auto-advance and stays on card',
        (WidgetTester tester) async {
      await provider.toggleViewMode();
      final exceedItem = provider.book!.categories.first.items.firstWhere(
        (it) => provider.canExceedRepeatCount(it),
      );
      final dummyNextItem = provider.book!.categories.first.items.firstWhere(
        (it) => it.id != exceedItem.id,
      );

      final category = AzkarCategory(
        categoryId: 'test_exceed_pause',
        categoryName: 'تجربة الاستزادة أثناء الانتظار',
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

      // Before the 300ms pause expires (at 100ms), user taps again to exceed to 101
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('تم الإنجاز (100 / 100)'));
      await tester.pump();
      expect(find.text('تم الإنجاز (101 / 100)'), findsOneWidget);

      // Wait past 300ms (e.g. 400ms)
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Card must NOT auto-advance; it stays on Card 1!
      expect(find.textContaining('الذكر 1 من 2'), findsOneWidget);
      expect(find.text('تم الإنجاز (101 / 100)'), findsOneWidget);
    });

    testWidgets(
        'Manual touch drag during 300ms pause cancels auto-advance',
        (WidgetTester tester) async {
      await provider.toggleViewMode();
      final category = AzkarCategory(
        categoryId: 'test_drag_cancel',
        categoryName: 'تجربة السحب اليدوي',
        timeWindow: 'وقت',
        items: [
          provider.book!.categories.first.items[0],
          provider.book!.categories.first.items[1],
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

      expect(find.textContaining('الذكر 1 من 2'), findsOneWidget);

      // Tap to complete item 1 (0/1 -> 1/1)
      await tester.tap(find.text('0 / 1'));
      await tester.pump();
      expect(find.text('تم الإنجاز (1 / 1)'), findsOneWidget);

      // At 100ms, user starts dragging the card slightly (drag gesture)
      await tester.pump(const Duration(milliseconds: 100));
      final gesture = await tester.startGesture(const Offset(200, 300));
      await gesture.moveBy(const Offset(20, 0)); // small touch drag
      await tester.pump();

      // Wait past the original 300ms pause while still touching
      await tester.pump(const Duration(milliseconds: 300));
      // Release gesture back without switching page
      await gesture.moveBy(const Offset(-20, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      // Auto-advance was cancelled by manual drag; stays on Card 1
      expect(find.textContaining('الذكر 1 من 2'), findsOneWidget);
    });

    testWidgets(
        'Toggling view mode during 300ms pause cancels auto-advance cleanly',
        (WidgetTester tester) async {
      await provider.toggleViewMode();
      final category = AzkarCategory(
        categoryId: 'test_toggle_view',
        categoryName: 'تجربة تبديل العرض',
        timeWindow: 'وقت',
        items: [
          provider.book!.categories.first.items[0],
          provider.book!.categories.first.items[1],
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

      expect(find.textContaining('الذكر 1 من 2'), findsOneWidget);

      // Tap to complete item 1
      await tester.tap(find.text('0 / 1'));
      await tester.pump();

      // At 100ms, user toggles view mode
      await tester.pump(const Duration(milliseconds: 100));
      final toggleBtn = find.byTooltip('عرض كقائمة');
      await tester.tap(toggleBtn);
      await tester.pumpAndSettle();

      // In list mode now
      expect(provider.isSwipeMode, isFalse);

      // Wait past 300ms
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Switch back to swipe mode
      final switchBackBtn = find.byTooltip('عرض كبطاقات متتابعة');
      await tester.tap(switchBackBtn);
      await tester.pumpAndSettle();

      // Should still be on Card 1 (not auto-advanced to 2)
      expect(find.textContaining('الذكر 1 من 2'), findsOneWidget);
    });

    testWidgets(
        'Tapping next or previous navigation arrow cancels pending auto-advance timer',
        (WidgetTester tester) async {
      await provider.toggleViewMode();
      final category = AzkarCategory(
        categoryId: 'test_arrow_cancel',
        categoryName: 'تجربة أسهم التنقل',
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
      expect(find.text('تم الإنجاز (1 / 1)'), findsOneWidget);

      // At 100ms (during the 300ms pause), user taps the next arrow button manually
      await tester.pump(const Duration(milliseconds: 100));
      final nextBtn = find.byTooltip('الذكر التالي');
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      // Card advanced to card 2 immediately via arrow
      expect(find.textContaining('الذكر 2 من 3'), findsOneWidget);

      // Wait past the original auto-advance timer to ensure it was cancelled (no double jump to card 3)
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Must cleanly remain on Card 2
      expect(find.textContaining('الذكر 2 من 3'), findsOneWidget);

      // Tap previous arrow to navigate back to card 1
      final prevBtn = find.byTooltip('الذكر السابق');
      await tester.tap(prevBtn);
      await tester.pumpAndSettle();
      expect(find.textContaining('الذكر 1 من 3'), findsOneWidget);
    });

    testWidgets(
        'Catch-up button appears when earlier item was skipped and tapping navigates back',
        (WidgetTester tester) async {
      await provider.toggleViewMode();
      final category = AzkarCategory(
        categoryId: 'test_catchup_btn',
        categoryName: 'تجربة الاستدراك',
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

      // On card 1, no catch-up button
      expect(find.textContaining('العودة للأذكار غير المكتملة'), findsNothing);

      // Skip card 1 by tapping next arrow to go to card 2
      final nextBtn = find.byTooltip('الذكر التالي');
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      // Now on card 2 (index 1), earlier card 0 is incomplete!
      expect(find.textContaining('الذكر 2 من 3'), findsOneWidget);
      expect(
          find.textContaining('«العودة للأذكار غير المكتملة (متبقٍ 3) ↩»'),
          findsOneWidget);

      // Tap next button again to move to card 3 (index 2, last card)
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('الذكر 3 من 3'), findsOneWidget);
      expect(
          find.textContaining('«العودة للأذكار غير المكتملة (متبقٍ 3) ↩»'),
          findsOneWidget);

      // Tap catch-up button: should navigate back to first incomplete item (card 1 / index 0)
      final catchUpBtn = find.textContaining('العودة للأذكار غير المكتملة');
      await tester.ensureVisible(catchUpBtn);
      await tester.tap(catchUpBtn);
      await tester.pumpAndSettle();

      // Should be back on card 1!
      expect(find.textContaining('الذكر 1 من 3'), findsOneWidget);
    });

    testWidgets(
        'Completing the last card when earlier items were skipped loops back to first incomplete item',
        (WidgetTester tester) async {
      await provider.toggleViewMode();
      final category = AzkarCategory(
        categoryId: 'test_loopback',
        categoryName: 'تجربة الالتفاف للأذكار المتبقية',
        timeWindow: 'وقت',
        items: [
          provider.book!.categories.first.items[0],
          provider.book!.categories.first.items[1],
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

      // On card 1: skip it by tapping next
      final nextBtn = find.byTooltip('الذكر التالي');
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('الذكر 2 من 2'), findsOneWidget);

      // Complete card 2 (the last card)
      final counterFinder = find.text('0 / 1');
      await tester.tap(counterFinder);
      await tester.pump();

      // Still on card 2 immediately
      expect(find.textContaining('الذكر 2 من 2'), findsOneWidget);

      // Wait 300ms for auto-advance timer
      await tester.pump(const Duration(milliseconds: 320));
      await tester.pumpAndSettle();

      // Should have looped back to card 1 (the first incomplete item)!
      expect(find.textContaining('الذكر 1 من 2'), findsOneWidget);
    });
  });
}
