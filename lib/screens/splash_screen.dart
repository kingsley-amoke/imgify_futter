import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/onboarding_service.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final OnboardingService _service = OnboardingService();
  bool? _hasSeen;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final seen = await _service.hasSeenOnboarding();
    setState(() {
      _hasSeen = seen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeen == null) {
      // 🔄 Splash/loading
      return const Scaffold(
        body: Center(child: CupertinoActivityIndicator()),
      );
    }

    return _hasSeen!
        ? const HomeScreen()
        : const OnboardingScreen();
  }
}
