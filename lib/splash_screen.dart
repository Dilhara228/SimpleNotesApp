import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:my_simple_note_app/screens/NoteHomeUi.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset(
                'assets/animation/Animation - 1729701521983.json', // Path to your Lottie file
                width: 200, // Adjust width as needed
                height: 200, // Adjust height as needed
              ),
            ),
            const SizedBox(height: 16), // Space between animation and text
            const Text(
              'My Simple Notes',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,

              ),
            ),
          ],
        ),
      ),
      nextScreen: const NoteHomeUI(),
      splashIconSize: 250,
      duration: 4000,
      backgroundColor: Colors.blueAccent, // Background color
    );
  }
}
