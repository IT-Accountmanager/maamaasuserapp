import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/subscrptions/notification_model.dart';
import 'Apiclient.dart';

class NotificationService {
  static Future<bool> markSingleNotificationRead(String notifId) async {
    if (notifId.isEmpty) {
      return false;
    }

    final endpoint = "api/user/$notifId/read";

    try {
      final response = await ApiClient.put(
        endpoint,
        {}, // empty body
        service: "notification",
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
          "Failed to mark notification read → ${response.statusCode}",
        );
      }
    } catch (e) {
      // debugPrint("❌ Exception in markSingleNotificationRead: $e");
      return false;
    }
  }

  static Future<bool> deleteNotification(String id) async {
    final endpoint = "api/user/$id";

    try {
      final response = await ApiClient.delete(
        endpoint,
        service: "notification",
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> markAllNotificationsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    if (userId == 0) {
      return false;
    }

    final endpoint =
        "api/user/$userId/mark-all-read"; // relative endpoint (ApiClient adds base URL)

    try {
      final response = await ApiClient.put(
        endpoint,
        {}, // empty body
        service: "notification",
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
          "Failed to mark all notifications read → ${response.statusCode}",
        );
      }
    } catch (e) {
      return false;
    }
  }

  static Future<List<NotificationModel>> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final endpoint = "api/user/$userId";

    try {
      final response = await ApiClient.get(endpoint, service: "notification");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((e) => NotificationModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<bool> deleteallNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    final endpoint = "api/user/all/$userId";

    try {
      final response = await ApiClient.delete(
        endpoint,
        service: "notification",
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<int> fetchUnreadNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    final String endpoint = "api/user/$userId/unread-count";

    try {
      final response = await ApiClient.get(endpoint, service: "notification");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is Map ? (data['count'] ?? 0) : (data as int);
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  static Future<void> registerFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final customerId = prefs.getString("customerId");

    if (userId == null) {
      return;
    }

    String deviceType;

    if (Platform.isAndroid) {
      deviceType = "ANDROID";
    } else if (Platform.isIOS) {
      deviceType = "IOS";
    } else {
      deviceType = "UNKNOWN";
    }

    final body = {
      "userId": userId,
      "customerId": customerId,
      "fcmToken": token,
      "deviceType": deviceType,
    };

    try {
      final response = await ApiClient.post(
        "api/user/register-token",
        body,
        service: "notification",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
      } else {}
    } catch (e, stackTrace) {}
  }
}
