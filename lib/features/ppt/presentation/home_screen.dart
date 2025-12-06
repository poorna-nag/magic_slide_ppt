import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic_slide_ppt/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:magic_slide_ppt/features/auth/presentation/bloc/auth_event.dart';
import 'package:magic_slide_ppt/features/ppt/presentation/bloc/presentation_bloc.dart';
import 'package:magic_slide_ppt/features/ppt/presentation/bloc/presentation_event.dart';
import 'package:magic_slide_ppt/features/ppt/presentation/bloc/presentation_state.dart';
import 'package:magic_slide_ppt/features/ppt/presentation/pdf_preview_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final String email;
  const HomeScreen({super.key, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _topicController = TextEditingController();
  final _presentationForController = TextEditingController();
  final _watermarkWidthController = TextEditingController();
  final _watermarkHeightController = TextEditingController();
  final _watermarkBrandUrlController = TextEditingController();

  late String loggedInEmail;
  String _templateCategory = 'default';
  String _template = 'bullet-point1';
  int _slideCount = 10;
  String _language = 'en';
  bool _aiImages = false;
  bool _imageForEachSlide = true;
  bool _googleImage = false;
  bool _googleText = false;
  String _model = 'gpt-4';
  String _watermarkPosition = 'BottomRight';
  bool _showWatermark = false;

  String? _pptUrl;
  String? _pdfUrl;

  static const List<String> defaultTemplates = [
    'bullet-point1',
    'bullet-point2',
    'bullet-point4',
    'bullet-point5',
    'bullet-point6',
    'bullet-point7',
    'bullet-point8',
    'bullet-point9',
    'bullet-point10',
    'custom2',
    'custom3',
    'custom4',
    'custom5',
    'custom6',
    'custom7',
    'custom8',
    'custom9',
    'verticalBulletPoint1',
    'verticalCustom1',
  ];

  static const List<String> editableTemplates = [
    'ed-bullet-point1',
    'ed-bullet-point2',
    'ed-bullet-point4',
    'ed-bullet-point5',
    'ed-bullet-point6',
    'ed-bullet-point7',
    'ed-bullet-point9',
    'custom gold 1',
    'custom Dark 1',
    'custom sync 1',
    'custom sync 2',
    'custom sync 3',
    'custom sync 4',
    'custom sync 5',
    'custom sync 6',
    'custom-ed-7',
    'custom-ed-8',
    'custom-ed-9',
    'custom-ed-10',
    'custom-ed-11',
    'custom-ed-12',
    'pitchdeckorignal',
    'pitch-deck-2',
    'pitch-deck-3',
  ];

  static const List<String> languages = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'zh',
    'ja',
    'ko',
    'ar',
  ];

  static const List<String> watermarkPositions = [
    'TopLeft',
    'TopRight',
    'BottomLeft',
    'BottomRight',
    'Center',
  ];

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    loggedInEmail = user?.email ?? '';
  }

  @override
  void dispose() {
    _topicController.dispose();
    _presentationForController.dispose();
    _watermarkWidthController.dispose();
    _watermarkHeightController.dispose();
    _watermarkBrandUrlController.dispose();
    super.dispose();
  }

  List<String> get _availableTemplates {
    return _templateCategory == 'default'
        ? defaultTemplates
        : editableTemplates;
  }

  Future<void> _downloadFile(String url, String extension) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Downloading..."),
            duration: Duration(seconds: 1),
          ),
        );
      }

      Directory? dir = await DownloadsPathProvider.downloadsDirectory;

      if (Platform.isAndroid && dir == null) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Storage permission is required to download files. Please grant permission in settings.",
                ),
                duration: Duration(seconds: 4),
              ),
            );
          }
          return;
        }
        dir = await DownloadsPathProvider.downloadsDirectory;
      }

      if (dir == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Cannot access Downloads folder. Please check app permissions in device settings.",
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      final fileName =
          "MagicSlides_${DateTime.now().millisecondsSinceEpoch}.$extension";
      final file = File("${dir.path}/$fileName");

      await Dio().download(url, file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Downloaded successfully: $fileName"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Download failed: ${e.toString()}"),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _openPPTX(String url) async {
    try {
      final uri = Uri.parse(url);

      if (kIsWeb) {
        // For web, open in new tab/window
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } else if (Platform.isAndroid) {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          try {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          } catch (e2) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cannot open URL. Error: ${e2.toString()}'),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        }
      } else {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cannot open URL. Please check your settings.'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open URL: $e'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Map<String, dynamic> _buildApiOptions() {
    final options = <String, dynamic>{
      'template': _template,
      'language': _language,
      'slideCount': _slideCount,
      'aiImages': _aiImages,
      'imageForEachSlide': _imageForEachSlide,
      'googleImage': _googleImage,
      'googleText': _googleText,
      'model': _model,
    };

    if (_presentationForController.text.trim().isNotEmpty) {
      options['presentationFor'] = _presentationForController.text.trim();
    }

    if (_showWatermark && _watermarkBrandUrlController.text.trim().isNotEmpty) {
      options['watermark'] = {
        if (_watermarkWidthController.text.trim().isNotEmpty)
          'width': _watermarkWidthController.text.trim(),
        if (_watermarkHeightController.text.trim().isNotEmpty)
          'height': _watermarkHeightController.text.trim(),
        'brandURL': _watermarkBrandUrlController.text.trim(),
        'position': _watermarkPosition,
      };
    }

    return options;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: const Text("MagicSlides", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.login_rounded, color: Colors.white),
            onPressed: () => context.read<AuthBloc>().add(AuthLogout()),
          ),
        ],
      ),
      body: BlocConsumer<PresentationBloc, PresentationState>(
        listener: (context, state) {
          if (state is PresentationError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is PresentationSuccess) {
            setState(() {
              _pptUrl = state.pptUrl;
              _pdfUrl = state.pdfUrl;
            });
          }
        },
        builder: (context, state) {
          if (_pptUrl != null || _pdfUrl != null) return _generatedScreen();

          return _inputUI(state);
        },
      ),
    );
  }

  Widget _inputUI(PresentationState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter Topic",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _topicController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Enter your topic...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Template Type",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text("Default Template"),
                        value: 'default',
                        groupValue: _templateCategory,
                        onChanged: (value) {
                          setState(() {
                            _templateCategory = value!;
                            _template = _availableTemplates.first;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text("Editable Template"),
                        value: 'editable',
                        groupValue: _templateCategory,
                        onChanged: (value) {
                          setState(() {
                            _templateCategory = value!;
                            _template = _availableTemplates.first;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Presentation Settings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _template,
                    decoration: InputDecoration(
                      labelText: "Template",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _availableTemplates
                        .map(
                          (template) => DropdownMenuItem(
                            value: template,
                            child: Text(template),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _template = v!),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Text(
                        "Slide Count",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Slider(
                          min: 1,
                          max: 50,
                          divisions: 49,
                          value: _slideCount.toDouble(),
                          onChanged: (v) =>
                              setState(() => _slideCount = v.toInt()),
                        ),
                      ),
                      Text(
                        "$_slideCount",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _language,
                    decoration: InputDecoration(
                      labelText: "Language",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: languages
                        .map(
                          (lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(lang.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _language = v!),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _model,
                    decoration: InputDecoration(
                      labelText: "Model",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'gpt-4', child: Text('GPT-4')),
                      DropdownMenuItem(
                        value: 'gpt-3.5',
                        child: Text('GPT-3.5'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _model = v!),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _presentationForController,
                    decoration: InputDecoration(
                      labelText: "Presentation For (optional)",
                      hintText: "e.g., student, teacher, business",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Image Settings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _aiImages,
                    title: const Text("AI Images"),
                    subtitle: const Text("Generate AI artwork for slides"),
                    onChanged: (v) => setState(() => _aiImages = v),
                  ),
                  SwitchListTile(
                    value: _imageForEachSlide,
                    title: const Text("Image on Each Slide"),
                    subtitle: const Text("Add image to every slide"),
                    onChanged: (v) => setState(() => _imageForEachSlide = v),
                  ),
                  SwitchListTile(
                    value: _googleImage,
                    title: const Text("Google Images"),
                    subtitle: const Text("Use Google Images"),
                    onChanged: (v) => setState(() => _googleImage = v),
                  ),
                  SwitchListTile(
                    value: _googleText,
                    title: const Text("Google Text"),
                    subtitle: const Text("Use Google Text"),
                    onChanged: (v) => setState(() => _googleText = v),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Watermark (Optional)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: _showWatermark,
                        onChanged: (v) => setState(() => _showWatermark = v),
                      ),
                    ],
                  ),
                  if (_showWatermark) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _watermarkWidthController,
                      decoration: InputDecoration(
                        labelText: "Width",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _watermarkHeightController,
                      decoration: InputDecoration(
                        labelText: "Height",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _watermarkBrandUrlController,
                      decoration: InputDecoration(
                        labelText: "Brand URL",
                        hintText: "https://example.com/logo.png",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _watermarkPosition,
                      decoration: InputDecoration(
                        labelText: "Position",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: watermarkPositions
                          .map(
                            (pos) =>
                                DropdownMenuItem(value: pos, child: Text(pos)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _watermarkPosition = v!),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: state is PresentationLoading
                  ? null
                  : () {
                      if (_topicController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter a topic")),
                        );
                        return;
                      }

                      context.read<PresentationBloc>().add(
                        GeneratePresentation(
                          _topicController.text.trim(),
                          loggedInEmail,
                          _buildApiOptions(),
                        ),
                      );
                    },
              child: state is PresentationLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Generate Presentation",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _generatedScreen() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle, color: Colors.green, size: 110),
        const SizedBox(height: 20),
        const Text(
          "Presentation Ready!",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),

        if (_pdfUrl != null && _pdfUrl!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Preview PDF"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PdfPreviewScreen(url: _pdfUrl!),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 55),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (_pptUrl != null && _pptUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text("Download PPTX"),
              onPressed: () => _downloadFile(_pptUrl!, 'pptx'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
              ),
            ),
          ),

        if (_pdfUrl != null && _pdfUrl!.isNotEmpty) ...[
          if (_pptUrl != null && _pptUrl!.isNotEmpty)
            const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text("Download PDF"),
              onPressed: () => _downloadFile(_pdfUrl!, 'pdf'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 55),
              ),
            ),
          ),
        ],

        const SizedBox(height: 12),

        if (_pptUrl != null && _pptUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text("Open PPTX in Browser"),
              onPressed: () => _openPPTX(_pptUrl!),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
              ),
            ),
          ),

        if (_pdfUrl != null && _pdfUrl!.isNotEmpty) ...[
          if (_pptUrl != null && _pptUrl!.isNotEmpty)
            const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text("Open PDF in Browser"),
              onPressed: () => _openPPTX(_pdfUrl!),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
              ),
            ),
          ),
        ],

        const Spacer(),

        TextButton(
          onPressed: () => setState(() {
            _pptUrl = null;
            _pdfUrl = null;
          }),
          child: const Text("Generate Another"),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}
