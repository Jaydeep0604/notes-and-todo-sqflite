import 'package:flutter/material.dart';
import 'package:notes_sqflite/ui/base_screen.dart';
import 'package:notes_sqflite/ui/notes_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 84, 130, 190)),
        useMaterial3: true,
      ),
      home: Base(),
    );
  }
}
