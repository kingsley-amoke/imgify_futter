import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:imgify/models/batch_models.dart';

import 'package:imgify/services/batch_processor_service.dart';

class BatchProcessingProvider extends ChangeNotifier {
  final BatchProcessorService _processor = BatchProcessorService();

  BatchProgressState _state = const BatchProgressState();

  BatchProgressState get state => _state;

  Future<void> processBatch(BatchJob job) async {
    // Update state to processing
    _state = _state.copyWith(
      isProcessing: true,
      totalImages: job.imagePaths.length,
      currentIndex: 0,
      completedResults: [],
      isCancelled: false,
    );
    notifyListeners();

    final images = job.imagePaths.map((path) => File(path)).toList();

    // Process images one by one
    for (int i = 0; i < images.length; i++) {
      // Check if cancelled
      if (_state.isCancelled) {
        break;
      }

      final image = images[i];

      // Update current file being processed
      _state = _state.copyWith(
        currentIndex: i,
        currentFileName: image.path.split('/').last,
        currentProgress: 0.0,
      );
      notifyListeners();

      try {
        // Process the image
        final result = await _processor.processImage(
          image: image,
          operation: job.operation,
          settings: job.settings,
          onProgress: (progress) {
            // Update individual file progress
            _state = _state.copyWith(currentProgress: progress);
            notifyListeners();
          },
        );

        // Add result
        _state = _state.copyWith(
          completedResults: [..._state.completedResults, result],
        );
        notifyListeners();
      } catch (e) {
        // Add failed result
        final failedResult = BatchImageResult(
          fileName: image.path.split('/').last,
          success: false,
          errorMessage: e.toString(),
        );

        _state = _state.copyWith(
          completedResults: [..._state.completedResults, failedResult],
        );
        notifyListeners();
      }
    }

    // Mark as complete
    _state = _state.copyWith(
      isProcessing: false,
      currentIndex: job.imagePaths.length,
    );
    notifyListeners();
  }

  void cancelProcessing() {
    _state = _state.copyWith(isCancelled: true);
    notifyListeners();
  }

  void reset() {
    _state = const BatchProgressState();
    notifyListeners();
  }

  Future<void> cleanupTempFiles() async {
    await _processor.cleanupTempFiles(_state.completedResults);
  }
}
