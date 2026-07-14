// lib/screens/spin_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class SpinScreen11 extends StatefulWidget {
  const SpinScreen11({super.key});

  @override
  State<SpinScreen11> createState() => _SpinScreen11State();
}

class _SpinScreen11State extends State<SpinScreen11> {
  final StreamController<int> _controller = StreamController<int>();

  final List<String> _prizes = [
    '10 pts',
    '50 pts',
    'Try Again',
    '100 pts',
    'Jackpot',
    '20 pts',
    '30 pts'
  ];

  // Optional: weighted odds so some prizes are rarer than others.
  final List<double> _weights = [1, 1, 2, 1, 0.3, 1];

  String? _result;
  bool _spinning = false;

  int _pickWeightedIndex() {
    final total = _weights.fold<double>(0, (sum, w) => sum + w);
    final rand = Random().nextDouble() * total;
    double cumulative = 0;
    for (int i = 0; i < _weights.length; i++) {
      cumulative += _weights[i];
      if (rand <= cumulative) return i;
    }
    return _weights.length - 1;
  }

  void _spin() {
    if (_spinning) return;
    setState(() {
      _spinning = true;
      _result = null;
    });
    final winnerIndex = _pickWeightedIndex();
    _controller.add(winnerIndex);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spin & Win')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 320,
              width: 320,
              child: FortuneWheel(
                selected: _controller.stream,
                animateFirst: false,
                items: [
                  for (int i = 0; i < _prizes.length; i++)
                    FortuneItem(
                      child: Text(
                        _prizes[i],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: FortuneItemStyle(
                        color: Colors.primaries[i % Colors.primaries.length],
                        borderColor: Colors.white,
                        borderWidth: 2,
                      ),
                    ),
                ],
                onAnimationEnd: () {
                  // NOTE: the stream only carries the index; grab it separately
                },
              ),
            ),
            const SizedBox(height: 32),
            if (_result != null)
              Text('You won: $_result', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _spinning ? null : _spin,
              child: Text(_spinning ? 'Spinning...' : 'SPIN'),
            ),
          ],
        ),
      ),
    );
  }
}