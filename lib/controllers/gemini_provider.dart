import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intelligent_prospectus/secrets.dart';
import 'package:pdf_gemini/pdf_gemini.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class GeminiProvider extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  late GenaiClient _genaiClient;
  GenaiFile? uploadedFile;
  String status = "Initializing...";
  String? uploadedFilePath;
  String? uploadedFileName;
  bool isCancelled = false;
  String? spokenText;
  bool get isUploading => _isUploading;

  set isUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  bool _isUploading = false;

  GeminiProvider() {
    initialize();
  }

  Future<void> initialize() async {
    await _checkPermissions();
    await _initializeGemini();
    await _loadFilePath();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  void stopInteraction() {
    isCancelled = true;
    _tts.stop();
    status = "Response cancelled.";
    spokenText = "";
  }

  Future<void> _initializeGemini() async {
    try {
      _genaiClient = GenaiClient(geminiApiKey: AppSecrets.password);
      status = "Ready to upload your PDF.";
    } catch (e) {
      status = "Failed to initialize Gemini.";
      debugPrint('Gemini initialization error: \$e');
    }
    notifyListeners();
  }

  Future<void> uploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      final file = File(result.files.single.path!);
      final uploaded = await _genaiClient.genaiFileManager.uploadFile(
        file.path.split('/').last,
        'application/pdf',
        file.readAsBytesSync(),
      );
      uploadedFile = uploaded;
      uploadedFilePath = file.path;
      uploadedFileName = "Prospectus.pdf";
      status = "File Uploaded Successfully!";
      await _saveFilePath(file.path);
      await speak(status);
      notifyListeners();
    }
  }

  Future<void> _saveFilePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pdf_path', path);
  }

  Future<void> _loadFilePath() async {
    final prefs = await SharedPreferences.getInstance();
    uploadedFilePath = prefs.getString('pdf_path');
    if (uploadedFilePath != null) {
      status = "PDF loaded from local storage.";
    }
    notifyListeners();
  }

  Future<File?> getFileFromPreferences() async {
    if (uploadedFilePath != null) {
      return File(uploadedFilePath!);
    }
    return null;
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  Future<String?> askQuestion(String question) async {
    final file = await getFileFromPreferences();
    if (file == null || uploadedFile == null) {
      status = "Please upload a PDF first.";
      notifyListeners();
      return null;
    }

    status = "Gemini is thinking...";
    notifyListeners();

    try {
      final response = await _genaiClient.promptDocument(
        uploadedFile!.displayName,
        uploadedFile!.mimeType,
        file.readAsBytesSync(),
        "$question. Please give a brief and direct answer.",
      );
      status = "Answer received.";
      if (isCancelled) return "Cancelled.";
      notifyListeners();
      spokenText = response.text;
      await speak(response.text);

      return response.text;
    } catch (e) {
      status = "Failed to get answer.";
      notifyListeners();
      debugPrint("Gemini error: \$e");
      await speak("Sorry, I couldn't understand that.");
      return null;
    }
  }

  void startVoiceQuestion() async {
    bool available = await _speech.initialize();
    if (available) {
      status = "Listening for your question...";
      _speech.listen(onResult: (result) {
        final question = result.recognizedWords;
        if (question.isNotEmpty) {
          askQuestion(question);
        }
      });
    } else {
      status = "Voice recognition not available.";
    }
  }
}
