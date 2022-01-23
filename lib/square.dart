import 'coord.dart';

/// Represents each square of the puzzle
///
/// Includes the blank square 16
enum Square {
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  eleven,
  twelve,
  thirteen,
  fourteen,
  fifteen,
  sixteen,
}

extension SquareExtension on Square {
  /// The [Coordinate] corresponding to the square
  Coordinate get coordinate {
    switch (this) {
      case Square.one:
        return const Coordinate(x: 0, y: 0);
      case Square.two:
        return const Coordinate(x: 1, y: 0);
      case Square.three:
        return const Coordinate(x: 2, y: 0);
      case Square.four:
        return const Coordinate(x: 3, y: 0);
      case Square.five:
        return const Coordinate(x: 0, y: 1);
      case Square.six:
        return const Coordinate(x: 1, y: 1);
      case Square.seven:
        return const Coordinate(x: 2, y: 1);
      case Square.eight:
        return const Coordinate(x: 3, y: 1);
      case Square.nine:
        return const Coordinate(x: 0, y: 2);
      case Square.ten:
        return const Coordinate(x: 1, y: 2);
      case Square.eleven:
        return const Coordinate(x: 2, y: 2);
      case Square.twelve:
        return const Coordinate(x: 3, y: 2);
      case Square.thirteen:
        return const Coordinate(x: 0, y: 3);
      case Square.fourteen:
        return const Coordinate(x: 1, y: 3);
      case Square.fifteen:
        return const Coordinate(x: 2, y: 3);
      case Square.sixteen:
        return const Coordinate(x: 3, y: 3);
    }
  }
}
