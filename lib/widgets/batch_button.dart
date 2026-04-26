import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imgify/models/batch_models.dart';
import 'package:imgify/providers/pro_status_provider.dart';
import 'package:imgify/screens/batch_selection_screen.dart';
import 'package:imgify/widgets/paywall_dialog.dart';

class BatchButton extends StatelessWidget {
  final BatchOperation operation;

  const BatchButton({
    super.key,
    required this.operation,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProStatusProvider>(
      builder: (context, proProvider, _) {
        final isPro = proProvider.isPro;
        final colorScheme = Theme.of(context).colorScheme;

        return Material(
          color: isPro
              ? colorScheme.primaryContainer.withOpacity(0.35)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _handleTap(context, isPro),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _LeadingIcon(isPro: isPro),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _Content(isPro: isPro),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleTap(BuildContext context, bool isPro) async {
    if (isPro) {
      _goToBatch(context);
      return;
    }

    final unlocked = await showPaywall(context);


    if (unlocked == true && context.mounted) {
      _goToBatch(context);
    }else{
      Navigator.pop(context);
    }
  }

  void _goToBatch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BatchSelectionScreen(operation: operation),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final bool isPro;

  const _LeadingIcon({required this.isPro});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPro
            ? colorScheme.primary.withOpacity(0.15)
            : colorScheme.outline.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isPro ? Icons.layers_outlined : Icons.lock_outline,
        color: isPro ? colorScheme.primary : colorScheme.onSurfaceVariant,
        size: 24,
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final bool isPro;

  const _Content({required this.isPro});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Batch Processing',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isPro) ...[
              const SizedBox(width: 8),
              _ProBadge(),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isPro
              ? 'Apply actions to multiple images at once'
              : 'Unlock batch actions for faster workflow',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'PRO',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
