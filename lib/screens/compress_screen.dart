import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:imgify/models/batch_models.dart';
import 'package:imgify/providers/image_provider.dart';
import 'package:imgify/providers/pro_status_provider.dart';
import 'package:imgify/providers/usage_provider.dart';
import 'package:imgify/screens/tool_scaffold.dart';
import 'package:imgify/services/ad_service.dart';
import 'package:imgify/services/revenue_cat_service.dart';
import 'package:imgify/widgets/compression_settings.dart';
import 'package:imgify/widgets/error_message.dart';
import 'package:imgify/widgets/image_actions.dart';
import 'package:imgify/widgets/image_preview.dart';
import 'package:imgify/widgets/success_message.dart';
import 'package:provider/provider.dart';

import '../widgets/paywall_dialog.dart';

class CompressScreen extends StatefulWidget {
  const CompressScreen({super.key});

  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  final ScrollController _scrollController = ScrollController();

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
      _adMobService.loadRewardedAd();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = context.watch<ImageProviderState>();
    final isProUser = context.watch<ProStatusProvider>().isPro;
    final usageProvider = context.watch<UsageProvider>();

    void showError(String message) {
      ScaffoldMessenger.of(context).showSnackBar(errorMessageSnackBar(message));
    }

    void showSuccess(String message) {
      ScaffoldMessenger.of(context)
          .showSnackBar(successMessageSnackBar(message));
    }

    void scrollToEnd() {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOut,
      );
    }

    String formatBytes(int bytes) {
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    return ToolScaffold(
      title: 'Compress',
      hasImages: imageProvider.images.isNotEmpty,
      hasImage: imageProvider.image != null,
      imageCount: imageProvider.images.length,
      operation: BatchOperation.compress,
      onPickImages: () {
        imageProvider.pickImage();
      },
      onPrimaryAction: () async {
        if(!isProUser && usageProvider.remaining == 0) {
          showPaywall(context);
          return;
        }
        final result =
            await imageProvider.compressImage(adMobService: _adMobService, isProUser: isProUser);
        if (result) {
          showSuccess('Successful');
        } else {
          showError('Something went wrong');
        }
        await Future.delayed(const Duration(seconds: 1));
        scrollToEnd();
      },
      primaryActionLabel: 'Compress',
      content: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          if (imageProvider.image != null) ...[
            ImagePreview(
              image: Image.file(imageProvider.image!),
            ),
          ],
          const SizedBox(height: 24),
          const CompressionSettings(),
          if (imageProvider.processedImage != null) ...[
            const SizedBox(height: 24),
            ImagePreview(
              title: 'Compressed',
              image: Image.memory(imageProvider.processedImage!),
            ),
            const SizedBox(height: 12),
            _ResultStats(
              newSize: formatBytes(imageProvider.compressedSize!),
              reduction: imageProvider.getCompressionRatio(),
            ),
            const SizedBox(height: 12),
            ImageActions(
              onSave: () async {

                final result =
                    await imageProvider.saveImage(adMobService: _adMobService, isProUser:isProUser);
                if (result) {
                  showSuccess('Successful');
                } else {
                  showError('Failed');
                }
              },
              onPickNew: () {
                imageProvider.pickImage();
                imageProvider.deleteProcessed();
              },
              onShare: () async {
                final result = await imageProvider.shareImage();
                if (result) {
                  showSuccess('Successful');
                } else {
                  showError('Something went wrong');
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultStats extends StatelessWidget {
  final String newSize;
  final double reduction;

  const _ResultStats({
    required this.newSize,
    required this.reduction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(label: 'New size', value: newSize),
        _StatItem(
          label: 'Reduced',
          value: '${reduction.toStringAsFixed(1)}%',
          highlight: true,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatItem({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: highlight ? Colors.green : null,
          ),
        ),
      ],
    );
  }
}
