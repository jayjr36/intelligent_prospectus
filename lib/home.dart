import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intelligent_prospectus/prospectus/home_scrn.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(context, MaterialPageRoute(builder: (context) => ProspectusQA()));
      //   },
      //   child: Icon(Icons.book),
      // )
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
