import 'package:flutter_test/flutter_test.dart';
import 'package:al_khulasah_al_hasna/data/azkar_repository.dart';

void main() {
  test('AzkarRepository loads and parses correctly', () async {
    final book = await AzkarRepository.getBook();
    expect(book.bookTitle, 'الخلاصة الحسناء في أذكار الصباح والمساء');
    expect(book.author, 'صالح بن عبد الله بن حمد العصيمي');
    expect(book.categories.length, 2);

    final morning = book.categories.firstWhere((c) => c.categoryId == 'morning');
    expect(morning.categoryName, 'أذكار الصباح');
    expect(morning.items.length, 13);
    expect(morning.items.first.id, 1);
    expect(morning.items.first.repeatCount, 1);
    expect(morning.items.first.repeatText, 'مَرَّةً وَاحِدَةً');
    expect(morning.items.first.note, contains('أَمَتُكَ'));

    final evening = book.categories.firstWhere((c) => c.categoryId == 'evening');
    expect(evening.categoryName, 'أذكار المساء');
    expect(evening.items.length, 12);
    expect(evening.items.last.id, 25);
    expect(evening.items.last.note, 'فِي المَسَاءِ فَقَطْ');

    expect(book.generalNotes.length, 2);
  });
}
