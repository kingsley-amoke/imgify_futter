import 'package:flutter/material.dart';
import 'package:imgify/providers/connectivity_provider.dart';
import 'package:imgify/widgets/paywall_dialog.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart'; // For animations
import '../providers/pro_status_provider.dart';
import '../services/onboarding_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final OnboardingService _onboardingService = OnboardingService();
  int _currentPage = 0;

  final List<_OnboardPage> _pages = [
    _OnboardPage(
      title: 'All-in-One Image Tool',
      description: 'Convert, resize, and compress images in seconds',
      asset: 'assets/animations/gallery.json', // Lottie mockup
    ),
    _OnboardPage(
      title: 'Stop wasting time on large images',
      description:
          'Reduce file size without losing quality and process multiple images at once',
      asset: 'assets/animations/gallery.json',
    ),
    _OnboardPage(
      title: 'Free to start. Upgrade anytime.',
      description:
          'Enjoy free usage with limits. Unlock unlimited processing with Imgify Pro',
      asset: 'assets/animations/success.json',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final navigator = Navigator.of(context);
    final isProUser = context.read<ProStatusProvider>().isPro;

    final isOnline = context.read<ConnectivityProvider>().isOnline;


    if (!mounted) {
      return;
    }

    if (!isOnline || isProUser) {
      navigator.pushReplacementNamed('/home');
    }

   try{
     final result = await showPaywall(context);

     if (result) {

       await _onboardingService.setSeenOnboarding();
     }
   }catch(e){
     print(e.toString());
   }

    navigator.pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Lottie.asset(page.asset, repeat: true),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 24 : 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.greenAccent
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Next/Finish button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(16),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _currentPage == _pages.length - 1 ? 'Get Started 🚀' : 'Next',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Helper class
class _OnboardPage {
  final String title;
  final String description;
  final String asset;

  _OnboardPage({
    required this.title,
    required this.description,
    required this.asset,
  });
}
