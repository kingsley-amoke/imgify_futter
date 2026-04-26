import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:imgify/constants/revenue_cat.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;

  RevenueCatService._internal();

  bool _isInitialized = false;

  /// Your RevenueCat API Keys
  static const String _androidApiKey = REVENUE_CAT_KEY;
  static const String _iosApiKey = REVENUE_CAT_KEY;

  /// Entitlement ID (set this in RevenueCat dashboard)
  static const String entitlementId = "pro";

  /// Initialize RevenueCat
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final config = PurchasesConfiguration(
        Platform.isAndroid ? _androidApiKey : _iosApiKey,
      );

      await Purchases.configure(config);

      _isInitialized = true;

      if (kDebugMode) {
        print("✅ RevenueCat initialized");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ RevenueCat init error: $e");
      }
    }


  }

  /// Get offerings (products)
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint("Error fetching offerings: $e");
      return null;
    }
  }

  /// Purchase a package
  Future<bool> purchase(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);

      return customerInfo.customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint("Purchase error: $e");
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();

      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint("Restore error: $e");
      return false;
    }
  }

  /// Check if user is premium
  Future<bool> isProUser() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint("Check pro error: $e");
      return false;
    }
  }

  /// Log in user (optional - for syncing across devices)
  Future<void> login(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint("Login error: $e");
    }
  }

  /// Log out user
  Future<void> logout() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }
}