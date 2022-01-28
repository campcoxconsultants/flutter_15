import 'package:flutter/material.dart';
import 'package:flutter_15/coord.dart';

import 'square.dart';

class GameEngine extends ChangeNotifier {
  /// Represents the state of a completed puzzle.
  static final _completedPuzzle = {
    Square.one.coordinate: 1,
    Square.two.coordinate: 2,
    Square.three.coordinate: 3,
    Square.four.coordinate: 4,
    Square.five.coordinate: 5,
    Square.six.coordinate: 6,
    Square.seven.coordinate: 7,
    Square.eight.coordinate: 8,
    Square.nine.coordinate: 9,
    Square.ten.coordinate: 10,
    Square.eleven.coordinate: 11,
    Square.twelve.coordinate: 12,
    Square.thirteen.coordinate: 13,
    Square.fourteen.coordinate: 14,
    Square.fifteen.coordinate: 15,
    Square.sixteen.coordinate: null,
  };

  GameEngine() : _puzzle = Map<Coordinate, int>.from(_completedPuzzle);

  /// Represents the current state of the puzzle.
  ///
  /// Each [Coordinate] maps to the number shown in that square.  The blank square maps to null.
  Map<Coordinate, int> get puzzle => _puzzle;

  final Map<Coordinate, int> _puzzle;
}
