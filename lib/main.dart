// // import 'dart:async';
// // import 'dart:ui';
// //
// // import 'package:android_play_install_referrer/android_play_install_referrer.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// // import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_dotenv/flutter_dotenv.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:maamaas/providers/provider.dart';
// // import 'package:maamaas/screens/foodmainscreen.dart';
// // import 'package:maamaas/screens/screens/advertisements/videoscreen.dart';
// // import 'package:maamaas/screens/screens/splash_screen.dart';
// // import 'package:maamaas/session_controller.dart';
// // import 'package:maamaas/widgets/app_navigator.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
// // import 'Services/Auth_service/Apiclient.dart';
// // import 'firebase_options.dart';
// // import 'homewrapper.dart';
// //
// // // ── NEW: dynamic theme imports ────────────────────────────────────────────────
// // import 'Services/App_color_service/app_colours.dart';
// // import 'Services/App_color_service/theme_colour.dart';
// //
// // Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// // }
// //
// // final GlobalKey<ScaffoldMessengerState> messengerKey =
// //     GlobalKey<ScaffoldMessengerState>();
// //
// // final FirebaseInAppMessaging _inAppMessaging = FirebaseInAppMessaging.instance;
// //
// // final RouteObserver<ModalRoute<void>> routeObserver =
// //     RouteObserver<ModalRoute<void>>();
// //
// // Future<void> main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //
// //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// //
// //   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
// //
// //   PlatformDispatcher.instance.onError = (error, stack) {
// //     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
// //     return true;
// //   };
// //
// //   await dotenv.load(fileName: ".env");
// //
// //   ApiClient.initialize();
// //
// //   // ✅ CONNECT SESSION HANDLER
// //   ApiClient.onSessionExpired = () async {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       SessionOverlayController().show();
// //     });
// //   };
// //   ApiClient.resetSessionFlag();
// //
// //   runApp(const BootstrapApp());
// // }
// //
// // class BootstrapApp extends StatefulWidget {
// //   const BootstrapApp({super.key});
// //
// //   @override
// //   State<BootstrapApp> createState() => _BootstrapAppState();
// // }
// //
// // class _BootstrapAppState extends State<BootstrapApp> {
// //   int _userId = 0;
// //   bool _campaignOpened = false;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeStartupServices();
// //     _initDynamicLinks();
// //     _handleInstallReferrer();
// //   }
// //
// //   Future<void> _initializeStartupServices() async {
// //     try {
// //       await Firebase.initializeApp(
// //         options: DefaultFirebaseOptions.currentPlatform,
// //       ).timeout(const Duration(seconds: 10));
// //       FirebaseMessaging.onBackgroundMessage(
// //         _firebaseMessagingBackgroundHandler,
// //       );
// //     } catch (e, st) {
// //       debugPrint('Firebase init failed/timed out: $e');
// //       debugPrintStack(stackTrace: st);
// //     }
// //
// //     try {
// //       final prefs = await SharedPreferences.getInstance().timeout(
// //         const Duration(seconds: 4),
// //       );
// //       final userId = prefs.getInt('userId') ?? 0;
// //       if (!mounted) return;
// //       setState(() {
// //         _userId = userId;
// //       });
// //       await _inAppMessaging.setAutomaticDataCollectionEnabled(true);
// //     } catch (e, st) {
// //       debugPrint('Startup prefs init failed: $e');
// //       debugPrintStack(stackTrace: st);
// //     }
// //   }
// //
// //   Future<void> _handleInstallReferrer() async {
// //     try {
// //       final referrerDetails = await AndroidPlayInstallReferrer.installReferrer;
// //
// //       final referrer = referrerDetails.installReferrer;
// //
// //       debugPrint("📥 Referrer: $referrer");
// //
// //       final uri = Uri.parse("https://dummy?$referrer");
// //       final campaignIdStr = uri.queryParameters['campaignId'];
// //
// //       if (campaignIdStr != null) {
// //         final campaignId = int.tryParse(campaignIdStr);
// //
// //         if (campaignId != null) {
// //           _openCampaign(campaignId);
// //         }
// //       }
// //     } catch (e) {
// //       debugPrint("❌ Referrer error: $e");
// //     }
// //   }
// //
// //   Future<void> _initDynamicLinks() async {
// //     try {
// //       // ✅ App opened from terminated state
// //       final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks
// //           .instance
// //           .getInitialLink();
// //
// //       if (initialLink != null) {
// //         _handleDeepLink(initialLink.link);
// //       }
// //
// //       // ✅ App opened from background / foreground
// //       FirebaseDynamicLinks.instance.onLink
// //           .listen((dynamicLinkData) {
// //             _handleDeepLink(dynamicLinkData.link);
// //           })
// //           .onError((error) {
// //             debugPrint('❌ Dynamic link error: $error');
// //           });
// //     } catch (e) {
// //       debugPrint('❌ initDynamicLinks error: $e');
// //     }
// //   }
// //
// //   void _handleDeepLink(Uri link) {
// //     debugPrint("🔗 Deep Link Received: $link");
// //
// //     // ✅ FIX: read 'id' instead of 'campaignId'
// //     final campaignIdStr =
// //         link.queryParameters['campaignId'] ?? link.queryParameters['id'];
// //     if (campaignIdStr != null) {
// //       final campaignId = int.tryParse(campaignIdStr);
// //
// //       if (campaignId != null) {
// //         _openCampaign(campaignId);
// //       }
// //     }
// //   }
// //
// //   void _openCampaign(int campaignId) {
// //     debugPrint("🚀 Opening campaign: $campaignId");
// //
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       navigatorKey.currentState?.pushAndRemoveUntil(
// //         MaterialPageRoute(
// //           builder: (_) => MainScreenfood(
// //             initialIndex: 1, // 👉 Deals tab
// //             campaignId: campaignId, // 👉 pass id
// //           ),
// //         ),
// //             (route) => false,
// //       );
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return ProviderScope(
// //       overrides: [userIdProvider.overrideWithValue(_userId)],
// //       child: const MyApp(),
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────────────────────────────────────
// // // MyApp — now a ConsumerWidget so it rebuilds whenever the palette changes
// // // ─────────────────────────────────────────────────────────────────────────────
// //
// // class MyApp extends ConsumerWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     // 👇 Watch the theme — any palette change triggers a full ThemeData rebuild
// //     final colorScheme = ref.watch(themeProvider);
// //
// //     return ScreenUtilInit(
// //       designSize: const Size(390, 844),
// //       minTextAdapt: true,
// //       splitScreenMode: true,
// //       builder: (context, child) {
// //         return MaterialApp(
// //           scaffoldMessengerKey: messengerKey,
// //           debugShowCheckedModeBanner: false,
// //           // 👇 Dynamic theme — derives from the current palette
// //           theme: AppTheme.fromScheme(colorScheme),
// //           navigatorObservers: [routeObserver],
// //           navigatorKey: navigatorKey,
// //           home: NetworkWrapper(child: const SplashScreen()),
// //         );
// //       },
// //     );
// //   }
// // }
//
//
// import 'dart:async';
// import 'dart:ui';
//
// import 'package:android_play_install_referrer/android_play_install_referrer.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:maamaas/providers/provider.dart';
// import 'package:maamaas/screens/foodmainscreen.dart';
// import 'package:maamaas/screens/screens/splash_screen.dart';
// import 'package:maamaas/session_controller.dart';
// import 'package:maamaas/widgets/app_navigator.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
// import 'package:app_links/app_links.dart'; // ✅ cPanel App Links (replaces Firebase Dynamic Links)
// import 'Services/Auth_service/Apiclient.dart';
// import 'firebase_options.dart';
// import 'homewrapper.dart';
//
// // ── Dynamic theme imports ─────────────────────────────────────────────────────
// import 'Services/App_color_service/app_colours.dart';
// import 'Services/App_color_service/theme_colour.dart';
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// }
//
// final GlobalKey<ScaffoldMessengerState> messengerKey =
// GlobalKey<ScaffoldMessengerState>();
//
// final FirebaseInAppMessaging _inAppMessaging = FirebaseInAppMessaging.instance;
//
// final RouteObserver<ModalRoute<void>> routeObserver =
// RouteObserver<ModalRoute<void>>();
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//
//   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
//
//   PlatformDispatcher.instance.onError = (error, stack) {
//     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
//     return true;
//   };
//
//   await dotenv.load(fileName: ".env");
//
//   ApiClient.initialize();
//
//   // ✅ Session expiry handler
//   ApiClient.onSessionExpired = () async {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       SessionOverlayController().show();
//     });
//   };
//   ApiClient.resetSessionFlag();
//
//   runApp(const BootstrapApp());
// }
//
// class BootstrapApp extends StatefulWidget {
//   const BootstrapApp({super.key});
//
//   @override
//   State<BootstrapApp> createState() => _BootstrapAppState();
// }
//
// class _BootstrapAppState extends State<BootstrapApp> {
//   int _userId = 0;
//
//   // ✅ app_links instance — handles cPanel-hosted assetlinks / apple-app-site-association
//   final _appLinks = AppLinks();
//   StreamSubscription<Uri>? _linkSub;
//
//   // Holds a campaignId that arrived BEFORE the navigator was ready.
//   // Consumed by SplashScreen / HomeWrapper once navigation is possible.
//   int? _pendingCampaignId;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeStartupServices();
//     _initAppLinks();      // ✅ replaces _initDynamicLinks()
//     _handleInstallReferrer();
//   }
//
//   @override
//   void dispose() {
//     _linkSub?.cancel();
//     super.dispose();
//   }
//
//   // ── cPanel App Links (Universal Links / App Links) ────────────────────────
//
//   Future<void> _initAppLinks() async {
//     // 1️⃣ Cold-start: app was completely closed when the link was tapped.
//     try {
//       final initialUri = await _appLinks.getInitialLink();
//       if (initialUri != null) {
//         debugPrint("🔗 Cold-start link: $initialUri");
//         _handleDeepLink(initialUri);
//       }
//     } catch (e) {
//       debugPrint("❌ getInitialLink error: $e");
//     }
//
//     // 2️⃣ Warm/foreground: app already running when link is tapped.
//     _linkSub = _appLinks.uriLinkStream.listen(
//           (uri) {
//         debugPrint("🔗 Foreground link: $uri");
//         _handleDeepLink(uri);
//       },
//       onError: (err) => debugPrint("❌ uriLinkStream error: $err"),
//     );
//   }
//
//   /// Parses the URI and routes to the correct screen.
//   /// Supports:
//   ///   https://applink.maamaas.com/campaign?campaignId=123
//   ///   https://applink.maamaas.com/campaign?id=123
//   void _handleDeepLink(Uri uri) {
//     debugPrint("🔗 Deep Link Received: $uri");
//
//     final campaignIdStr =
//         uri.queryParameters['campaignId'] ?? uri.queryParameters['id'];
//
//     if (campaignIdStr == null) return;
//
//     final campaignId = int.tryParse(campaignIdStr);
//     if (campaignId == null) return;
//
//     _openCampaign(campaignId);
//   }
//
//   /// Navigate to Deals tab with the given campaign.
//   /// Safe to call at any lifecycle stage — defers if navigator isn't ready yet.
//   void _openCampaign(int campaignId) {
//     debugPrint("🚀 Opening campaign: $campaignId");
//
//     // If the navigator key already has a context, go immediately.
//     if (navigatorKey.currentState != null) {
//       navigatorKey.currentState!.pushAndRemoveUntil(
//         MaterialPageRoute(
//           builder: (_) => MainScreenfood(
//             initialIndex: 1,       // Deals tab
//             campaignId: campaignId,
//           ),
//         ),
//             (route) => false,
//       );
//     } else {
//       // App is still starting up — store and let SplashScreen pick it up.
//       debugPrint("⏳ Navigator not ready — queuing campaign $campaignId");
//       _pendingCampaignId = campaignId;
//     }
//   }
//
//   // ── Install referrer (Google Play) ────────────────────────────────────────
//
//   Future<void> _handleInstallReferrer() async {
//     try {
//       final referrerDetails = await AndroidPlayInstallReferrer.installReferrer;
//       final referrer = referrerDetails.installReferrer;
//       debugPrint("📥 Referrer: $referrer");
//
//       final uri = Uri.parse("https://dummy?$referrer");
//       final campaignIdStr = uri.queryParameters['campaignId'];
//
//       if (campaignIdStr != null) {
//         final campaignId = int.tryParse(campaignIdStr);
//         if (campaignId != null) {
//           _openCampaign(campaignId);
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Referrer error: $e");
//     }
//   }
//
//   // ── Firebase / Prefs startup ──────────────────────────────────────────────
//
//   Future<void> _initializeStartupServices() async {
//     try {
//       await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform,
//       ).timeout(const Duration(seconds: 10));
//       FirebaseMessaging.onBackgroundMessage(
//         _firebaseMessagingBackgroundHandler,
//       );
//     } catch (e, st) {
//       debugPrint('Firebase init failed/timed out: $e');
//       debugPrintStack(stackTrace: st);
//     }
//
//     try {
//       final prefs = await SharedPreferences.getInstance()
//           .timeout(const Duration(seconds: 4));
//       final userId = prefs.getInt('userId') ?? 0;
//       if (!mounted) return;
//       setState(() => _userId = userId);
//       await _inAppMessaging.setAutomaticDataCollectionEnabled(true);
//     } catch (e, st) {
//       debugPrint('Startup prefs init failed: $e');
//       debugPrintStack(stackTrace: st);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ProviderScope(
//       overrides: [userIdProvider.overrideWithValue(_userId)],
//       child: MyApp(pendingCampaignId: _pendingCampaignId),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // MyApp
// // ─────────────────────────────────────────────────────────────────────────────
//
// class MyApp extends ConsumerWidget {
//   /// A campaignId that arrived before the navigator was ready.
//   /// Passed down to SplashScreen so it can redirect after initialisation.
//   final int? pendingCampaignId;
//
//   const MyApp({super.key, this.pendingCampaignId});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final colorScheme = ref.watch(themeProvider);
//
//     return ScreenUtilInit(
//       designSize: const Size(390, 844),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return MaterialApp(
//           scaffoldMessengerKey: messengerKey,
//           debugShowCheckedModeBanner: false,
//           theme: AppTheme.fromScheme(colorScheme),
//           navigatorObservers: [routeObserver],
//           navigatorKey: navigatorKey,
//           // ✅ Pass pendingCampaignId into SplashScreen via NetworkWrapper
//           home: NetworkWrapper(
//             child: SplashScreen(pendingCampaignId: pendingCampaignId),
//           ),
//         );
//       },
//     );
//   }
// }


import 'dart:async';
import 'dart:ui';

import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaas/providers/provider.dart';
import 'package:maamaas/screens/foodmainscreen.dart';
import 'package:maamaas/screens/screens/signup_screen.dart';
import 'package:maamaas/screens/screens/splash_screen.dart';
import 'package:maamaas/session_controller.dart';
import 'package:maamaas/widgets/app_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:app_links/app_links.dart';

import 'Services/Auth_service/Apiclient.dart';
import 'firebase_options.dart';
import 'homewrapper.dart';

// ── Dynamic theme imports ─────────────────────────────────────────────────────
import 'Services/App_color_service/app_colours.dart';
import 'Services/App_color_service/theme_colour.dart';

// ─── SharedPreferences key used across the app ───────────────────────────────
// Signup screen reads this key to pre-fill the referral code field.
const String kPendingReferralCodeKey = 'pending_referral_code';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

final GlobalKey<ScaffoldMessengerState> messengerKey =
GlobalKey<ScaffoldMessengerState>();

final FirebaseInAppMessaging _inAppMessaging = FirebaseInAppMessaging.instance;

final RouteObserver<ModalRoute<void>> routeObserver =
RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await dotenv.load(fileName: ".env");

  ApiClient.initialize();

  ApiClient.onSessionExpired = () async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SessionOverlayController().show();
    });
  };
  ApiClient.resetSessionFlag();

  runApp(const BootstrapApp());
}

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  int _userId = 0;

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  // A campaignId that arrived before the navigator was ready.
  int? _pendingCampaignId;

  @override
  void initState() {
    super.initState();
    _initializeStartupServices();
    _initAppLinks();
    _handleInstallReferrer(); // ✅ handles referral code from Play Store install
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  // ── cPanel App Links ──────────────────────────────────────────────────────

  Future<void> _initAppLinks() async {
    // Cold-start: app was closed when the link was tapped.
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint("🔗 Cold-start link: $initialUri");
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint("❌ getInitialLink error: $e");
    }

    // Warm / foreground
    _linkSub = _appLinks.uriLinkStream.listen(
          (uri) {
        debugPrint("🔗 Foreground link: $uri");
        _handleDeepLink(uri);
      },
      onError: (err) => debugPrint("❌ uriLinkStream error: $err"),
    );
  }

  /// Handles deep links of the form:
  ///   https://applink.maamaas.com/campaign?campaignId=123
  ///   https://applink.maamaas.com/referral?referralCode=ABC123   ← NEW
  void _handleDeepLink(Uri uri) {
    debugPrint("🔗 Deep Link Received: $uri");

    // ── Referral link ─────────────────────────────────────────────────────
    // Supported: /referral?referralCode=ABC123
    //            /campaign?referralCode=ABC123  (optional fallback)
    final referralCode = uri.queryParameters['referralCode'];
    if (referralCode != null && referralCode.isNotEmpty) {
      debugPrint("🎁 Referral code from deep link: $referralCode");
      _saveReferralCodeAndOpenSignup(referralCode);
      return; // don't also treat as campaign
    }

    // ── Campaign link ─────────────────────────────────────────────────────
    final campaignIdStr =
        uri.queryParameters['campaignId'] ?? uri.queryParameters['id'];
    if (campaignIdStr == null) return;
    final campaignId = int.tryParse(campaignIdStr);
    if (campaignId == null) return;
    _openCampaign(campaignId);
  }

  /// Saves the referral code to SharedPreferences and navigates to Signup.
  Future<void> _saveReferralCodeAndOpenSignup(String referralCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kPendingReferralCodeKey, referralCode);
      debugPrint("✅ Referral code saved: $referralCode");
    } catch (e) {
      debugPrint("❌ Could not save referral code: $e");
    }

    // Navigate to Signup screen.
    // If the navigator isn't ready yet (cold-start), defer via addPostFrameCallback.
    void navigate() {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const Signup(), // your existing Signup widget
        ),
      );
    }

    if (navigatorKey.currentState != null) {
      navigate();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => navigate());
    }
  }

  /// Navigate to Deals tab with the given campaign.
  void _openCampaign(int campaignId) {
    debugPrint("🚀 Opening campaign: $campaignId");

    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainScreenfood(
            initialIndex: 1,
            campaignId: campaignId,
          ),
        ),
            (route) => false,
      );
    } else {
      debugPrint("⏳ Navigator not ready — queuing campaign $campaignId");
      _pendingCampaignId = campaignId;
    }
  }

  // ── Install referrer (Google Play) ───────────────────────────────────────
  //
  // When the app is NOT installed and the user taps the referral share link,
  // the redirect HTML forwards them to:
  //   play.google.com/...?referrer=referralCode%3DABC123
  //
  // After install, Google Play delivers that referrer string here.

  Future<void> _handleInstallReferrer() async {
    try {
      final referrerDetails = await AndroidPlayInstallReferrer.installReferrer;
      final referrer = referrerDetails.installReferrer;
      debugPrint("📥 Referrer string: $referrer");

      // Parse the referrer as a query string, e.g. "referralCode=ABC123"
      // or "campaignId=42"
      final uri = Uri.parse("https://dummy?$referrer");

      // ── Referral code ─────────────────────────────────────────────────
      final referralCode = uri.queryParameters['referralCode'];
      if (referralCode != null && referralCode.isNotEmpty) {
        debugPrint("🎁 Referral code from Play referrer: $referralCode");
        // Save so Signup screen can read it even before navigation is ready.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(kPendingReferralCodeKey, referralCode);
        // We do NOT navigate here — SplashScreen will push Signup anyway for
        // a new install. The referral code will be waiting in SharedPreferences.
        return;
      }

      // ── Campaign id (existing behaviour) ──────────────────────────────
      final campaignIdStr = uri.queryParameters['campaignId'];
      if (campaignIdStr != null) {
        final campaignId = int.tryParse(campaignIdStr);
        if (campaignId != null) _openCampaign(campaignId);
      }
    } catch (e) {
      debugPrint("❌ Referrer error: $e");
    }
  }

  // ── Firebase / Prefs startup ─────────────────────────────────────────────

  Future<void> _initializeStartupServices() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 10));
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    } catch (e, st) {
      debugPrint('Firebase init failed/timed out: $e');
      debugPrintStack(stackTrace: st);
    }

    try {
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 4));
      final userId = prefs.getInt('userId') ?? 0;
      if (!mounted) return;
      setState(() => _userId = userId);
      await _inAppMessaging.setAutomaticDataCollectionEnabled(true);
    } catch (e, st) {
      debugPrint('Startup prefs init failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [userIdProvider.overrideWithValue(_userId)],
      child: MyApp(pendingCampaignId: _pendingCampaignId),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MyApp
// ─────────────────────────────────────────────────────────────────────────────

class MyApp extends ConsumerWidget {
  final int? pendingCampaignId;
  const MyApp({super.key, this.pendingCampaignId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = ref.watch(themeProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          scaffoldMessengerKey: messengerKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.fromScheme(colorScheme),
          navigatorObservers: [routeObserver],
          navigatorKey: navigatorKey,
          home: NetworkWrapper(
            child: SplashScreen(pendingCampaignId: pendingCampaignId),
          ),
        );
      },
    );
  }
}