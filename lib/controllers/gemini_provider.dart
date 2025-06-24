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
import 'package:dio/dio.dart';

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
    await _addHardcodedQuestionsToCache();
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
      status = "Prospectus not loaded.";
      _getCachedBase64Pdf();
    } catch (e) {
      status = "Failed to initialize Gemini.";
      debugPrint('Gemini initialization error: \$e');
    }
    notifyListeners();
  }

  // New method to hardcode questions and answers
  Future<void> _addHardcodedQuestionsToCache() async {
    final Map<String, String> hardcodedQuestions = {
      "which academic programs are offered":
          "Dar es Salaam Institute of Technology (DIT) offers a wide range of programs, including certificates, ordinary diplomas, bachelor's, and master's degrees in various fields such as maintenance management, computing and communications technology, computational science and engineering, sustainable energy engineering, civil engineering, computer engineering, electrical engineering, mechanical engineering, science and laboratory technology, oil and gas engineering, information technology, mining engineering, biomedical equipment engineering, communication system technology, renewable energy technology, multimedia and film technology, biotechnology, leather products and allied technologies, and food science and technology.  In addition, DIT offers vocational training programs at the National Vocational Award (NVA) levels 1-3. as detailed in Chapter Two.",
      "what are the admission requirements":
          "The Dar es Salaam Institute of Technology (DIT) admission requirements vary depending on the program level (NVA levels 1-3, NTA levels 4-6, NTA levels 7-8, and NTA level 9).  Specific entry qualifications are detailed for each NTA level and program.  These requirements include minimum grade point averages (GPAs), specific subject combinations and pass grades from the Certificate of Secondary Education Examination (CSEE) or its equivalent, and NVA level requirements.  Details are available in Chapter Three, Section 3.  The admission office manages a fair, transparent and consistent process.  Prospective students should consult the Postgraduate, Undergraduate, and Diploma programme Admission Guidebooks prepared annually by the Tanzania Commission for Universities (TCU) and the National Council for Technical Education (NACTVET) for complete details.",
      "what are the exam regulations":
          "The DIT exam regulations include: statutory examination powers, primacy of institute examination regulations, examination regulations and their applications, cognizance of examination regulations, examinations, registration for modules, eligibility for examinations, performance threshold, absence from examination, postponement of examinations, dates and duration of examinations, conduction of examinations, administrative organs, examination irregularities and penalties, progression from one academic audit unit to another, progression from one level to the next level of award, classification of awards, procedure for classification of degrees, procedure for calculating grade point average (GPA), right and discretion of the institute, and amendments.",
      "what are financial and fees requirements":
          "Apart from tuition fees, each student is required to pay a registration fee, caution money, identity card fee, and DIT Students’ Organization membership fee.  Students with no valid health insurance must pay a contribution towards joining NHIF.  Specific fees vary depending on program (NTA level), sponsorship type (government or private), and other factors such as accommodation.  Detailed fee structures are listed in Tables 4.1, 4.2, and 4.3. Additional costs may include special faculty/course requirements, final project/research, and additional hostel charges.  Payment may be in installments.",
      "describe profile of academic departments":
          "The DIT prospectus details six academic departments: Civil Engineering, Computer Studies, Electrical Engineering, Electronics and Telecommunication Engineering, Mechanical Engineering, and Science and Laboratory Technology.  Each department's profile includes offered programs (NTA levels 4-9),  staff lists, and module descriptions.  Additional academic related directorates, departments, or units, such as Research and Publication, Postgraduate Studies, and the Institute Consultancy Bureau (ICB) are also profiled.",
      "what are the tuition fees for different programs":
          "The provided prospectus does not offer a single table of tuition fees for all programs.  Tuition fees vary by program level (NTA levels 4-9), program type (Ordinary Diploma, Bachelor Degree, Master's Degree, Certificate, etc.), and whether the student is a Tanzanian citizen or a non-Tanzanian citizen.  Specific fee breakdowns are provided in tables 4.1 (a, b, c), 4.2 (a, b), and 4.3 (a, b, c, d) within the prospectus, each detailing costs for a particular program level and student citizenship status.  Additional fees (registration, examination, etc.) are also listed separately.",
      "where is dit located":
          "The Dar es Salaam Institute of Technology (DIT) is located in the Dar es Salaam city centre, at the junction of Morogoro Road and Bibi Titi Mohamed Street.",
      "what is the institute's mission, vision and core values":
          "Here's a summary of the Dar es Salaam Institute of Technology's (DIT) mission, vision, and core values based on the provided prospectus:Vision: To become the leading technical education institution in addressing societal needs.Mission: To provide competence-based technical education through training, research, innovation, and the development of appropriate technology.  DIT is an agent of industrialization, a progressive and customer-centered higher learning institution.Core Values: The prospectus highlights a commitment to excellence in professionalism and enduring knowledge, stimulating creativity and innovation, and embracing competence-based education and training.  It also emphasizes the importance of scientific and engineering skills, and entrepreneurship",
      "how many campuses does dit have":
          "DIT has three campuses: Dar es Salaam Main Campus, DIT Mwanza Campus, and DIT Myunga Campus.",
      "what facilities does dit have":
          "DIT has classrooms, laboratories, workshops, a library, a computer laboratory, and a registered soil laboratory.  The main campus also has hostels and a dining hall.  Mwanza campus has lecture theatres, classrooms, scientific laboratories, computer laboratories, a teaching tannery, and leather manufacturing workshops.  Myunga campus has a computer laboratory and a registered soil laboratory.",
      "what accomodation options are available":
          "The Dar es Salaam Institute of Technology has a limited number of rooms in its hostels.  Students are encouraged to seek private accommodation.  Costs for DIT hostels vary by block and range from TZS 50,000.00 to TZS 120,000.00 per academic year.  Additional costs for other services are available in table 4.5.",
      "what is the criteria for student evaluation":
          "The university prospectus states that student evaluation includes continuous assessment (tests, assignments, seminars, presentations, practical, dissertations, theses, or any other form of assessment) and end-of-semester examinations.  The weighting is 60% for continuous assessment and 40% for end-of-semester examinations unless otherwise specified.  Passing scores vary by NTA level (4-9).  Postgraduate students' dissertations are assessed separately."
    };

    bool updated = false;
    hardcodedQuestions.forEach((question, answer) {
      // Only add if the question is not already in the cache
      if (!_questionCache.containsKey(question)) {
        _questionCache[question] = answer;
        updated = true;
      }
    });

    if (updated) {
      await _saveQuestionCache();
      debugPrint("Hardcoded questions added to cache.");
    } else {
      debugPrint("Hardcoded questions already present in cache.");
    }
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
      status = "Ready.";
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

  // Future<String?> askQuestion(String question) async {
  //   // question = "dit location";
  //  print(question);
  //   if (_questionCache.containsKey(question)) {
  //     final cachedAnswer = _questionCache[question];
  //     spokenText = cachedAnswer;
  //     status = "Answer retrieved.";
  //     notifyListeners();
  //     await speak(cachedAnswer!);
  //     return cachedAnswer;
  //   }

  //   notifyListeners();
  //   try {
  //     final base64Pdf = await _getCachedBase64Pdf();
  //     if (base64Pdf == null || base64Pdf.isEmpty) {
  //       status =
  //           "No PDF prospectus found. Please connect internet and restart your application.";
  //       speak(status);
  //       notifyListeners();
  //       return null;
  //     }

  //     status = "Analyzing...";
  //     speak(status);

  //     final prompt = '''
  //       Answer the following question using only the university prospectus provided.

  //       Question: $question
  //       ''';

  //     final url = Uri.parse(
  //       'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
  //     );

  //     final headers = {'Content-Type': 'application/json'};
  //     final body = jsonEncode({
  //       "contents": [
  //         {
  //           "parts": [
  //             {
  //               "inline_data": {
  //                 "mime_type": "application/pdf",
  //                 "data": base64Pdf,
  //               }
  //             },
  //             {"text": prompt}
  //           ]
  //         }
  //       ]
  //     });

  //     final response = await http.post(url, headers: headers, body: body);
  //     print("Gemini API Response: ${response.body}");

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final answer = data["candidates"][0]["content"]["parts"][0]["text"];
  //       status = "Answer received.";
  //       if (isCancelled) return "Cancelled.";
  //       notifyListeners();
  //       spokenText = answer;
  //       _questionCache[question] = answer;
  //       await _saveQuestionCache();
  //       await speak(answer);
  //       return answer;
  //     } else {
  //       throw Exception('Gemini API Error: ${response.body}');
  //     }
  //   } catch (e) {
  //     status = "Failed to get answer.";
  //     notifyListeners();
  //     debugPrint("Gemini error: $e");
  //     await speak("Sorry, I couldn't understand that.");
  //     return null;
  //   }
  // }

  Future<String?> askQuestion(String question) async {
    //   // question = "dit location";
    //  print(question);
    if (_questionCache.containsKey(question)) {
      final cachedAnswer = _questionCache[question];
      spokenText = cachedAnswer;
      status = "Answer retrieved.";
      notifyListeners();
      await speak(cachedAnswer!);
      return cachedAnswer;
    }
    notifyListeners();

    final base64Pdf = await _getCachedBase64Pdf();
    if (base64Pdf == null || base64Pdf.isEmpty) {
      status =
          "No PDF prospectus found. Please connect internet and restart your application.";
      speak(status);
      notifyListeners();
      return null;
    }

    final dio = Dio();
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final prompt = '''
        Answer the following question using only the university prospectus provided.

        Question: $question
        ''';

    final data = {
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
    };

    try {
      status = "Analyzing...";
      speak(status);

      final response = await dio.post(url, data: data);
      if (response.statusCode == 200) {
        final answer =
            response.data["candidates"][0]["content"]["parts"][0]["text"];
        status = "Answer received.";
        if (isCancelled) return "Cancelled.";
        notifyListeners();
        spokenText = answer;
        _questionCache[question] = answer;
        await _saveQuestionCache();
        await speak(answer);
        return answer;
      } else {
        speak("Failed to get answer from GeminAPI.");
        throw Exception('Failed to get answer');
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
      status = "Ready.";
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

  void startVoiceQuestion() async {
    bool available = await _speech.initialize();
    if (available) {
      status = "Listening for your question...";
      notifyListeners();
      await speak(status);

      if (isCancelled) {
        status = "Voice question cancelled.";
        notifyListeners();
        return;
      }

      _speech.listen(
          onResult: (result) {
            final question = result.recognizedWords;
            if (question.isNotEmpty) {
              askQuestion(question);
            }
          },
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 5),
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.dictation,
            //  partialResults: true
          ));
      status = "Speak now...";
      notifyListeners();
    } else {
      status = "Voice recognition not available.";
      await speak(status);
      notifyListeners();
    }
  }
}
