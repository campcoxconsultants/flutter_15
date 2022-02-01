import 'package:flutter/material.dart';
import 'package:flutter_15/image.dart';
import 'package:flutter_15/settings.dart';
import 'package:provider/provider.dart';

class PuzzlePiece extends StatelessWidget {
  const PuzzlePiece({
    Key? key,
    this.value,
    required this.size,
    this.usePhoto = false,
  }) : super(key: key);

  final int? value;
  final double size;
  final bool usePhoto;

  double _getAlign(int value) {
    switch (value) {
      case 0:
        return -1;
      case 1:
        return -1 / 3;
      case 2:
        return 1 / 3;
      case 3:
        return 1;
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: _buildDisplay(settings),
    );
  }

  Widget _buildDisplay(Settings settings) {
    if (!usePhoto) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            value != null ? '$value' : '',
            style: TextStyle(fontSize: size * 0.8),
          ),
        ),
      );
    }

    return ClipRect(
      child: Align(
        alignment: Alignment(_getAlign((value! - 1) % 4), _getAlign((value! - 1) ~/ 4)),
        heightFactor: 0.25,
        widthFactor: 0.25,
        child: SizedBox(
          width: size * 4,
          height: size * 4,
          child: ImageFromSource(width: size * 4),
        ),
      ),
    );
  }
}
