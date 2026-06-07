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
  String get emptyTitle => 'Куда едем сегодня?';

  @override
  String get emptySubtitle => 'Спросите о месте, визе или маршруте.';

  @override
  String get today => 'Сегодня';

  @override
  String get suggestionTrip => 'Планы на поездку';

  @override
  String get suggestionVisa => 'Вопрос о визе';

  @override
  String get suggestionRecommendations => 'Рекомендации';

  @override
  String get suggestionVisaQuestion => 'Нужна ли виза в Японию?';

  @override
  String get suggestionVisaHint => 'гражданство · сроки';

  @override
  String get suggestionTripQuestion => 'Лучшие маршруты по Японии';

  @override
  String get suggestionTripHint => '10–14 дней · оптимально';

  @override
  String get suggestionRecommendationsQuestion => 'Что посмотреть в Токио';

  @override
  String get suggestionRecommendationsHint => 'must-see · off-beat';

  @override
  String get composePlaceholder => 'Сообщение Kai…';

  @override
  String get offlineTitle => 'Нет сети';

  @override
  String get offlineBody =>
      'Отправлю, когда выйдете в онлайн. Очередь сохранена.';

  @override
  String get retry => 'повторить';

  @override
  String get errorTitle => 'Не удалось ответить';

  @override
  String get errorBody =>
      'Возможно, проблема со связью. Можно повторить или попробовать иначе.';

  @override
  String get errorRetryHint => 'или напишите снова';

  @override
  String get rateLimitTitle => 'Слишком много запросов';

  @override
  String rateLimitSecondsRemaining(int secs) {
    return '$secs сек';
  }

  @override
  String get rateLimitBodyPrefix => 'Сброс в';

  @override
  String get rateLimitUpgradeHint => 'Plan Pro — без лимита.';

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
  String get crisisResourceLabelPhone => 'Доверие · Россия';

  @override
  String get crisisResourceNumberPhone => '8 800 2000 122';

  @override
  String get crisisResourceLabelText => 'Crisis Text Line';

  @override
  String get crisisResourceNumberText => 'Текст HOME на 741741';

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

  @override
  String get newChat => 'Новый чат';

  @override
  String get search => 'Поиск поездок и чатов';

  @override
  String get tripsLabel => 'ПОЕЗДКИ';

  @override
  String get dateToday => 'СЕГОДНЯ';

  @override
  String get dateYesterday => 'ВЧЕРА';

  @override
  String get datePrevious7 => 'ПРЕДЫДУЩИЕ 7 ДНЕЙ';

  @override
  String get appsLabel => 'ПРИЛОЖЕНИЯ';

  @override
  String get memoryAppLabel => 'Память';

  @override
  String get settingsAppLabel => 'Настройки';

  @override
  String get accountAnonymous => 'Anonymous';

  @override
  String get accountFreePlan => 'Free';

  @override
  String get noChats => 'Нет чатов';

  @override
  String get dateOlder => 'РАНЕЕ';

  @override
  String get streamingStatusThinking => 'думаю';

  @override
  String memoryFactsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count фактов о вас',
      few: '$count факта о вас',
      one: '$count факт о вас',
    );
    return '$_temp0';
  }

  @override
  String memoryLastSaved(String time) {
    return 'последнее сохранение $time назад';
  }

  @override
  String get memorySearchPlaceholder => 'Поиск фактов';

  @override
  String get memoryCategoryAbout => 'о вас';

  @override
  String get memoryCategoryPreferences => 'предпочтения';

  @override
  String get memoryCategoryRestrictions => 'ограничения';

  @override
  String get memoryCategoryTrips => 'поездки';

  @override
  String get memoryCategoryFacts => 'факты';

  @override
  String get memorySourceFrom => 'из';

  @override
  String get memorySourceExplicit => 'установлено явно';

  @override
  String get memorySourceLinked => 'связано';

  @override
  String get memoryDangerWipeAll => 'Забыть всё (GDPR-удаление)';

  @override
  String get memoryWipeConfirmation =>
      'Вы уверены, что хотите забыть всё? Это действие необратимо.';

  @override
  String get memoryWipeConfirmAction => 'Забыть';

  @override
  String get memoryWipeCancelAction => 'Отмена';

  @override
  String get memoryEditFactTitle => 'Редактировать факт';

  @override
  String get memoryDeleteFactAction => 'Удалить';

  @override
  String get memoryEditFactAction => 'Редактировать';

  @override
  String get memoryGoToSourceAction => 'Перейти к источнику';
}
