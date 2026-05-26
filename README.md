# Broncola

Flutter party game with dynamic card packs, player setup, photo avatars, and persistent local state.

## Overview

Broncola is a group party game built with Flutter. Players create a roster, choose a content pack, and take turns drawing cards with questions, challenges, and social prompts.

The project focuses on a simple but complete mobile game loop: setup, player state, random card draws, pack-based content, avatar selection, and persistence between sessions.

## Features

- Dynamic card draw system with reusable question packs
- Three included content packs with 49 cards each
- Player roster setup before each game
- Photo avatars from camera or gallery
- Local persistence with SharedPreferences
- Cross-platform Flutter codebase for Android, iOS, Web, Windows, macOS, and Linux

## Tech Stack

| Area | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Local storage | SharedPreferences |
| Media input | image_picker |
| Quality | flutter_lints |

## Getting Started

```bash
flutter pub get
flutter run
```

Build an Android APK:

```bash
flutter build apk --release
```

## Project Structure

```text
lib/
  main.dart
  models/
  screens/
  widgets/

assets/
  images/
```

## Privacy

Broncola stores player data locally on the device. Player photos are not uploaded to any server.
