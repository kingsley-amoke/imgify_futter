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

class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  Uint8List? _processedImage;
  String _selectedFormat = 'png';
  bool _isProcessing = false;

  final List<String> _formats = ['jpg', 'png', 'webp', 'gif', 'bmp', 'tiff'];

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _processedImage = null;
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _convertImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final result =
          await _apiService.convertImage(_selectedImage!, _selectedFormat);
      setState(() {
        _processedImage = result;
        _isProcessing = false;
      });
      _showSuccess('Image converted successfully!');
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Failed to convert image: $e');
    }
  }

  Future<void> _saveImage() async {
    if (_processedImage == null) return;

    //TODO:Add Intersteritial Ad here before saving image

    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/converted_${DateTime.now().millisecondsSinceEpoch}.$_selectedFormat';

      final success =
          await saveImageToGallery(filePath: filePath, image: _processedImage!);
      if (success) {
        _showSuccess('Image saved to gallery!');
      }
    } catch (e) {
      _showError('Failed to save image: $e');
    }
  }

  Future<void> _shareImage() async {
    // TODO:Sharing functionality can be implemented here
    if (_processedImage == null) return;
    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/converted_${DateTime.now().millisecondsSinceEpoch}.$_selectedFormat';

      final success =
          await shareImageToApps(filePath: filePath, image: _processedImage!);
      if (success) {
        _showSuccess('Image shared successfully!');
      }
    } catch (e) {
      _showError('Failed to share image: $e');
    }
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
      appBar: myAppbar(context, title: 'Convert Format', centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedImage != null)
              ImagePreview(
                  title: 'Original Image', image: Image.file(_selectedImage!)),
            const SizedBox(height: 20),
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
                      'Select Output Format',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedFormat,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Output Format',
                      ),
                      items: _formats.map((format) {
                        return DropdownMenuItem(
                          value: format,
                          child: Text(format.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFormat = value!;
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
                child: const Text('Pick Image',
                    style: TextStyle(color: Colors.white)),
              )
            else
              PrimaryButton(
                onTap: _isProcessing ? null : _convertImage,
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
                            Icons.swap_horiz,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text('Convert Image',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
              ),
            if (_processedImage != null) ...[
              const SizedBox(height: 20),
              Center(
                child: ImagePreview(
                    title: 'Converted Image',
                    image: Image.memory(_processedImage!)),
              ),
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
