import 'package:bletest/home.dart';
import 'package:flutter/material.dart';

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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.teal[500],
            titleTextStyle: TextStyle(fontSize: 20, color: Colors.white),
          ),
          useMaterial3: true,
        ),
        home: const Home());
  }
}
