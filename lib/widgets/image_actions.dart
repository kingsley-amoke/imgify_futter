import 'package:flutter/material.dart';
import 'package:imgify/widgets/image_action_icon.dart';

class ImageActions extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onPickNew;
  final VoidCallback? onShare;

  const ImageActions({
    super.key,
    required this.onSave,
    required this.onPickNew,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ImageActionIcon(
            icon: Icons.download_outlined,
            onTap: onSave,
            color: Colors.green,
          ),
          if (onShare != null) ...[
            _divider(),
            ImageActionIcon(
              icon: Icons.share_outlined,
              onTap: onShare!,
              color: Colors.blue,
            ),
          ],
          _divider(),
          ImageActionIcon(
            icon: Icons.refresh_rounded,
            onTap: onPickNew,
            color: Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(width: 1, height: 24),
      );
}
