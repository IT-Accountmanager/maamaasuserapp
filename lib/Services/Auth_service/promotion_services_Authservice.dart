import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/promotions_model/promotions_model.dart';
import '../../Models/subscrptions/ticket_model.dart';
import 'Apiclient.dart';

// ignore: camel_case_types
class promotion_Authservice {
  static Future<List<Ticket>> fetchTicketsByUser() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    if (userId == 0) {
      // debugPrint("❌ Invalid userId: $userId");
      return [];
    }

    final endpoint = "api/user/helpdesk/user/$userId"; // relative path

    try {
      final response = await ApiClient.get(endpoint, service: 'promotions');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final List<dynamic> data = jsonDecode(response.body);

          return data.map((json) => Ticket.fromJson(json)).toList();
        } catch (jsonError) {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Response> createTicket({
    int? orderId,
    required String description,
    // required String subject,
    required String issueType,
    String? serviceType,
    File? attachmentFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final String endpoint = "api/user/helpdesk/create"; // ✅ single API now

    final Map<String, dynamic> ticket = {
      "userId": userId,
      "orderId": orderId,
      "description": description.trim(),
      "issueType": issueType,
      "serviceType": serviceType,
      "createdBy": "CUSTOMER",
      "priority": "HIGH",
      "createdAt": DateTime.now().toIso8601String(),
    };

    final Map<String, File>? files = attachmentFile != null
        ? {"attachmentUrl": attachmentFile}
        : null;

    final Map<String, dynamic> multipartData = {
      "ticket": jsonEncode(ticket), // ✅ KEY CHANGED (IMPORTANT)
    };

    try {
      final response = await ApiClient.sendMultipartRequest(
        endpoint: endpoint,
        method: "POST",
        service: "promotions",
        data: multipartData,
        files: files,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Campaign>> fetchcampaign() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      return [];
    }

    final String endpoint = 'api/user/active/campaigns?userId=$userId';

    try {
      final response = await ApiClient.get(endpoint, service: "promotions");

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        final List<dynamic> campaignList = decodedData is List
            ? decodedData
            : [decodedData];

        ;

        final campaigns = campaignList
            .map((e) => Campaign.fromJson(e))
            .toList();

        return campaigns;
      } else {
        return [];
      }
    } catch (e, stackTrace) {
      return [];
    }
  }

  static Future<void> sendViewAnalytics(Map<String, dynamic> payload) async {
    final endpoint = "api/user/campaign/view";
    final startTime = DateTime.now();

    try {
      final response = await ApiClient.post(endpoint, payload);

      final duration = DateTime.now().difference(startTime).inMilliseconds;

      if (response.statusCode == 200 || response.statusCode == 201) {
      } else {}
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
    }
  }

  static Future<void> sendLikeAnalytics(Map<String, dynamic> payload) async {
    final endpoint = "api/user/campaign/like";

    try {
      final response = await ApiClient.post(
        endpoint,
        payload,
        service: "promotions",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
      } else {}
    } catch (e) {}
  }

  static Future<void> sendShareAnalytics(Map<String, dynamic> payload) async {
    final endpoint = "api/user/campaign/share";

    try {
      final response = await ApiClient.post(
        endpoint,
        payload,
        service: "promotions",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
      } else {}
    } catch (e) {}
  }

  static Future<void> sendSaveAnalytics(Map<String, dynamic> payload) async {
    final endpoint = "api/user/campaign/save";

    try {
      final response = await ApiClient.post(
        endpoint,
        payload,
        service: "promotions",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
      } else {}
    } catch (e, stack) {}
  }
}
