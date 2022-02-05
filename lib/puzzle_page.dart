import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_15/image.dart';
import 'package:flutter_15/settings.dart';

import 'drawer.dart';
import 'game_engine.dart';
import 'puzzle_piece.dart';

// TODO: dartdoc
class FlutterPuzzlePage extends StatefulWidget {
  const FlutterPuzzlePage({
    Key? key,
    required this.title,
    required this.settings,
  }) : super(key: key);

  final String title;
  final Settings settings;

  @override
  State<FlutterPuzzlePage> createState() => _FlutterPuzzlePageState();
}

class _FlutterPuzzlePageState extends State<FlutterPuzzlePage> {
  static const sideDisplaySize = 275.0;

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

  _onDragStart() {}

  _onDragUpdate() {}

  _onDragEnd() {}

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
      drawer: PuzzleDrawer(
        settings: widget.settings,
      ),
      // TODO: Teaching mode
      body: LayoutBuilder(
        builder: (_, BoxConstraints constraints) {
          final spaceNeeded =
              widget.settings.isShowingStatus || widget.settings.isTeachingMode ? sideDisplaySize + 25 : 0;

          if (constraints.maxHeight < constraints.maxWidth - spaceNeeded) {
            final size = constraints.maxHeight / 4.25;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildPuzzleStack(size),
                if (widget.settings.isShowingStatus || widget.settings.isTeachingMode)
                  SizedBox(
                    width: sideDisplaySize,
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
            final size = (min(constraints.maxHeight, constraints.maxWidth) - 108) / 4.25;
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
                _buildPuzzleStack(size),
                Text(
                  _gameEngine.solvingHeadline ?? '',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  _gameEngine.solvingDetails.join('. '),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
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
    // TODO: Ditch provider for Constructor injection
    return Center(
      child: Container(
        width: width * 4,
        height: width * 4,
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
                    // TODO: allow for sliding pieces
                    onTap: widget.settings.isSliding
                        ? null
                        : () {
                            _gameEngine.move(key);
                          },
                    onHorizontalDragUpdate: widget.settings.isSliding
                        ? (details) {
                            _gameEngine.move(key);
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
                    width: width * 4,
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
