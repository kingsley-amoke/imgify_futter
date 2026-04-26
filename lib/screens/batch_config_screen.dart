import 'dart:io';
import 'package:flutter/material.dart';
import 'package:imgify/constants/aspect_ratios.dart';
import 'package:imgify/constants/image_formats.dart';
import 'package:imgify/models/aspect_ratio.dart';
import 'package:imgify/models/batch_models.dart';
import 'package:imgify/models/image_format.dart';
import 'package:imgify/providers/image_provider.dart';
import 'package:imgify/screens/batch_processing_screen.dart';
import 'package:imgify/widgets/compression_option.dart';
import 'package:imgify/widgets/compression_settings.dart';
import 'package:imgify/widgets/my_appbar.dart';
import 'package:imgify/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class BatchConfigScreen extends StatefulWidget {
  final List<File> images;
  final BatchOperation operation;

  const BatchConfigScreen({
    super.key,
    required this.images,
    required this.operation,
  });

  @override
  State<BatchConfigScreen> createState() => _BatchConfigScreenState();
}

class _BatchConfigScreenState extends State<BatchConfigScreen> {
  // Compression settings
  CompressionLevel _level = CompressionLevel.balanced;
  bool _keepMetadata = true;
  int compressionQuality = 50;
  ImgifyImageFormat _format = ImgifyImageFormat.jpeg;

  // Resize settings
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  MyAspectRatio? _selectedAspectRatio;

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _applyAspectRatio(MyAspectRatio? aspectRatio) {
    setState(() {
      _selectedAspectRatio = aspectRatio;
    });

    if (aspectRatio == null) return;

    final width = _widthController.text.isNotEmpty
        ? int.tryParse(_widthController.text)
        : null;

    if (width != null && width > 0) {
      final calculatedHeight = (width / aspectRatio.ratio).round();
      _heightController.text = calculatedHeight.toString();
    } else {
      const defaultWidth = 1000;
      final calculatedHeight = (defaultWidth / aspectRatio.ratio).round();
      _widthController.text = defaultWidth.toString();
      _heightController.text = calculatedHeight.toString();
    }
  }

  void _onWidthChanged() {
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

  Map<String, dynamic> _getSettings() {
    switch (widget.operation) {
      case BatchOperation.compress:
        return {
          'quality':
              context.read<ImageProviderState>().compressionQuality.toInt(),
          'format': _format.name
        };
      case BatchOperation.resize:
        return {
          'width': _widthController.text.isNotEmpty
              ? int.tryParse(_widthController.text)
              : null,
          'height': _heightController.text.isNotEmpty
              ? int.tryParse(_heightController.text)
              : null,
        };
      case BatchOperation.convert:
        return {'format': _format.name};
    }
  }

  void _startProcessing() {
    final settings = _getSettings();

    // Validate settings
    if (widget.operation == BatchOperation.resize) {
      final width = settings['width'] as int?;
      final height = settings['height'] as int?;

      if (width == null && height == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter at least one dimension'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Create batch job
    final job = BatchJob(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePaths: widget.images.map((img) => img.path).toList(),
      operation: widget.operation,
      settings: settings,
    );

    // Navigate to processing screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BatchProcessingScreen(job: job),
      ),
    );
  }

  String _getOperationName() {
    switch (widget.operation) {
      case BatchOperation.compress:
        return 'Compress';
      case BatchOperation.resize:
        return 'Resize';
      case BatchOperation.convert:
        return 'Convert';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppbar(
        context,
        title: 'Batch ${_getOperationName()} (${widget.images.length})',
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPreview(),
            const SizedBox(height: 24),
            _buildSettings(),
            const SizedBox(height: 24),
            PrimaryButton(
              onTap: _startProcessing,
              child: const Text(
                'Start Processing',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Images',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.images.length.clamp(0, 5),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        widget.images[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            if (widget.images.length > 5) ...[
              const SizedBox(height: 8),
              Text(
                '+${widget.images.length - 5} more images',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings (applied to all images)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.operation == BatchOperation.compress) ...[
              _builtCompressionSettings(),

              const SizedBox(height: 16),
              // _buildFormatSelector(),
            ] else if (widget.operation == BatchOperation.resize) ...[
              _buildAspectRatioSelector(),
              const SizedBox(height: 16),
              _buildDimensionInputs(),
            ] else if (widget.operation == BatchOperation.convert) ...[
              _buildFormatSelector(),
              // const ConvertionSettings(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _builtCompressionSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompressionOption(
          title: 'Low',
          subtitle: 'Best quality, larger size',
          selected: _level == CompressionLevel.low,
          onTap: () => {
            setState(() {
              compressionQuality = 25;
              _level = CompressionLevel.low;
            })
          },
        ),
        CompressionOption(
          title: 'Balanced',
          subtitle: 'Recommended for most images',
          selected: _level == CompressionLevel.balanced,
          onTap: () => {
            setState(() {
              _level = CompressionLevel.balanced;
              compressionQuality = 50;
            })
          },
        ),
        CompressionOption(
          title: 'High',
          subtitle: 'Smallest size, lower quality',
          selected: _level == CompressionLevel.high,
          onTap: () => {
            setState(() {
              _level = CompressionLevel.high;
              compressionQuality = 100;
            })
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: _keepMetadata,
          onChanged: (v) => setState(() => _keepMetadata = v),
          title: const Text('Keep metadata'),
          subtitle: const Text('EXIF, location, camera info'),
        ),
      ],
    );
  }

  Widget _buildFormatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Output Format'),
        const SizedBox(height: 8),
        DropdownButtonFormField<ImgifyImageFormat>(
          initialValue: _format,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: presetFormats.map((format) {
            return DropdownMenuItem(
              value: format,
              child: Text(format.name.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _format = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildAspectRatioSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Aspect Ratio'),
        const SizedBox(height: 8),
        DropdownButtonFormField<MyAspectRatio?>(
          initialValue: _selectedAspectRatio,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintText: 'Select aspect ratio',
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
      ],
    );
  }

  Widget _buildDimensionInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dimensions'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _widthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Width (px)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _onWidthChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Height (px)',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedAspectRatio == null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
