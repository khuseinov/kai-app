# Исправление сборки iOS на CI

## Цель
Заставить CI-сервер GitHub Actions собрать билд iOS, принудительно отключив требования к подписи Xcode, чтобы получить артефакт (IPA) без настройки Development Team на сервере.

## Архитектура
1. Изменим `.github/workflows/ios_build.yml`.
2. Вместо простого `flutter build` используем `xcodebuild` с флагами `CODE_SIGNING_REQUIRED=NO` и `CODE_SIGNING_ALLOWED=NO`.
3. Соберем `.ipa` файл вручную через `zip`.

---

### Задача 1: Обновление workflow

**Файлы:**
- `.github/workflows/ios_build.yml`

- [ ] **Step 1:** Заменить шаг `Build iOS` и `Package to IPA` на принудительную сборку через `xcodebuild` с отключенной подписью.
- [ ] **Step 2:** Commit & Push.