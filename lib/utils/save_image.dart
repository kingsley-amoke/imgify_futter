import 'dart:io';
import 'dart:typed_data';
import 'package:imgify/utils/galler_saver.dart';

Future<bool> saveImageToGallery(
    {required String filePath, required Uint8List image}) async {
  try {
    final file = File(filePath);
    await file.writeAsBytes(image);
    final success = await GallerySaver.saveImage(filePath);
    return success ?? false;
  } catch (e) {
    print('Failed to save image: $e');
    return false;
  }
}
