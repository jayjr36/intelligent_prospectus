import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intelligent_prospectus/secrets.dart';
import 'package:pdf_gemini/pdf_gemini.dart';
import 'package:http/http.dart' as http;
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
  final String _prefsKey = 'cached_prospectus_base64';
  final String apiKey = AppSecrets.password;
  final String pdfUrl =
      'https://drive.google.com/uc?export=download&id=11y9W7fwqhStUVdD3fWVSIZETqk1eOdLE';
  final String _questionCacheKey = 'cached_question_responses';
  Map<String, String> _questionCache = {};

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
    await _loadQuestionCache();
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
      _getCachedBase64Pdf();
    } catch (e) {
      status = "Failed to initialize Gemini.";
      debugPrint('Gemini initialization error: \$e');
    }
    notifyListeners();
  }

  Future<void> _loadQuestionCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString(_questionCacheKey);
    if (cacheJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(cacheJson);
      _questionCache =
          decoded.map((key, value) => MapEntry(key, value.toString()));
    }
  }

  Future<void> _saveQuestionCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = jsonEncode(_questionCache);
    await prefs.setString(_questionCacheKey, cacheJson);
  }

  Future<void> uploadFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      final file = File(result.files.single.path!);
      try {
        final result =
            await InternetAddress.lookup('generativelanguage.googleapis.com');
        print('Lookup successful: $result');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Host unreachable. Please check your internet connection.")),
        );
        print('DNS resolution failed: $e');
      }
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
    status = "Analyzing...";
    if (_questionCache.containsKey(question)) {
      final cachedAnswer = _questionCache[question];
      spokenText = cachedAnswer;
      status = "Answer retrieved.";
      notifyListeners();
      await speak(cachedAnswer!);
      return cachedAnswer;
    }
    notifyListeners();
    try {
      final base64Pdf = await _getCachedBase64Pdf();
      if (base64Pdf == null || base64Pdf.isEmpty) {
        status =
            "No PDF prospectus found. Please connect internet and restart your application.";
        notifyListeners();
        return null;
      }

      final prompt = '''
        You are an academic assistant. Answer the following question using only the university prospectus provided. Do not use outside information. Be brief, specific and precise to the question asked.

        Question: $question
        ''';

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      );

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "inline_data": {
                  "mime_type": "application/pdf",
                  "data": base64Pdf,
                }
              },
              {"text": prompt}
            ]
          }
        ]
      });

      final response = await http.post(url, headers: headers, body: body);
      debugPrint("Gemini API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data["candidates"][0]["content"]["parts"][0]["text"];
        status = "Answer received.";
        if (isCancelled) return "Cancelled.";
        notifyListeners();
        spokenText = answer;
        _questionCache[question] = answer;
        await _saveQuestionCache();
        await speak(answer);
        return answer;
      } else {
        throw Exception('Gemini API Error: ${response.body}');
      }
    } catch (e) {
      status = "Failed to get answer.";
      notifyListeners();
      debugPrint("Gemini error: $e");
      await speak("Sorry, I couldn't understand that.");
      return null;
    }
  }

  Future<String> _getCachedBase64Pdf() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_prefsKey);

    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // Download the PDF
    final response = await http.get(Uri.parse(pdfUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download PDF');
    }

    final base64Data = base64Encode(response.bodyBytes);
    await prefs.setString(_prefsKey, base64Data);
    return base64Data;
  }
  // Future<String?> askQuestion(String question) async {
  //   final file = await getFileFromPreferences();
  //   if (file == null || uploadedFile == null) {
  //     status = "Please upload a PDF first.";
  //     notifyListeners();
  //     return null;
  //   }

  //   status = "Analyzing...";
  //   notifyListeners();

  //   try {
  //     final response = await _genaiClient.promptDocument(
  //       uploadedFile!.displayName,
  //       uploadedFile!.mimeType,
  //       file.readAsBytesSync(),
  //       "$question. Please give a brief and direct answer.",
  //     );
  //     status = "Answer received.";
  //     if (isCancelled) return "Cancelled.";
  //     notifyListeners();
  //     spokenText = response.text;
  //     await speak(response.text);

  //     return response.text;
  //   } catch (e) {
  //     status = "Failed to get answer.";
  //     notifyListeners();
  //     debugPrint("Gemini error: \$e");
  //     await speak("Sorry, I couldn't understand that.");
  //     return null;
  //   }
  // }

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
