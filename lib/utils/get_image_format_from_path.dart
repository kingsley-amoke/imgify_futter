import 'package:imgify/models/image_format.dart';

ImgifyImageFormat getImageFormatFromPath(String path) {
  final extension = path.split('.').last.toLowerCase();

  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return ImgifyImageFormat.jpeg;
    case 'png':
      return ImgifyImageFormat.png;
    case 'webp':
      return ImgifyImageFormat.webp;
    case 'gif':
      return ImgifyImageFormat.gif;
    case 'bmp':
      return ImgifyImageFormat.bmp;
    case 'heic':
      return ImgifyImageFormat.heic;
    default:
      return ImgifyImageFormat.unknown;
  }
}
