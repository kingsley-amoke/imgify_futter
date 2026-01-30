import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgify/constants/aspect_ratios.dart';
import 'package:imgify/data/api_service.dart';
import 'package:imgify/models/aspect_ratio.dart';
import 'package:imgify/utils/save_image.dart';
import 'package:imgify/utils/share_image.dart';
import 'package:imgify/widgets/error_message.dart';
import 'package:imgify/widgets/image_actions.dart';
import 'package:imgify/widgets/image_preview.dart';
import 'package:imgify/widgets/input_decoration.dart';
import 'package:imgify/widgets/my_appbar.dart';
import 'package:imgify/widgets/primary_button.dart';
import 'package:imgify/widgets/success_message.dart';
import 'package:path_provider/path_provider.dart';

class ResizeScreen extends StatefulWidget {
  const ResizeScreen({super.key});

  @override
  State<ResizeScreen> createState() => _ResizeScreenState();
}

class _ResizeScreenState extends State<ResizeScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  File? _selectedImage;
  Uint8List? _processedImage;
  bool _isProcessing = false;
  MyAspectRatio? _selectedAspectRatio; // null means custom

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

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

  void _applyAspectRatio(MyAspectRatio? aspectRatio) {
    setState(() {
      _selectedAspectRatio = aspectRatio;
    });

    if (aspectRatio == null) {
      // Custom - user can enter any values
      return;
    }

    // Apply aspect ratio based on existing width or height
    final width = _widthController.text.isNotEmpty
        ? int.tryParse(_widthController.text)
        : null;
    final height = _heightController.text.isNotEmpty
        ? int.tryParse(_heightController.text)
        : null;

    if (width != null && width > 0) {
      // Calculate height from width
      final calculatedHeight = (width / aspectRatio.ratio).round();
      _heightController.text = calculatedHeight.toString();
    } else if (height != null && height > 0) {
      // Calculate width from height
      final calculatedWidth = (height * aspectRatio.ratio).round();
      _widthController.text = calculatedWidth.toString();
    } else {
      // Set default dimensions (1000px width)
      const defaultWidth = 1000;
      final calculatedHeight = (defaultWidth / aspectRatio.ratio).round();
      _widthController.text = defaultWidth.toString();
      _heightController.text = calculatedHeight.toString();
    }
  }

  void _onWidthChanged() {
    // If aspect ratio is selected, auto-calculate height from width
    if (_selectedAspectRatio != null) {
      final width = _widthController.text.isNotEmpty
          ? int.tryParse(_widthController.text)
          : null;

      if (width != null && width > 0) {
        final calculatedHeight = (width / _selectedAspectRatio!.ratio).round();
        _heightController.text = calculatedHeight.toString();
      }
    }
  }

  Future<void> _resizeImage() async {
    if (_selectedImage == null) return;

    final width = _widthController.text.isNotEmpty
        ? int.tryParse(_widthController.text)
        : null;
    final height = _heightController.text.isNotEmpty
        ? int.tryParse(_heightController.text)
        : null;

    if (width == null && height == null) {
      _showError('Please enter at least one dimension');
      return;
    }

    if (width != null && width <= 0) {
      _showError('Width must be greater than 0');
      return;
    }

    if (height != null && height <= 0) {
      _showError('Height must be greater than 0');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _apiService.resizeImage(
        image: _selectedImage!,
        width: width,
        height: height,
        maintainAspectRatio: false, // Always use exact dimensions
      );
      setState(() {
        _processedImage = result;
        _isProcessing = false;
      });
      _showSuccess('Image resized successfully!');
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Failed to resize image: $e');
    }
  }

  Future<void> _saveImage() async {
    if (_processedImage == null) return;

    //TODO:Add Interstitial Ad here before saving image

    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
    if (_processedImage == null) return;

    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final success =
          await shareImageToApps(filePath: filePath, image: _processedImage!);
      if (success) {
        _showSuccess('Image shared successfully!');
      }
    } catch (e) {
      _showError('Failed to share image');
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
      appBar: myAppbar(context, title: 'Resize Image', centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedImage != null)
              ImagePreview(
                title: 'Original Image',
                image: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
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
                      'Aspect Ratio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<MyAspectRatio?>(
                      initialValue: _selectedAspectRatio,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Aspect ratio',
                      ),
                      items: [
                        const DropdownMenuItem<MyAspectRatio?>(
                          value: null,
                          child: Text('Custom'),
                        ),
                        ...AspectRatioConstants.commonRatios.map((aspectRatio) {
                          return DropdownMenuItem<MyAspectRatio?>(
                            value: aspectRatio,
                            child: Text(aspectRatio.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        _applyAspectRatio(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Dimensions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _widthController,
                            keyboardType: TextInputType.number,
                            decoration:
                                dimensionInput(context, label: 'Width (px)'),
                            onChanged: (_) => _onWidthChanged(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            decoration: dimensionInput(
                              context,
                              label: 'Height (px)',
                              suffix: _selectedAspectRatio != null
                                  ? const Icon(Icons.lock, size: 18)
                                  : null,
                            ),
                            enabled: _selectedAspectRatio == null,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedAspectRatio != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Height auto-calculated to maintain ${_selectedAspectRatio!.name} ratio',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                onTap: _isProcessing ? null : _resizeImage,
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
                            Icons.photo_size_select_large,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text('Resize Image',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
              ),
            if (_processedImage != null) ...[
              const SizedBox(height: 20),
              Center(
                child: ImagePreview(
                    title: 'Resized Image',
                    image: Image.memory(_processedImage!)),
              ),
              ImageActions(
                onSave: _saveImage,
                onPickNew: _pickImage,
                onShare: _shareImage,
              )
            ],
          ],
        ),
      ),
    );
  }
}
