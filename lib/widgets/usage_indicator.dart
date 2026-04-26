import 'package:flutter/material.dart';
import 'package:imgify/widgets/success_message.dart';
import 'package:provider/provider.dart';

import '../providers/usage_provider.dart';

class UsageIndicatorPro extends StatelessWidget {
  final VoidCallback onPaywallTap;

  const UsageIndicatorPro({super.key, required this.onPaywallTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsageProvider>();

    final remaining = provider.remaining;
    final total = provider.total;
    final progress = provider.progress;
    final isLow = provider.isLow;

    Future<void> handleAd() async {
      bool rewarded = await provider.watchAdForExtraUse();

      if (!rewarded) {
        onPaywallTap();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          successMessageSnackBar("🎉 You earned 1 extra use!"),
        );
      }
    }

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLow
              ? [Colors.red.shade400, Colors.red.shade600]
              : [Colors.deepPurple, Colors.indigo],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Free Plan",
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              GestureDetector(
                onTap: onPaywallTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Go Premium",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 8),

          /// TEXT
          Text(
            remaining > 0 ? "$remaining uses left today" : "No free uses left",
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          /// PROGRESS
          LinearProgressIndicator(value: progress),

          const SizedBox(height: 8),

          /// ACTIONS
          if (remaining == 0) ...[
            Consumer<UsageProvider>(
              builder: (context, provider, _) {
                String text;

                if (provider.adsRemaining == 0) {
                  text = "Ad limit reached today";
                } else if (!provider.canWatchAd) {
                  final seconds = provider.cooldownRemaining.inSeconds;
                  text = "Wait ${seconds}s";
                } else {
                  text = "Watch Ad to add +1 Use";
                }

                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: provider.canWatchAd && !provider.isLoading
                            ? () async {
                                final rewarded =
                                    await provider.watchAdForExtraUse();

                                if (!rewarded) {
                                  onPaywallTap();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    successMessageSnackBar(
                                        "🎉 You earned 1 extra use!"),
                                  );
                                }
                              }
                            : null,
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(text),
                      ),
                    ),
                  ],
                );
              },
            ),
          ] else if (isLow) ...[
            const Text(
              "Almost out. Upgrade for unlimited exports.",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ]
        ],
      ),
    );

    return GestureDetector(
      onTap: onPaywallTap,
      child: card,
    );
  }
}
