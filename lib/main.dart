import 'package:flutter/material.dart';
import 'screens/NoteHomeUi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Simple Notes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NoteHomeUI(),
    );
  }
}
