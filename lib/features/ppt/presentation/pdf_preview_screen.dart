import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfPreviewScreen extends StatefulWidget {
  final String url;
  const PdfPreviewScreen({super.key, required this.url});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  bool _isLoading = true;
  String? _error;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _handleError(dynamic error) {
    if (mounted) {
      setState(() {
        _hasError = true;
        if (error is UnimplementedError) {
          _error =
              'PDF viewer platform feature not available. '
              'Please ensure the app is updated and try again.';
        } else if (error is Exception) {
          _error = error.toString().replaceAll('Exception: ', '');
        } else {
          _error = error.toString();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('PDF Preview')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError || _error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PDF Preview')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load PDF',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _error ?? 'Unknown error occurred',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _hasError = false;
                      _isLoading = true;
                    });
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('PDF Preview')),
      body: Builder(
        builder: (context) {
          try {
            return SfPdfViewer.network(
              widget.url,
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                _handleError(details.error);
              },
            );
          } catch (e) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleError(e);
            });
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
