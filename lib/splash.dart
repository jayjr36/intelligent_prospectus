import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:intelligent_prospectus/home.dart'; // For BackdropFilter

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Animation control variables
  double _opacity = 0.0;
  double _topPosition = 100.0;
  TextStyle _textStyle =
  TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white);

  // Timer to navigate after animation finishes
  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _opacity = 1.0;
      _topPosition = 50.0;
      _textStyle = TextStyle(
          fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blueAccent);
    });

    // Wait for a few seconds before navigating to the next page
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Stack(
        children: [
          // Apply glassmorphism effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(seconds: 1),
              child: AnimatedAlign(
                duration: Duration(seconds: 1),
                alignment: Alignment(
                    0,
                    _topPosition == 50.0
                        ? -0.5
                        : 0), // animate vertical movement
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.school,
                        size: 50,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 20),
                    AnimatedDefaultTextStyle(
                      duration: Duration(seconds: 1),
                      style: _textStyle,
                      child: Text("Welcome to Digital Prospectus",
                          textAlign: TextAlign.center),
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
