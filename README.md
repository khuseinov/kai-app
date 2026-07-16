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
HF_TOKEN=hf_...              # Required when the HF Space is private
GOOGLE_SERVER_CLIENT_ID=...  # Google *web* client id — kai-auth sign-in
GOOGLE_IOS_CLIENT_ID=...     # Google iOS client id
```

- `API_BASE_URL` — base URL of the kai-core backend.
- `USE_REAL_CHAT=true` — switches from mock chat to the real Dio-backed repository.
- `HF_TOKEN` — Hugging Face access token. Required when the Space is private so HF ingress forwards requests to the container.
- `GOOGLE_SERVER_CLIENT_ID` — the **web/server** OAuth client id from Google Cloud. Counter-intuitively this is the one that matters on Android too: with `google_sign_in` v7 + Credential Manager it is the `aud` of the issued id_token, so it must appear in kai-auth's `AUTH_GOOGLE_CLIENT_IDS` allowlist or every sign-in is rejected. Blank → no Google sign-in.
- `GOOGLE_IOS_CLIENT_ID` — the iOS OAuth client id; also the source of the reversed-client-id URL scheme in `Info.plist`.

`INTERNAL_HEALTH_TOKEN` is **retired** (APP-AUTH-1, 2026-07-16). It was a single
shared secret that proved "a legitimate app instance", never *which* user — so
any holder could read or delete any user's data by changing a `user_id`. Per-user
identity is now a kai-auth JWT (`Authorization: Bearer`), and `/sessions`,
`/user/*` and `/schedules` require one. The secret still guards kai-core's
`/admin/*` and `/health/*`, which are operator tooling with no per-user concept —
that is a backend-side variable, nothing the app sends.

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
