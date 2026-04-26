import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreviewGrid extends StatelessWidget {
  final List<File> images;
  final void Function(int index)? onRemove;

  const ImagePreviewGrid({
    super.key,
    required this.images,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return _PreviewTile(
          image: images[index],
          onRemove: onRemove == null ? null : () => onRemove!(index),
        );
      },
    );
  }
}

class _PreviewTile extends StatelessWidget {
  final File image;
  final VoidCallback? onRemove;

  const _PreviewTile({
    required this.image,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
