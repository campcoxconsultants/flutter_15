import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_15/coord.dart';
import 'package:flutter_15/image.dart';
import 'package:flutter_15/settings.dart';

import 'drawer.dart';
import 'game_engine.dart';
import 'puzzle_piece.dart';

// TODO: dartdoc
class FlutterPuzzlePage extends StatefulWidget {
  const FlutterPuzzlePage({
    Key? key,
    required this.settings,
  }) : super(key: key);

  final Settings settings;

  @override
  State<FlutterPuzzlePage> createState() => _FlutterPuzzlePageState();
}

class _FlutterPuzzlePageState extends State<FlutterPuzzlePage> {
  static const _sideDisplaySize = 300.0;
  static const _verticalDisplaySize = 100.0;

  /// Whether the image is a picture vs the numbers
  bool _isPhoto = false;

  /// Whether reset timer is running
  ///
  /// Once a game is won, it resets
  bool _isDisplayingWin = false;

  /// Whether the game has been started.
  ///
  /// [initial] and [randomizing] are the unstarted states.
  bool get _isStartedGame =>
      _gameEngine.gameState != GameState.initial && _gameEngine.gameState != GameState.randomizing;

  bool _isTimerRunning = false;

  /// Stopwatch display
  String get _elapsedTimeString =>
      _gameEngine.elapsedTime.inMinutes.toString().padLeft(2, '0') +
      ':' +
      (_gameEngine.elapsedTime.inSeconds % 60).toString().padLeft(2, '0');

  final _assetsAudioPlayer = AssetsAudioPlayer();

  late final GameEngine _gameEngine;

  @override
  initState() {
    super.initState();

    _gameEngine = GameEngine(settings: widget.settings);
    _gameEngine.addListener(_engineListener);
    widget.settings.addListener(_settingsListener);

    _assetsAudioPlayer.open(
      Audio('assets/winner.wav'),
      autoStart: false,
    );
  }

  @override
  void dispose() {
    _gameEngine.removeListener(_engineListener);
    widget.settings.removeListener(_settingsListener);

    super.dispose();
  }

  void _settingsListener() {
    if (widget.settings.puzzleWidth != _gameEngine.currentWidth ||
        widget.settings.puzzleHeight != _gameEngine.currentHeight) {
      _gameEngine.initializePuzzle();
    }
    setState(() {});
  }

  void _engineListener() async {
    if (!_isDisplayingWin && _gameEngine.gameState == GameState.gameWon) {
      if (widget.settings.isPlayingSounds) {
        await _assetsAudioPlayer.play();
      }

      Future.delayed(
        const Duration(seconds: 3),
        () {
          _isDisplayingWin = false;
          // Make sure we are still in the same state
          if (_gameEngine.gameState == GameState.gameWon) {
            _gameEngine.gameState = GameState.initial;
          }
        },
      );
    }

    setState(() {});
  }

