import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeechState();
  }

  void _initSpeechState() async {
    // Check for speech recognition availability and request permissions
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech recognition status: $status'),
      onError: (errorNotification) => print('Speech recognition error: $errorNotification'),
    );
    if (!available) {
      print("The device doesn't support speech recognition.");
      // Optionally, show a message to the user that voice commands are not available
    }
  }
 /// Each time to start a speech recognition session
  void _startListening() async {
    _lastWords = ''; // Clear previous words
    await _speech.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 10), // Listen for up to 10 seconds
      pauseFor: const Duration(seconds: 3),   // Pause if no speech for 3 seconds
      partialResults: true,                   // Get results as they are spoken
      localeId: 'en_US',                      // Specify locale, e.g., 'en_US'
    );
    setState(() {
      _isListening = true;
    });
  }

  /// Manually stop the active speech recognition session
  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  /// This is called every time a speech recognition result is available.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    // Process the voice command
    _processVoiceCommand(_lastWords);
  }

    // --- Voice Command Processing ---
  void _processVoiceCommand(String command) {
    final lowerCaseCommand = command.toLowerCase();

    if (lowerCaseCommand.contains('prospectus enquiry') || lowerCaseCommand.contains('prospectus')) {
      Navigator.pushNamed(context, '/prospectus');
      _stopListening(); // Stop listening after command is executed
    } else if (lowerCaseCommand.contains('admission guidelines') || lowerCaseCommand.contains('admission')) {
      Navigator.pushNamed(context, '/admission');
      _stopListening();
    } else if (lowerCaseCommand.contains('dit programs') || lowerCaseCommand.contains('programs') || lowerCaseCommand.contains('programmes')) {
      Navigator.pushNamed(context, '/programmes');
      _stopListening();
    }
    // Add more commands as needed
    // else if (lowerCaseCommand.contains('go back') || lowerCaseCommand.contains('back')) {
    //   Navigator.pop(context);
    //   _stopListening();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: Stack(
        children: [
            BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                // color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Image.asset('assets/images/dit_logo.png', height: 80),
                  ),
                  Text(
                    'DIT SMART PROSPECTUS',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  _glassmorphicButtonContainer(
                    context,
                    "Prospectus Enquiry",
                    () {
                      // Navigate to the Prospectus Page
                      Navigator.pushNamed(context, '/prospectus');
                    },
                  ),
                  SizedBox(height: 20),
                  _glassmorphicButtonContainer(
                    context,
                    "Admission Guidelines",
                    () {
                      // Navigate to the Upload Page
                      Navigator.pushNamed(context, '/admission');
                    },
                  ),
                  SizedBox(height: 20),
                  _glassmorphicButtonContainer(
                    context,
                    "DIT Programs",
                    () {
                      // Navigate to the Upload Page
                      Navigator.pushNamed(context, '/programmes');
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Glassmorphic button container function
Widget _glassmorphicButtonContainer(BuildContext context, String label, VoidCallback onPressed, {IconData? icon}) {
 double w = MediaQuery.of(context).size.width;
  return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: Container(
        width: w*0.8,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.75),
              Colors.blue.withOpacity(0.75),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null)
                    Icon(icon, color: Colors.white, size: 26),
                  if (icon != null) SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        )
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
  );
}
}
