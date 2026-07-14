// lib/widgets/spin_wheel.dart  (clean version — use this one)
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:maamaas/Services/spin/spinmodel.dart';
import 'package:maamaas/Services/spin/wheelpainter.dart';


class SpinWheel extends StatefulWidget {
  final List<WheelItem> items;
  final double size;
  final void Function(WheelItem winner) onSpinComplete;

  const SpinWheel({
    super.key,
    required this.items,
    required this.onSpinComplete,
    this.size = 300,
  });

  @override
  State<SpinWheel> createState() => SpinWheelState();
}

class SpinWheelState extends State<SpinWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _rotationAnim;
  double _rotation = 0;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _rotationAnim = Tween<double>(begin: 0, end: 0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _pickWeightedIndex() {
    final totalWeight =
    widget.items.fold<double>(0, (sum, i) => sum + i.weight);
    final rand = Random().nextDouble() * totalWeight;
    double cumulative = 0;
    for (int i = 0; i < widget.items.length; i++) {
      cumulative += widget.items[i].weight;
      if (rand <= cumulative) return i;
    }
    return widget.items.length - 1;
  }

  void spin() {
    if (_isSpinning) return;
    final winnerIndex = _pickWeightedIndex();
    final n = widget.items.length;
    final sweep = 2 * pi / n;

    // Center angle of the winning slice, measured clockwise from angle 0 (3 o'clock).
    final sliceCenter = winnerIndex * sweep + sweep / 2;

    // Pointer sits at top = -pi/2. We want:
    // (sliceCenter + finalRotation) mod 2pi == -pi/2 (mod 2pi)
    // Solve for the rotation needed, then add extra full spins.
    final jitter = (Random().nextDouble() - 0.5) * sweep * 0.5;
    double delta = (-pi / 2) - sliceCenter - jitter;
    delta = delta % (2 * pi);
    if (delta < 0) delta += 2 * pi;

    const extraSpins = 6;
    final targetRotation = _rotation + extraSpins * 2 * pi + delta;

    _rotationAnim = Tween<double>(begin: _rotation, end: targetRotation)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    setState(() => _isSpinning = true);
    _controller.forward(from: 0).then((_) {
      _rotation = targetRotation % (2 * pi);
      setState(() => _isSpinning = false);
      widget.onSpinComplete(widget.items[winnerIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _rotationAnim,
          builder: (context, child) => Transform.rotate(
            angle: _rotationAnim.value,
            child: child,
          ),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(painter: WheelPainter(items: widget.items)),
          ),
        ),
        Positioned(
          top: -8,
          child: Icon(Icons.arrow_drop_down, size: 48, color: Colors.red[700]),
        ),
      ],
    );
  }
}