// // DROP-IN replacement for: lib/screens/screens/splash_screen.dart
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:maamaas/screens/screens/signup_screen.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Services/App_color_service/app_colours.dart';
// import '../../Services/Auth_service/Subscription_authservice.dart';
// import '../../Services/appconfigurations/app_configurtion_service.dart';
// import '../../Services/appconfigurations/cofigkeys.dart';
// import '../../Services/fcmservice/fcm_services.dart';
// import '../../Services/googleservices/Location_servces.dart';
// import '../Mainscreen.dart';
// import '../../Services/appconfigurations/appmaintainancescreen.dart';
// import 'login_page.dart';
//
// class SplashScreen extends StatefulWidget {
//   final int? pendingCampaignId;
//   final Future<void> Function()? waitForReferrer; // ✅ ADD THIS
//   const SplashScreen({super.key, this.pendingCampaignId, this.waitForReferrer});
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   bool isLoggedIn = false;
//   late final AnimationController _logoCtrl;
//   late final AnimationController _textCtrl;
//   late final AnimationController _pulseCtrl;
//   late final AnimationController _dotsCtrl;
//   late final Animation<Offset> _textSlide;
//   late final Animation<double> _textOpacity;
//
//   String kPendingReferralCodeKey = 'pending_referral_code';
//
//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       _initializeApp();
//       unawaited(FCMService().initFCM());
//     });
//     debugPrint("SPLASH OPENED");
//   }
//
//   @override
//   void dispose() {
//     _logoCtrl.dispose();
//     _textCtrl.dispose();
//     _pulseCtrl.dispose();
//     _dotsCtrl.dispose();
//     super.dispose();
//   }
//
//   void _setupAnimations() {
//     _logoCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//
//     _textCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _textSlide = Tween<Offset>(
//       begin: const Offset(0, 0.4),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
//     _textOpacity = Tween<double>(begin: 0, end: 1).animate(_textCtrl);
//
//     _pulseCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     )..repeat(reverse: true);
//
//     _dotsCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     )..repeat();
//
//     _logoCtrl.forward().then((_) => _textCtrl.forward());
//   }
//
//   // Future<void> _initializeApp() async {
//   //   try {
//   //     print("login check");
//   //     await _checkLogin();
//   //     unawaited(_requestPermissions());
//   //     print("request permission");
//   //     // await _requestPermissions();
//   //     // ✅ ONLY if already logged in → send location to API
//   //     if (isLoggedIn) {
//   //       await _sendLocationToApi();
//   //     }
//   //   } catch (e) {
//   //     //       debugPrint('Splash init failed: $e');
//   //   }
//   //   debugPrint("SPLASH START");
//   //
//   //   if (widget.waitForReferrer != null) {
//   //     await widget.waitForReferrer!();
//   //   }
//   //
//   //   debugPrint("SPLASH END");
//   //
//   //   await Future.delayed(const Duration(milliseconds: 1200));
//   //   _navigate();
//   // }
//   Future<void> _initializeApp() async {
//     try {
//       debugPrint("LOGIN CHECK START");
//
//       await _checkLogin();
//
//       debugPrint("LOGIN CHECK DONE");
//
//       unawaited(_requestPermissions());
//
//       debugPrint("PERMISSION REQUEST STARTED");
//
//       if (isLoggedIn) {
//         unawaited(_sendLocationToApi());
//       }
//
//       debugPrint("SPLASH START");
//
//       if (widget.waitForReferrer != null) {
//         debugPrint("WAITING FOR REFERRER");
//
//         await widget.waitForReferrer!().timeout(
//           const Duration(seconds: 5),
//           onTimeout: () {
//             debugPrint("REFERRER TIMEOUT");
//           },
//         );
//
//         debugPrint("REFERRER COMPLETED");
//       }
//
//       debugPrint("SPLASH END");
//       await AppConfigService.instance.loadConfigs();
//
//       debugPrint(
//         "Configs Loaded: ${AppConfigService.instance.allConfigs.length}",
//       );
//
//       await Future.delayed(const Duration(milliseconds: 1200));
//
//       debugPrint("NAVIGATE START");
//
//       await AppConfigService.instance.loadConfigs();
//
//       final maintenanceEnabled = AppConfigService.instance.isEnabled(
//         AppConfigKeys.appMaintenance,
//       );
//
//       if (maintenanceEnabled) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const MaintenanceScreen()),
//         );
//         return;
//       }
//
//       _navigate();
//     } catch (e, s) {
//       debugPrint("SPLASH ERROR = $e");
//       debugPrint("$s");
//
//       _navigate();
//     }
//   }
//
//   Future<void> _checkLogin() async {
//     try {
//       final loggedIn = await subscription_AuthService.isLoggedIn().timeout(
//         const Duration(seconds: 5),
//         onTimeout: () => false,
//       );
//       isLoggedIn = loggedIn;
//     } catch (_) {
//       isLoggedIn = false;
//     }
//   }
//
//   Future<void> _requestPermissions() async {
//     try {
//       debugPrint("PERMISSION START");
//
//       debugPrint("BEFORE NOTIFICATION");
//
//       final status = await Permission.notification.request();
//
//       debugPrint("AFTER NOTIFICATION = $status");
//       debugPrint("NOTIFICATION DONE");
//
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//
//       debugPrint("LOCATION SERVICE = $serviceEnabled");
//
//       if (!serviceEnabled) return;
//
//       LocationPermission permission = await Geolocator.checkPermission();
//
//       debugPrint("CURRENT LOCATION PERMISSION = $permission");
//
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//
//         debugPrint("AFTER LOCATION REQUEST = $permission");
//
//         if (permission == LocationPermission.denied) return;
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         debugPrint("LOCATION DENIED FOREVER");
//         await openAppSettings();
//         return;
//       }
//
//       debugPrint("GETTING POSITION");
//
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       ).timeout(const Duration(seconds: 8));
//
//       debugPrint("POSITION = ${position.latitude}, ${position.longitude}");
//
//       final prefs = await SharedPreferences.getInstance();
//
//       await prefs.setDouble('latitude', position.latitude);
//       await prefs.setDouble('longitude', position.longitude);
//
//       debugPrint("LOCATION SAVED");
//     } catch (e, s) {
//       debugPrint("PERMISSION ERROR = $e");
//       debugPrint("$s");
//     }
//   }
//
//   Future<void> _sendLocationToApi() async {
//     try {
//       //       debugPrint("📡 Sending location to API (Splash)...");
//
//       final prefs = await SharedPreferences.getInstance();
//
//       final lat = prefs.getDouble('latitude');
//       final lng = prefs.getDouble('longitude');
//
//       if (lat == null || lng == null) {
//         //         debugPrint("⚠️ No stored location found");
//         return;
//       }
//
//       // If you have reverse geocoding service, use it here
//       final location = await LocationService.getCurrentLocationWithAddress();
//
//       if (location != null) {
//         final ok = await subscription_AuthService.updateLocation(
//           latitude: location.latitude,
//           longitude: location.longitude,
//           address: location.fullAddress,
//           city: location.city,
//         );
//         //
//         // debugPrint("📡 Splash Location API status: $ok");
//
//         if (ok) {
//           await prefs.setBool('locationSet', true);
//         }
//       }
//     } catch (e) {
//       //       debugPrint("❌ Splash location API error: $e");
//     }
//   }
//
//   Future<void> _navigate() async {
//     if (!mounted) return;
//
//     final prefs = await SharedPreferences.getInstance();
//
//     final referralCode = prefs.getString(kPendingReferralCodeKey);
//
//     if (!isLoggedIn && referralCode != null && referralCode.isNotEmpty) {
//       debugPrint("GOING TO SIGNUP");
//       debugPrint("REFERRAL IN SPLASH = $referralCode");
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => Signup(referralCode: referralCode)),
//       );
//       return;
//     }
//     debugPrint("REFERRAL IN SPLASH = $referralCode");
//     debugPrint("isLoggedIn = $isLoggedIn");
//     debugPrint("NAVIGATE => isLoggedIn=$isLoggedIn referral=$referralCode");
//
//     debugPrint("GOING TO LOGIN");
//
//     Navigator.pushReplacement(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (_, __, ___) {
//           if (isLoggedIn) {
//             return MainScreenfood(showPromotion: true);
//           }
//
//           return const LoginScreen();
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(gradient: AppColors.splashGradient),
//         child: SafeArea(
//           child: Column(
//             children: [
//               const Spacer(flex: 2),
//
//               // ── App Name ──────────────────────────────────────────────────
//               SlideTransition(
//                 position: _textSlide,
//                 child: FadeTransition(
//                   opacity: _textOpacity,
//                   child: Column(
//                     children: [
//                       Text(
//                         "MAAMAAS",
//                         style: AppText.display1.copyWith(
//                           color: Colors.white,
//                           fontSize: 36.sp,
//                           letterSpacing: 1.5,
//                         ),
//                       ),
//                       SizedBox(height: 8.h),
//                       Text(
//                         "Taste the moment, every time",
//                         style: AppText.body.copyWith(
//                           // ignore: deprecated_member_use
//                           color: Colors.white.withOpacity(0.75),
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const Spacer(flex: 3),
//               // ── Dots loader ───────────────────────────────────────────────
//               FadeTransition(
//                 opacity: _textOpacity,
//                 child: _AnimatedDots(controller: _dotsCtrl),
//               ),
//               SizedBox(height: 52.h),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _AnimatedDots extends StatelessWidget {
//   final AnimationController controller;
//   const _AnimatedDots({required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: controller,
//       builder: (_, __) => Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: List.generate(3, (i) {
//           final delay = i / 3;
//           final t = ((controller.value - delay) % 1.0).clamp(0.0, 1.0);
//           final scale = (0.5 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2)).clamp(
//             0.0,
//             1.0,
//           );
//           final opacity = (0.6 + 0.4 * scale).clamp(0.0, 1.0); // ← clamped
//           return Container(
//             margin: EdgeInsets.symmetric(horizontal: 5.w),
//             child: Transform.scale(
//               scale: scale,
//               child: Container(
//                 width: 9.w,
//                 height: 9.w,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(opacity),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

