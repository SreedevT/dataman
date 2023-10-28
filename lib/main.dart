import 'package:flutter/material.dart';
import './home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          dialogTheme: DialogTheme(
            backgroundColor: Colors.grey[850],
            titleTextStyle: TextStyle(
                color: Colors.grey[50],
                fontSize: 20,
                fontWeight: FontWeight.bold),
            contentTextStyle: TextStyle(color: Colors.grey[100], fontSize: 16),
          )),
      home: const HomePage(),
    );
  }
}

