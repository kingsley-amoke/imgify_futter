import 'package:flutter/material.dart';

class ImageActionIcon extends StatelessWidget {
  const ImageActionIcon(
      {super.key, required this.icon, required this.onTap, this.color});

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkResponse(
      radius: 28,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color ?? colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 22,
          color: color != null ? Colors.white : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
