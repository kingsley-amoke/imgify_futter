import 'package:shared_preferences/shared_preferences.dart';

class UsageLimitService {
  static const String _countKey = "usage_count";
  static const String _lastResetKey = "last_reset";

  static const int dailyLimit = 5; // 🔥 Adjust your free limit

  /// Get current usage count
  Future<int> getUsageCount() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkAndResetIfNeeded(prefs);
    return prefs.getInt(_countKey) ?? 0;
  }

  /// Increment usage
  Future<void> incrementUsage() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkAndResetIfNeeded(prefs);

    int current = prefs.getInt(_countKey) ?? 0;
    await prefs.setInt(_countKey, current + 1);
  }

  /// Check if user exceeded limit
  Future<bool> hasReachedLimit() async {
    final count = await getUsageCount();
    return count >= dailyLimit;
  }

  /// Reset after 24 hours
  Future<void> _checkAndResetIfNeeded(SharedPreferences prefs) async {
    final lastReset = prefs.getInt(_lastResetKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lastReset == null) {
      await prefs.setInt(_lastResetKey, now);
      return;
    }

    final diff = now - lastReset;

    // 24 hours = 86400000 ms
    if (diff >= 86400000) {
      await prefs.setInt(_countKey, 0);
      await prefs.setInt(_lastResetKey, now);
    }
  }

  Future<int> remainingUses() async {
    final count = await getUsageCount();
    return dailyLimit - count;
  }

  Future<void> decrementUsage() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_countKey) ?? 0;

    if (current > 0) {
      await prefs.setInt(_countKey, current - 1);
    }
  }

  Future<void> addExtraUse() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkAndResetIfNeeded(prefs);

    int current = prefs.getInt(_countKey) ?? 0;

    if (current > 0) {
      await prefs.setInt(_countKey, current - 1);
    }
  }
}