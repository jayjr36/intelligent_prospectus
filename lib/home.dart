import 'dart:ui';

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Colors.blueAccent,
      
      body: Stack(
        children: [
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // First glassmorphic container for Upload Page
                  _glassmorphicButtonContainer(
                    Icons.upload_file,
                    "Upload Prospectus",
                    () {
                      // Navigate to the Upload Page
                      Navigator.pushNamed(context, '/upload');
                    },
                  ),
                  SizedBox(height: 20),
                  // Second glassmorphic container for Prospectus Page
                  _glassmorphicButtonContainer(
                    Icons.book,
                    "View Prospectus",
                    () {
                      // Navigate to the Prospectus Page
                      Navigator.pushNamed(context, '/prospectus');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Glassmorphic button container function
  Widget _glassmorphicButtonContainer(
      IconData icon, String label, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 4), // Shadow direction
          ),
        ],
        // Glassmorphic effect using a background blur
        // image: DecorationImage(
        //   image: AssetImage('assets/your_background_image.png'), // Optional background image
        //   fit: BoxFit.cover,
        // ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
