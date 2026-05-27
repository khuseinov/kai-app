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

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

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

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start using Kai'**
  String get onboardingStart;

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
  /// **'The flowing curve at the top shows Kai’s state — idle, thinking, or responding.'**
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
  /// **'Let’s begin'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Ask Kai anything — from visas to must-see spots.'**
  String get onboardingStep3Body;
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
