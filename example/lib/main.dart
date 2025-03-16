import 'package:file_encrypter_example/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const EncrypterApp());
}

class EncrypterApp extends StatelessWidget {
  const EncrypterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Encrypter Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.amber,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
