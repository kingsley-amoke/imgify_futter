import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({super.key, this.title, this.height, required this.image});

  final String? title;
  final Widget image;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        const SizedBox(height: 12),
        Container(
          height: height ?? 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.08),
                Colors.blue.withValues(alpha: 0.08),
              ],
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: image,
          ),
        ),
      ],
    );
  }
}
