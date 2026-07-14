// lib/screens/spin_screen.dart
import 'package:flutter/material.dart';
import 'package:maamaas/Services/spin/spinmodel.dart';
import 'package:maamaas/Services/spin/spinwheeler.dart';


class SpinScreen extends StatefulWidget {
  const SpinScreen({super.key});

  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen> {
  final _wheelKey = GlobalKey<SpinWheelState>();

  final items =  [
    WheelItem(label: '10 pts', color: Colors.red),
    WheelItem(label: '50 pts', color: Colors.orange),
    WheelItem(label: 'Try Again', color: Colors.grey, weight: 2), // more common
    WheelItem(label: '100 pts', color: Colors.green),
    WheelItem(label: 'Jackpot', color: Colors.purple, weight: 0.3), // rare
    WheelItem(label: '20 pts', color: Colors.blue),
  ];

  String? _result;
  bool _spinning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spin & Win')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinWheel(
              key: _wheelKey,
              items: items,
              size: 320,
              onSpinComplete: (winner) {
                setState(() {
                  _result = winner.label;
                  _spinning = false;
                });
                // TODO: apply reward to user's account here
              },
            ),
            const SizedBox(height: 32),
            if (_result != null)
              Text('You won: $_result', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _spinning
                  ? null
                  : () {
                setState(() {
                  _spinning = true;
                  _result = null;
                });
                _wheelKey.currentState?.spin();
              },
              child: Text(_spinning ? 'Spinning...' : 'SPIN'),
            ),
          ],
        ),
      ),
    );
  }
}