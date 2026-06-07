import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Kai'**
  String get appTitle;

  /// Empty state prompt
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with Kai'**
  String get startConversation;

  /// Empty state invitation title
  ///
  /// In en, this message translates to:
  /// **'Where to today?'**
  String get emptyTitle;

  /// Empty state invitation subtitle
  ///
  /// In en, this message translates to:
  /// **'Ask about a destination, visa, or itinerary.'**
  String get emptySubtitle;

  /// Date separator in chat
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @suggestionTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip plans'**
  String get suggestionTrip;

  /// No description provided for @suggestionVisa.
  ///
  /// In en, this message translates to:
  /// **'Visa question'**
  String get suggestionVisa;

  /// No description provided for @suggestionRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get suggestionRecommendations;

  /// No description provided for @suggestionVisaQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do I need a visa for Japan?'**
  String get suggestionVisaQuestion;

  /// No description provided for @suggestionVisaHint.
  ///
  /// In en, this message translates to:
  /// **'citizenship · timelines'**
  String get suggestionVisaHint;

  /// No description provided for @suggestionTripQuestion.
  ///
  /// In en, this message translates to:
  /// **'Best routes through Japan'**
  String get suggestionTripQuestion;

  /// No description provided for @suggestionTripHint.
  ///
  /// In en, this message translates to:
  /// **'10–14 days · optimised'**
  String get suggestionTripHint;

  /// No description provided for @suggestionRecommendationsQuestion.
  ///
  /// In en, this message translates to:
  /// **'What to see in Tokyo'**
  String get suggestionRecommendationsQuestion;

  /// No description provided for @suggestionRecommendationsHint.
  ///
  /// In en, this message translates to:
  /// **'must-see · off-beat'**
  String get suggestionRecommendationsHint;

  /// No description provided for @composePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Message Kai…'**
  String get composePlaceholder;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get offlineTitle;

  /// Offline surface body copy
  ///
  /// In en, this message translates to:
  /// **'Will send when you\'re back online. Queue saved.'**
  String get offlineBody;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'retry'**
  String get retry;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t respond'**
  String get errorTitle;

  /// No description provided for @errorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again or rephrase.'**
  String get errorBody;

  /// No description provided for @errorRetryHint.
  ///
  /// In en, this message translates to:
  /// **'or type a new message'**
  String get errorRetryHint;

  /// No description provided for @rateLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Too many requests'**
  String get rateLimitTitle;

  /// Rate limit countdown
  ///
  /// In en, this message translates to:
  /// **'{secs} sec'**
  String rateLimitSecondsRemaining(int secs);

  /// Rate limit body prefix before countdown time
  ///
  /// In en, this message translates to:
  /// **'Resets at'**
  String get rateLimitBodyPrefix;

  /// Rate limit upgrade hint
  ///
  /// In en, this message translates to:
  /// **'Plan Pro removes limits.'**
  String get rateLimitUpgradeHint;

  /// No description provided for @viewPlans.
  ///
  /// In en, this message translates to:
  /// **'View plans'**
  String get viewPlans;

  /// No description provided for @crisisHeading.
  ///
  /// In en, this message translates to:
  /// **'I hear you.'**
  String get crisisHeading;

  /// No description provided for @crisisBody.
  ///
  /// In en, this message translates to:
  /// **'If things feel heavy right now, you are not alone. Kai is always here, and help is available.'**
  String get crisisBody;

  /// No description provided for @crisisResourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Crisis helpline'**
  String get crisisResourceLabel;

  /// No description provided for @crisisResourceNumber.
  ///
  /// In en, this message translates to:
  /// **'988'**
  String get crisisResourceNumber;

  /// Crisis phone resource label
  ///
  /// In en, this message translates to:
  /// **'Lifeline'**
  String get crisisResourceLabelPhone;

  /// Crisis phone resource number
  ///
  /// In en, this message translates to:
  /// **'988'**
  String get crisisResourceNumberPhone;

  /// Crisis text resource label
  ///
  /// In en, this message translates to:
  /// **'Crisis Text Line'**
  String get crisisResourceLabelText;

  /// Crisis text resource number/instruction
  ///
  /// In en, this message translates to:
  /// **'Text HOME to 741741'**
  String get crisisResourceNumberText;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start using Kai'**
  String get onboardingStart;

  /// No description provided for @onboardingStep1CTA.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get onboardingStep1CTA;

  /// No description provided for @onboardingStep0Title.
  ///
  /// In en, this message translates to:
  /// **'Meet Kai'**
  String get onboardingStep0Title;

  /// No description provided for @onboardingStep0Body.
  ///
  /// In en, this message translates to:
  /// **'Your AI travel companion — always ready to help plan, answer, and guide.'**
  String get onboardingStep0Body;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Your tide'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Body.
  ///
  /// In en, this message translates to:
  /// **'The flowing curve at the top shows Kai\'s state — idle, thinking, or responding.'**
  String get onboardingStep1Body;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Gestures'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Swipe from the left edge to open your trip history.'**
  String get onboardingStep2Body;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Let\'s begin'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Ask Kai anything — from visas to must-see spots.'**
  String get onboardingStep3Body;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Meet Kai.'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Your travel companion.\nKnowledgeable. Honest. Quiet when not needed.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingTideTitle.
  ///
  /// In en, this message translates to:
  /// **'The line above is Kai.'**
  String get onboardingTideTitle;

  /// No description provided for @onboardingTideBody.
  ///
  /// In en, this message translates to:
  /// **'Still when waiting. Alive when Kai is doing something — listening, thinking, responding, learning.'**
  String get onboardingTideBody;

  /// No description provided for @onboardingTideStateIdleName.
  ///
  /// In en, this message translates to:
  /// **'idle'**
  String get onboardingTideStateIdleName;

  /// No description provided for @onboardingTideStateIdleDesc.
  ///
  /// In en, this message translates to:
  /// **'nothing happening'**
  String get onboardingTideStateIdleDesc;

  /// No description provided for @onboardingTideStateThinkingName.
  ///
  /// In en, this message translates to:
  /// **'thinking'**
  String get onboardingTideStateThinkingName;

  /// No description provided for @onboardingTideStateThinkingDesc.
  ///
  /// In en, this message translates to:
  /// **'processing'**
  String get onboardingTideStateThinkingDesc;

  /// No description provided for @onboardingTideStateRespondingName.
  ///
  /// In en, this message translates to:
  /// **'responding'**
  String get onboardingTideStateRespondingName;

  /// No description provided for @onboardingTideStateRespondingDesc.
  ///
  /// In en, this message translates to:
  /// **'tokens streaming'**
  String get onboardingTideStateRespondingDesc;

  /// No description provided for @onboardingGesturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Three gestures.'**
  String get onboardingGesturesTitle;

  /// No description provided for @onboardingGesturesBody.
  ///
  /// In en, this message translates to:
  /// **'Everything else is hidden until needed.'**
  String get onboardingGesturesBody;

  /// No description provided for @onboardingGestureNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Swipe right · from edge'**
  String get onboardingGestureNavLabel;

  /// No description provided for @onboardingGestureNavHint.
  ///
  /// In en, this message translates to:
  /// **'opens panel — trips, chats, settings'**
  String get onboardingGestureNavHint;

  /// No description provided for @onboardingGestureInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Swipe up · from bottom'**
  String get onboardingGestureInputLabel;

  /// No description provided for @onboardingGestureInputHint.
  ///
  /// In en, this message translates to:
  /// **'opens input sheet'**
  String get onboardingGestureInputHint;

  /// No description provided for @onboardingGestureActionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Long press · on Kai\'s reply'**
  String get onboardingGestureActionsLabel;

  /// No description provided for @onboardingGestureActionsHint.
  ///
  /// In en, this message translates to:
  /// **'sources, copy, re-ask'**
  String get onboardingGestureActionsHint;

  /// No description provided for @onboardingContextTitle.
  ///
  /// In en, this message translates to:
  /// **'Two facts.\nThen we begin.'**
  String get onboardingContextTitle;

  /// No description provided for @onboardingContextBody.
  ///
  /// In en, this message translates to:
  /// **'Used in every answer about visas, routes and prices. Editable later.'**
  String get onboardingContextBody;

  /// No description provided for @onboardingContextPassportLabel.
  ///
  /// In en, this message translates to:
  /// **'passport'**
  String get onboardingContextPassportLabel;

  /// No description provided for @onboardingContextLangsLabel.
  ///
  /// In en, this message translates to:
  /// **'languages I speak'**
  String get onboardingContextLangsLabel;

  /// No description provided for @onboardingContextCountryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Russian Federation'**
  String get onboardingContextCountryPlaceholder;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search trips and chats'**
  String get search;

  /// No description provided for @tripsLabel.
  ///
  /// In en, this message translates to:
  /// **'TRIPS'**
  String get tripsLabel;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get dateYesterday;

  /// No description provided for @datePrevious7.
  ///
  /// In en, this message translates to:
  /// **'PREVIOUS 7 DAYS'**
  String get datePrevious7;

  /// No description provided for @appsLabel.
  ///
  /// In en, this message translates to:
  /// **'APPS'**
  String get appsLabel;

  /// No description provided for @memoryAppLabel.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get memoryAppLabel;

  /// No description provided for @settingsAppLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsAppLabel;

  /// No description provided for @accountAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get accountAnonymous;

  /// No description provided for @accountFreePlan.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get accountFreePlan;

  /// No description provided for @noChats.
  ///
  /// In en, this message translates to:
  /// **'No chats'**
  String get noChats;

  /// Nav panel date group label for sessions older than 7 days
  ///
  /// In en, this message translates to:
  /// **'OLDER'**
  String get dateOlder;

  /// Italic status suffix shown next to KAI label while streaming
  ///
  /// In en, this message translates to:
  /// **'thinking'**
  String get streamingStatusThinking;

  /// No description provided for @memoryFactsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 fact about you} other{{count} facts about you}}'**
  String memoryFactsCount(num count);

  /// No description provided for @memoryLastSaved.
  ///
  /// In en, this message translates to:
  /// **'last saved {time} ago'**
  String memoryLastSaved(String time);

  /// No description provided for @memorySearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search facts'**
  String get memorySearchPlaceholder;

  /// No description provided for @memoryCategoryAbout.
  ///
  /// In en, this message translates to:
  /// **'about you'**
  String get memoryCategoryAbout;

  /// No description provided for @memoryCategoryPreferences.
  ///
  /// In en, this message translates to:
  /// **'preferences'**
  String get memoryCategoryPreferences;

  /// No description provided for @memoryCategoryRestrictions.
  ///
  /// In en, this message translates to:
  /// **'restrictions'**
  String get memoryCategoryRestrictions;

  /// No description provided for @memoryCategoryTrips.
  ///
  /// In en, this message translates to:
  /// **'trips'**
  String get memoryCategoryTrips;

  /// No description provided for @memoryCategoryFacts.
  ///
  /// In en, this message translates to:
  /// **'facts'**
  String get memoryCategoryFacts;

  /// No description provided for @memorySourceFrom.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get memorySourceFrom;

  /// No description provided for @memorySourceExplicit.
  ///
  /// In en, this message translates to:
  /// **'set explicitly'**
  String get memorySourceExplicit;

  /// No description provided for @memorySourceLinked.
  ///
  /// In en, this message translates to:
  /// **'linked'**
  String get memorySourceLinked;

  /// No description provided for @memoryDangerWipeAll.
  ///
  /// In en, this message translates to:
  /// **'Forget all (GDPR-deletion)'**
  String get memoryDangerWipeAll;

  /// No description provided for @memoryWipeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to forget everything? This action is irreversible.'**
  String get memoryWipeConfirmation;

  /// No description provided for @memoryWipeConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Forget'**
  String get memoryWipeConfirmAction;

  /// No description provided for @memoryWipeCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get memoryWipeCancelAction;

  /// No description provided for @memoryEditFactTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit fact'**
  String get memoryEditFactTitle;

  /// No description provided for @memoryDeleteFactAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get memoryDeleteFactAction;

  /// No description provided for @memoryEditFactAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get memoryEditFactAction;

  /// No description provided for @memoryGoToSourceAction.
  ///
  /// In en, this message translates to:
  /// **'Go to source'**
  String get memoryGoToSourceAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
