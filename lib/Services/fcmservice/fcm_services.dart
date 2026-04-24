import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize FCM and local notifications
  /// Returns the FCM token (can be null)
  Future<String?> initFCM() async {
    // 1️⃣ Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint("🔔 Permission: ${settings.authorizationStatus}");

    // 2️⃣ iOS APNS token with max retry (non-blocking)
    if (Platform.isIOS) {
      // String? apnsToken;
      // int retry = 0;
      // while (apnsToken == null && retry < 10) {
      //   await Future.delayed(const Duration(seconds: 1));
      //   apnsToken = await _messaging.getAPNSToken();
      //   retry++;
      // }
      String? apnsToken = await _messaging.getAPNSToken();
      debugPrint("🍏 APNS Token: $apnsToken");

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // 3️⃣ Initialize local notifications
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(initSettings);

    // 4️⃣ Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    Future<String?> _getTokenWithRetry() async {
      int retryCount = 0;
      const maxRetries = 5;

      while (retryCount < maxRetries) {
        try {
          String? token = await _messaging.getToken();
          if (token != null) return token;
        } catch (e) {
          debugPrint("⚠️ FCM Token Error: $e");
        }

        retryCount++;
        await Future.delayed(const Duration(seconds: 2));
      }

      return null;
    }

    // 5️⃣ Get FCM token
    String? token = await _getTokenWithRetry();
    debugPrint("📱 FCM Token: $token");

    // 6️⃣ Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 Foreground Message Received");
      if (message.notification != null) {
        _localNotifications.show(
          message.hashCode,
          message.notification?.title ?? "New Notification",
          message.notification?.body ?? "",
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
              enableLights: true,
              ticker: 'ticker',
            ),
            iOS: DarwinNotificationDetails(),
          ),
        );
      }
    });

    // 7️⃣ Background notification click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("🚀 Notification Clicked");
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("🔥 FOREGROUND MESSAGE RECEIVED");
      debugPrint("DATA: ${message.data}");
    });
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint("🔄 Refreshed Token: $newToken");

      // TODO: send to backend
    });

    // ✅ Return FCM token
    return token;
  }
}
