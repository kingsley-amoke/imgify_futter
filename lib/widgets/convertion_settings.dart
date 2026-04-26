import 'package:flutter/material.dart';
import 'package:imgify/models/image_format.dart';
import 'package:imgify/providers/image_provider.dart';
import 'package:provider/provider.dart';

class ConvertionSettings extends StatelessWidget {
  const ConvertionSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final imageProvider = context.watch<ImageProviderState>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            DropdownButtonFormField<ImgifyImageFormat>(
              // initialValue: imageProvider.selectedFormat,
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Output Format',
              ),
              items: imageProvider.formatList.map((format) {
                return DropdownMenuItem(
                  value: format,
                  child: Text(format.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (format) {
                imageProvider.setSelectedFormat(format!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
