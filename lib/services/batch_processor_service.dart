import 'dart:io';
import 'package:imgify/data/api_service.dart';
import 'package:imgify/models/batch_models.dart';
import 'package:imgify/utils/get_image_format_from_bytes.dart';
import 'package:path_provider/path_provider.dart';

class BatchProcessorService {
  final ApiService _apiService = ApiService();

  Future<BatchImageResult> processImage({
    required File image,
    required BatchOperation operation,
    required Map<String, dynamic> settings,
    Function(double)? onProgress,
  }) async {
    try {
      final originalSize = await image.length();

      // Report start
      onProgress?.call(0.0);

      // Process based on operation type
      dynamic result;
      switch (operation) {
        case BatchOperation.compress:
          result = await _apiService.compressImage(
            image: image,
            quality: settings['quality'] as int,
          );
          onProgress?.call(0.5);
          break;

        case BatchOperation.resize:
          result = await _apiService.resizeImage(
            image: image,
            width: settings['width'] as int?,
            height: settings['height'] as int?,
            maintainAspectRatio: false,
          );
          onProgress?.call(0.5);
          break;

        case BatchOperation.convert:
          result = await _apiService.convertImage(
            image,
            settings['format'] as String,
          );
          onProgress?.call(0.5);
          break;
      }

      // Report complete
      onProgress?.call(1.0);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final fileName =
          'batch_$timestamp.${getImageFormatFromBytes(result).name}';

      // Save the result to temp file
      final tempDir = await getTemporaryDirectory();

      final outputPath = '${tempDir.path}/$fileName';
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(result);

      final processedSize = result.length as int;

      return BatchImageResult(
        fileName: fileName,
        success: true,
        originalSize: originalSize,
        processedSize: processedSize,
        outputPath: outputPath,
      );
    } catch (e) {
      return BatchImageResult(
        fileName: image.path.split('/').last,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> cleanupTempFiles(List<BatchImageResult> results) async {
    for (final result in results) {
      if (result.outputPath != null) {
        try {
          final file = File(result.outputPath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error cleaning up file: $e');
        }
      }
    }
  }
}
