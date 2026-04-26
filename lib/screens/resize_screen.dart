import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:imgify/models/batch_models.dart';
import 'package:imgify/providers/image_provider.dart';
import 'package:imgify/providers/pro_status_provider.dart';
import 'package:imgify/providers/usage_provider.dart';
import 'package:imgify/screens/tool_scaffold.dart';
import 'package:imgify/services/ad_service.dart';
import 'package:imgify/services/revenue_cat_service.dart';
import 'package:imgify/widgets/error_message.dart';
import 'package:imgify/widgets/image_actions.dart';
import 'package:imgify/widgets/image_preview.dart';
import 'package:imgify/widgets/resize_settings.dart';
import 'package:imgify/widgets/success_message.dart';
import 'package:provider/provider.dart';

import '../widgets/paywall_dialog.dart';

class ResizeScreen extends StatefulWidget {
  const ResizeScreen({super.key});

  @override
  State<ResizeScreen> createState() => _ResizeScreenState();
}

class _ResizeScreenState extends State<ResizeScreen> {
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
    void scrollToEnd() {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOut,
      );
    }

    void showError(String message) {
      ScaffoldMessenger.of(context).showSnackBar(errorMessageSnackBar(message));
    }

    void showSuccess(String message) {
      ScaffoldMessenger.of(context)
          .showSnackBar(successMessageSnackBar(message));
    }

    final imageProvider = context.watch<ImageProviderState>();
    final isProUser = context.watch<ProStatusProvider>().isPro;
    final usageProvider = context.watch<UsageProvider>();
    return ToolScaffold(
      title: 'Resize',
      hasImages: imageProvider.hasImages,
      hasImage: imageProvider.hasImage,
      imageCount: imageProvider.images.length,
      operation: BatchOperation.resize,
      onPickImages: () {
        imageProvider.pickImage();
      },
      onPrimaryAction: () async {
        if (imageProvider.width == null && imageProvider.height == null) {
          showError('Please enter at least one dimension');
          return;
        }

        if (imageProvider.width != null && imageProvider.width! <= 0) {
          showError('Width must be greater than 0');
          return;
        }

        if (imageProvider.height != null && imageProvider.height! <= 0) {
          showError('Height must be greater than 0');
          return;
        }

        if(!isProUser && usageProvider.remaining == 0) {
          showPaywall(context);
          return;
        }
        final result =
            await imageProvider.resizeImage(adMobService: _adMobService, isProUser: isProUser
            );
        if (result) {
          showSuccess('Successful');
        } else {
          showError('Something went wrong');
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToEnd();
        });
      },
      primaryActionLabel: 'Resize',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          controller: _scrollController,
          children: [
            // const BatchButton(
            //   operation: BatchOperation.resize,
            // ),
            const SizedBox(height: 20),
            if (imageProvider.image != null) ...[
              ImagePreview(
                image: Image.file(imageProvider.image!),
              ),
            ],
            const SizedBox(height: 24),
            const ResizeSettings(),

            if (imageProvider.processedImage != null) ...[
              const SizedBox(height: 24),
              ImagePreview(
                image: Image.memory(imageProvider.processedImage!),
              ),
              const SizedBox(height: 12),
              ImageActions(
                onSave: () async {

                  final result = await imageProvider.saveImage(
                      adMobService: _adMobService,
                    isProUser:isProUser
                  );
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
      ),
    );
  }
}
