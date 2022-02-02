import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_15/image.dart';
import 'package:flutter_15/settings.dart';
import 'package:provider/provider.dart';

import 'drawer.dart';
import 'game_engine.dart';
import 'puzzle_piece.dart';

// TODO: dartdoc
class FlutterPuzzlePage extends StatefulWidget {
  const FlutterPuzzlePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<FlutterPuzzlePage> createState() => _FlutterPuzzlePageState();
}

class _FlutterPuzzlePageState extends State<FlutterPuzzlePage> {
  /// Whether the image is a picture vs the numbers
  bool _isPhoto = false;

  /// Whether reset timer is running
  ///
  /// Once a game is won, it resets
  bool _isDisplayingWin = false;

  final _assetsAudioPlayer = AssetsAudioPlayer();

  final _gameEngine = GameEngine();

  @override
  initState() {
    super.initState();

    _gameEngine.addListener(engineListener);

    _assetsAudioPlayer.open(
      Audio('assets/winner.wav'),
      autoStart: false,
    );
  }

  @override
  void dispose() {
    _gameEngine.removeListener(engineListener);

    super.dispose();
  }

  void engineListener() {
    final settings = context.read<Settings>();
    if (!_isDisplayingWin && _gameEngine.gameState == GameState.gameWon) {
      if (settings.isPlayingSounds) {
        _assetsAudioPlayer.play();
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

  void _stopSolve() {
    _gameEngine.gameState = GameState.activeGame;
  }

  VoidCallback? _getFabAction() {
    switch (_gameEngine.gameState) {
      case GameState.initial:
      case GameState.gameWon:
        return _gameEngine.randomize;
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

  Duration _getAnimationDuration() {
    if (_gameEngine.gameState == GameState.randomizing) {
      return const Duration(milliseconds: 50);
    }

    final settings = context.read<Settings>();
    return Duration(milliseconds: 150 * settings.moveSpeed);
  }

  @override
  Widget build(BuildContext context) {
    // Todo: fix with builder vs media query
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
      // TODO: Teaching mode
      body: Center(
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
                      onTap: () {
                        _gameEngine.move(key);
                      },
                      child: PuzzlePiece(
                        value: _gameEngine.puzzle[key],
                        size: width,
                        usePhoto: _isPhoto,
                      ),
                    ),
                  ),
              if (_isPhoto)
                IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _gameEngine.gameState == GameState.gameWon ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: ImageFromSource(width: width * 4),
                  ),
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
}
