import 'dart:math';

import 'package:flutter/foundation.dart';

import 'coord.dart';
import 'settings.dart';
import 'square.dart';

// TODO: Teaching mode
/// Handles the business logic of the game.
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

  GameEngine({required this.settings}) : _puzzle = Map<Coordinate, int?>.from(_completedPuzzle);

  final Settings settings;

  /// Represents the current state of the puzzle.
  ///
  /// Each [Coordinate] maps to the number shown in that square.
  /// The blank square maps to null.
  Map<Coordinate, int?> get puzzle => _puzzle;
  final Map<Coordinate, int?> _puzzle;

  /// Tracks the blank location.
  Coordinate get blank => _blank;
  Coordinate _blank = Square.sixteen.coordinate;

  /// Current state of the game
  GameState get gameState => _gameState;
  set gameState(newGameState) {
    _gameState = newGameState;
    notifyListeners();
  }

  GameState _gameState = GameState.initial;

  /// Number of moves in current game
  ///
  /// This is not valid for initial and randomizing.
  int get numberOfMoves => _numberOfMoves;
  int _numberOfMoves = 0;

  /// Elapsed time since a new game started.
  ///
  /// The timer stops when the game is solved.
  Duration get elapsedTime => _stopwatch.elapsed;
  final _stopwatch = Stopwatch();

  /// The top level goal for auto solving
  String? get solvingHeadline => _gameState == GameState.autoSolving ? _solvingHeadline : null;
  String? _solvingHeadline;

  /// List of reasons for current move.
  List<String> get solvingDetails => _solvingDetails;
  final List<String> _solvingDetails = [];

  /// Whether the proposed slide is safe.
  ///
  /// This assumes that the current puzzle is solved above and to the right of target.  Sometimes a proposed
  /// slide is not a legal move.
  bool _isSafeSlide({required Coordinate target, required Coordinate proposed}) =>
      (proposed.y > target.y || proposed.x >= target.x) &&
      proposed.y >= 0 &&
      proposed.y < 4 &&
      proposed.x >= 0 &&
      proposed.x < 4;

  /// Generates a new coordinate to be used in a move.
  ///
  /// Should be passed exactly one value since the other must be blank to be a legal move.
  Coordinate _newMove({int? x, int? y}) => Coordinate(x: x ?? _blank.x, y: y ?? _blank.y);

  /// Slides one or more tiles towards [_blank]
  void move(Coordinate pushedPiece, {auto = false}) async {
    assert(pushedPiece.x >= 0 && pushedPiece.x < 4);
    assert(pushedPiece.y >= 0 && pushedPiece.y < 4);

    if (pushedPiece == _blank || (!pushedPiece.isSameColumn(_blank) && !pushedPiece.isSameRow(_blank))) {
      return;
    }

    if (!auto && _gameState != GameState.activeGame) {
      return;
    }

    late final Coordinate delta;

    if (pushedPiece.x == _blank.x) {
      delta = Coordinate(x: 0, y: pushedPiece.y - _blank.y > 0 ? 1 : -1);
    } else {
      delta = Coordinate(x: pushedPiece.x - _blank.x > 0 ? 1 : -1, y: 0);
    }

    Coordinate swap = _blank;

    /// Slide can be 1 to 3 tiles, move from blank towards the pushed piece.
    while (swap != pushedPiece) {
      swap += delta;

      _puzzle[_blank] = _puzzle[swap];
      _puzzle[swap] = null;
      _blank = swap;
    }

    if (_gameState != GameState.randomizing) {
      _numberOfMoves++;
    }

    _checkForWin();

    notifyListeners();
  }

  /// Checks the puzzle to see if it is solved and sets correct variables
  _checkForWin() {
    if (mapEquals(_puzzle, _completedPuzzle)) {
      _gameState = GameState.gameWon;
      _stopwatch.stop();
    }
  }

  /// Performs move and waits until time for next move
  _autoMove(Coordinate newMove, {Duration? duration}) async {
    assert(newMove.compare(isSameRow: _blank, isDifferentColumn: _blank) ||
        newMove.compare(isDifferentRow: _blank, isSameColumn: _blank));

    if (_gameState != GameState.autoSolving && _gameState != GameState.randomizing) {
      return;
    }
    move(newMove, auto: true);

    final speedFactor = (settings.isTeachingMode && _gameState == GameState.autoSolving) ? 3 : 1;
    await Future.delayed(
      duration ?? Duration(milliseconds: 200 * settings.moveSpeed * speedFactor),
    );
  }

  /// Generates automatic moves until the puzzle is solved.
  Future<void> solutionMove() async {
    _gameState = GameState.autoSolving;

    _solvingHeadline = 'Solving Tile 1';
    await _solveTarget(piece: 1, target: Square.one.coordinate);
    _solvingHeadline = 'Solving Tile 2';
    await _solveTarget(piece: 2, target: Square.two.coordinate);
    _solvingHeadline = 'Solving Tile 3';
    await _solveTarget(piece: 3, target: Square.three.coordinate);
    _solvingHeadline = 'Solving Tile 4';
    await _solveTarget(piece: 4, target: Square.four.coordinate);
    _solvingHeadline = 'Solving Tile 5';
    await _solveTarget(piece: 5, target: Square.five.coordinate);
    _solvingHeadline = 'Solving Tile 6';
    await _solveTarget(piece: 6, target: Square.six.coordinate);
    _solvingHeadline = 'Solving Tile 7';
    await _solveTarget(piece: 7, target: Square.seven.coordinate);
    _solvingHeadline = 'Solving Tile 8';
    await _solveTarget(piece: 8, target: Square.eight.coordinate);

    // if 9 & 13 are not already in place, solve them next to each other
    if (_puzzle[Square.nine.coordinate] != 9 || _puzzle[Square.thirteen.coordinate] != 13) {
      _solvingHeadline = "Moving Tile 13 to 9's Square";
      await _solveTarget(piece: 13, target: Square.nine.coordinate);

      // Case where 9 and 13 are in opposite order
      if (_puzzle[Square.thirteen.coordinate] == 9 ||
          (_blank == Square.thirteen.coordinate && _puzzle[Square.fourteen.coordinate] == 9)) {
        _solvingHeadline = 'Solving 9 and 13';
        await _unhideCorner(target: Square.thirteen.coordinate);
      } else {
        _solvingHeadline = "Moving Tile 9 to 10's Square";
        await _solveTarget(piece: 9, target: Square.ten.coordinate);

        _solvingHeadline = 'Solving 9 and 13';
        await _rotateBottomStart(target: Square.nine.coordinate);
      }
    }

    // if 10 & 14 are not already in place, solve them next to each other
    if (_puzzle[Square.ten.coordinate] != 10 || _puzzle[Square.fourteen.coordinate] != 14) {
      _solvingHeadline = "Moving Tile 14 to 10's Square";
      await _solveTarget(piece: 14, target: Square.ten.coordinate);
      // Case where 10 and 14 are in opposite order
      if (_puzzle[Square.fourteen.coordinate] == 10 ||
          (_blank == Square.fourteen.coordinate && _puzzle[Square.fifteen.coordinate] == 10)) {
        _solvingHeadline = "Solving 10 and 14";
        await _unhideCorner(target: Square.fourteen.coordinate);
      } else {
        _solvingHeadline = "Moving Tile 10 to 11's Square";
        await _solveTarget(piece: 10, target: Square.eleven.coordinate);

        _solvingHeadline = 'Solving 10 and 14';
        await _rotateBottomStart(target: Square.ten.coordinate);
      }
    }

    _solvingHeadline = 'Solving Tile 11';
    await _solveTarget(piece: 11, target: Square.eleven.coordinate);
    _solvingHeadline = 'Solving Tile 12';
    await _solveTarget(piece: 12, target: Square.twelve.coordinate);
    _solvingHeadline = 'Solving Tile 15';
    await _solveTarget(piece: 15, target: Square.fifteen.coordinate);
  }

  /// Generates 0 or more automatic moves until the piece
  /// has been moved to the target square.
  ///
  /// Note: there are cases where the target square is not the
  /// same as the solved puzzle.
  Future<void> _solveTarget({required int piece, required Coordinate target}) async {
    while (_gameState == GameState.autoSolving && _puzzle[target] != piece) {
      await _makeNextMove(_findTile(piece), target);
    }
  }

  /// Moves a piece located at x, y+1 (where x is the right hand side)
  /// into the target location while leaving the already solved pieces
  /// in place.
  Future<void> _rotateEnd(Coordinate target) async {
    final targetPiece = _completedPuzzle[target]!;

    _solvingDetails.clear();
    _solvingDetails.insert(0, 'Perform end piece rotation');
    // There is always a second element
    _solvingDetails.insert(1, '');

    if (_blank.x != target.x - 2) {
      _solvingDetails[1] = 'Make room to move ${targetPiece - 2} down';
      await _autoMove(_newMove(x: target.x - 2));
    }

    _solvingDetails[1] = 'Move ${targetPiece - 2} down';
    await _autoMove(_newMove(y: target.y));

    _solvingDetails[1] = 'Make room to move $targetPiece into place';
    await _autoMove(_newMove(x: target.x));

    _solvingDetails[1] = 'Move $targetPiece into place';
    await _autoMove(_newMove(y: target.y + 1));

    _solvingDetails[1] = 'Make room to remove incorrect piece';
    await _autoMove(_newMove(x: target.x - 1));

    _solvingDetails[1] = 'Remove incorrect piece';
    await _autoMove(_newMove(y: target.y));

    _solvingDetails[1] = 'Move ${targetPiece - 1} back in place';
    await _autoMove(_newMove(x: target.x - 2));

    _solvingDetails[1] = 'Move ${targetPiece - 2} back in place';
    await _autoMove(_newMove(y: target.y + 1));
  }

  /// Moves bottom left pieces into order.
  ///
  /// The solving algorithm puts the two vertical pieces next to each other
  /// on the top row (x, y-1) and (x + 1, y) into their correct places.
  /// Eg. for a 4x4 puzzle, the first two squares of the third row are 13 and 9,
  /// and after this, they are in their correct places, then this is repeated
  /// for 14 and 10.
  Future<void> _rotateBottomStart({required Coordinate target}) async {
    final targetPiece = _completedPuzzle[target]!;

    _solvingDetails.clear();
    _solvingDetails.insert(0, 'Rotate $targetPiece and ${targetPiece + 4} into place');
    // There is always a second element
    _solvingDetails.insert(1, '');

    if (_blank.y != target.y + 1) {
      _solvingDetails[1] = 'Move blank to bottom row';
      await _autoMove(_newMove(y: target.y + 1));
    }

    if (_blank.x != target.x) {
      _solvingDetails[1] = 'Make room for ${targetPiece + 4}';
      await _autoMove(_newMove(x: target.x));
    }

    _solvingDetails[1] = 'Move ${targetPiece + 4} into place';
    await _autoMove(_newMove(y: target.y));

    _solvingDetails[1] = 'Move $targetPiece into place';
    await _autoMove(_newMove(x: target.x + 1));
  }

  /// Solves issue in the bottom left corner which can't be solved
  /// by the algorithm.
  ///
  /// The solving algorithm places two vertical pieces next each other.
  /// There is the possibility that the lower number is below the larger
  /// number (eg 9 is at (0,3) and 13 is at (0,2) - or the blank is
  /// (0,3) and and 9 is (1,3).
  Future<void> _unhideCorner({required Coordinate target}) async {
    final higherPiece = _completedPuzzle[target]!;
    final lowerPiece = higherPiece - 4;

    _solvingDetails.clear();
    _solvingDetails.insert(0, 'Swap $lowerPiece and $higherPiece');
    // There is always a second element
    _solvingDetails.insert(1, '');

    if (_blank.y != target.y) {
      _solvingDetails[1] = 'Make room to move $lowerPiece right';
      await _autoMove(_newMove(y: target.y));
    }

    if (_blank != target) {
      _solvingDetails[1] = 'Move $lowerPiece right';
      await _autoMove(_newMove(x: target.x));
    }

    _solvingDetails[1] = 'Move $higherPiece down';
    await _autoMove(_newMove(y: target.y - 1));

    _solvingDetails[1] = 'Make room to move $lowerPiece up';
    await _autoMove(_newMove(x: target.x + 1));

    _solvingDetails[1] = 'Move $lowerPiece up';
    await _autoMove(_newMove(y: target.y));

    _solvingDetails[1] = 'Make room to move $higherPiece up';
    _solvingDetails.add('Move blank to the right');
    await _autoMove(_newMove(x: target.x + 2));

    _solvingDetails[2] = 'Move Blank up next to $lowerPiece';
    await _autoMove(_newMove(y: target.y - 1));

    _solvingDetails.removeAt(2);
    await _autoMove(_newMove(x: target.x));

    _solvingDetails[1] = 'Move $higherPiece up';
    await _autoMove(_newMove(y: target.y));

    _solvingDetails[1] = 'Make room to move incorrect piece out of the way';
    await _autoMove(_newMove(x: target.x + 1));

    _solvingDetails[1] = 'Move incorrect piece out of the way';
    await _autoMove(_newMove(y: target.y - 1));

    _solvingDetails[1] = 'Move $lowerPiece left';
    await _autoMove(_newMove(x: target.x + 2));

    _solvingDetails[1] = 'Move blank down';
    await _autoMove(_newMove(y: target.y));

    _solvingDetails[1] = 'Make room to move $higherPiece down';
    await _autoMove(_newMove(x: target.x));

    _solvingDetails[1] = 'Move $higherPiece down';
    await _autoMove(_newMove(y: target.y - 1));

    _solvingDetails[1] = 'Move $lowerPiece left';
    await _autoMove(_newMove(x: target.x + 1));
  }

  /// Determines the coordinates where a tile is currently.
  Coordinate _findTile(int targetTile) {
    Coordinate? targetLocation;

    for (final Coordinate key in _puzzle.keys) {
      if (_puzzle[key] == targetTile) {
        targetLocation = key;
        break;
      }
    }

    assert(targetLocation != null);
    return targetLocation!;
  }

  /// Automoves the next move according to the algorithm.
  ///
  /// The basic plan is to move the piece into position if it is
  /// in the correct row or column. Otherwise, move the piece to
  /// the correct column.
  ///
  /// It is assumed that the puzzle is solved for all rows above
  /// target and all columns to the left of target in the target row.
  ///
  /// Note there are cases where a sequence of moves are needed
  /// when the algorithm would basically not work.
  Future<void> _makeNextMove(Coordinate location, Coordinate target) async {
    Coordinate? movePiece;
    if (location == target) {
      return;
    }

    _solvingDetails.clear();

    if (location.isSameRow(target)) {
      movePiece = _moveCorrectRow(location, target);
    } else if (location.compare(isSameColumn: target)) {
      movePiece = await _moveCorrectColumn(location, target);
    } else {
      movePiece = _moveToCorrectColumn(location, target);
    }

    if (movePiece != null) {
      await _autoMove(movePiece);
    }
  }

  Coordinate _moveCorrectRow(Coordinate location, Coordinate target) {
    Coordinate movePiece;
    final targetPiece = _puzzle[location]!;

    _solvingDetails.add('Move $targetPiece left');

    // If blank is to the left, then move the piece
    if (_blank.compare(isLeftOf: location, isSameRow: target)) {
      movePiece = _newMove(x: location.x);
    } else if (_blank.compare(isBelow: location)) {
      if (_blank.x == location.x - 1) {
        _solvingDetails.add('Make room to move $targetPiece left');
        movePiece = _newMove(y: location.y);
      } else {
        _solvingDetails.add('Move blank to left of $targetPiece');
        movePiece = _newMove(x: location.x - 1);
      }
    } else {
      _solvingDetails.add('Move blank around $targetPiece');
      movePiece = _newMove(y: location.y + 1);
    }

    return movePiece;
  }

  Future<Coordinate?> _moveCorrectColumn(Coordinate location, Coordinate target) async {
    Coordinate movePiece;

    final targetPiece = _puzzle[location]!;
    _solvingDetails.add('Move $targetPiece up');

    if (_blank.compare(isSameColumn: location, isAbove: location)) {
      movePiece = _newMove(y: location.y);
    } else if (location.x == 3 && _blank != target && location == target + const Coordinate(x: 0, y: 1)) {
      await _rotateEnd(target);
      return null;
    } else if (_blank.compare(isAbove: location)) {
      _solvingDetails.add('Make room for $targetPiece');
      movePiece = _newMove(x: location.x);
    } else if (_blank.compare(isSameColumn: location)) {
      _solvingDetails.add('Move blank around $targetPiece');
      movePiece = _newMove(x: location.x == 3 ? 2 : location.x + 1);
    } else if (_blank.compare(isRightOf: location) || (location.y - 1 > target.y || _blank.x > target.x)) {
      _solvingDetails.add('Move blank to row above $targetPiece');
      movePiece = _newMove(y: location.y - 1);
    } else if (_blank.compare(isSameRow: location)) {
      _solvingDetails.add('Make room for $targetPiece');
      movePiece = _newMove(y: location.y + 1);
    } else {
      _solvingDetails.add('Move blank around $targetPiece');
      movePiece = _newMove(x: location.x == 3 ? 2 : location.x + 1);
    }
    return movePiece;
  }

  Coordinate _moveToCorrectColumn(Coordinate location, Coordinate target) {
    Coordinate movePiece;

    final targetPiece = _puzzle[location]!;
    final isTargetLeft = target.isLeftOf(location);
    _solvingDetails.add('Move $targetPiece ' + (isTargetLeft ? 'Left' : 'Right'));

    final isBlankCorrectDirection = (location.isLeftOf(_blank) && location.isLeftOf(target)) ||
        (location.isRightOf(_blank) && location.isRightOf(target));
    if (isBlankCorrectDirection) {
      if (_blank.isSameRow(location)) {
        movePiece = _newMove(x: location.x);
      } else {
        final shortMove = _newMove(y: location.y);
        if (_isSafeSlide(target: target, proposed: shortMove)) {
          _solvingDetails.add('Move blank above $targetPiece');
          movePiece = shortMove;
        } else {
          _solvingDetails.add('Move blank around $targetPiece');
          movePiece = _newMove(y: location.y + 1);
        }
      }
    } else if (_blank.isSameColumn(location)) {
      _solvingDetails.add('Make room for $targetPiece');
      movePiece = _newMove(x: target.x);
    } else {
      final targetDirection = isTargetLeft ? -1 : 1;
      final preferredMove = _newMove(x: location.x + targetDirection);
      final alternateMove = _newMove(y: location.y - 1);
      if (!_blank.isSameRow(location) && _isSafeSlide(target: target, proposed: preferredMove)) {
        _solvingDetails.add('Make blank to ' + (isTargetLeft ? 'left' : 'right') + ' of $targetPiece');
        movePiece = preferredMove;
      } else if (_isSafeSlide(target: target, proposed: alternateMove) && alternateMove != _blank) {
        _solvingDetails.add('Make blank above $targetPiece');
        movePiece = alternateMove;
      } else {
        _solvingDetails.add('Make blank below $targetPiece');
        movePiece = _newMove(y: location.y + 1);
      }
    }

    return movePiece;
  }

  /// Shuffles the board and starts a new game
  Future<void> startGame() async {
    final random = Random();

    _gameState = GameState.randomizing;
    _stopwatch.reset();
    _numberOfMoves = 0;

    for (int i = 0; i < 40; i++) {
      int next = random.nextInt(4);
      while (next == _blank.x) {
        next = random.nextInt(4);
      }
      await _autoMove(
        _newMove(x: next),
        duration: const Duration(milliseconds: 50),
      );

      next = random.nextInt(4);
      while (next == _blank.y) {
        next = random.nextInt(4);
      }
      await _autoMove(
        _newMove(y: next),
        duration: const Duration(milliseconds: 50),
      );
    }

    _stopwatch.start();
    _gameState = GameState.activeGame;

    notifyListeners();
  }
}

/// States a game can be in
enum GameState {
  /// The initial state where the puzzle is solved and ready to
  /// start a game
  initial,

  /// The game is currently shuffling pieces to start a new game
  randomizing,

  /// The game is in progress with the user making moves
  activeGame,

  /// The app is currently automatically solving the game
  autoSolving,

  /// A temporary state where the game has been won.
  ///
  /// After any winning display, this is changed back to initial.
  gameWon,
}
