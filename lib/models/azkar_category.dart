import 'zikr_item.dart';

class AzkarCategory {
  final String categoryId;
  final String categoryName;
  final String timeWindow;
  final List<ZikrItem> items;

  const AzkarCategory({
    required this.categoryId,
    required this.categoryName,
    required this.timeWindow,
    required this.items,
  });

  factory AzkarCategory.fromJson(Map<String, dynamic> json) {
    return AzkarCategory(
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String,
      timeWindow: json['time_window'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => ZikrItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'time_window': timeWindow,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  int get totalRepetitions =>
      items.fold(0, (sum, item) => sum + item.repeatCount);
}
