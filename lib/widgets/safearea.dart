import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformSafeArea extends StatelessWidget {
  final Widget child;

  /// Whether to apply SafeArea on Android.
  final bool android;

  /// Whether to apply SafeArea on iOS.
  final bool ios;

  const PlatformSafeArea({
    super.key,
    required this.child,
    this.android = true,
    this.ios = false,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return child;

    if (Platform.isAndroid && android) {
      return SafeArea(child: child);
    }

    if (Platform.isIOS && ios) {
      return SafeArea(child: child);
    }

    return child;
  }
}
