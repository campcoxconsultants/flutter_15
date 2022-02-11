import 'package:flutter/material.dart';

import 'puzzle_page.dart';
import 'settings.dart';

late Settings _settings;
void main() async {
  _settings = await Settings.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Puzzle Hack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FlutterPuzzlePage(title: 'Flutter 15 Puzzle', settings: _settings),
    );
  }
}
