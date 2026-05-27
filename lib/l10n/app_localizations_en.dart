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
  String get onboardingNext => 'Continue';

  @override
  String get onboardingStart => 'Start using Kai';

  @override
  String get onboardingStep1CTA => 'Got it';

  @override
  String get onboardingStep0Title => 'Meet Kai';

  @override
  String get onboardingStep0Body =>
      'Your AI travel companion — always ready to help plan, answer, and guide.';

  @override
  String get onboardingStep1Title => 'Your tide';

  @override
  String get onboardingStep1Body =>
      'The flowing curve at the top shows Kai\'s state — idle, thinking, or responding.';

  @override
  String get onboardingStep2Title => 'Gestures';

  @override
  String get onboardingStep2Body =>
      'Swipe from the left edge to open your trip history.';

  @override
  String get onboardingStep3Title => 'Let\'s begin';

  @override
  String get onboardingStep3Body =>
      'Ask Kai anything — from visas to must-see spots.';

  @override
  String get onboardingWelcomeTitle => 'Meet Kai.';

  @override
  String get onboardingWelcomeBody =>
      'Your travel companion.\nKnowledgeable. Honest. Quiet when not needed.';

  @override
  String get onboardingTideTitle => 'The line above is Kai.';

  @override
  String get onboardingTideBody =>
      'Still when waiting. Alive when Kai is doing something — listening, thinking, responding, learning.';

  @override
  String get onboardingTideStateIdleName => 'idle';

  @override
  String get onboardingTideStateIdleDesc => 'nothing happening';

  @override
  String get onboardingTideStateThinkingName => 'thinking';

  @override
  String get onboardingTideStateThinkingDesc => 'processing';

  @override
  String get onboardingTideStateRespondingName => 'responding';

  @override
  String get onboardingTideStateRespondingDesc => 'tokens streaming';

  @override
  String get onboardingGesturesTitle => 'Three gestures.';

  @override
  String get onboardingGesturesBody =>
      'Everything else is hidden until needed.';

  @override
  String get onboardingGestureNavLabel => 'Swipe right · from edge';

  @override
  String get onboardingGestureNavHint => 'opens panel — trips, chats, settings';

  @override
  String get onboardingGestureInputLabel => 'Swipe up · from bottom';

  @override
  String get onboardingGestureInputHint => 'opens input sheet';

  @override
  String get onboardingGestureActionsLabel => 'Long press · on Kai\'s reply';

  @override
  String get onboardingGestureActionsHint => 'sources, copy, re-ask';

  @override
  String get onboardingContextTitle => 'Two facts.\nThen we begin.';

  @override
  String get onboardingContextBody =>
      'Used in every answer about visas, routes and prices. Editable later.';

  @override
  String get onboardingContextPassportLabel => 'passport';

  @override
  String get onboardingContextLangsLabel => 'languages I speak';

  @override
  String get onboardingContextCountryPlaceholder => 'Russian Federation';
}
