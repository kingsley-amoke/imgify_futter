import 'package:imgify/models/pro_status.dart';
import 'package:imgify/data/pro_status_repository.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io';

/// Pro Manager Service
/// Handles Pro status management and provides upgrade functionality
///
/// For now, this is a simplified version without IAP integration.
/// To add Google Play IAP later:
/// 1. Add in_app_purchase package to pubspec.yaml
/// 2. Set up Google Play Console product
/// 3. Implement IAP service (see IAP_IMPLEMENTATION_GUIDE.md)
class ProManager {
  final ProStatusRepository _repository = ProStatusRepository();

  ProStatus? _cachedStatus;

  ///initialize revenue cat
  Future<void> initializeRevenueCat() async {
    // Platform-specific API keys
    String apiKey;
    if (Platform.isIOS) {
      apiKey = 'test_nAwCYiPkvDiKEvsRFQOWAVekwjI';
    } else if (Platform.isAndroid) {
      apiKey = 'test_nAwCYiPkvDiKEvsRFQOWAVekwjI';
    } else {
      throw UnsupportedError('Platform not supported');
    }

    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  /// Get current Pro status
  Future<ProStatus> getProStatus() async {
    _cachedStatus ??= await _repository.getProStatus();
    return _cachedStatus!;
  }

  /// Check if user is Pro
  Future<bool> isPro() async {
    final status = await getProStatus();
    return status.isPro;
  }

  /// Grant Pro access (for testing or after successful purchase)
  Future<void> grantProAccess({
    required String productId,
    String? purchaseToken,
  }) async {
    final status = ProStatus(
      isPro: true,
      purchaseDate: DateTime.now(),
      purchaseToken: purchaseToken ?? 'test_token',
      productId: productId,
    );

    await _repository.saveProStatus(status);
    _cachedStatus = status;
  }

  /// Revoke Pro access (for testing)
  Future<void> revokeProAccess() async {
    const status = ProStatus(isPro: false);
    await _repository.saveProStatus(status);
    _cachedStatus = status;
  }

  /// Simulate purchase (for testing without IAP)
  /// Replace this with real IAP implementation later
  Future<bool> purchasePro() async {
    // Simulate a successful purchase
    await Future.delayed(const Duration(seconds: 1));

    await grantProAccess(productId: 'imgify_pro_lifetime');
    return true;
  }

  /// Clear cache
  void clearCache() {
    _cachedStatus = null;
  }
}
