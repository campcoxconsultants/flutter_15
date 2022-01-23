import 'package:flutter/material.dart';

class PuzzlePiece extends StatelessWidget {
  const PuzzlePiece({
    Key? key,
    this.value,
    required this.size,
  }) : super(key: key);

  final int? value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Center(
        child: Text(
          value != null ? '$value' : '',
          style: TextStyle(fontSize: size * 0.8),
        ),
      ),
    );
  }
}
