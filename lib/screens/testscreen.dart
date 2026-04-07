import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class testscreen extends StatelessWidget {
  const testscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            FirebaseCrashlytics.instance.crash();
          },
          child: Text("Test Crash"),
        ),
      ),
    );
  }
}
