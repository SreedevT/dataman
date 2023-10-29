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
        ),
        textTheme: Typography.blackMountainView.copyWith(
          bodyLarge: TextStyle(color: Colors.grey[100], fontSize: 16),
          bodyMedium: TextStyle(color: Colors.grey[100], fontSize: 14),
          bodySmall: TextStyle(color: Colors.grey[100], fontSize: 12),
        ),
        bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20))),
        inputDecorationTheme: const InputDecorationTheme(isDense: true),
        scaffoldBackgroundColor: Colors.grey[900],
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.grey[850]),
          padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
          iconSize: MaterialStateProperty.all(75),
          textStyle: MaterialStateProperty.all(
              TextStyle(color: Colors.purple[200], fontSize: 14, fontWeight: FontWeight.bold),),
        )),
      ),
      home: const HomePage(),
    );
  }
}
