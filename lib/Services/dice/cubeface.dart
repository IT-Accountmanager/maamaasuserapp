import 'package:flutter/material.dart';
import 'dice.dart';

class CubeFace extends StatelessWidget {
  final int value;
  final Matrix4 transform;
  final double size;
  final Color faceColor;

  const CubeFace({
    super.key,
    required this.value,
    required this.transform,
    required this.size,
    required this.faceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: DiceFace(value: value, size: size, faceColor: faceColor),
    );
  }
}
