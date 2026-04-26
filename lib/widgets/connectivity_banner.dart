import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  bool _showOnlineBanner = false;
  bool _wasOffline = false;
  bool _blinkEnabled = true;

  Timer? _blinkTimer;
  Timer? _onlineTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacity = Tween(begin: 1.0, end: 0.3).animate(_controller);

    _controller.repeat(reverse: true);
  }

  void _handleState(bool isOnline) {
    // 🔴 Went offline
    if (!isOnline) {
      _wasOffline = true;

      // Enable blinking for a few seconds
      _blinkEnabled = true;
      _controller.repeat(reverse: true);

      _blinkTimer?.cancel();
      _blinkTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _blinkEnabled = false;
          });
          _controller.stop(); // stop blinking → static
        }
      });
    }

    // 🟢 Back online
    if (isOnline && _wasOffline) {
      _wasOffline = false;

      setState(() {
        _showOnlineBanner = true;
      });

      _onlineTimer?.cancel();
      _onlineTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showOnlineBanner = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _blinkTimer?.cancel();
    _onlineTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;

    _handleState(isOnline);

    // 🟢 ONLINE BANNER
    if (_showOnlineBanner) {
      return  const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Icon(Icons.wifi, color: Colors.green, size: 24),
      );
    }

    // 🔴 OFFLINE
    if (!isOnline) {
      const child = Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Icon(Icons.wifi_off, color: Colors.red, size: 24),
      );

      return _blinkEnabled
          ? FadeTransition(opacity: _opacity, child: child)
          : child;
    }

    return const SizedBox.shrink();
  }
}