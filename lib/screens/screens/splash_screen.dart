// DROP-IN replacement for: lib/screens/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/App_color_service/app_colours.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/fcmservice/fcm_services.dart';
import '../foodmainscreen.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool isLoggedIn = false;
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _dotsCtrl;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initializeApp();
      unawaited(FCMService().initFCM());
    });
  }

  void _setupAnimations() {
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(_textCtrl);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _logoCtrl.forward().then((_) => _textCtrl.forward());
  }

  Future<void> _initializeApp() async {
    try {
      await _checkLogin();
      unawaited(_requestPermissions());
    } catch (e) {
      debugPrint('Splash init failed: $e');
    }
    await Future.delayed(const Duration(milliseconds: 2400));
    _navigate();
  }

  Future<void> _checkLogin() async {
    try {
      final loggedIn = await subscription_AuthService.isLoggedIn().timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
      isLoggedIn = loggedIn;
    } catch (_) {
      isLoggedIn = false;
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await Permission.notification.request();
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) {
        await openAppSettings();
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);
      debugPrint("latitide: ${position.latitude}");
      debugPrint("longitude: ${position.longitude}");
    } catch (_) {}
  }

  void _navigate() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              isLoggedIn ? const MainScreenfood() : const LoginPage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _pulseCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // ── Animated Logo ─────────────────────────────────────────────
              // Center(
              //   child: ScaleTransition(
              //     scale: _logoScale,
              //     child: FadeTransition(
              //       opacity: _logoOpacity,
              //       child: ScaleTransition(
              //         scale: _pulse,
              //         child: Container(
              //           width: 130.w,
              //           height: 130.w,
              //           decoration: BoxDecoration(
              //             color: Colors.white.withOpacity(0.12),
              //             shape: BoxShape.circle,
              //             border: Border.all(
              //               color: Colors.white.withOpacity(0.3),
              //               width: 2.5,
              //             ),
              //           ),
              //           child: Center(
              //             child: Container(
              //               width: 96.w,
              //               height: 96.w,
              //               decoration: const BoxDecoration(
              //                 color: Colors.white,
              //                 shape: BoxShape.circle,
              //               ),
              //               child: Center(
              //                 child: Icon(
              //                   Icons.restaurant_rounded,
              //                   size: 48.sp,
              //                   color: AppColors.primary,
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // SizedBox(height: 32.h),
              // ── App Name ──────────────────────────────────────────────────
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Column(
                    children: [
                      Text(
                        "MAAMAAS",
                        style: AppText.display1.copyWith(
                          color: Colors.white,
                          fontSize: 36.sp,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Taste the moment, every time",
                        style: AppText.body.copyWith(
                          color: Colors.white.withOpacity(0.75),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // ── Dots loader ───────────────────────────────────────────────
              FadeTransition(
                opacity: _textOpacity,
                child: _AnimatedDots(controller: _dotsCtrl),
              ),
              SizedBox(height: 52.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedDots extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final delay = i / 3;
          final t = ((controller.value - delay) % 1.0).clamp(0.0, 1.0);
          final scale = (0.5 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2)).clamp(
            0.0,
            1.0,
          );
          final opacity = (0.6 + 0.4 * scale).clamp(0.0, 1.0); // ← clamped
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 9.w,
                height: 9.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
