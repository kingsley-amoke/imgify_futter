import 'package:flutter/material.dart';
import 'package:imgify/providers/image_provider.dart';
import 'package:imgify/widgets/compression_option.dart';
import 'package:provider/provider.dart';

enum CompressionLevel { low, balanced, high }

class CompressionSettings extends StatefulWidget {
  const CompressionSettings({super.key});

  @override
  State<CompressionSettings> createState() => _CompressionSettingsState();
}

class _CompressionSettingsState extends State<CompressionSettings> {
  CompressionLevel _level = CompressionLevel.balanced;
  bool _keepMetadata = true;

  @override
  Widget build(BuildContext context) {
    final imageProvider = context.read<ImageProviderState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Compression',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        CompressionOption(
          title: 'Low',
          subtitle: 'Best quality, larger size',
          selected: _level == CompressionLevel.low,
          onTap: () => {
            imageProvider.setCompressionQuality(25),
            setState(() => _level = CompressionLevel.low)
          },
        ),
        CompressionOption(
          title: 'Balanced',
          subtitle: 'Recommended for most images',
          selected: _level == CompressionLevel.balanced,
          onTap: () => {
            imageProvider.setCompressionQuality(50),
            setState(() => _level = CompressionLevel.balanced)
          },
        ),
        CompressionOption(
          title: 'High',
          subtitle: 'Smallest size, lower quality',
          selected: _level == CompressionLevel.high,
          onTap: () => {
            imageProvider.setCompressionQuality(100),
            setState(() => _level = CompressionLevel.high)
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
}
