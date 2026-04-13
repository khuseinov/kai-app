# KAI App — Notes for Claude

## iOS CI Build — DO NOT TOUCH

The iOS unsigned build pipeline is configured and working. Do not change the
signing settings without a specific reason.

### What's configured and why

**`ios/Runner.xcodeproj/project.pbxproj` — Runner target (Release + Profile):**
- `DEVELOPMENT_TEAM = PLACEHOLDER` — Flutter 3.x requires a non-empty value
  even with `--no-codesign`. Any non-empty string works; we use "PLACEHOLDER".
- `CODE_SIGN_STYLE = Manual` — prevents Xcode from contacting Apple servers
  to auto-provision with the placeholder team ID.
- `CODE_SIGNING_REQUIRED = NO` — xcodebuild skips the signing step.
- `CODE_SIGNING_ALLOWED = NO` — belt-and-suspenders: signing is not permitted.
- `CODE_SIGN_IDENTITY = ""` — no specific certificate required.

**`.github/workflows/ios_build.yml`:**
- `dart run build_runner build` is required — `*.g.dart` and `*.freezed.dart`
  are gitignored and must be generated on CI before the Flutter build.
- `CODE_SIGNING_REQUIRED: NO` and `CODE_SIGNING_ALLOWED: NO` env vars mirror
  the project settings as an extra safeguard.

### Build output
Artifact: `kai-app-ios-unsigned` → `app.ipa`
Install via: Sideloadly + USB cable → iPhone

### Repo must stay public
GitHub Actions macOS runners are free only for public repos.
