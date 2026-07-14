// lib/widgets/dice_face.dart
import 'package:flutter/material.dart';

class DiceFace extends StatelessWidget {
  final int value; // 1–6
  final double size;
  final Color dotColor;
  final Color faceColor;

  const DiceFace({
    super.key,
    required this.value,
    this.size = 100,
    this.dotColor = Colors.black87,
    this.faceColor = Colors.white,
  });

  // Dot positions per value, in a 3x3 grid (row, col) from 0–2
  static const Map<int, List<List<int>>> _dotLayouts = {
    1: [
      [1, 1],
    ],
    2: [
      [0, 0],
      [2, 2],
    ],
    3: [
      [0, 0],
      [1, 1],
      [2, 2],
    ],
    4: [
      [0, 0],
      [0, 2],
      [2, 0],
      [2, 2],
    ],
    5: [
      [0, 0],
      [0, 2],
      [1, 1],
      [2, 0],
      [2, 2],
    ],
    6: [
      [0, 0],
      [0, 2],
      [1, 0],
      [1, 2],
      [2, 0],
      [2, 2],
    ],
  };

  @override
  Widget build(BuildContext context) {
    final dots = _dotLayouts[value] ?? [];
    final cellSize = size / 3;
    final dotSize = size * 0.16;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: faceColor,
        borderRadius: BorderRadius.circular(size * 0.18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          for (final pos in dots)
            Positioned(
              left: pos[1] * cellSize + (cellSize - dotSize) / 2,
              top: pos[0] * cellSize + (cellSize - dotSize) / 2,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
