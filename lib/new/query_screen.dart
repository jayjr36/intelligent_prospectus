import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intelligent_prospectus/secrets.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'gemini_service.dart';

class StudentQueryScreen extends StatefulWidget {
  const StudentQueryScreen({super.key});

  @override
  State<StudentQueryScreen> createState() => _StudentQueryScreenState();
}

class _StudentQueryScreenState extends State<StudentQueryScreen> {
  final _controller = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  bool _isLoading = false;
  String _response = '';

final GeminiService geminiService = GeminiService(
  apiKey: AppSecrets.password,
  pdfUrl: 'https://drive.google.com/uc?export=download&id=11y9W7fwqhStUVdD3fWVSIZETqk1eOdLE',
);


  Future<void> _askQuestion(String question) async {
    if (question.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final answer = await geminiService.queryGemini(question.trim());
      setState(() {
        _response = answer;
      });
      await flutterTts.speak(answer);
    } catch (e) {
      setState(() {
        _response = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startListening() async {
    final available = await _speech.initialize();
    if (!available) return;

    setState(() => _isListening = true);

    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          setState(() {
            _controller.text = result.recognizedWords;
            _isListening = false;
          });
          _askQuestion(result.recognizedWords);
        }
      },
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("University Info Assistant")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _askQuestion,
              decoration: InputDecoration(
                labelText: "Ask your question (English or Swahili)",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _askQuestion(_controller.text.trim()),
              child: const Text("Submit"),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_response.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _response,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
