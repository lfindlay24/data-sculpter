import 'package:flutter/material.dart';
import 'package:flutter_ui/pages/home.dart';

List<Map<String, dynamic>> workingData = [];

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
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
      home: HomePage(),
      );
  }
}
