import 'package:flutter/material.dart';
import 'package:maamaas/Services/App_color_service/app_colours.dart';
import '../Services/Auth_service/Subscription_authservice.dart';
import '../screens/screens/login_page.dart';
import '../screens/screens/loginscreensas.dart';
import '../screens/screens/signup_screen.dart';

class AuthRequiredWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onLogin;
  final VoidCallback? onSignup;

  const AuthRequiredWidget({
    super.key,
    this.title,
    this.subtitle,
    this.onLogin,
    this.onSignup,
  });

  @override
  Widget build(BuildContext context) {
    return
    // Center(
    // child:
    Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            title ?? "Sign in Required",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle ?? "Please login or create an account to continue.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),

          /// Login Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  onLogin ??
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, // your primaryColor
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// Signup Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed:
                  onSignup ??
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const Signup(), // replace with your signup screen
                      ),
                    );
                  },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5E35B1),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      // ),
    );
  }
}

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: subscription_AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.data!) {
          return const AuthRequiredWidget();
        }

        return child;
      },
    );
  }
}
