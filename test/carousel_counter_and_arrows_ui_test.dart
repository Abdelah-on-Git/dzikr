import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_khulasah_al_hasna/models/azkar_category.dart';
import 'package:al_khulasah_al_hasna/providers/azkar_provider.dart';
import 'package:al_khulasah_al_hasna/screens/category_screen.dart';
import 'package:al_khulasah_al_hasna/services/storage_service.dart';
import 'package:al_khulasah_al_hasna/widgets/circular_counter_button.dart';
import 'package:al_khulasah_al_hasna/widgets/zikr_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Circular Counter and Arrows UI layout', () {
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
        'In Carousel mode: navigation arrows and circular counter appear directly below the zikr card as a unified group',
        (WidgetTester tester) async {
      await provider.toggleViewMode(); // Switch to carousel mode

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

      // Verify no docked bottom navigation bar exists at the screen edge
      // The PageView should occupy the space and the controls are inside the page
      final nextBtn = find.byTooltip('الذكر التالي');
      final prevBtn = find.byTooltip('الذكر السابق');
      expect(nextBtn, findsOneWidget);
      expect(prevBtn, findsOneWidget);

      final nextCenter = tester.getCenter(nextBtn);
      final prevCenter = tester.getCenter(prevBtn);

      // Verify Circular Counter Button exists
      final circularBtnFinder = find.byType(CircularCounterButton);
      expect(circularBtnFinder, findsOneWidget);
      final counterCenter = tester.getCenter(circularBtnFinder);

      // Verify horizontal arrangement: Left Arrow (<) ... Circular Button ... Right Arrow (>)
      expect(nextCenter.dx, lessThan(counterCenter.dx));
      expect(counterCenter.dx, lessThan(prevCenter.dx));

      // Symmetrically centered
      final screenWidth = tester.getSize(find.byType(CategoryScreen)).width;
      expect(counterCenter.dx, closeTo(screenWidth / 2, 4.0));
      expect((nextCenter.dx + prevCenter.dx) / 2, closeTo(screenWidth / 2, 4.0));

      // Vertically aligned together in the row
      expect(nextCenter.dy, closeTo(counterCenter.dy, 4.0));
      expect(prevCenter.dy, closeTo(counterCenter.dy, 4.0));

      // Verify positioned directly below the Zikr Card with a little vertical margin
      final cardFinder = find.byType(ZikrCard);
      expect(cardFinder, findsOneWidget);
      final cardBottom = tester.getBottomLeft(cardFinder).dy;
      expect(counterCenter.dy, greaterThan(cardBottom));
      // Distance between card bottom and counter center is small (little margin)
      expect(counterCenter.dy - cardBottom, lessThan(60.0));

      // On first card: Prev arrow (>) is disabled, Next arrow (<) is enabled
      final prevIconBtn = tester.widget<IconButton>(
          find.byWidgetPredicate((w) => w is IconButton && w.tooltip == 'الذكر السابق'));
      expect(prevIconBtn.onPressed, isNull);

      final nextIconBtn = tester.widget<IconButton>(
          find.byWidgetPredicate((w) => w is IconButton && w.tooltip == 'الذكر التالي'));
      expect(nextIconBtn.onPressed, isNotNull);

      // Tap circular counter button to increment (0/1 -> 1/1)
      expect(find.text('0 / 1'), findsOneWidget);
      await tester.tap(circularBtnFinder);
      await tester.pump();

      // Shows completed styling and text
      expect(find.text('تم الإنجاز (1 / 1)'), findsOneWidget);
    });

    testWidgets(
        'On the last card in Carousel mode: Next arrow is disabled, Prev arrow is enabled',
        (WidgetTester tester) async {
      await provider.toggleViewMode();

      final firstCategory = provider.book!.categories.first;
      final twoItemCategory = AzkarCategory(
        categoryId: 'test_last',
        categoryName: 'تجربة',
        timeWindow: 'وقت',
        items: [
          firstCategory.items[0],
          firstCategory.items[1],
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AzkarProvider>.value(
            value: provider,
            child: CategoryScreen(category: twoItemCategory),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Card 1
      expect(find.textContaining('الذكر 1 من 2'), findsOneWidget);

      // Tap next arrow
      final nextBtn = find.byTooltip('الذكر التالي');
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      // Now on Card 2 (the last card)
      expect(find.textContaining('الذكر 2 من 2'), findsOneWidget);

      // Next arrow should now be disabled
      final nextIconBtn = tester.widget<IconButton>(
          find.byWidgetPredicate((w) => w is IconButton && w.tooltip == 'الذكر التالي'));
      expect(nextIconBtn.onPressed, isNull);

      // Prev arrow should now be enabled
      final prevBtn = find.byTooltip('الذكر السابق');
      final prevIconBtn = tester.widget<IconButton>(
          find.byWidgetPredicate((w) => w is IconButton && w.tooltip == 'الذكر السابق'));
      expect(prevIconBtn.onPressed, isNotNull);

      // Tap prev arrow to return to Card 1
      await tester.tap(prevBtn);
      await tester.pumpAndSettle();
      expect(find.textContaining('الذكر 1 من 2'), findsOneWidget);
    });

    testWidgets(
        'In List mode: each card displays its own circular counter centered at the bottom of the card',
        (WidgetTester tester) async {
      // By default isSwipeMode is false (List mode)
      expect(provider.isSwipeMode, isFalse);

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

      // There are no navigation arrows in list mode
      expect(find.byTooltip('الذكر التالي'), findsNothing);
      expect(find.byTooltip('الذكر السابق'), findsNothing);

      // Circular counter buttons exist for cards in view
      final circularButtons = find.byType(CircularCounterButton);
      expect(circularButtons, findsWidgets);

      // Tap the first circular button
      final firstBtn = circularButtons.first;
      expect(find.text('0 / 1'), findsWidgets);
      await tester.tap(firstBtn);
      await tester.pumpAndSettle();

      // First item is completed
      expect(find.text('تم الإنجاز (1 / 1)'), findsOneWidget);
    });
  });
}
