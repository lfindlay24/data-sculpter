import 'package:flutter/material.dart';
import 'package:flutter_ui/pages/home.dart';

List<Map<String, dynamic>> workingData = [
  {'year': '2016', 'sales': '30'},
  {'year': '2017', 'sales': '40'},
  {'year': '2018', 'sales': '50'},
  {'year': '2019', 'sales': '60'},
  {'year': '2020', 'sales': '70'},
];

var auth = '';

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
