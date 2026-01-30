import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:imgify/constants/external_links.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = ExternalLinks.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<Uint8List> convertImage(File image, String format) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path, filename: fileName),
        'format': format,
      });

      final response = await _dio.post(
        '${ExternalLinks.baseUrl}/convert',
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      return Uint8List.fromList(response.data);
    } catch (e) {
      throw Exception('Failed to convert image');
    }
  }

  Future<Uint8List> resizeImage({
    required File image,
    int? width,
    int? height,
    bool maintainAspectRatio = true,
  }) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path, filename: fileName),
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        'maintainAspectRatio': maintainAspectRatio,
      });

      final response = await _dio.post(
        '${ExternalLinks.baseUrl}/resize',
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      return Uint8List.fromList(response.data);
    } catch (e) {
      throw Exception('Failed to resize image');
    }
  }

  Future<Uint8List> compressImage({
    required File image,
    required int quality,
    String? format,
  }) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path, filename: fileName),
        'quality': quality,
        if (format != null) 'format': format,
      });

      final response = await _dio.post(
        '${ExternalLinks.baseUrl}/compress',
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      return Uint8List.fromList(response.data);
    } catch (e) {
      throw Exception('Failed to compress image');
    }
  }
}
