class ActiveRule {
  final String text;
  final String createdBy;

  const ActiveRule({required this.text, required this.createdBy});

  Map<String, dynamic> toJson() => {
        'text': text,
        'createdBy': createdBy,
      };

  factory ActiveRule.fromJson(Map<String, dynamic> json) {
    return ActiveRule(
      text: json['text'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
    );
  }
}
