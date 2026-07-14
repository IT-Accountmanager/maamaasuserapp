// lib/models/wheel_item.dart
import 'package:flutter/material.dart';

class WheelItem {
  final String label;
  final Color color;
  final double weight; // higher weight = more likely to be picked

  const WheelItem({
    required this.label,
    required this.color,
    this.weight = 1.0,
  });
}