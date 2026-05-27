// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kai';

  @override
  String get startConversation => 'Start a conversation with Kai';

  @override
  String get today => 'Today';

  @override
  String get suggestionTrip => 'Trip plans';

  @override
  String get suggestionVisa => 'Visa question';

  @override
  String get suggestionRecommendations => 'Recommendations';

  @override
  String get composePlaceholder => 'Message Kai…';

  @override
  String get offlineTitle => 'No connection';

  @override
  String get retry => 'Retry';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get rateLimitTitle => 'Too many requests';

  @override
  String rateLimitSecondsRemaining(int secs) {
    return '$secs sec';
  }

  @override
  String get viewPlans => 'View plans';

  @override
  String get crisisHeading => 'I hear you.';

  @override
  String get crisisBody =>
      'If things feel heavy right now, you are not alone. Kai is always here, and help is available.';

  @override
  String get crisisResourceLabel => 'Crisis helpline';

  @override
  String get crisisResourceNumber => '988';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start using Kai';

  @override
  String get onboardingStep0Title => 'Meet Kai';

  @override
  String get onboardingStep0Body =>
      'Your AI travel companion — always ready to help plan, answer, and guide.';

  @override
  String get onboardingStep1Title => 'Your tide';

  @override
  String get onboardingStep1Body =>
      'The flowing curve at the top shows Kai’s state — idle, thinking, or responding.';

  @override
  String get onboardingStep2Title => 'Gestures';

  @override
  String get onboardingStep2Body =>
      'Swipe from the left edge to open your trip history.';

  @override
  String get onboardingStep3Title => 'Let’s begin';

  @override
  String get onboardingStep3Body =>
      'Ask Kai anything — from visas to must-see spots.';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Kai';

  @override
  String get onboardingWelcomeBody =>
      'Kai is your personal AI assistant — always ready to help with plans, questions, and ideas.';

  @override
  String get onboardingTideTitle => 'Kai is always here';

  @override
  String get onboardingTideChipThinking => 'Thinking';

  @override
  String get onboardingTideChipResponding => 'Responding';

  @override
  String get onboardingTideChipListening => 'Listening';

  @override
  String get onboardingGesturesTitle => 'Gestures';

  @override
  String get onboardingGestureNavLabel => 'Open navigation';

  @override
  String get onboardingGestureNavHint => 'Swipe right';

  @override
  String get onboardingGestureInputLabel => 'Open input';

  @override
  String get onboardingGestureInputHint => 'Swipe up';

  @override
  String get onboardingGestureActionsLabel => 'Quick actions';

  @override
  String get onboardingGestureActionsHint => 'Long press';

  @override
  String get onboardingContextTitle => 'Settings';

  @override
  String get onboardingContextCountryPlaceholder => '🌍 Country';
}
