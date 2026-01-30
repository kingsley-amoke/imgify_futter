import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgify/data/api_service.dart';
import 'package:imgify/utils/save_image.dart';
import 'package:imgify/utils/share_image.dart';
import 'package:imgify/widgets/error_message.dart';
import 'package:imgify/widgets/image_actions.dart';
import 'package:imgify/widgets/image_preview.dart';
import 'package:imgify/widgets/my_appbar.dart';
import 'package:imgify/widgets/primary_button.dart';
import 'package:imgify/widgets/success_message.dart';
import 'package:path_provider/path_provider.dart';

class CompressScreen extends StatefulWidget {
  const CompressScreen({super.key});

  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  Uint8List? _processedImage;
  bool _isProcessing = false;
  double _quality = 80;
  int? _originalSize;
  int? _compressedSize;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final file = File(image.path);
        final size = await file.length();
        setState(() {
          _selectedImage = file;
          _processedImage = null;
          _originalSize = size;
          _compressedSize = null;
        });
      }
    } catch (e) {
      _showError('Failed to pick image');
    }
  }

  Future<void> _compressImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _apiService.compressImage(
        image: _selectedImage!,
        quality: _quality.toInt(),
      );
      setState(() {
        _processedImage = result;
        _compressedSize = result.length;
        _isProcessing = false;
      });
      _showSuccess('Image compressed successfully!');
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Failed to compress image');
    }
  }

  Future<void> _saveImage() async {
    if (_processedImage == null) return;
//TODO:Add Intersteritial Ad here before saving image
    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final success =
          await saveImageToGallery(filePath: filePath, image: _processedImage!);
      if (success) {
        _showSuccess('Image saved to gallery!');
      }
    } catch (e) {
      _showError('Failed to save image');
    }
  }

  Future<void> _shareImage() async {
    if (_processedImage == null) return;

    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final success =
          await shareImageToApps(filePath: filePath, image: _processedImage!);
      if (success) {
        _showSuccess('Image shared successfully!');
      }
    } catch (e) {
      _showError('Failed to share image');
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  double _getCompressionRatio() {
    if (_originalSize == null || _compressedSize == null) return 0;
    return (1 - (_compressedSize! / _originalSize!)) * 100;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(errorMessageSnackBar(message));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(successMessageSnackBar(message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(context, title: 'Compress Image', centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedImage != null)
              ImagePreview(
                title: 'Original Image',
                image: Image.file(_selectedImage!),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _formatBytes(_originalSize ?? 0),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Compression Quality',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Low'),
                        Text(
                          '${_quality.toInt()}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Text('High'),
                      ],
                    ),
                    Slider(
                      value: _quality,
                      min: 1,
                      max: 100,
                      divisions: 99,
                      label: '${_quality.toInt()}%',
                      onChanged: (value) {
                        setState(() {
                          _quality = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedImage == null)
              PrimaryButton(
                onTap: _pickImage,
                child: const Text(
                  'Pick Image',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            else
              PrimaryButton(
                onTap: _isProcessing ? null : _compressImage,
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.compress_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text('Compress Image',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
              ),
            if (_processedImage != null) ...[
              const SizedBox(height: 20),
              ImagePreview(
                  title: 'Compressed Image',
                  image: Image.memory(_processedImage!)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'New Size',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        _formatBytes(_compressedSize!),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Reduced',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '${_getCompressionRatio().toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ImageActions(
                onSave: _saveImage,
                onPickNew: _pickImage,
                onShare: _shareImage,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
