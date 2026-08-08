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
import 'package:maamaas/screens/Mainscreen.dart';
import 'package:maamaas/screens/screens/splash_screen.dart';
import 'package:maamaas/session_controller.dart';
import 'package:maamaas/widgets/app_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:app_links/app_links.dart';
import 'Services/App_color_service/theme_provider.dart';
import 'Services/Auth_service/Apiclient.dart';
import 'firebase_options.dart';
import 'homewrapper.dart';

// ── Dynamic theme imports ─────────────────────────────────────────────────────
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
  bool _referrerReady = false;
  String? _pendingReferral;

  final Completer<void> _referrerCompleter = Completer<void>();

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

  Future<void> waitForReferrer() async {
    try {
      await _referrerCompleter.future.timeout(const Duration(seconds: 5));
    } catch (e) {
    }


  }

  Future<void> _initAppLinks() async {
    // Cold-start: app was closed when the link was tapped.
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        //         debugPrint("🔗 Cold-start link: $initialUri");
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      //       debugPrint("❌ getInitialLink error: $e");
    }

    // Warm / foreground
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      //       debugPrint("🔗 Foreground link: $uri");
      _handleDeepLink(uri);
    }, onError: (err) => debugPrint("❌ uriLinkStream error: $err"));
  }


  void _handleDeepLink(Uri uri) {
    final referralCode = uri.queryParameters['referralCode'];
    if (referralCode != null && referralCode.isNotEmpty) {
      //       debugPrint("🎁 Referral code from deep link: $referralCode");
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
      //       debugPrint("✅ Referral code saved: $referralCode");
      // debugPrint("REFERRAL SAVED = $referralCode");
    } catch (e) {
      //       debugPrint("❌ Could not save referral code: $e");
    }
  }

  /// Navigate to Deals tab with the given campaign.
  void _openCampaign(int campaignId) {
    //     debugPrint("🚀 Opening campaign: $campaignId");

    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              MainScreenfood(initialIndex: 1, campaignId: campaignId),
        ),
        (route) => false,
      );
    } else {
      //       debugPrint("⏳ Navigator not ready — queuing campaign $campaignId");
      _pendingCampaignId = campaignId;
    }
  }

  Future<void> _handleInstallReferrer() async {
    try {
      final referrerDetails = await AndroidPlayInstallReferrer.installReferrer;

      final referrer = referrerDetails.installReferrer;

      // debugPrint("📥 Referrer string: $referrer");

      if (referrer != null && referrer.isNotEmpty) {
        // debugPrint("RAW REFERRER = $referrer");

        final uri = Uri.parse("https://dummy?$referrer");

        // debugPrint("ALL PARAMS = ${uri.queryParameters}");

        final referralCode = uri.queryParameters['referralCode'];

        if (referralCode != null && referralCode.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();

          await prefs.setString(
            kPendingReferralCodeKey,
            referralCode,
            // "TEST123"
          );
          // debugPrint("REFERRAL = ${prefs.getString(kPendingReferralCodeKey)}");

          // debugPrint("✅ Referral saved: $referralCode");
        }

        final campaignIdStr = uri.queryParameters['campaignId'];

        if (campaignIdStr != null) {
          final campaignId = int.tryParse(campaignIdStr);

          if (campaignId != null) {
            _pendingCampaignId = campaignId;
          }
        }
      }
    } catch (e) {
      // debugPrint("❌ Referrer error: $e");
    } finally {
      if (!_referrerCompleter.isCompleted) {
        _referrerCompleter.complete();
      }
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
      //       debugPrint('Firebase init failed/timed out: $e');
      debugPrintStack(stackTrace: st);
    }

    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 4),
      );
      final userId = prefs.getInt('userId') ?? 0;
      if (!mounted) return;
      setState(() => _userId = userId);
      await _inAppMessaging.setAutomaticDataCollectionEnabled(true);
    } catch (e, st) {
      //       debugPrint('Startup prefs init failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [userIdProvider.overrideWithValue(_userId)],
      child: MyApp(
        pendingCampaignId: _pendingCampaignId,
        waitForReferrer: waitForReferrer,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MyApp
// ─────────────────────────────────────────────────────────────────────────────

class MyApp extends ConsumerWidget {
  final int? pendingCampaignId;
  final Future<void> Function()? waitForReferrer;
  const MyApp({super.key, this.pendingCampaignId, this.waitForReferrer});

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
            child: SplashScreen(
              pendingCampaignId: pendingCampaignId,
              waitForReferrer: waitForReferrer,
            ),
          ),
        );
      },
    );
  }
}
