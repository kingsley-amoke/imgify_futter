import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenue_cat_service.dart';
import 'connectivity_provider.dart';

class ProStatusProvider extends ChangeNotifier {
  final RevenueCatService _revenueCatService = RevenueCatService();

  bool _initialized = false;
  bool _isOnline = true;
  bool _isPro = false;
  bool _isLoading = false;
  Offerings? _offerings;

  bool get isPro => _isPro;
  bool get isLoading => _isLoading;
  Offerings? get offerings => _offerings;

  /// Initialize provider
  Future<void> init() async {
    _setLoading(true);

    await _revenueCatService.init();

    await _loadUserStatus();
    await _loadOfferings();

    _setLoading(false);

    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      final isProNow = customerInfo.entitlements.all[
      RevenueCatService.entitlementId]
          ?.isActive ??
          false;

      if (_isPro != isProNow) {
        _isPro = isProNow;
        notifyListeners();
      }
    });
  }

  void updateConnectivity(ConnectivityProvider connectivity) {
    final wasOffline = !_isOnline;
    _isOnline = connectivity.isOnline;

    // First init
    if (_isOnline && !_initialized) {
      _initialized = true;
      init();
    }

    // Re-init when coming back online
    if (_isOnline && wasOffline) {
      refresh();
    }
  }

  Future<void> refresh() async {
    print("Refreshing Pro status...");
  }


  /// Load premium status
  Future<void> _loadUserStatus() async {
    try {
      _isPro = await _revenueCatService.isProUser();
    } catch (e) {
      debugPrint("Error loading pro status: $e");
    }
    notifyListeners();
  }

  /// Load products
  Future<void> _loadOfferings() async {
    try {
      _offerings = await _revenueCatService.getOfferings();
    } catch (e) {
      debugPrint("Error loading offerings: $e");
    }
    notifyListeners();
  }

  /// Purchase
  Future<bool> purchase(Package package) async {
    _setLoading(true);

    final success = await _revenueCatService.purchase(package);

    if (success) {
      _isPro = true;
    }

    _setLoading(false);
    notifyListeners();

    return success;
  }

  /// Restore purchases
  Future<bool> restore() async {
    _setLoading(true);

    final success = await _revenueCatService.restorePurchases();

    if (success) {
      _isPro = true;
    }

    _setLoading(false);
    notifyListeners();

    return success;
  }

  /// Refresh status manually
  Future<void> refreshProStatus() async {
    await _loadUserStatus();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}