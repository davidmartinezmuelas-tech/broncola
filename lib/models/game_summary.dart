class GameSummary {
  final String topDrinkerName;
  final int turnCount;
  final String modeLabel;
  final int totalDrinks;
  final DateTime finishedAt;

  const GameSummary({
    required this.topDrinkerName,
    required this.turnCount,
    required this.modeLabel,
    required this.totalDrinks,
    required this.finishedAt,
  });

  Map<String, dynamic> toJson() => {
        'topDrinkerName': topDrinkerName,
        'turnCount': turnCount,
        'modeLabel': modeLabel,
        'totalDrinks': totalDrinks,
        'finishedAt': finishedAt.toIso8601String(),
      };

  factory GameSummary.fromJson(Map<String, dynamic> json) {
    return GameSummary(
      topDrinkerName: json['topDrinkerName'] as String? ?? json['winnerName'] as String? ?? '',
      turnCount: json['turnCount'] as int? ?? 0,
      modeLabel: json['modeLabel'] as String? ?? '',
      totalDrinks: json['totalDrinks'] as int? ?? 0,
      finishedAt: DateTime.tryParse(json['finishedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
