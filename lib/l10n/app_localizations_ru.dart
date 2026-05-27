// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Kai';

  @override
  String get startConversation => 'Начните разговор с Kai';

  @override
  String get today => 'Сегодня';

  @override
  String get suggestionTrip => 'Планы на поездку';

  @override
  String get suggestionVisa => 'Вопрос о визе';

  @override
  String get suggestionRecommendations => 'Рекомендации';

  @override
  String get composePlaceholder => 'Сообщение Kai…';

  @override
  String get offlineTitle => 'Нет сети';

  @override
  String get retry => 'Повторить';

  @override
  String get errorTitle => 'Ошибка — попробуйте ещё раз';

  @override
  String get rateLimitTitle => 'Слишком много запросов';

  @override
  String rateLimitSecondsRemaining(int secs) {
    return '$secs сек';
  }

  @override
  String get viewPlans => 'Посмотреть планы';

  @override
  String get crisisHeading => 'Я слышу тебя.';

  @override
  String get crisisBody =>
      'Если тебе сейчас тяжело, ты не один. Kai всегда рядом, и помощь доступна прямо сейчас.';

  @override
  String get crisisResourceLabel => 'Телефон доверия';

  @override
  String get crisisResourceNumber => '8-800-2000-122';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboardingStep0Title => 'Знакомьтесь: Kai';

  @override
  String get onboardingStep0Body =>
      'Ваш AI-помощник в путешествиях — всегда готов помочь с планированием, ответить на вопросы и направить.';

  @override
  String get onboardingStep1Title => 'Ваш прилив';

  @override
  String get onboardingStep1Body =>
      'Волнистая кривая наверху показывает состояние Kai — в покое, в раздумьях или отвечает.';

  @override
  String get onboardingStep2Title => 'Жесты';

  @override
  String get onboardingStep2Body =>
      'Проведите пальцем от левого края, чтобы открыть историю поездок.';

  @override
  String get onboardingStep3Title => 'Начнём';

  @override
  String get onboardingStep3Body =>
      'Спросите Kai что угодно — от виз до must-see мест.';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать в Kai';

  @override
  String get onboardingWelcomeBody =>
      'Kai — ваш персональный ИИ-помощник. Он всегда рядом, чтобы помочь с планами, вопросами и идеями.';

  @override
  String get onboardingTideTitle => 'Kai всегда здесь';

  @override
  String get onboardingTideChipThinking => 'Думает';

  @override
  String get onboardingTideChipResponding => 'Отвечает';

  @override
  String get onboardingTideChipListening => 'Слушает';

  @override
  String get onboardingGesturesTitle => 'Жесты';

  @override
  String get onboardingGestureNavLabel => 'Открыть навигацию';

  @override
  String get onboardingGestureNavHint => 'Свайп вправо';

  @override
  String get onboardingGestureInputLabel => 'Открыть ввод';

  @override
  String get onboardingGestureInputHint => 'Свайп вверх';

  @override
  String get onboardingGestureActionsLabel => 'Быстрые действия';

  @override
  String get onboardingGestureActionsHint => 'Долгое нажатие';

  @override
  String get onboardingContextTitle => 'Настройки';

  @override
  String get onboardingContextCountryPlaceholder => '🌍 Страна';
}
