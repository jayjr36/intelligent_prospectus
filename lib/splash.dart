import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intelligent_prospectus/home.dart';
import 'package:intelligent_prospectus/prospectus_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _topPosition = 100.0;

  TextStyle _textStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _opacity = 1.0;
      _topPosition = 50.0;
      _textStyle = const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
        letterSpacing: 1.0,
      );
    });

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProspectusHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Light blur for modern feel
          
           BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.white.withOpacity(0.05),
            ),
          ),

          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 900),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 900),
                alignment:
                    _topPosition == 50.0 ? Alignment.topCenter : Alignment.center,
                curve: Curves.easeOut,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: h*0.2,),
                    // --- DIT Logo with circular frame ---
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/dit_logo.png', // <- Make sure this exists
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Title
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 900),
                      style: _textStyle,
                      curve: Curves.easeInOut,
                      child: const Text(
                        "Dar es Salaam Institute of Technology",
                        textAlign: TextAlign.center,
                         style: TextStyle(
                        // color: Colors.black54,
                        fontSize: 18,
                        letterSpacing: 0.8,
                      ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Digital Prospectus",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
