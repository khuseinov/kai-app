# KAI Unified Architecture — Design Spec

> **Status:** APPROVED  
> **Date:** 2026-06-17  
> **Author:** AI + Khuseinov (brainstorming session)  
> **Approach:** Big Bang — all changes in one pass

---

## Context

KAI is a Flutter AI travel agent app (wize.travel). Solo developer, long-term product.
The codebase has 8 features, 874 passing tests, 0 analysis issues.

After a market audit of BigTech Flutter practices in 2026 (Nubank, Google Pay, BMW, VGV,
flutter.dev official guide), the following architecture was validated and approved.

## Decision: Feature-First + Clean Architecture

Every feature gets strict `data/domain/presentation` layers, no exceptions.
This was a deliberate choice over "layers by necessity" — the solo developer
prefers consistency and predictability over minimizing boilerplate.

### Target Structure

```
lib/
├── core/
│   ├── error/            → Result<T>, AppException, Failure (NEW)
│   ├── logger/           → AppLogger wrapper (NEW)
│   ├── network/          → dio_client, interceptors/, sse_parser
│   ├── providers/        → root.dart (global providers)
│   ├── routing/          → router.dart
│   └── storage/          → hive_setup.dart
│
├── features/
│   ├── auth/             → session management (NEW, from core/repositories/)
│   │   ├── data/repositories/
│   │   └── domain/repositories/
│   ├── boot/             → splash + bootstrap (RESTRUCTURE)
│   │   └── presentation/pages/
│   ├── dev/              → storybook + theme showcase (KEEP as-is)
│   ├── memory/           → user memory/facts (DONE)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── nav/              → navigation shell (RESTRUCTURE)
│   │   ├── data/models/
│   │   └── presentation/{pages,widgets}/
│   ├── onboarding/       → first-time flow (DONE)
│   │   └── presentation/
│   ├── room/             → chat room (DONE)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── settings/         → app settings (DONE)
│   │   ├── data/
│   │   └── presentation/
│   └── voice/            → voice mode (DONE)
│       └── presentation/
│
├── design_system/        → tokens, primitives, atoms, molecules, theme
├── l10n/                 → localization (EN, RU)
├── app.dart
├── bootstrap.dart
├── main.dart
└── main_storybook.dart
```

### Dependency Flow (strict)

```
presentation → domain → data
presentation → core, design_system
data → core
domain → core (pure Dart only, no Flutter imports)
```

Domain layer NEVER imports Flutter, Riverpod, Dio, or any framework.

---

## Decision: Error Handling — Result<T>

Custom sealed classes. No dartz (Dart 3 sealed classes make it redundant).

### core/error/result.dart

```dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
```

### core/error/failure.dart

```dart
sealed class Failure {
  const Failure([this.message = '']);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Unauthorized']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage error']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown error']);
}
```

### core/error/app_exception.dart

```dart
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized']);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network unavailable']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error']);
}
```

### Usage Pattern

Repositories catch exceptions and return `Result<T>`:

```dart
Future<Result<List<Session>>> getSessions() async {
  try {
    final sessions = await _dataSource.fetchSessions();
    return Success(sessions);
  } on UnauthorizedException {
    return const Err(AuthFailure());
  } catch (e, st) {
    AppLogger.e('getSessions failed', e, st);
    return const Err(UnknownFailure());
  }
}
```

Presentation layer NEVER uses try/catch. Notifiers call usecases, usecases call repos.

---

## Decision: AppLogger

Single wrapper over `package:logger`. No direct Logger() usage in features.

### core/logger/app_logger.dart

```dart
import 'package:logger/logger.dart';

abstract final class AppLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(methodCount: 2, errorMethodCount: 8),
  );

  static void d(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  static void i(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  static void w(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  static void e(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
```

Rules:
- All current `Logger()` calls → replaced with `AppLogger.d/i/w/e`
- No `print()`, `debugPrint()`, or direct `Logger()` in feature code
- VGA lint `avoid_print` enforces this automatically

---

## Decision: Very Good Analysis ^6

Replace `flutter_lints ^4.0.0` with `very_good_analysis ^6.0.0`.

### pubspec.yaml change

