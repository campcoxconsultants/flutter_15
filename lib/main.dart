import 'package:flutter/material.dart';

import 'puzzle_page.dart';
import 'settings.dart';

late Settings _settings;
void main() async {
  // To avoid updating the board in rapid succession on startup
  // we want the settings to be loaded before drawing it the first time.
  _settings = await Settings.load();

  runApp(
    MaterialApp(
      title: 'Super Slider',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FlutterPuzzlePage(settings: _settings),
    ),
  );
}
