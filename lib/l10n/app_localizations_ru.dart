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
  String get onboardingNext => 'Продолжить';

  @override
  String get onboardingStart => 'Начать использовать Kai';

  @override
  String get onboardingStep1CTA => 'Понятно';

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
  String get onboardingWelcomeTitle => 'Познакомьтесь с Kai.';

  @override
  String get onboardingWelcomeBody =>
      'Ваш компаньон путешественника.\nЗнающий. Честный. Тихий, когда не нужен.';

  @override
  String get onboardingTideTitle => 'Линия вверху — это Kai.';

  @override
  String get onboardingTideBody =>
      'Тихая в ожидании. Живая когда Kai что-то делает — слушает, думает, отвечает, обучается.';

  @override
  String get onboardingTideStateIdleName => 'idle';

  @override
  String get onboardingTideStateIdleDesc => 'ничего не происходит';

  @override
  String get onboardingTideStateThinkingName => 'thinking';

  @override
  String get onboardingTideStateThinkingDesc => 'обрабатывает';

  @override
  String get onboardingTideStateRespondingName => 'responding';

  @override
  String get onboardingTideStateRespondingDesc => 'токены стримятся';

  @override
  String get onboardingGesturesTitle => 'Три жеста.';

  @override
  String get onboardingGesturesBody =>
      'Всё остальное скрыто, пока не понадобится.';

  @override
  String get onboardingGestureNavLabel => 'Свайп вправо · от края';

  @override
  String get onboardingGestureNavHint =>
      'открывает панель — поездки, чаты, настройки';

  @override
  String get onboardingGestureInputLabel => 'Свайп вверх · снизу';

  @override
  String get onboardingGestureInputHint => 'открывает лист ввода';

  @override
  String get onboardingGestureActionsLabel => 'Долгое нажатие · на ответ Kai';

  @override
  String get onboardingGestureActionsHint =>
      'источники, копировать, переспросить';

  @override
  String get onboardingContextTitle => 'Два факта.\nЗатем начнём.';

  @override
  String get onboardingContextBody =>
      'Используется в каждом ответе о визе, маршруте и цене. Можно редактировать позже.';

  @override
  String get onboardingContextPassportLabel => 'паспорт';

  @override
  String get onboardingContextLangsLabel => 'владею языками';

  @override
  String get onboardingContextCountryPlaceholder => 'Российская Федерация';
}
