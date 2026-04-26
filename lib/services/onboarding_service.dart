import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _key = "has_seen_onboarding";

  /// Check if onboarding was already completed
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Mark onboarding as completed
  Future<void> setSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}