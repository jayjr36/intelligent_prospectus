import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intelligent_prospectus/controllers/gemini_provider.dart';
import 'package:intelligent_prospectus/home.dart';
import 'package:pdf_gemini/pdf_gemini.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:manual_speech_to_text/manual_speech_to_text.dart';

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
  late GenaiClient _genaiClient;
  String _status = "Upload a university prospectus PDF";
  String _spokenText = "";
  late ManualSttController _sttController;
  String _finalRecognizedText = '';
  ManualSttState _currentState = ManualSttState.stopped;

  @override
  void initState() {
    super.initState();
    // _initializeGemini();
    // _checkPermissions();
    _tts.speak(
        "Hello and Welcome to the Digital Prospectus. To get started tap on the screen to ask questions.");
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
    _sttController = ManualSttController(context);
    startListening(Provider.of<GeminiProvider>(context, listen: false));
  }

  @override
  void dispose() {
    _controller.dispose();
    _sttController.dispose();
    super.dispose();
  }

  void startListening(GeminiProvider provider) {
    _sttController.listen(
      onListeningStateChanged: (state) {
        setState(() => _currentState = state);
      },
      onListeningTextChanged: (recognizedText) {
        setState(() => _finalRecognizedText = recognizedText);
        provider.askQuestion("bachelor degree programs offered in dit");
        _sttController.stopStt();
      },
    );
    _sttController.clearTextOnStart = false;
    _sttController.pauseIfMuteFor = Duration(seconds: 5);
  }

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
        // onTap: () => provider.askQuestion("modules offered in computer engineering program"),
        // onDoubleTap: () => provider.stopInteraction(),
        onTap: () {
          _sttController.startStt();
          _sttController.listen(
            onListeningStateChanged: (state) {
              setState(() => _currentState = state);
            },
            onListeningTextChanged: (recognizedText) {
              setState(() => _finalRecognizedText = recognizedText);
              provider.askQuestion(_finalRecognizedText);
              _sttController.stopStt();
            },
          );
          _sttController.clearTextOnStart = false;
          _sttController.pauseIfMuteFor = Duration(seconds: 5);
        },
        // _currentState == ManualSttState.stopped
        //     ? _sttController.startStt
        //     : null,
        onDoubleTap: _currentState == ManualSttState.stopped
            ? _sttController.stopStt
            : null,
        onLongPress: _currentState == ManualSttState.listening
            ? _sttController.pauseStt
            : _currentState == ManualSttState.paused
                ? _sttController.resumeStt
                : null,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Spacer(),
                      _currentState == ManualSttState.listening
                          ? Text(
                              "Listening...",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            )
                          : Text(
                              provider.status,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                      Center(
                        child:
                            // provider.  _speech.isListening ? Text("Listening"):
                            _roundGlassButton(
                                Icons.mic,
                                "",
                                // _uploadedFile != null
                                () => provider.startVoiceQuestion(),
                                // : null,
                                Colors.white),
                      ),
                      Spacer(),
                      _glassButton(Icons.explore, "", () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()));
                      }, Colors.white)
                    ],
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
