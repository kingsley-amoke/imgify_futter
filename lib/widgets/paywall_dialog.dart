import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter/material.dart';

Future<bool> showPaywall(BuildContext context) async {
  final result = await RevenueCatUI.presentPaywall();

  switch (result) {
    case PaywallResult.purchased:
    // user bought subscription
      _showMessage(context, "Welcome to Imgify Pro 🎉");
      return true;

    case PaywallResult.restored:
      _showMessage(context, "Purchase restored ✅");
      return true;

    case PaywallResult.cancelled:
    // user closed paywall
      return false;

    case PaywallResult.error:
      _showMessage(context, "Something went wrong ❌");
      return false;

    case PaywallResult.notPresented:
      _showMessage(context, "No paywall configured ⚠️");
      return false;
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}