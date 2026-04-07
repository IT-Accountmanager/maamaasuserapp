import 'package:flutter/material.dart';
import 'package:maamaas/session_Expired.dart';
import 'package:maamaas/widgets/app_navigator.dart';

class SessionOverlayController {
  static final SessionOverlayController _instance =
      SessionOverlayController._internal();

  factory SessionOverlayController() => _instance;

  SessionOverlayController._internal();

  OverlayEntry? _overlayEntry;
  bool _isShowing = false;

  void show() {
    if (_isShowing) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigatorState = navigatorKey.currentState;
      if (navigatorState == null) {
        debugPrint("❌ Navigator not ready");
        return;
      }

      final overlayState = navigatorState.overlay;
      if (overlayState == null) {
        debugPrint("❌ Overlay not available");
        return;
      }

      _overlayEntry = OverlayEntry(
        builder: (_) => const SessionExpiredScreen(),
      );

      overlayState.insert(_overlayEntry!);
      _isShowing = true;

      debugPrint("✅ Session overlay shown");
    });
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
  }
}
