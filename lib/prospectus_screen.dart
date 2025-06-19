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
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ProspectusHomePage extends StatefulWidget {
  const ProspectusHomePage({super.key});

  @override
  _ProspectusHomePageState createState() => _ProspectusHomePageState();
}

class _ProspectusHomePageState extends State<ProspectusHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _textController = TextEditingController();

  bool _isCancelled = false;

  // late GenerativeModel _geminiModel;
  late GenaiClient _genaiClient;
  // GenaiFile? _uploadedFile;

  String _status = "Upload a university prospectus PDF";
  String _spokenText = "";

  // late File file;

  @override
  void initState() {
    super.initState();
    // _initializeGemini();
    // _checkPermissions();
    _tts.speak("Welcome to the Digital Prospectus.");
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

//   Future<void> _checkPermissions() async {
//     var status = await Permission.microphone.status;
//     if (!status.isGranted) {
//       await Permission.microphone.request();
//     }
//   }

//   Future<void> _initializeGemini() async {
//     try {
//       _genaiClient =
//           GenaiClient(geminiApiKey: 'AIzaSyC-biuW-m-fovC5dV7gb_g52vVJ-H-hrTw');
//       // _geminiModel = _genaiClient.getGenerativeModel(model: 'models/gemini-pro-vision');
//       setState(() => _status = "Ready to upload your PDF.");
//     } catch (e) {
//       setState(() => _status = "Failed to initialize Gemini.");
//       print('Gemini initialization error: $e');
//     }
//   }

//   // Future<void> _uploadPdf() async {
//   //   final result = await FilePicker.platform
//   //       .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
//   //   if (result != null) {
//   //     file = File(result.files.single.path!);
//   //     final uploaded = await _genaiClient.genaiFileManager.uploadFile(
//   //       file.path.split('/').last,
//   //       'application/pdf',
//   //       file.readAsBytesSync(),
//   //     );
//   //     setState(() {
//   //       _uploadedFile = uploaded;
//   //       _status = "PDF uploaded successfully. You can now ask questions.";
//   //     });
//   //   }
//   // }

//   Future<File?> _getFileFromPreferences() async {
//   final prefs = await SharedPreferences.getInstance();
//   String? filePath = prefs.getString('pdf_path');
  
//   if (filePath != null) {
//         setState(() {
//         // _uploadedFile = GenaiFile(name: name, displayName: displayName, mimeType: mimeType, sizeBytes: sizeBytes, createTime: createTime, updateTime: updateTime, expirationTime: expirationTime, sha256Hash: sha256Hash, uri: uri, state: state);
//         _status = "PDF uploaded successfully. You can now ask questions.";
//       });
//     return File(filePath); // Convert the string path back to a File object
//   }
  
//   return null;
// }

//   Future<void> _askGemini(String question) async {
//     final file = await _getFileFromPreferences();

//     if (file == null) {
//       setState(() => _status = "Please upload a PDF first.");
//       return;
//     }

//     _isCancelled = false; // Reset cancel flag
//     setState(() {
//       _status = "Gemini is thinking...";
//       _spokenText = "";
//     });

//     try {
//       final conciseQuestion =
//           "$question. Please give a brief and direct answer.";
//       final response = await _genaiClient.promptDocument(
//         _uploadedFile!.displayName,
//         _uploadedFile!.mimeType,
//         file.readAsBytesSync(),
//         conciseQuestion,
//       );

//       if (_isCancelled) return; // Ignore if canceled mid-way

//       setState(() {
//         _spokenText = response.text;
//         _status = "Answer received.";
//       });

//       await _tts.speak(response.text);
//     } catch (e) {
//       if (!_isCancelled) {
//         print("Gemini error: $e");
//         setState(() {
//           _spokenText = "An error occurred.";
//           _status = "Failed to get answer.";
//         });
//         await _tts.speak("Sorry, I couldn't understand that.");
//       }
//     }
//   }

//   void stopInteraction() {
//     _isCancelled = true;
//     _tts.stop();
//     setState(() {
//       _status = "Response cancelled.";
//       _spokenText = "";
//     });
//   }

//   Future<String?> _loadFilePath() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('pdf_path');
// }

//   void _submitTextQuestion() {
//     final question = _textController.text.trim();
//     if (question.isNotEmpty) {
//       _askGemini(question);
//     }
//   }

//   void _startVoiceQuestion() async {
//     bool available = await _speech.initialize();
//     if (available) {
//       setState(() => _status = "Listening for your question...");
//       _speech.listen(onResult: (result) {
//         final question = result.recognizedWords;
//         if (question.isNotEmpty) {
//           _askGemini(question);
//         }
//       });
//     } else {
//       setState(() => _status = "Voice recognition not available.");
//     }
//   }

  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
     final provider = Provider.of<GeminiProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Digital Prospectus",
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => provider.startVoiceQuestion(),
        onDoubleTap: () => provider.askQuestion(_textController.text),
        child: Container(
          height: h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade900, Colors.blue.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SlideTransition(
            position: _offsetAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    height: h,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                         provider.status,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          // _glassButton(Icons.upload, "Upload PDF", _uploadPdf,
                              // Colors.white),
                          // const SizedBox(height: 12),
                         
                          // TextField(
                          //   controller: _textController,
                          //   style: TextStyle(color: Colors.white),
                          //   decoration: InputDecoration(
                          //     filled: true,
                          //     fillColor: Colors.white.withOpacity(0.1),
                          //     labelText: "Type your question",
                          //     labelStyle: TextStyle(color: Colors.white),
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(12),
                          //     ),
                          //     prefixIcon:
                          //         Icon(Icons.text_fields, color: Colors.white),
                          //   ),
                          // ),
                          // const SizedBox(height: 12),
                          // _glassButton(
                          //     Icons.send,
                          //     "Ask with Text",
                          //     () => provider.askQuestion(_textController.text),
                          //     // _uploadedFile != null
                          //         //  _submitTextQuestion,
                          //         // : null,
                          //     Colors.white),
                          // const SizedBox(height: 12),
                          // _glassButton(Icons.cancel, "Cancel", ()=> provider.stopInteraction(),
                          //     Colors.redAccent),
                          // const SizedBox(height: 24),
                           Center(
                             child: _roundGlassButton(
                                Icons.mic,
                                "",
                                // _uploadedFile != null
                                    () => provider.startVoiceQuestion(),
                                    // : null,
                                Colors.white),
                           ),
                          const SizedBox(height: 12),
                          if (_spokenText.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Answer:",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Text(provider.spokenText ?? "",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ],
                              ),
                            ),
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

  Widget _glassButton(
      IconData icon, String label, VoidCallback? onPressed, Color color) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Colors.white.withOpacity(0.2),
        shadowColor: Colors.black.withOpacity(0.2),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  Widget _roundGlassButton(
    IconData icon, String label, VoidCallback? onPressed, Color color) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, color: color),
    label: Text(label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500)),
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 40),
      backgroundColor: Colors.white.withOpacity(0.2),
      shadowColor: Colors.black.withOpacity(0.2),
      elevation: 4,
      shape: CircleBorder(), // Circular button shape
    ),
  );
}

}
