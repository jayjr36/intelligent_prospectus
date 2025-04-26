import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intelligent_prospectus/controllers/gemini_provider.dart';
import 'package:pdf_gemini/pdf_gemini.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  final FlutterTts _flutterTts = FlutterTts();
  String _status = "No file uploaded yet.";
  String? _uploadedFileName;
  bool _isUploading = false;
  double _progress = 0.0;
  late File file;
  late GenaiClient _genaiClient;
  GenaiFile? _uploadedFile;

  @override
  void initState() {
    super.initState();
    // _initializeGemini();
    // _checkPermissions();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    _controller.forward();
  }

  // Future<void> _checkPermissions() async {
  //   var status = await Permission.microphone.status;
  //   if (!status.isGranted) {
  //     await Permission.microphone.request();
  //   }
  // }

  // Future<void> _initializeGemini() async {
  //   try {
  //     _genaiClient =
  //         GenaiClient(geminiApiKey: 'AIzaSyC-biuW-m-fovC5dV7gb_g52vVJ-H-hrTw');
  //     // _geminiModel = _genaiClient.getGenerativeModel(model: 'models/gemini-pro-vision');
  //     setState(() => _status = "Ready to upload your PDF.");
  //   } catch (e) {
  //     setState(() => _status = "Failed to initialize Gemini.");
  //     print('Gemini initialization error: $e');
  //   }
  // }

  // Future<void> _saveFilePath(String path) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('pdf_path', path);
  // }

  // Future<void> _uploadFile() async {
  //   final result = await FilePicker.platform
  //       .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
  //   if (result != null) {
  //     file = File(result.files.single.path!);
  //     final uploaded = await _genaiClient.genaiFileManager.uploadFile(
  //       file.path.split('/').last,
  //       'application/pdf',
  //       file.readAsBytesSync(),
  //     );
  //     setState(() {
  //       _uploadedFile = uploaded;
  //       _uploadedFileName = "Prospectus.pdf";
  //       _isUploading = false;
  //       _status = "File Uploaded Successfully!";
  //     });

  //     await _saveFilePath(file.path);

  //     _speak(_status);
  //   }
  // }

  // Future<void> _speak(String text) async {
  //   await _flutterTts.speak(text);
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GeminiProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title:
            Text("Upload File", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SlideTransition(
            position: _offsetAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            provider.status,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => provider.uploadFile(),
                            icon: Icon(Icons.upload, color: Colors.white),
                            label: Text("Upload File",
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.white.withOpacity(0.2),
                              shadowColor: Colors.black.withOpacity(0.2),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          provider.isUploading
                              ? LinearProgressIndicator(
                                  value: _progress,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue),
                                )
                              : provider.uploadedFileName != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Uploaded File: ",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        SizedBox(height: 8),
                                        Text(provider.uploadedFileName!,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                      ],
                                    )
                                  : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
