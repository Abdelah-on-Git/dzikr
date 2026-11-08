import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_khulasah_al_hasna/main.dart';
import 'package:al_khulasah_al_hasna/providers/azkar_provider.dart';
import 'package:al_khulasah_al_hasna/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App renders Home, displays categories and general notes, and navigates',
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
    expect(find.text('مِنْ طُلُوعِ الفَجْرِ الثَّانِي إِلَى طُلُوعِ الشَّمْسِ'), findsOneWidget);
    expect(find.textContaining('اللَّهُمَّ أَنْتَ رَبِّي'), findsOneWidget);

    // Tap first zikr counter (0/1 -> 1/1)
    final firstCounter = find.text('0 / 1').first;
    expect(firstCounter, findsOneWidget);
    await tester.tap(firstCounter);
    await tester.pumpAndSettle();

    // Check that it reached 1/1 and marked as completed
    expect(find.text('تم الإنجاز (1 / 1)'), findsOneWidget);
    expect(find.text('مُكتمل'), findsWidgets);
  });
}
