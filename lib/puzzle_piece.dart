import 'package:flutter/material.dart';
import 'package:flutter_15/image.dart';
import 'package:flutter_15/settings.dart';

class PuzzlePiece extends StatelessWidget {
  const PuzzlePiece({
    Key? key,
    this.value,
    required this.size,
    required this.settings,
    this.usePhoto = false,
  }) : super(key: key);

  final int? value;
  final double size;
  final bool usePhoto;
  final Settings settings;

  double _getAlign(int value, int numberOfSquares) {
    final percentage = value.toDouble() / (numberOfSquares - 1);

    if (percentage < 0.5) {
      return -1 + 2 * percentage;
    } else {
      return 1 - 2 * (1 - percentage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: _buildDisplay(),
    );
  }

  Widget _buildDisplay() {
    if (!usePhoto) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            value != null ? '$value' : '',
            style: TextStyle(fontSize: size * 0.75),
          ),
        ),
      );
    }

    return ClipRect(
      child: Align(
        alignment: Alignment(
          _getAlign((value! - 1) % settings.puzzleWidth, settings.puzzleWidth),
          _getAlign((value! - 1) ~/ settings.puzzleWidth, settings.puzzleHeight),
        ),
        heightFactor: 1 / settings.puzzleHeight,
        widthFactor: 1 / settings.puzzleWidth,
        child: SizedBox(
          width: size * settings.puzzleWidth,
          height: size * settings.puzzleHeight,
          child: ImageFromSource(
            width: size * settings.puzzleWidth,
            height: size * settings.puzzleHeight,
            settings: settings,
          ),
        ),
      ),
    );
  }
}
