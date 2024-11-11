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
                'assets/animation/Animation - 1729701521983.json',
                width: 200,
                height: 200,
              ),
            ),
            SizedBox(height: 1),
            const Text(
              'My Simple Notes',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      nextScreen: const NoteHomeUI(),
      splashIconSize: 500,
      duration: 4000,
      backgroundColor: Colors.blueAccent,
    );
  }
}
