import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgify/models/batch_models.dart';
import 'package:imgify/screens/batch_config_screen.dart';
import 'package:imgify/widgets/my_appbar.dart';
import 'package:imgify/widgets/primary_button.dart';

class BatchSelectionScreen extends StatefulWidget {
  final BatchOperation operation;

  const BatchSelectionScreen({
    super.key,
    required this.operation,
  });

  @override
  State<BatchSelectionScreen> createState() => _BatchSelectionScreenState();
}

class _BatchSelectionScreenState extends State<BatchSelectionScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

  bool _isLoading = false;

  Future<void> _pickImages() async {
    setState(() => _isLoading = true);

    try {
      final images = await _picker.pickMultiImage(imageQuality: 100);
      if (images.isNotEmpty) {
        _selectedImages.addAll(
          images.map((e) => File(e.path)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick images')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _continue() {
    if (_selectedImages.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BatchConfigScreen(
          images: _selectedImages,
          operation: widget.operation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = _selectedImages.isNotEmpty;

    return Scaffold(
      appBar: myAppbar(
        context,
        title: 'Select images',
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasImages
              ? _ImageGrid(
                  images: _selectedImages,
                  onAddMore: _pickImages,
                  onRemove: (i) => setState(() => _selectedImages.removeAt(i)),
                )
              : _EmptyState(onPick: _pickImages),
      bottomNavigationBar: hasImages
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 52,
                  child: PrimaryButton(
                    onTap: _continue,
                    child: Text(
                      'Continue (${_selectedImages.length})',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onPick;

  const _EmptyState({required this.onPick});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 72,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select images to begin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose multiple images from your gallery for batch processing',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.add),
              label: const Text('Choose images'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAddMore;
  final ValueChanged<int> onRemove;

  const _ImageGrid({
    required this.images,
    required this.onAddMore,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              // Text(
              //   '${images.length} selected',
              //   style: const TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
              const Spacer(),
              TextButton.icon(
                onPressed: onAddMore,
                icon: const Icon(Icons.add),
                label: const Text('Add more'),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: images.length,
            itemBuilder: (_, index) {
              return _ImageTile(
                image: images[index],
                onRemove: () => onRemove(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _ImageTile({
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.file(image, fit: BoxFit.cover),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
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
      ),
    );
  }
}
