import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_15/drawer.dart';
import 'package:flutter_15/settings.dart';
import 'package:provider/provider.dart';

import 'coord.dart';
import 'puzzle_piece.dart';
import 'square.dart';

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
        home: const MyHomePage(title: 'Flutter 15 Puzzle'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// Represents the current state of the puzzle.
  ///
  /// Each [Coordinate] maps to the number shown in that square.  The blank square maps to null.
  final _puzzle = {
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

  /// Tracks the blank location.
  Coordinate _blank = Square.sixteen.coordinate;

  /// Current state of the game
  GameState _gameState = GameState.initial;

  /// Whether the image is a picture vs the numbers
  bool _isPhoto = false;

  final _assetsAudioPlayer = AssetsAudioPlayer();

  @override
  initState() {
    super.initState();
  }

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
  void _move(Coordinate pushedPiece) async {
    assert(pushedPiece.x >= 0 && pushedPiece.x < 4);
    assert(pushedPiece.y >= 0 && pushedPiece.y < 4);

    if (pushedPiece == _blank || (!pushedPiece.isSameColumn(_blank) && !pushedPiece.isSameRow(_blank))) {
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

    setState(() {
      _checkForWin();
    });
  }

  /// Checks if the puzzle to see if it is solved and sets correct variables
  _checkForWin() async {
    if (mapEquals(_puzzle, {
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
    })) {
      _gameState = GameState.gameWon;

      await _assetsAudioPlayer.open(
        Audio('assets/winner.wav'),
        autoStart: true,
      );

      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        _gameState = GameState.initial;
      });
    }
  }

  _autoMove(Coordinate move, {Duration duration = const Duration(milliseconds: 200)}) async {
    assert(move.compare(isSameRow: _blank, isDifferentColumn: _blank) ||
        move.compare(isDifferentRow: _blank, isSameColumn: _blank));

    if (_gameState != GameState.autoSolving && _gameState != GameState.randomizing) {
      return;
    }
    _move(move);
    await Future.delayed(duration);
  }

  Future<void> _solutionMove() async {
    _gameState = GameState.autoSolving;

    await _solveTarget(piece: 1, target: Square.one.coordinate);
    await _solveTarget(piece: 2, target: Square.two.coordinate);
    await _solveTarget(piece: 3, target: Square.three.coordinate);
    await _solveTarget(piece: 4, target: Square.four.coordinate);
    await _solveTarget(piece: 5, target: Square.five.coordinate);
    await _solveTarget(piece: 6, target: Square.six.coordinate);
    await _solveTarget(piece: 7, target: Square.seven.coordinate);
    await _solveTarget(piece: 8, target: Square.eight.coordinate);

    // if 9 & 13 are not already in place, solve them next to each other
    if (_puzzle[Square.nine.coordinate] != 9 || _puzzle[Square.thirteen.coordinate] != 13) {
      await _solveTarget(piece: 13, target: Square.nine.coordinate);

      // Case where 9 and 13 are in opposite order
      if (_puzzle[Square.thirteen.coordinate] == 9 ||
          (_blank == Square.thirteen.coordinate && _puzzle[Square.fourteen.coordinate] == 9)) {
        await _unhideCorner(target: Square.thirteen.coordinate);
      } else {
        await _solveTarget(piece: 9, target: Square.ten.coordinate);

        await _rotateBottomStart(target: Square.nine.coordinate);
      }
    }

    // if 10 & 14 are not already in place, solve them next to each other
    if (_puzzle[Square.ten.coordinate] != 10 || _puzzle[Square.fourteen.coordinate] != 14) {
      await _solveTarget(piece: 14, target: Square.ten.coordinate);
      // Case where 10 and 14 are in opposite order
      if (_puzzle[Square.fourteen.coordinate] == 10 ||
          (_blank == Square.fourteen.coordinate && _puzzle[Square.fifteen.coordinate] == 10)) {
        await _unhideCorner(target: Square.fourteen.coordinate);
      } else {
        await _solveTarget(piece: 10, target: Square.eleven.coordinate);

        await _rotateBottomStart(target: Square.ten.coordinate);
      }
    }

    await _solveTarget(piece: 11, target: Square.eleven.coordinate);
    await _solveTarget(piece: 12, target: Square.twelve.coordinate);
    await _solveTarget(piece: 15, target: Square.fifteen.coordinate);
  }

  Future<bool> _solveTarget({required int piece, required Coordinate target}) async {
    while (_gameState == GameState.autoSolving && _puzzle[target] != piece) {
      await _makeNextMove(_findTile(piece), target);
    }
    return true;
  }

  Future<void> _rotateEnd(Coordinate target) async {
    if (_blank.x != target.x - 2) {
      await _autoMove(_newMove(x: target.x - 2));
    }
    await _autoMove(_newMove(y: target.y));

    await _autoMove(_newMove(x: target.x));

    await _autoMove(_newMove(y: target.y + 1));

    await _autoMove(_newMove(x: target.x - 1));

    await _autoMove(_newMove(y: target.y));

    await _autoMove(_newMove(x: target.x - 2));

    await _autoMove(_newMove(y: target.y + 1));
  }

  Future<void> _rotateBottomStart({required Coordinate target}) async {
    if (_blank.y != target.y + 1) {
      await _autoMove(_newMove(y: target.y + 1));
    }

    if (_blank.x != target.x) {
      await _autoMove(_newMove(x: target.x));
    }

    await _autoMove(_newMove(y: target.y));

    await _autoMove(_newMove(x: target.x + 1));
  }

  Future<void> _unhideCorner({required Coordinate target}) async {
    if (_blank.y != target.y) {
      await _autoMove(_newMove(y: target.y));
    }

    if (_blank != target) {
      await _autoMove(_newMove(x: target.x));
    }

    await _autoMove(_newMove(y: target.y - 1));

    await _autoMove(_newMove(x: target.x + 1));

    await _autoMove(_newMove(y: target.y));

    await _autoMove(_newMove(x: target.x + 2));

    await _autoMove(_newMove(y: target.y - 1));

    await _autoMove(_newMove(x: target.x));

    await _autoMove(_newMove(y: target.y));

    await _autoMove(_newMove(x: target.x + 1));

    await _autoMove(_newMove(y: target.y - 1));

    await _autoMove(_newMove(x: target.x + 2));

    await _autoMove(_newMove(y: target.y));

    await _autoMove(_newMove(x: target.x));

    await _autoMove(_newMove(y: target.y - 1));

    await _autoMove(_newMove(x: target.x + 1));
  }

  Coordinate _findTile(int targetTile) {
    Coordinate? targetLocation;

    _puzzle.forEach((key, value) {});

    for (final Coordinate key in _puzzle.keys) {
      if (_puzzle[key] == targetTile) {
        targetLocation = key;
        break;
      }
    }

    assert(targetLocation != null);
    return targetLocation!;
  }

  Future<void> _makeNextMove(Coordinate location, Coordinate target) async {
    Coordinate? movePiece;
    if (location == target) {
      return;
    }

    if (location.isSameRow(target)) {
      if (_blank.compare(isLeftOf: location, isSameRow: target)) {
        movePiece = _newMove(x: location.x);
      } else if (_blank.compare(isBelow: location)) {
        if (_blank.x == location.x - 1) {
          movePiece = _newMove(y: location.y);
        } else {
          movePiece = _newMove(x: location.x - 1);
        }
      } else {
        movePiece = _newMove(y: location.y + 1);
      }
    } else if (location.compare(isSameColumn: target)) {
      if (_blank.compare(isSameColumn: location, isAbove: location)) {
        movePiece = _newMove(y: location.y);
      } else if (location.x == 3 && _blank != target && location == target + const Coordinate(x: 0, y: 1)) {
        await _rotateEnd(target);
        return;
      } else if (_blank.compare(isAbove: location)) {
        movePiece = _newMove(x: location.x);
      } else if (_blank.compare(isSameColumn: location)) {
        movePiece = _newMove(x: location.x == 3 ? 2 : location.x + 1);
      } else if (_blank.compare(isRightOf: location) || (location.y - 1 > target.y || _blank.x > target.x)) {
        movePiece = _newMove(y: location.y - 1);
      } else if (_blank.compare(isSameRow: location)) {
        movePiece = _newMove(y: location.y + 1);
      } else {
        movePiece = _newMove(x: location.x == 3 ? 2 : location.x + 1);
      }
    } else {
      final isBlankCorrectDirection = (location.isLeftOf(_blank) && location.isLeftOf(target)) ||
          (location.isRightOf(_blank) && location.isRightOf(target));
      if (isBlankCorrectDirection) {
        if (_blank.isSameRow(location)) {
          movePiece = _newMove(x: location.x);
        } else {
          final shortMove = _newMove(y: location.y);
          if (_isSafeSlide(target: target, proposed: shortMove)) {
            movePiece = shortMove;
          } else {
            movePiece = _newMove(y: location.y + 1);
          }
        }
      } else if (_blank.isSameColumn(location)) {
        movePiece = _newMove(x: target.x);
      } else {
        final targetDirection = target.isLeftOf(location) ? -1 : 1;
        final preferredMove = _newMove(x: location.x + targetDirection);
        final alternateMove = _newMove(y: location.y - 1);
        if (!_blank.isSameRow(location) && _isSafeSlide(target: target, proposed: preferredMove)) {
          movePiece = preferredMove;
        } else if (_isSafeSlide(target: target, proposed: alternateMove) && alternateMove != _blank) {
          movePiece = alternateMove;
        } else {
          movePiece = _newMove(y: location.y + 1);
        }
      }
    }

    if (movePiece != null) {
      await _autoMove(movePiece);
    }
  }

  Future<void> _randomize() async {
    final random = Random();

    _gameState = GameState.randomizing;

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

    setState(() {
      _gameState = GameState.activeGame;
    });
  }

  void _stopSolve() {
    setState(() {
      _gameState = GameState.activeGame;
    });
  }

  VoidCallback? _getFabAction() {
    switch (_gameState) {
      case GameState.initial:
      case GameState.gameWon:
        return _randomize;
      case GameState.activeGame:
        return _solutionMove;
      case GameState.autoSolving:
        return _stopSolve;
      case GameState.randomizing:
        return null;
    }
  }

  Widget _getFabLabel() {
    switch (_gameState) {
      case GameState.initial:
      case GameState.gameWon:
      case GameState.randomizing:
        return const Text('New');
      case GameState.activeGame:
        return const Text('Solve');
      case GameState.autoSolving:
        return const Text('Stop');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Todo: fix with builder
    final media = MediaQuery.of(context);
    final width = min(media.size.width, media.size.height) / 5;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isPhoto = false;
              });
            },
            icon: const Text('15'),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isPhoto = true;
              });
            },
            icon: const Icon(Icons.photo_outlined),
          ),
        ],
      ),
      drawer: const PuzzleDrawer(),
      body: Center(
        child: Container(
          width: width * 4,
          height: width * 4,
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          child: Stack(
            children: [
              for (final key in _puzzle.keys)
                if (key != _blank)
                  AnimatedPositioned(
                    key: ValueKey(_puzzle[key]),
                    top: key.y * width,
                    left: key.x * width,
                    duration: _gameState == GameState.randomizing
                        ? const Duration(milliseconds: 50)
                        : const Duration(milliseconds: 150),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _move(key);
                        });
                      },
                      child: PuzzlePiece(
                        value: _puzzle[key],
                        size: width,
                        usePhoto: _isPhoto,
                      ),
                    ),
                  ),
              if (_isPhoto)
                AnimatedOpacity(
                  // If the widget is visible, animate to 0.0 (invisible).
                  // If the widget is hidden, animate to 1.0 (fully visible).
                  opacity: _gameState == GameState.gameWon ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  // The green box must be a child of the AnimatedOpacity widget.
                  child: _buildFullSizeImage(width * 4),
                )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getFabAction(),
        tooltip: 'Start',
        child: _getFabLabel(),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildFullSizeImage(width) {
    final settings = context.watch<Settings>();
    if (settings.imageFile != null) {
      return Image.network(
        settings.imageFile!.path,
        width: width,
        height: width,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'assets/family.jpg',
        width: width,
        height: width,
        fit: BoxFit.cover,
      );
    }
  }
}

enum GameState {
  initial,
  randomizing,
  activeGame,
  autoSolving,
  gameWon,
}
