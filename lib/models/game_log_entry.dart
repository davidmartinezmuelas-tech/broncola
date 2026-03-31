class GameLogEntry {
  final String title;
  final String detail;
  final DateTime createdAt;

  const GameLogEntry({
    required this.title,
    required this.detail,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'detail': detail,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GameLogEntry.fromJson(Map<String, dynamic> json) {
    return GameLogEntry(
      title: json['title'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
