// lib/widgets/animated_dice.dart
import 'dart:math';
import 'package:flutter/material.dart';

import 'dice.dart';

class AnimatedDice extends StatefulWidget {
  final double size;
  final void Function(int result) onRollComplete;

  const AnimatedDice({
    super.key,
    required this.onRollComplete,
    this.size = 100,
  });

  @override
  State<AnimatedDice> createState() => AnimatedDiceState();
}

class AnimatedDiceState extends State<AnimatedDice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _displayValue = 1;
  bool _rolling = false;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> roll() async {
    if (_rolling) return;
    setState(() => _rolling = true);

    final finalValue = _random.nextInt(6) + 1;

    // Rapidly cycle through random faces to sell the "rolling" effect.
    const totalTicks = 12;
    for (int i = 0; i < totalTicks; i++) {
      await Future.delayed(Duration(milliseconds: 60 + i * 8)); // slow down over time
      setState(() {
        _displayValue = i == totalTicks - 1 ? finalValue : _random.nextInt(6) + 1;
      });
    }

    setState(() => _rolling = false);
    widget.onRollComplete(finalValue);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _rolling ? 1 : 0),
      duration: const Duration(milliseconds: 150),
      builder: (context, wobble, child) {
        return Transform.rotate(
          angle: _rolling ? sin(_controller.value * 20) * 0.15 : 0,
          child: child,
        );
      },
      child: DiceFace(value: _displayValue, size: widget.size),
    );
  }
}