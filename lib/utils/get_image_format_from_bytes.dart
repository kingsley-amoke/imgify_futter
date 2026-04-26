import 'dart:typed_data';

import 'package:imgify/models/image_format.dart';

ImgifyImageFormat getImageFormatFromBytes(Uint8List bytes) {
  if (bytes.length < 12) {
    return ImgifyImageFormat.unknown;
  }

  // JPEG (FF D8 FF)
  if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
    return ImgifyImageFormat.jpeg;
  }

  // PNG (89 50 4E 47)
  if (bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    return ImgifyImageFormat.png;
  }

  // GIF (47 49 46)
  if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
    return ImgifyImageFormat.gif;
  }

  // WEBP (RIFF....WEBP)
  if (bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return ImgifyImageFormat.webp;
  }

  // BMP (42 4D)
  if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
    return ImgifyImageFormat.bmp;
  }

  // TIFF (49 49 2A 00) or (4D 4D 00 2A)
  if ((bytes[0] == 0x49 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x2A &&
          bytes[3] == 0x00) ||
      (bytes[0] == 0x4D &&
          bytes[1] == 0x4D &&
          bytes[2] == 0x00 &&
          bytes[3] == 0x2A)) {
    return ImgifyImageFormat.tiff;
  }

  // HEIC (ftypheic / ftypheix / ftyphevc)
  final header = String.fromCharCodes(bytes.sublist(4, 12));
  if (header.contains('ftypheic') ||
      header.contains('ftypheix') ||
      header.contains('ftyphevc')) {
    return ImgifyImageFormat.heic;
  }

  return ImgifyImageFormat.unknown;
}