  void _startElapsedTimeTimer() async {
    _isTimerRunning = true;

    while (true) {
      if (!_isTimerRunning || !_isStartedGame) {
        _isTimerRunning = false;
        return;
      }

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) {
        _isTimerRunning = false;
        return;
      }
      setState(() {});
    }
  }

  void _stopSolve() {
    _gameEngine.gameState = GameState.activeGame;
  }

  Offset _cumulativeDrag = const Offset(0, 0);
  bool _hasSlid = false;
  _onDragStart(Coordinate square, DragStartDetails details) {
    _hasSlid = false;
  }

  _onDragUpdate(Coordinate square, DragUpdateDetails details) {
    _cumulativeDrag += details.delta;
    _checkMove(square);
  }

  _onDragEnd(Coordinate square, DragEndDetails details) {
    setState(() {
      _cumulativeDrag = const Offset(0, 0);
      _hasSlid = false;
    });
  }

  _checkMove(Coordinate square) {
    if (_hasSlid) {
      return;
    }

    double delta = 0;
    if (_gameEngine.canSlideHorizontally(square)) {
      if (square.isRightOf(_gameEngine.blank)) {
        delta = -_cumulativeDrag.dx;
      } else {
        delta = _cumulativeDrag.dx;
      }
    } else if (square.isAbove(_gameEngine.blank)) {
      delta = _cumulativeDrag.dy;
    } else {
      delta = -_cumulativeDrag.dy;
    }

    if (delta > 5) {
      _hasSlid = true;
      _gameEngine.move(square);
    }
  }

  VoidCallback? _getFabAction() {
    switch (_gameEngine.gameState) {
      case GameState.initial:
      case GameState.gameWon:
        return _gameEngine.startGame;
      case GameState.activeGame:
        return _gameEngine.solutionMove;
      case GameState.autoSolving:
        return _stopSolve;
      case GameState.randomizing:
        return null;
    }
  }

  Widget _getFabLabel() {
    switch (_gameEngine.gameState) {
      case GameState.activeGame:
        return const Text('Solve');
      case GameState.autoSolving:
        return const Text('Stop');
      case GameState.initial:
      case GameState.gameWon:
      case GameState.randomizing:
        return const Text('New');
    }
  }

  Duration _getAnimationDuration() {
    if (_gameEngine.gameState == GameState.randomizing) {
      return const Duration(milliseconds: 50);
    }

    return Duration(milliseconds: 150 * widget.settings.moveSpeed);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isTimerRunning || !_isStartedGame) {
      _startElapsedTimeTimer();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Slider'),
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
      drawer: PuzzleDrawer(
        settings: widget.settings,
      ),
      body: LayoutBuilder(
        builder: (_, BoxConstraints constraints) {
          final portraitWidthConstraint = constraints.maxWidth / (widget.settings.puzzleWidth + 0.25);
          final landscapeWidthConstraint = (constraints.maxWidth -
                  (widget.settings.isShowingStatus || widget.settings.isTeachingMode ? _sideDisplaySize : 0)) /
              (widget.settings.puzzleWidth + 0.25);
          final portraitHeightConstraint =
              (constraints.maxHeight - _verticalDisplaySize) / (widget.settings.puzzleHeight + 0.25);
          final landscapeHeightConstraint = constraints.maxHeight / (widget.settings.puzzleHeight + 0.25);
          final portraitSize = min(portraitWidthConstraint, portraitHeightConstraint);
          final landscapeSize = min(landscapeWidthConstraint, landscapeHeightConstraint);

          if (landscapeSize > portraitSize) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildPuzzleStack(landscapeSize),
                if (widget.settings.isShowingStatus || widget.settings.isTeachingMode)
                  SizedBox(
                    width: _sideDisplaySize,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        if (widget.settings.isShowingStatus)
                          Text(
                            'Time: $_elapsedTimeString'
                            '\nMoves: ${_gameEngine.numberOfMoves}',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        const Spacer(
                          flex: 3,
                        ),
                        if (widget.settings.isTeachingMode && _gameEngine.gameState == GameState.autoSolving) ...[
                          Text(
                            _gameEngine.solvingHeadline ?? '',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            _gameEngine.solvingDetails.join('\n'),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                        const Spacer(),
                      ],
                    ),
                  ),
              ],
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Time: $_elapsedTimeString',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      'Moves: ${_gameEngine.numberOfMoves}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                _buildPuzzleStack(portraitSize),
                if (widget.settings.isTeachingMode && _gameEngine.gameState == GameState.autoSolving) ...[
                  Text(
                    _gameEngine.solvingHeadline ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    _gameEngine.solvingDetails.join('. '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getFabAction(),
        child: _getFabLabel(),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Center _buildPuzzleStack(double width) {
    return Center(
      child: Container(
        width: width * widget.settings.puzzleWidth,
        height: width * widget.settings.puzzleHeight,
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: Stack(
          children: [
            for (final key in _gameEngine.puzzle.keys)
              if (key != _gameEngine.blank)
                AnimatedPositioned(
                  key: ValueKey(_gameEngine.puzzle[key]),
                  top: key.y * width,
                  left: key.x * width,
                  duration: _getAnimationDuration(),
                  child: GestureDetector(
                    onTap: widget.settings.isSliding
                        ? null
                        : () {
                            _gameEngine.move(key);
                          },
                    onHorizontalDragStart: _gameEngine.canSlideHorizontally(key)
                        ? (details) {
                            _onDragStart(key, details);
                          }
                        : null,
                    onHorizontalDragUpdate: _gameEngine.canSlideHorizontally(key)
                        ? (details) {
                            _onDragUpdate(key, details);
                          }
                        : null,
                    onHorizontalDragEnd: _gameEngine.canSlideHorizontally(key)
                        ? (details) {
                            _onDragEnd(key, details);
                          }
                        : null,
                    onVerticalDragStart: _gameEngine.canSlideVertically(key)
                        ? (details) {
                            _onDragStart(key, details);
                          }
                        : null,
                    onVerticalDragUpdate: _gameEngine.canSlideVertically(key)
                        ? (details) {
                            _onDragUpdate(key, details);
                          }
                        : null,
                    onVerticalDragEnd: _gameEngine.canSlideVertically(key)
                        ? (details) {
                            _onDragEnd(key, details);
                          }
                        : null,
                    child: PuzzlePiece(
                      value: _gameEngine.puzzle[key],
                      size: width,
                      usePhoto: _isPhoto,
                      settings: widget.settings,
                    ),
                  ),
                ),
            if (_isPhoto)
              IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _gameEngine.gameState == GameState.gameWon ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: ImageFromSource(
                    width: width * widget.settings.puzzleWidth,
                    height: width * widget.settings.puzzleHeight,
                    settings: widget.settings,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
