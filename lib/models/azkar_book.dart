import 'azkar_category.dart';

class AzkarBook {
  final String bookTitle;
  final String author;
  final List<AzkarCategory> categories;
  final List<String> generalNotes;

  const AzkarBook({
    required this.bookTitle,
    required this.author,
    required this.categories,
    required this.generalNotes,
  });

  factory AzkarBook.fromJson(Map<String, dynamic> json) {
    return AzkarBook(
      bookTitle: json['book_title'] as String,
      author: json['author'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((cat) => AzkarCategory.fromJson(cat as Map<String, dynamic>))
          .toList(),
      generalNotes: (json['general_notes'] as List<dynamic>)
          .map((note) => note.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_title': bookTitle,
      'author': author,
      'categories': categories.map((c) => c.toJson()).toList(),
      'general_notes': generalNotes,
    };
  }
}
