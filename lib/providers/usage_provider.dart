import 'dart:async';

import 'package:flutter/material.dart';
import 'package:imgify/services/usage_limit_service.dart';
import 'package:imgify/services/ad_service.dart';

class UsageProvider extends ChangeNotifier {
  final UsageLimitService _usageService;
  final AdMobService _adService;

  UsageProvider(this._usageService, this._adService);

  int remaining = 0;
  int total = UsageLimitService.dailyLimit;
  bool isLoading = false;

  int _adsWatchedToday = 0;
  DateTime? _lastAdTime;

  int get adsRemaining => 3 - _adsWatchedToday;
  bool get canWatchAd => adsRemaining > 0 && !_isOnCooldown;

  bool get _isOnCooldown {
    if (_lastAdTime == null) return false;
    return DateTime.now().difference(_lastAdTime!) <
        const Duration(minutes: 2);
  }

  Duration get cooldownRemaining {
    if (_lastAdTime == null) return Duration.zero;
    final diff = DateTime.now().difference(_lastAdTime!);
    final remaining = const Duration(minutes: 2) - diff;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Timer? _cooldownTimer;

  void startCooldownTicker() {
    _cooldownTimer?.cancel();

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isOnCooldown) {
        _cooldownTimer?.cancel();
      }
      notifyListeners();
    });
  }

  bool get isLow => remaining <= 2;
  double get progress => total == 0 ? 0 : remaining / total;

  /// INIT
  Future<void> init() async {
    await loadUsage();
  }

  /// LOAD USAGE
  Future<void> loadUsage() async {
    isLoading = true;
    notifyListeners();

    final count = await _usageService.getUsageCount();
    remaining = (total - count).clamp(0, total);

    isLoading = false;
    notifyListeners();
  }

  Future<void> incrementUsage() async {
    await _usageService.incrementUsage();

    // Update local state instantly
    if (remaining > 0) {
      remaining--;
    }

    notifyListeners();
  }

  /// WATCH AD
  Future<bool> watchAdForExtraUse() async {
    if (isLoading || !canWatchAd) return false;

    print(canWatchAd);
    print(_adsWatchedToday);
    print(adsRemaining);

    isLoading = true;
    notifyListeners();

    try {
      final rewarded = await _adService.showRewardedAdAsync();

      if (!rewarded) return false;

      await _usageService.addExtraUse();

      // Update state
      remaining = (remaining + 1).clamp(0, total);
      _adsWatchedToday++;
      _lastAdTime = DateTime.now();

      notifyListeners();
      return true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}