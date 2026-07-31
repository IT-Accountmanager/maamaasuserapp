// lib/screens/dice_screen.dart
import 'package:flutter/material.dart';

import 'animateddice.dart';

class DiceScreen extends StatefulWidget {
  final int diceCount;
  const DiceScreen({super.key, this.diceCount = 1});

  @override
  State<DiceScreen> createState() => _DiceScreenState();
}

class _DiceScreenState extends State<DiceScreen> {
  late final List<GlobalKey<AnimatedDiceCubeState>> _keys;

  late final List<int> _results;
  bool _rolling = false;

  void initState() {
    super.initState();

    _keys = List.generate(
      widget.diceCount,
      (_) => GlobalKey<AnimatedDiceCubeState>(),
    );

    _results = List.filled(widget.diceCount, 1);
  }

  Future<void> _rollAll() async {
    if (_rolling) return;
    setState(() => _rolling = true);

    // Roll all dice concurrently and wait for all to finish.
    final futures = <Future>[];
    for (int i = 0; i < _keys.length; i++) {
      futures.add(_keys[i].currentState!.roll());
    }
    await Future.wait(futures);

    setState(() => _rolling = false);
  }

  int get _total => _results.reduce((a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dice Roll')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: List.generate(
                widget.diceCount,
                (i) => AnimatedDiceCube(
                  key: _keys[i],
                  size: 120,
                  onRollComplete: (value) {
                    setState(() {
                      _results[i] = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            // if (widget.diceCount > 1)
            Text(
              'Total: $_total',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _rolling ? null : _rollAll,
              child: Text(_rolling ? 'Rolling...' : 'ROLL'),
            ),
          ],
        ),
      ),
    );
  }
}
