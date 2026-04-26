import 'package:flutter/material.dart';
import 'package:imgify/models/batch_models.dart';
import 'package:imgify/providers/image_provider.dart';
import 'package:imgify/screens/empty_state_screen.dart';
import 'package:imgify/widgets/my_appbar.dart';
import 'package:imgify/widgets/primary_button.dart';
import 'package:provider/provider.dart';

import '../providers/pro_status_provider.dart';
import '../widgets/paywall_dialog.dart';
import '../widgets/usage_indicator.dart';

class ToolScaffold extends StatelessWidget {
  final String title;
  final bool hasImages;
  final bool hasImage;
  final int imageCount;
  final VoidCallback onPrimaryAction;
  final String primaryActionLabel;
  final Widget content;
  final VoidCallback onPickImages;
  final BatchOperation operation;

  const ToolScaffold({
    super.key,
    required this.title,
    required this.hasImages,
    required this.hasImage,
    required this.imageCount,
    required this.onPrimaryAction,
    required this.primaryActionLabel,
    required this.content,
    required this.onPickImages,
    required this.operation,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = context.watch<ImageProviderState>();
    final isProUser = context.watch<ProStatusProvider>().isPro;
    return Scaffold(
      appBar: myAppbar(context, title: title, centerTitle: true),
      body: hasImages || hasImage
          ? content
          : EmptyPickState(
              onPick: onPickImages,
              operation: operation,
            ),
      bottomNavigationBar: hasImages || hasImage
          ? SingleChildScrollView(
              child: Column(
                children: [
                 if(!isProUser) ...[UsageIndicatorPro(onPaywallTap: () {
                    showPaywall(context);
                  }),
                  ],
                  PrimaryButton(
                    onTap: onPrimaryAction,
                    child: imageProvider.isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            primaryActionLabel,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                  ),
                  const SizedBox(
                    height: 8,
                  )
                ],
              ),
            )
          : null,
    );
  }
}
