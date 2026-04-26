import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imgify/models/batch_models.dart';
import 'package:imgify/providers/batch_processing_provider.dart';
import 'package:imgify/screens/batch_results_screen.dart';
import 'package:imgify/widgets/my_appbar.dart';

class BatchProcessingScreen extends StatefulWidget {
  final BatchJob job;

  const BatchProcessingScreen({
    super.key,
    required this.job,
  });

  @override
  State<BatchProcessingScreen> createState() => _BatchProcessingScreenState();
}

class _BatchProcessingScreenState extends State<BatchProcessingScreen> {
  @override
  void initState() {
    super.initState();

    // Start processing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BatchProcessingProvider>(context, listen: false)
          .processBatch(widget.job);
    });
  }

  void _cancelProcessing() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Processing?'),
        content: const Text(
          'Are you sure you want to cancel? '
          'Already processed images will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Processing'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<BatchProcessingProvider>(context, listen: false)
                  .cancelProcessing();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BatchProcessingProvider>(
      builder: (context, batchProvider, child) {
        final progressState = batchProvider.state;

        // Navigate to results when complete
        if (!progressState.isProcessing &&
            progressState.currentIndex == widget.job.imagePaths.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BatchResultsScreen(
                    results: progressState.completedResults,
                    operation: widget.job.operation,
                  ),
                ),
              );
            }
          });
        }

        return PopScope(
          canPop: !progressState.isProcessing,
          onPopInvoked: (didPop) {
            if (!didPop && progressState.isProcessing) {
              _cancelProcessing();
            }
          },
          child: Scaffold(
            appBar: myAppbar(
              context,
              title: 'Processing Images',
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildOverallProgress(progressState),
                  const SizedBox(height: 24),
                  if (progressState.currentFileName != null)
                    _buildCurrentFileProgress(progressState),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _buildFileList(progressState),
                  ),
                  const SizedBox(height: 16),
                  if (progressState.isProcessing)
                    OutlinedButton(
                      onPressed: _cancelProcessing,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Cancel Processing'),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverallProgress(BatchProgressState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overall Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${state.currentIndex}/${state.totalImages}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: state.overallProgress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 8),
            Text(
              '${(state.overallProgress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentFileProgress(BatchProgressState state) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Processing: ${state.currentFileName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: state.currentProgress,
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileList(BatchProgressState state) {
    return Card(
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: widget.job.imagePaths.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final fileName = widget.job.imagePaths[index].split('/').last;
          final isComplete = index < state.completedResults.length;
          final isCurrent = index == state.currentIndex;
          final isWaiting = index > state.currentIndex;

          BatchImageResult? result;
          if (isComplete) {
            result = state.completedResults[index];
          }

          return ListTile(
            leading: _buildStatusIcon(
              isComplete: isComplete,
              isCurrent: isCurrent,
              isWaiting: isWaiting,
              success: result?.success,
            ),
            title: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: _buildSubtitle(
              isComplete: isComplete,
              isCurrent: isCurrent,
              isWaiting: isWaiting,
              result: result,
            ),
            trailing: result != null && result.success
                ? Text(
                    _formatFileSize(result.originalSize, result.processedSize),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon({
    required bool isComplete,
    required bool isCurrent,
    required bool isWaiting,
    bool? success,
  }) {
    if (isComplete) {
      return Icon(
        success == true ? Icons.check_circle : Icons.error,
        color: success == true ? Colors.green : Colors.red,
      );
    } else if (isCurrent) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      return const Icon(
        Icons.schedule,
        color: Colors.grey,
      );
    }
  }

  Widget? _buildSubtitle({
    required bool isComplete,
    required bool isCurrent,
    required bool isWaiting,
    BatchImageResult? result,
  }) {
    if (isComplete && result != null) {
      if (result.success) {
        return const Text(
          'Complete',
          style: TextStyle(color: Colors.green),
        );
      } else {
        return Text(
          result.errorMessage ?? 'Failed',
          style: const TextStyle(color: Colors.red),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }
    } else if (isCurrent) {
      return const Text(
        'Processing...',
        style: TextStyle(color: Colors.blue),
      );
    } else {
      return const Text(
        'Waiting...',
        style: TextStyle(color: Colors.grey),
      );
    }
  }

  String _formatFileSize(int? original, int? processed) {
    if (original == null || processed == null) return '';

    final saved = original - processed;
    final savedMB = saved / (1024 * 1024);

    return saved > 0 ? '-${savedMB.toStringAsFixed(1)}MB' : '';
  }
}
