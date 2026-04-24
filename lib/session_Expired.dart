// ignore: file_names
import 'package:flutter/material.dart';
import 'package:maamaas/screens/screens/login_page.dart';
import 'package:maamaas/screens/screens/loginscreensas.dart';
import 'package:maamaas/widgets/app_navigator.dart';
import 'Services/Auth_service/Apiclient.dart';
import 'session_controller.dart';

class SessionExpiredScreen extends StatelessWidget {
  const SessionExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                "Session Expired",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please login again to continue.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  SessionOverlayController().hide();

                  await ApiClient.clearSession();

                  navigatorKey.currentState!.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text("Login Again"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
