/// Feature gates matching kai-core CC gates.
/// Enable features progressively as backend support lands.
class FeatureFlags {
  const FeatureFlags._();

  // Gate 0: Core chat (always on)
  static const bool chatEnabled = true;
  static const bool onboardingEnabled = true;
  static const bool settingsEnabled = true;

  // Gate 2: Sessions & offline
  static const bool sessionPersistenceEnabled = true;
  static const bool offlineQueueEnabled = true;

  // Gate 3: Voice & push (Phase 3.5)
  static const bool voiceEnabled = false;
  static const bool pushNotificationsEnabled = false;
}
