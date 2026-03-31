class GameSummary {
  final String winnerName;
  final int turnCount;
  final int boardLength;
  final String modeLabel;
  final int totalDrinks;
  final DateTime finishedAt;

  const GameSummary({
    required this.winnerName,
    required this.turnCount,
    required this.boardLength,
    required this.modeLabel,
    required this.totalDrinks,
    required this.finishedAt,
  });

  Map<String, dynamic> toJson() => {
        'winnerName': winnerName,
        'turnCount': turnCount,
        'boardLength': boardLength,
        'modeLabel': modeLabel,
        'totalDrinks': totalDrinks,
        'finishedAt': finishedAt.toIso8601String(),
      };

  factory GameSummary.fromJson(Map<String, dynamic> json) {
    return GameSummary(
      winnerName: json['winnerName'] as String? ?? '',
      turnCount: json['turnCount'] as int? ?? 0,
      boardLength: json['boardLength'] as int? ?? 50,
      modeLabel: json['modeLabel'] as String? ?? '',
      totalDrinks: json['totalDrinks'] as int? ?? 0,
      finishedAt: DateTime.tryParse(json['finishedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
