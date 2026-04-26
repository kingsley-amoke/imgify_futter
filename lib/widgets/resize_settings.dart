import 'package:flutter/material.dart';
import 'package:imgify/constants/aspect_ratios.dart';
import 'package:imgify/models/aspect_ratio.dart';
import 'package:imgify/providers/image_provider.dart';
import 'package:imgify/widgets/input_decoration.dart';
import 'package:provider/provider.dart';

class ResizeSettings extends StatefulWidget {
  const ResizeSettings({super.key});

  @override
  State<ResizeSettings> createState() => _ResizeSettingsState();
}

class _ResizeSettingsState extends State<ResizeSettings> {
  MyAspectRatio? _selectedAspectRatio; // null means custom

  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final imageProvider = context.read<ImageProviderState>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
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
              onChanged: (value) async {
                _applyAspectRatio(value);
                await Future.delayed(const Duration(seconds: 1));
                final width = _widthController.text.isNotEmpty
                    ? int.tryParse(_widthController.text)
                    : null;
                final height = _heightController.text.isNotEmpty
                    ? int.tryParse(_heightController.text)
                    : null;
                imageProvider.setImageWidth(width);
                imageProvider.setImageHeight(height);
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
                    decoration: dimensionInput(context, label: 'Width (px)'),
                    onChanged: (_) async {
                      _onWidthChanged();
                      await Future.delayed(const Duration(seconds: 1));
                      final width = _widthController.text.isNotEmpty
                          ? int.tryParse(_widthController.text)
                          : null;
                      final height = _heightController.text.isNotEmpty
                          ? int.tryParse(_heightController.text)
                          : null;

                      imageProvider.setImageWidth(width);
                      imageProvider.setImageHeight(height);
                    },
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
    );
  }
}
