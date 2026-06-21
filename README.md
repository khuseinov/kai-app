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

## Developer & Design Tools

To keep the production client clean, the Storybook and HTML design spec viewer are run separately:

*   **`run_storybook.bat`**: Launches the standalone Storybook in Chrome at port `8081`.
*   **`run_specs.bat`**: Serves the design mockups/specifications (`new-design/spec-viewer.html`) at port `8743` via Python.

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

Configuration is loaded from the bundled `.env` asset at startup:

```text
API_BASE_URL=https://<username>-<space>.hf.space
USE_REAL_CHAT=true
HF_TOKEN=hf_...          # Required when the HF Space is private
INTERNAL_HEALTH_TOKEN=... # Used by backend admin/health endpoints
```

- `API_BASE_URL` — base URL of the kai-core backend.
- `USE_REAL_CHAT=true` — switches from mock chat to the real Dio-backed repository.
- `HF_TOKEN` — Hugging Face access token. Required when the Space is private so HF ingress forwards requests to the container.
- `INTERNAL_HEALTH_TOKEN` — backend internal token for `/sessions`, `/user`, `/health`, `/admin` endpoints.

If `.env` is missing, the app falls back to `https://api.wize.travel` (non-functional placeholder).

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
