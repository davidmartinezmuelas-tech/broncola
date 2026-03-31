enum GameMode { light, spicy, wild }

extension GameModeX on GameMode {
  String get label {
    switch (this) {
      case GameMode.light:
        return 'Tranquilo';
      case GameMode.spicy:
        return 'Picante';
      case GameMode.wild:
        return 'Extremo';
    }
  }

  String get description {
    switch (this) {
      case GameMode.light:
        return 'Risas, retos suaves y ambientazo relajado.';
      case GameMode.spicy:
        return 'Más tensión social y preguntas comprometidas.';
      case GameMode.wild:
        return 'Sin filtros y con contenido más salvaje.';
    }
  }

  String get emoji {
    switch (this) {
      case GameMode.light:
        return '🍃';
      case GameMode.spicy:
        return '🌶️';
      case GameMode.wild:
        return '🔥';
    }
  }
}