// DROP-IN replacement for: lib/screens/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maamaas/screens/screens/signup_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/App_color_service/app_colours.dart';
import '../../Services/App_color_service/app_text.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/fcmservice/fcm_services.dart';
import '../../Services/googleservices/Location_servces.dart';
import '../Mainscreen.dart';
import '../homescreens/home_page.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  final int? pendingCampaignId;
  final Future<void> Function()? waitForReferrer; // ✅ ADD THIS
  const SplashScreen({super.key, this.pendingCampaignId, this.waitForReferrer});
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

  String kPendingReferralCodeKey = 'pending_referral_code';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initializeApp();
      unawaited(FCMService().initFCM());
    });
    // debugPrint("SPLASH OPENED");
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _pulseCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
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

  // Future<void> _initializeApp() async {
  //   try {
  //     print("login check");
  //     await _checkLogin();
  //     unawaited(_requestPermissions());
  //     print("request permission");
  //     // await _requestPermissions();
  //     // ✅ ONLY if already logged in → send location to API
  //     if (isLoggedIn) {
  //       await _sendLocationToApi();
  //     }
  //   } catch (e) {
  //     //       debugPrint('Splash init failed: $e');
  //   }
  //   debugPrint("SPLASH START");
  //
  //   if (widget.waitForReferrer != null) {
  //     await widget.waitForReferrer!();
  //   }
  //
  //   debugPrint("SPLASH END");
  //
  //   await Future.delayed(const Duration(milliseconds: 1200));
  //   _navigate();
  // }
  Future<void> _initializeApp() async {
    try {
      // debugPrint("LOGIN CHECK START");

      await _checkLogin();

      // debugPrint("LOGIN CHECK DONE");

      unawaited(_requestPermissions());

      // debugPrint("PERMISSION REQUEST STARTED");

      if (isLoggedIn) {
        unawaited(_sendLocationToApi());
      }

      // debugPrint("SPLASH START");

      if (widget.waitForReferrer != null) {
        // debugPrint("WAITING FOR REFERRER");

        await widget.waitForReferrer!().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            // debugPrint("REFERRER TIMEOUT");
          },
        );

        // debugPrint("REFERRER COMPLETED");
      }

      // debugPrint("SPLASH END");

      await Future.delayed(const Duration(milliseconds: 1200));

      // debugPrint("NAVIGATE START");

      _navigate();
    } catch (e, s) {
      // debugPrint("SPLASH ERROR = $e");
      // debugPrint("$s");

      _navigate();
    }
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
      // debugPrint("PERMISSION START");

      // debugPrint("BEFORE NOTIFICATION");

      final status = await Permission.notification.request();

      // debugPrint("AFTER NOTIFICATION = $status");
      // debugPrint("NOTIFICATION DONE");

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      // debugPrint("LOCATION SERVICE = $serviceEnabled");

      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();

      // debugPrint("CURRENT LOCATION PERMISSION = $permission");

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        // debugPrint("AFTER LOCATION REQUEST = $permission");

        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) {
        // debugPrint("LOCATION DENIED FOREVER");
        await openAppSettings();
        return;
      }

      // debugPrint("GETTING POSITION");

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));

      // debugPrint("POSITION = ${position.latitude}, ${position.longitude}");

      final prefs = await SharedPreferences.getInstance();

      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);

      debugPrint("Lalitude: ${position.latitude}");
      debugPrint("Lonitude: ${position.longitude}");
    } catch (e, s) {
      // debugPrint("PERMISSION ERROR = $e");
      // debugPrint("$s");
    }
  }

  Future<void> _sendLocationToApi() async {
    try {
      //       debugPrint("📡 Sending location to API (Splash)...");

      final prefs = await SharedPreferences.getInstance();

      final lat = prefs.getDouble('latitude');
      final lng = prefs.getDouble('longitude');

      if (lat == null || lng == null) {
        //         debugPrint("⚠️ No stored location found");
        return;
      }

      // If you have reverse geocoding service, use it here
      final location = await LocationService.getCurrentLocationWithAddress();

      if (location != null) {
        final ok = await subscription_AuthService.updateLocation(
          latitude: location.latitude,
          longitude: location.longitude,
          address: location.fullAddress,
          city: location.city,
        );
        //
        // debugPrint("📡 Splash Location API status: $ok");

        if (ok) {
          await prefs.setBool('locationSet', true);
        }
      }
    } catch (e) {
      //       debugPrint("❌ Splash location API error: $e");
    }
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    final referralCode = prefs.getString(kPendingReferralCodeKey);

    if (!isLoggedIn && referralCode != null && referralCode.isNotEmpty) {
      // debugPrint("GOING TO SIGNUP");
      // debugPrint("REFERRAL IN SPLASH = $referralCode");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Signup(referralCode: referralCode)),
      );
      return;
    }
    // debugPrint("REFERRAL IN SPLASH = $referralCode");
    // debugPrint("isLoggedIn = $isLoggedIn");
    // debugPrint("NAVIGATE => isLoggedIn=$isLoggedIn referral=$referralCode");
    //
    // debugPrint("GOING TO LOGIN");

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) {
          if (isLoggedIn) {
            return MainScreenfood(showPromotion: true);
            // return HomePage(scrollController: _scrollController,);
          }

          return const LoginScreen();
        },
      ),
    );
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
                          // ignore: deprecated_member_use
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
