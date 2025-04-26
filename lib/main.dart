
import 'package:flutter/material.dart';
import 'package:intelligent_prospectus/controllers/gemini_provider.dart';
import 'package:intelligent_prospectus/file_upload.dart';
import 'package:intelligent_prospectus/prospectus_screen.dart';
import 'package:intelligent_prospectus/splash.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GeminiProvider(),
      child: ProspectusApp(),
    ),
  );
}

class ProspectusApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Prospectus',
        routes: {
    '/upload': (context) => FileUploadScreen(),
    '/prospectus': (context) => ProspectusHomePage(),
  },
      home: SplashScreen(),
    );
  }
}
