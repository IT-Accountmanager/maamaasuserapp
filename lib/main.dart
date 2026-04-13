import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaas/providers/provider.dart';
import 'package:maamaas/screens/screens/advertisements/videoscreen.dart';
import 'package:maamaas/screens/screens/splash_screen.dart';
import 'package:maamaas/session_controller.dart';
import 'package:maamaas/widgets/app_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'Services/Auth_service/Apiclient.dart';
import 'firebase_options.dart';
import 'homewrapper.dart';

// ── NEW: dynamic theme imports ────────────────────────────────────────────────
import 'Services/App_color_service/app_colours.dart';
import 'Services/App_color_service/theme_colour.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
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

  // ✅ CONNECT SESSION HANDLER
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

  @override
  void initState() {
    super.initState();
    _initializeStartupServices();
    _initDynamicLinks();
  }

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
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 4),
      );
      final userId = prefs.getInt('userId') ?? 0;
      if (!mounted) return;
      setState(() {
        _userId = userId;
      });
      await _inAppMessaging.setAutomaticDataCollectionEnabled(true);
    } catch (e, st) {
      debugPrint('Startup prefs init failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> _initDynamicLinks() async {
    try {
      // ✅ App opened from terminated state
      final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks
          .instance
          .getInitialLink();

      if (initialLink != null) {
        _handleDeepLink(initialLink.link);
      }

      // ✅ App opened from background / foreground
      FirebaseDynamicLinks.instance.onLink
          .listen((dynamicLinkData) {
            _handleDeepLink(dynamicLinkData.link);
          })
          .onError((error) {
            debugPrint('❌ Dynamic link error: $error');
          });
    } catch (e) {
      debugPrint('❌ initDynamicLinks error: $e');
    }
  }

  void _handleDeepLink(Uri link) {
    debugPrint("🔗 Deep Link Received: $link");

    final campaignIdStr = link.queryParameters['id'];

    if (campaignIdStr != null) {
      final campaignId = int.tryParse(campaignIdStr);

      if (campaignId != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ReelsScreen(campaignId: campaignId),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [userIdProvider.overrideWithValue(_userId)],
      child: const MyApp(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MyApp — now a ConsumerWidget so it rebuilds whenever the palette changes
// ─────────────────────────────────────────────────────────────────────────────

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👇 Watch the theme — any palette change triggers a full ThemeData rebuild
    final colorScheme = ref.watch(themeProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // 👇 Dynamic theme — derives from the current palette
          theme: AppTheme.fromScheme(colorScheme),
          navigatorObservers: [routeObserver],
          navigatorKey: navigatorKey,
          home: NetworkWrapper(child: const SplashScreen()),
        );
      },
    );
  }
}
