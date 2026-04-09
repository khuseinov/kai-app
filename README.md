# KAI App — Flutter Mobile Client

KAI travel companion app for iOS and Android.

## Setup

```bash
# Install Flutter SDK (if not installed)
# https://docs.flutter.dev/get-started/install

# Get dependencies
flutter pub get

# Run code generation (freezed, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Run on emulator/device
flutter run

# Run tests
flutter test
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── app.dart               # MaterialApp + router
├── core/
│   ├── api/               # API client (dio)
│   ├── storage/           # Local storage (Hive)
│   ├── models/            # Data models (freezed)
│   ├── providers/         # Riverpod providers
│   └── theme/             # App theme
├── features/
│   ├── chat/              # Chat UI + logic
│   ├── onboarding/        # First-run experience
│   ├── settings/          # App settings
│   ├── companion/         # Eco-companion (Gate 4)
│   ├── voice/             # Voice I/O (Gate 3)
│   ├── subscriptions/     # Travel alerts (Gate 4)
│   └── files/             # PDF viewer (Gate 4)
└── l10n/                  # RU + EN localizations
```

## Backend Connection

Default: `http://10.0.2.2:8000` (Android emulator → host machine).

Change in Settings screen or set `api_base_url` in Hive box `settings`.

## CI/CD

- **iOS:** Codemagic (codemagic.yaml) — 500 free M2 min/month
- **Android:** Codemagic or GitHub Actions

## Gates (Backend Dependencies)

| Gate | Flutter Features | Backend Sprint |
|------|-----------------|----------------|
| F-0 | Chat, Settings, Onboarding | S1-S10 ✅ (ready now) |
| F-1 | SSE Streaming, Async Tasks | CC-0 |
| F-2 | Scheduler, Verification | CC-1 |
| F-3 | WebSocket, Voice, Push | CC-2 |
| F-4 | Companion, Subscriptions, PDF | CC-3 |
