import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityProvider() {
    _init();
  }

  void _init() {
    print('initializiing connectivity');
    // Initial check
    checkConnection();

    // Listen to changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {


      if (results.contains(ConnectivityResult.none)) {
        _updateStatus(false);
      } else {
        checkConnection(); // verify real internet
      }
    });
  }

  Future<void> checkConnection() async {
    print('checking connection');
    try {
      final result = await _connectivity.checkConnectivity();

      if (result.contains(ConnectivityResult.none)) {
        _updateStatus(false);
        return;
      }

      // Verify actual internet access
      final lookup = await InternetAddress.lookup('google.com');
      final hasInternet =
          lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;

      _updateStatus(hasInternet);
    } catch (_) {
      _updateStatus(false);
    }
  }

  void _updateStatus(bool status) {
    if (_isOnline != status) {
      _isOnline = status;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}