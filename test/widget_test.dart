import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_khulasah_al_hasna/main.dart';
import 'package:al_khulasah_al_hasna/providers/azkar_provider.dart';
import 'package:al_khulasah_al_hasna/services/storage_service.dart';
import 'package:al_khulasah_al_hasna/theme/app_colors.dart';
import 'package:al_khulasah_al_hasna/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'App renders Home, displays categories and general notes, navigates, counts, and toggles swipe view',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);
    final provider = AzkarProvider(storage);
    await provider.loadData();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: provider),
        ],
        child: const AlKhulasahApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title and Author
    expect(find.text('الخلاصة الحسناء'), findsWidgets);
    expect(find.textContaining('العصيمي'), findsOneWidget);

    // Verify Categories
    expect(find.text('أذكار الصباح'), findsOneWidget);
    expect(find.text('أذكار المساء'), findsOneWidget);

    // Verify General notes card
    expect(find.text('تنبيهات عامة من المصنف'), findsOneWidget);

    // Tap on General Notes to open sheet
    await tester.tap(find.text('تنبيهات عامة من المصنف'));
    await tester.pumpAndSettle();
    expect(find.text('تنبيهات عامة للمصنف'), findsOneWidget);
    expect(find.textContaining('لَا يَلْزَمُ تَرْتِيبُهَا'), findsOneWidget);

    // Dismiss sheet
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // Navigate to Morning Azkar
    await tester.tap(find.text('أذكار الصباح'));
    await tester.pumpAndSettle();

    // Verify category screen opened
    expect(find.text('مِنْ طُلُوعِ الفَجْرِ الثَّانِي إِلَى طُلُوعِ الشَّمْسِ'),
        findsOneWidget);
    expect(find.textContaining('اللَّهُمَّ أَنْتَ رَبِّي'), findsOneWidget);

    // Tap first zikr counter button (0/1 -> 1/1)
    final firstCounter = find.text('0 / 1').first;
    expect(firstCounter, findsOneWidget);
    await tester.tap(firstCounter);
    await tester.pumpAndSettle();

    // Check that it reached 1/1 and marked as completed
    expect(find.text('تم الإنجاز (1 / 1)'), findsOneWidget);
    expect(find.text('مُكتمل'), findsWidgets);

    // Test Decrement button in header
    final decrementBtn = find.byTooltip('إنقاص').first;
    expect(decrementBtn, findsOneWidget);
    await tester.tap(decrementBtn);
    await tester.pumpAndSettle();

    // Now it should be 0 / 1 again
    expect(find.text('0 / 1'), findsWidgets);

    // Test Large Tap Area: tapping the text area directly increments
    final zikrTextArea = find.textContaining('اللَّهُمَّ أَنْتَ رَبِّي');
    await tester.tap(zikrTextArea);
    await tester.pumpAndSettle();

    // Back to 1 / 1
    expect(find.text('تم الإنجاز (1 / 1)'), findsOneWidget);

    // Toggle view mode to Card-Swipe mode
    final toggleModeBtn = find.byTooltip('عرض كبطاقات متتابعة');
    expect(toggleModeBtn, findsOneWidget);
    await tester.tap(toggleModeBtn);
    await tester.pumpAndSettle();

    // In swipe mode, verify PageView stepper is visible
    expect(find.textContaining('الذكر 1 من'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);

    // Toggle back to list mode
    final toggleBackBtn = find.byTooltip('عرض كقائمة');
    expect(toggleBackBtn, findsOneWidget);
    await tester.tap(toggleBackBtn);
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets(
      '60-30-10 theme tokens and metallic gold accents are properly configured',
      (WidgetTester tester) async {
    // 60% Dominant (pitch black / surface)
    expect(AppColors.pitchBlack, const Color(0xFF000000));
    expect(AppColors.cardSurface, const Color(0xFF1C1C1E));

    // 30% Secondary (emerald green)
    expect(AppColors.pitchGreen, const Color(0xFF30D158));

    // 10% Accent (metallic Islamic gold #D4AF37)
    expect(AppColors.metallicGold, const Color(0xFFD4AF37));
    expect(AppColors.accentGold, const Color(0xFFD4AF37));
    expect(AppColors.badgeGoldBg, const Color(0x1FD4AF37));
    expect(AppColors.badgeGoldBorder, const Color(0x40D4AF37));

    // ColorScheme tokens in darkTheme
    expect(AppTheme.darkTheme.colorScheme.primary, AppColors.pitchGreen);
    expect(AppTheme.darkTheme.colorScheme.tertiary, AppColors.metallicGold);
    expect(
        AppTheme.darkTheme.colorScheme.tertiaryContainer, AppColors.badgeGoldBg);
    expect(AppTheme.darkTheme.scaffoldBackgroundColor, AppColors.pitchBlack);
  });

  testWidgets(
      'HomeScreen displays categories in 2-column grid and CategoryScreen has proper carousel arrows',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService(await SharedPreferences.getInstance());
    final provider = AzkarProvider(storage);
    await provider.loadData();

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: provider)],
        child: const AlKhulasahApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify AppBar action button for general notes exists
    expect(find.byTooltip('تنبيهات عامة'), findsOneWidget);

    // Verify categories are placed in a 2-column grid (same vertical Y coordinate)
    final morningCenter = tester.getCenter(find.text('أذكار الصباح'));
    final eveningCenter = tester.getCenter(find.text('أذكار المساء'));
    // Since they are arranged horizontally in a 2-column grid, their Y coordinates match closely
    expect((morningCenter.dy - eveningCenter.dy).abs(), lessThan(5.0));
    // And their X coordinates are distinct (side-by-side)
    expect(morningCenter.dx, isNot(equals(eveningCenter.dx)));

    // Open category screen and switch to swipe mode
    await tester.tap(find.text('أذكار الصباح'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('عرض كبطاقات متتابعة'));
    await tester.pumpAndSettle();

    final nextBtn = find.byTooltip('الذكر التالي');
    final prevBtn = find.byTooltip('الذكر السابق');
    expect(nextBtn, findsOneWidget);
    expect(prevBtn, findsOneWidget);

    // Verify arrow icons
    final nextIcon = tester.widget<Icon>(find.descendant(of: nextBtn, matching: find.byType(Icon)));
    final prevIcon = tester.widget<Icon>(find.descendant(of: prevBtn, matching: find.byType(Icon)));
    expect(nextIcon.icon, Icons.arrow_back_ios_rounded);
    expect(prevIcon.icon, Icons.arrow_forward_ios_rounded);

    // Verify left/right positions: next is on the left (dx < prev dx) and points left
    final nextCenter = tester.getCenter(nextBtn);
    final prevCenter = tester.getCenter(prevBtn);
    expect(nextCenter.dx, lessThan(prevCenter.dx));

    // Tap next arrow and verify it advances to zikr 2
    expect(find.textContaining('الذكر 1 من'), findsOneWidget);
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();
    expect(find.textContaining('الذكر 2 من'), findsOneWidget);

    // Tap prev arrow and verify it returns to zikr 1
    await tester.tap(prevBtn);
    await tester.pumpAndSettle();
    expect(find.textContaining('الذكر 1 من'), findsOneWidget);
  });
}
