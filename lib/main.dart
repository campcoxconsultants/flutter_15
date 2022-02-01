import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'puzzle_page.dart';
import 'settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Settings(),
      child: MaterialApp(
        title: 'Flutter Puzzle Hack',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const FlutterPuzzlePage(title: 'Flutter 15 Puzzle'),
      ),
    );
  }
}
