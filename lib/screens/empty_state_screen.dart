import 'package:flutter/material.dart';
import 'package:imgify/models/batch_models.dart';
import 'package:imgify/widgets/batch_button.dart';

class EmptyPickState extends StatelessWidget {
  final VoidCallback onPick;
  final BatchOperation operation;

  const EmptyPickState({
    super.key,
    required this.onPick,
    required this.operation,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          BatchButton(operation: operation),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onPick,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 56,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Select an image',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Choose a photo from your gallery to continue',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
