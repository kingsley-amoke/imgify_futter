import 'dart:io';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

Future<bool> shareImageToApps({
  required String filePath,
  required Uint8List image,
}) async {
  try {
    print('Sharing image at path: $filePath');
    final file = File(filePath);
    await file.writeAsBytes(image);

    final params = ShareParams(
      files: [XFile(filePath)],
    );

    final result = await SharePlus.instance.share(params);

    if (result.status == ShareResultStatus.success) {
      print('Thank you for sharing the picture!');
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print('Error sharing image: $e');
    return false;
  }
}
