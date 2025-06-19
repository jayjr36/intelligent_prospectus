import 'package:flutter/material.dart';
import 'package:intelligent_prospectus/admission_guide.dart';
import 'package:intelligent_prospectus/controllers/gemini_provider.dart';
import 'package:intelligent_prospectus/file_upload.dart';
import 'package:intelligent_prospectus/new/query_screen.dart';
import 'package:intelligent_prospectus/programmes.dart';
import 'package:intelligent_prospectus/prospectus_screen.dart';
import 'package:intelligent_prospectus/splash.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GeminiProvider(),
      child: const ProspectusApp(),
    ),
  );
}

class ProspectusApp extends StatelessWidget {
  const ProspectusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Prospectus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Clean white background

        primarySwatch: Colors.indigo,
        fontFamily: 'Inter', // Ensure 'Inter' is added in pubspec.yaml

        appBarTheme: AppBarTheme(
          color: Colors.blue.shade500,
          elevation: 6,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Inter',
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        ),

        textTheme: TextTheme(
          headlineSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade700,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade800,
          ),
          bodyLarge: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.blueGrey.shade800,
          ),
          bodyMedium: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),

        // Button & Elevated Button theme (optional)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),

      // App Navigation Routes
      routes: {
        '/upload': (context) => const FileUploadScreen(),
        '/prospectus': (context) => const ProspectusHomePage(),
        '/programmes': (context) => const DITProgramsScreen(),
        '/admission': (context) => const DITAdmissionsScreen(),
      },

      home: const SplashScreen(),
    );
  }
}
