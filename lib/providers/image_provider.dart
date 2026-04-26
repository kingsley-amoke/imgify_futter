import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgify/constants/image_formats.dart';
import 'package:imgify/data/api_service.dart';
import 'package:imgify/models/image_format.dart';
import 'package:imgify/providers/usage_provider.dart';
import 'package:imgify/services/ad_service.dart';
import 'package:imgify/utils/get_image_format_from_path.dart';
import 'package:imgify/utils/share_image.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/gallery_saver.dart';


class ImageProviderState extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  UsageProvider? _usageProvider;



  final List<File> _images = [];
  List<ImgifyImageFormat> formatList = List.from(presetFormats);
  File? _image;
  bool _isPicking = false;
  bool _isProcessing = false;
  double _compressionQuality = 80;
  Uint8List? _processedImage;
  int? _compressedSize;
  int? _originalSize;

  ImgifyImageFormat _selectedFormat = ImgifyImageFormat.png;

  int? _width;
  int? _height;

  int? get compressedSize => _compressedSize;
  Uint8List? get processedImage => _processedImage;
  bool get isProcessing => _isProcessing;
  double get compressionQuality => _compressionQuality;

  List<File> get images => List.unmodifiable(_images);
  File? get image => _image;
  bool get isPicking => _isPicking;
  bool get hasImages => _images.isNotEmpty;
  bool get hasImage => _image != null;
  ImgifyImageFormat get selectedFormat => _selectedFormat;
  int? get width => _width;
  int? get height => _height;

  final ApiService _apiService = ApiService();

  void updateUsageProvider(UsageProvider usageProvider) {
    _usageProvider = usageProvider;
  }

  Future<void> pickImage() async {
    _isPicking = true;
    formatList = List.from(presetFormats);
    notifyListeners();

    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        _image = File(picked.path);
        final size = await _image!.length();
        _originalSize = size;
        notifyListeners();
      }
    } finally {
      _isPicking = false;
      formatList.remove(getImageFormatFromPath(_image!.path));
      notifyListeners();
    }
  }

  Future<void> pickImages() async {
    _isPicking = true;
    notifyListeners();

    try {
      final picked = await _picker.pickMultiImage(imageQuality: 100);
      if (picked.isNotEmpty) {
        _images.addAll(picked.map((x) => File(x.path)));
        notifyListeners();
      }
    } finally {
      _isPicking = false;
      notifyListeners();
    }
  }

  Future<bool> compressImage(
      {required AdMobService adMobService, required bool isProUser}) async {
    if (_images.isEmpty && image == null) return false;

    _isProcessing = true;
    notifyListeners();
    try {
      final result = await _apiService.compressImage(
        image: image ?? images.first,
        quality: _compressionQuality.toInt(),
      );
      _processedImage = result;
      _compressedSize = result.length;
      _isProcessing = false;

      await _usageProvider?.incrementUsage();
      _isProcessing = false;
      if (!isProUser) {
        adMobService.showInterstitialAdWithFrequency();
      }

      notifyListeners();
      return true;
    } catch (e) {
      _isProcessing = false;
      if (!isProUser) {
        adMobService.showInterstitialAdWithFrequency();
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> convertImage(
      {required AdMobService adMobService, required bool isProUser}) async {
    if (_images.isEmpty && image == null) return false;

    _isProcessing = true;
    notifyListeners();

    try {
      final result = await _apiService.convertImage(
          image ?? images.first, _selectedFormat.name);

      _processedImage = result;

      await _usageProvider?.incrementUsage();
      _isProcessing = false;
      if (!isProUser) {
        adMobService.showInterstitialAdWithFrequency();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _isProcessing = false;
      if (!isProUser) {
        adMobService.showInterstitialAdWithFrequency();
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> resizeImage(
      {required AdMobService adMobService, required bool isProUser}) async {
    if (_images.isEmpty && image == null) return false;


    _isProcessing = true;
    notifyListeners();

    try {
      final result = await _apiService.resizeImage(
        image: image!,
        width: width,
        height: height,
        maintainAspectRatio: false, // Always use exact dimensions
      );

      _processedImage = result;

      await _usageProvider?.incrementUsage();
      _isProcessing = false;
      if (!isProUser) {
        adMobService.showInterstitialAdWithFrequency();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _isProcessing = false;
      if (!isProUser) {
        adMobService.showInterstitialAdWithFrequency();
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveImage({required AdMobService adMobService, required bool isProUser}) async {
    if (_processedImage == null) return false;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/imgify_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await file.writeAsBytes(_processedImage!);

      final success = await GallerySaver.saveImage(file.path);

      return success ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> shareImage() async {
    if (_processedImage == null) return false;

    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final success =
          await shareImageToApps(filePath: filePath, image: _processedImage!);
      if (!success) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  double getCompressionRatio() {
    if (_originalSize == null || _compressedSize == null) return 0;
    return (1 - (_compressedSize! / _originalSize!)) * 100;
  }

  void setCompressionQuality(double quality) {
    _compressionQuality = quality;
    notifyListeners();
  }

  void setSelectedFormat(ImgifyImageFormat format) {
    _selectedFormat = format;
    notifyListeners();
  }

  void setImageWidth(int? width) {
    _width = width;
    notifyListeners();
  }

  void setImageHeight(int? height) {
    _height = height;
    notifyListeners();
  }

  void removeAt(int index) {
    _images.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _images.clear();
    _image = null;
    _processedImage = null;
    notifyListeners();
  }

  void deleteProcessed() {
    _processedImage = null;

    notifyListeners();
  }
}
