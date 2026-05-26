# Broncola

Flutter party game for groups. Players set up a roster, pick a content pack, and take turns drawing cards with questions, challenges, and social prompts.

---

## Features

- **3 content packs** — 49 cards each, drawn dynamically so no two games feel the same
- **Player roster** — set up players before the game with names and photo avatars
- **Photo avatars** — pick from camera or gallery using `image_picker`
- **Persistent roster** — player profiles survive app restarts via `SharedPreferences`
- **Cross-platform** — Android, iOS, Web, Windows, macOS, Linux from one codebase

---

## Tech Stack

| Area | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Local storage | `shared_preferences` |
| Photo input | `image_picker` |
| Code quality | `flutter_lints` |

---

## Getting Started

```bash
git clone https://github.com/davidmartinezmuelas-tech/broncola.git
cd broncola
flutter pub get
flutter run
```

Build a release APK for Android:

```bash
flutter build apk --release
```

**Requirements:** Flutter SDK ≥ 3.0.0

---

## Project Structure

```
lib/
├── main.dart
├── models/       # Player, Card, Pack data classes
├── screens/      # Setup, Game, Results screens
└── widgets/      # Reusable UI components

assets/
└── images/       # Logo and branding assets
```

---

## Privacy

All player data is stored locally on the device. Photos are never uploaded to any server. See [privacy-policy.md](privacy-policy.md) for full details.