```diff
dev_dependencies:
-  flutter_lints: ^4.0.0
+  very_good_analysis: ^6.0.0
```

### analysis_options.yaml change

```diff
-include: package:flutter_lints/flutter.yaml
+include: package:very_good_analysis/analysis_options.yaml

+linter:
+  rules:
+    public_member_api_docs: false
+    lines_longer_than_80_chars: false
```

### Migration strategy

1. Install VGA
2. Run `flutter analyze` — collect warnings
3. `dart fix --apply` — auto-fix ~70% (quotes, imports)
4. Manual fixes for remaining ~30-50 issues

---

## Decision: Feature Migrations

### nav/ → feature-first

```
# FROM:                               # TO:
nav/                                   nav/
├── nav_screen.dart                    ├── data/
├── session_groups.dart                │   └── models/
└── components/                        │       └── nav_models.dart
    ├── kai_nav_item.dart              └── presentation/
    ├── kai_nav_panel.dart                 ├── pages/
    └── nav_models.dart                    │   └── nav_page.dart
                                           └── widgets/
                                               ├── kai_nav_item.dart
                                               ├── kai_nav_panel.dart
                                               └── session_groups.dart
```

### boot/ → presentation layer

```
# FROM:                               # TO:
boot/                                  boot/
├── booting_app.dart                   └── presentation/
├── splash_config.dart                     ├── pages/
└── splash_screen.dart                     │   ├── booting_app.dart
                                           │   └── splash_screen.dart
                                           └── widgets/
                                               └── splash_config.dart
```

### core/repositories/ → features/auth/

```
# FROM:                               # TO:
core/repositories/                     features/auth/
├── session_repository.dart            ├── data/repositories/
├── real_session_repository.dart       │   ├── session_repository_impl.dart
└── mock_session_repository.dart       │   └── mock_session_repository.dart
                                       └── domain/repositories/
                                           └── session_repository.dart
```

`core/repositories/` is deleted entirely.

---

## Cleanup

| Target | Action |
|---|---|
| `lib/core/storage/entities/` | DELETE (empty) |
| `lib/features/room/components/` | DELETE (empty) |
| `test/features/voice/components/` | DELETE (empty) |
| `test/features/edge_states_test.dart` | MOVE into proper feature subfolder |
| `test/features/onboarding_test.dart` | MOVE into proper feature subfolder |
| `test/features/room_test.dart` | MOVE into proper feature subfolder |
| `test/features/tide_states_test.dart` | MOVE into proper feature subfolder |

---

## Explicitly NOT Doing (YAGNI)

| Proposal | Reason |
|---|---|
| Monorepo + Melos | Overkill for 1 dev |
| get_it + injectable | Riverpod = DI already |
| Server-Driven UI | Scale of Nubank (100M+), KAI is a startup |
| BLoC migration | Riverpod already adopted |
| dartz Either | Dart 3 sealed classes are sufficient |
| Signals | Experimental, too early |
| Retrofit | Deferred — add when connecting real backend REST endpoints |

---

## Decision: Retrofit — Deferred

Backend analysis shows:
- Main endpoint `/chat` uses SSE streaming — Retrofit cannot handle SSE
- REST endpoints (sessions, user, schedules) exist but app currently uses mocks
- Retrofit will be added when real backend integration begins
- SSE will always use Dio + SseParser directly

---

## Architecture Rules (10 Commandments)

1. Feature-First, always. Every business feature = `lib/features/<name>/`
2. Strict Clean Architecture layers for all features (data/domain/presentation)
3. Dependencies flow inward: presentation → domain → data
4. Errors via `Result<T>`. No try/catch in presentation.
5. State = Riverpod `@riverpod` codegen. No setState for business logic.
6. One provider = one file.
7. Logging via `AppLogger` only. Never print() or direct Logger().
8. Design System = single source of UI primitives. No ad-hoc styles in features.
9. Tests mirror source structure.
10. No gold plating. YAGNI.

---

## Verification Plan

After all changes:

```bash
dart fix --apply
flutter analyze        # must show 0 issues
flutter test           # must show 874+ tests passing
```

Manual check: app launches, storybook works, routes resolve correctly.
