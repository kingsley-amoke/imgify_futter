import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:imgify/providers/pro_status_provider.dart';
import 'package:imgify/screens/settings.dart';
import 'package:imgify/services/ad_service.dart';
import 'package:imgify/widgets/connectivity_banner.dart';
import 'package:imgify/widgets/my_appbar.dart';
import 'package:provider/provider.dart';
import 'convert_screen.dart';
import 'resize_screen.dart';
import 'compress_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AdMobService _adMobService = AdMobService();
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _initializeAds();
  }

  void _initializeAds() {
    final status = context.read<ProStatusProvider>();
    if (!status.isPro) {
      _bannerAd = _adMobService.createBannerAd();
      _adMobService.loadInterstitialAd();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(
        context,
        title: 'IMGIFY',
        centerTitle: true,
        showBackIcon: false,

      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              Column(

                children: [
                  Image.asset(
                    'assets/images/icon.png',
                    fit: BoxFit.contain,
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Convert, resize, and compress images easily',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(
                children: [

                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context,
                    icon: Icons.compress,
                    title: 'Compress Image',
                    subtitle: 'Reduce file size while maintaining quality',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CompressScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildFeatureCard(
                    context,
                    icon: Icons.photo_size_select_large,
                    title: 'Resize Image',
                    subtitle: 'Change image dimensions',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ResizeScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildFeatureCard(
                    context,
                    icon: Icons.swap_horiz,
                    title: 'Convert Format',
                    subtitle: 'Change image format (JPG, PNG, WebP, etc.)',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ConvertScreen()),
                      );
                    },
                  ),


                ],
              ),
              const SizedBox(height: 24),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //Banner Ad Here
                  Consumer<ProStatusProvider>(
                    builder: (context, status, child) {
                      if (status.isPro || _bannerAd == null) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        height: 50,
                        alignment: Alignment.center,
                        color: Colors.grey[100],
                        child: AdWidget(ad: _bannerAd!),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
