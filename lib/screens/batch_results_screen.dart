import 'package:flutter/material.dart';
import 'package:imgify/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:imgify/models/batch_models.dart';
import 'package:imgify/providers/batch_processing_provider.dart';
import 'package:imgify/utils/gallery_saver.dart';
import 'package:imgify/widgets/my_appbar.dart';
import 'package:imgify/widgets/success_message.dart';
import 'package:imgify/widgets/error_message.dart';

class BatchResultsScreen extends StatefulWidget {
  final List<BatchImageResult> results;
  final BatchOperation operation;

  const BatchResultsScreen({
    super.key,
    required this.results,
    required this.operation,
  });

  @override
  State<BatchResultsScreen> createState() => _BatchResultsScreenState();
}

class _BatchResultsScreenState extends State<BatchResultsScreen> {
  bool _isSaving = false;

  int get _successCount => widget.results.where((r) => r.success).length;

  int get _failureCount => widget.results.where((r) => !r.success).length;

  int get _totalSavedBytes {
    int total = 0;
    for (final result in widget.results) {
      if (result.success &&
          result.originalSize != null &&
          result.processedSize != null) {
        total += (result.originalSize! - result.processedSize!);
      }
    }
    return total;
  }

  Future<void> _saveAllToGallery() async {
    setState(() => _isSaving = true);

    try {
      int savedCount = 0;
      final successfulResults =
          widget.results.where((r) => r.success && r.outputPath != null);

      for (final result in successfulResults) {
        final success = await GallerySaver.saveImage(result.outputPath!);
        if (success ?? false) {
          savedCount++;
        }
      }

      if (mounted) {
        if (savedCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            successMessageSnackBar(
              '$savedCount images saved to gallery!',
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            errorMessageSnackBar('No images could be saved'),
          );
        }
      }

      // Cleanup temp files
      if (mounted) {
        await Provider.of<BatchProcessingProvider>(context, listen: false)
            .cleanupTempFiles();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          errorMessageSnackBar('Error saving images: $e'),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _finish() {
    // Reset batch processing state
    Provider.of<BatchProcessingProvider>(context, listen: false).reset();

    // Navigate back to home (pop all batch screens)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final hasFailures = _failureCount > 0;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _finish();
        }
      },
      child: Scaffold(
        appBar: myAppbar(
          context,
          title: hasFailures ? 'Completed with Errors' : 'Batch Complete!',
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 16),
              Expanded(
                child: _buildResultsList(),
              ),
              const SizedBox(height: 16),
              if (_successCount > 0) ...[
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveAllToGallery,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : 'Save All to Gallery ($_successCount)',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              PrimaryButton(
                onTap: _finish,
                child: const Text(
                  'Finish',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: _failureCount > 0 ? Colors.orange[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              _failureCount > 0 ? Icons.warning_amber : Icons.check_circle,
              size: 48,
              color: _failureCount > 0 ? Colors.orange : Colors.green,
            ),
            const SizedBox(height: 12),
            Text(
              _failureCount > 0
                  ? 'Completed with $_failureCount errors'
                  : 'All images processed successfully! ✨',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Successful',
                  _successCount.toString(),
                  Colors.green,
                ),
                if (_failureCount > 0)
                  _buildStatItem(
                    'Failed',
                    _failureCount.toString(),
                    Colors.red,
                  ),
                if (_totalSavedBytes > 0)
                  _buildStatItem(
                    'Space Saved',
                    '${(_totalSavedBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
                    Colors.blue,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: widget.results.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final result = widget.results[index];
          return ListTile(
            leading: Icon(
              result.success ? Icons.check_circle : Icons.error,
              color: result.success ? Colors.green : Colors.red,
            ),
            title: Text(
              result.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: result.success
                ? Text(
                    'Saved ${_formatBytes(result.originalSize, result.processedSize)}',
                    style: const TextStyle(color: Colors.green),
                  )
                : Text(
                    result.errorMessage ?? 'Failed',
                    style: const TextStyle(color: Colors.red),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          );
        },
      ),
    );
  }

  String _formatBytes(int? original, int? processed) {
    if (original == null || processed == null) return '';

    final saved = original - processed;
    if (saved <= 0) return '';

    final savedMB = saved / (1024 * 1024);
    return '${savedMB.toStringAsFixed(1)} MB';
  }
}
