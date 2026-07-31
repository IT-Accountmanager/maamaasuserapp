import 'dart:math';
import 'package:flutter/material.dart';
import 'cubeface.dart';

class AnimatedDiceCube extends StatefulWidget {
  final double size;
  final Function(int) onRollComplete;

  const AnimatedDiceCube({
    super.key,
    required this.onRollComplete,
    this.size = 120,
  });

  @override
  State<AnimatedDiceCube> createState() => AnimatedDiceCubeState();
}

class AnimatedDiceCubeState extends State<AnimatedDiceCube>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  late Animation<double> rotateX;
  late Animation<double> rotateY;
  late Animation<double> rotateZ;

  final random = Random();

  bool rolling = false;

  int value = 1;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    rotateX = Tween<double>(
      begin: 0,
      end: pi * 8,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    rotateY = Tween<double>(
      begin: 0,
      end: pi * 7,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    rotateZ = Tween<double>(
      begin: 0,
      end: pi * 6,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
  }

  Future<void> roll() async {
    if (rolling) return;

    rolling = true;

    controller.reset();

    controller.forward();

    await Future.delayed(const Duration(milliseconds: 1600));

    setState(() {
      value = random.nextInt(6) + 1;
    });

    await controller.forward(from: 0);

    rolling = false;

    widget.onRollComplete(value);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Matrix4 _faceTransform({
    double x = 0,
    double y = 0,
    double z = 0,
    double rx = 0,
    double ry = 0,
  }) {
    return Matrix4.identity()
      ..translate(x, y, z)
      ..rotateX(rx)
      ..rotateY(ry);
  }

  @override
  Widget build(BuildContext context) {
    final depth = widget.size / 2;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateX(rotateX.value)
            ..rotateY(rotateY.value)
            ..rotateZ(rotateZ.value),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CubeFace(
                  value: 1,
                  faceColor: Colors.white,
                  size: widget.size,
                  transform: _faceTransform(z: depth),
                ),

                CubeFace(
                  value: 6,
                  faceColor: Colors.grey.shade100,
                  size: widget.size,
                  transform: _faceTransform(z: -depth, ry: pi),
                ),

                CubeFace(
                  faceColor: Colors.grey.shade100,
                  value: 2,
                  size: widget.size,
                  transform: _faceTransform(x: depth, ry: pi / 2),
                ),

                CubeFace(
                  faceColor: Colors.grey.shade100,
                  value: 5,
                  size: widget.size,
                  transform: _faceTransform(x: -depth, ry: -pi / 2),
                ),

                CubeFace(
                  faceColor: Colors.grey.shade100,
                  value: 3,
                  size: widget.size,
                  transform: _faceTransform(y: -depth, rx: pi / 2),
                ),

                CubeFace(
                  faceColor: Colors.grey.shade100,
                  value: 4,
                  size: widget.size,
                  transform: _faceTransform(y: depth, rx: -pi / 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
