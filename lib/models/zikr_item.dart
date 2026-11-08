class ZikrItem {
  final int id;
  final String text;
  final int repeatCount;
  final String repeatText;
  final String? note;

  const ZikrItem({
    required this.id,
    required this.text,
    required this.repeatCount,
    required this.repeatText,
    this.note,
  });

  factory ZikrItem.fromJson(Map<String, dynamic> json) {
    return ZikrItem(
      id: json['id'] as int,
      text: json['text'] as String,
      repeatCount: json['repeat_count'] as int,
      repeatText: json['repeat_text'] as String,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'repeat_count': repeatCount,
      'repeat_text': repeatText,
      if (note != null) 'note': note,
    };
  }
}
