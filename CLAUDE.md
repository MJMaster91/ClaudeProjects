# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

**ElderAid** — a Flutter mobile app for elderly people with mild-to-moderate memory loss. Replaces the phone home screen with a calm, distraction-free interface for calling loved ones, sending messages, and getting help.

- **Platform:** Android (primary) + iOS
- **Language:** Dart
- **Framework:** Flutter
- **MVP scope:** Local-only, no backend, no accounts

The Flutter project lives in the `elder_aid/` subfolder of this repository.

## Running the App

```powershell
cd elder_aid
flutter run          # runs on connected emulator or device
flutter analyze      # static analysis
flutter test         # unit tests
```

Requires the Android emulator to be running in Android Studio before `flutter run`.

## Architecture

```
elder_aid/lib/
├── main.dart                        # Entry point — ProviderScope + MaterialApp
├── theme/
│   └── app_theme.dart               # Warm & Friendly ThemeData
├── models/
│   └── contact.dart                 # Contact data model
├── db/
│   └── database_helper.dart         # sqflite CRUD helpers
├── screens/
│   ├── home_screen.dart             # Feature 1 — Contact grid + clock
│   ├── messages_screen.dart         # Feature 2 — SMS interface
│   └── setup/
│       └── setup_gate.dart          # Feature 4 — PIN-gated admin screens
├── widgets/
│   ├── contact_tile.dart            # Large photo + name + call button tile
│   └── help_button.dart             # Persistent amber "? Help" FAB
└── l10n/
    └── app_en.arb                   # English strings
```

## Key Design Rules (from spec)

- Minimum tap target: **64×64dp** — never go smaller
- Default font size: **20sp** body, **28sp** contact names
- Max **2 taps** to reach any core action from the Home screen
- Back button **always returns to Home** — never exits the app
- App works **fully offline** — no network calls except the AI helper (Phase 2)
- No ads, no unsolicited notifications, no dark patterns

## Theme — Warm & Friendly

| Token | Value |
|---|---|
| Background | `#FDF6EC` |
| Primary (buttons) | `#4A9B8E` |
| Accent (Help button) | `#E8A838` |
| Text primary | `#2C2C2C` |
| Text secondary | `#6B6B6B` |
| Font | Nunito (via `google_fonts`) |
| Corner radius | 16dp |

## State Management

Riverpod (`flutter_riverpod`). All providers live close to the screen that uses them. No global god-state.

## Local Database

sqflite. `DatabaseHelper` in `db/database_helper.dart` is a singleton. Tables:
- `contacts` — id, name, phone, photo_path, sort_order

## Dependencies

See `elder_aid/pubspec.yaml` for the full list. Key packages:
- `flutter_riverpod` — state management
- `sqflite` + `path` — local database
- `url_launcher` — `tel:` links for calling
- `shared_preferences` — PIN storage
- `google_fonts` — Nunito font
- `flutter_localizations` + `intl` — i18n scaffold (English MVP, German Phase 2)

## Git Workflow

```powershell
git add .
git commit -m "short description of what changed"
git push
```

Remote: `https://github.com/MJMaster91/ClaudeProjects`

## Product Spec

Full feature spec is in `ElderAid-Spec.md` at the repo root.
