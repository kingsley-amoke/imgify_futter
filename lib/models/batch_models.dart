enum BatchOperation {
  compress,
  resize,
  convert,
}

enum BatchStatus {
  pending,
  processing,
  completed,
  cancelled,
  failed,
}

class BatchJob {
  final String id;
  final List<String> imagePaths;
  final BatchOperation operation;
  final Map<String, dynamic> settings;
  final BatchStatus status;
  final List<BatchImageResult> results;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const BatchJob({
    required this.id,
    required this.imagePaths,
    required this.operation,
    required this.settings,
    this.status = BatchStatus.pending,
    this.results = const [],
    this.startedAt,
    this.completedAt,
  });

  BatchJob copyWith({
    String? id,
    List<String>? imagePaths,
    BatchOperation? operation,
    Map<String, dynamic>? settings,
    BatchStatus? status,
    List<BatchImageResult>? results,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return BatchJob(
      id: id ?? this.id,
      imagePaths: imagePaths ?? this.imagePaths,
      operation: operation ?? this.operation,
      settings: settings ?? this.settings,
      status: status ?? this.status,
      results: results ?? this.results,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class BatchImageResult {
  final String fileName;
  final bool success;
  final String? errorMessage;
  final int? originalSize;
  final int? processedSize;
  final String? outputPath;

  const BatchImageResult({
    required this.fileName,
    required this.success,
    this.errorMessage,
    this.originalSize,
    this.processedSize,
    this.outputPath,
  });

  BatchImageResult copyWith({
    String? fileName,
    bool? success,
    String? errorMessage,
    int? originalSize,
    int? processedSize,
    String? outputPath,
  }) {
    return BatchImageResult(
      fileName: fileName ?? this.fileName,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
      originalSize: originalSize ?? this.originalSize,
      processedSize: processedSize ?? this.processedSize,
      outputPath: outputPath ?? this.outputPath,
    );
  }
}

class BatchProgressState {
  final int currentIndex;
  final int totalImages;
  final String? currentFileName;
  final double currentProgress;
  final bool isProcessing;
  final bool isCancelled;
  final List<BatchImageResult> completedResults;

  const BatchProgressState({
    this.currentIndex = 0,
    this.totalImages = 0,
    this.currentFileName,
    this.currentProgress = 0.0,
    this.isProcessing = false,
    this.isCancelled = false,
    this.completedResults = const [],
  });

  double get overallProgress =>
      totalImages > 0 ? currentIndex / totalImages : 0.0;

  int get successCount => completedResults.where((r) => r.success).length;

  int get failureCount => completedResults.where((r) => !r.success).length;

  BatchProgressState copyWith({
    int? currentIndex,
    int? totalImages,
    String? currentFileName,
    double? currentProgress,
    bool? isProcessing,
    bool? isCancelled,
    List<BatchImageResult>? completedResults,
  }) {
    return BatchProgressState(
      currentIndex: currentIndex ?? this.currentIndex,
      totalImages: totalImages ?? this.totalImages,
      currentFileName: currentFileName ?? this.currentFileName,
      currentProgress: currentProgress ?? this.currentProgress,
      isProcessing: isProcessing ?? this.isProcessing,
      isCancelled: isCancelled ?? this.isCancelled,
      completedResults: completedResults ?? this.completedResults,
    );
  }
}
