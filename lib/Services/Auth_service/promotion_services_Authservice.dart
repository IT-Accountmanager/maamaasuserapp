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
      "createdBy": "USER",
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
        debugPrint("resposnse body : ${response.body}");

        final List<dynamic> campaignList = decodedData is List
            ? decodedData
            : [decodedData];

        final campaigns = campaignList
            .map((e) => Campaign.fromJson(e))
            .toList();

        return campaigns;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<void> sendViewAnalytics(Map<String, dynamic> payload) async {
    try {
      //
      //       debugPrint("");
      //       debugPrint("=============== VIEW ANALYTICS START ================");
      //       debugPrint("📤 Endpoint: api/user/campaign/view");
      //       debugPrint("📦 Payload: $payload");
      //       debugPrint("");

      final response = await ApiClient.post(
        'api/user/campaign/view',
        payload,
        service: "promotions",
      );
      //
      //       debugPrint("📥 RESPONSE RECEIVED");
      //       debugPrint("🔢 Status Code : ${response.statusCode}");
      //       debugPrint("📑 Headers : ${response.headers}");
      //       debugPrint("");

      // ✅ THIS IS THE IMPORTANT FIX
      if (response.statusCode != 200 && response.statusCode != 201) {
        //
        //         debugPrint("❌ VIEW ANALYTICS FAILED");
        //         debugPrint("❌ Backend returned non-success status");

        throw Exception("View analytics failed: ${response.statusCode}");
      }
      //
      //       debugPrint("✅ VIEW ANALYTICS SUCCESS");
    } catch (e) {
      //
      //       debugPrint("❌ VIEW ANALYTICS ERROR: $e");

      rethrow;
    } finally {
      //
      //       debugPrint("=============== VIEW ANALYTICS END =================");
      //       debugPrint("");
    }
  }

  static Future<void> sendLikeAnalytics(Map<String, dynamic> payload) async {
    final endpoint = "api/user/campaign/like";
    final startTime = DateTime.now();
    //
    //     debugPrint("\n================ LIKE ANALYTICS START ================");
    //     debugPrint("📤 Endpoint: $endpoint");
    //     debugPrint("📦 Payload: $payload");

    try {
      final response = await ApiClient.post(
        endpoint,
        payload,
        service: "promotions",
      );

      final duration = DateTime.now().difference(startTime).inMilliseconds;
      //
      //       debugPrint("\n📥 RESPONSE RECEIVED");
      //       debugPrint("🔢 Status Code : ${response.statusCode}");
      //       debugPrint("📑 Headers : ${response.headers}");
      //       debugPrint("⏱ API Time : $duration ms");

      if (response.statusCode == 200 || response.statusCode == 201) {
        //         debugPrint("✅ LIKE ANALYTICS SUCCESS");
      } else {
        //         debugPrint("❌ LIKE ANALYTICS FAILED");
      }
    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      //
      //       debugPrint("\n❌ LIKE ANALYTICS ERROR");
      //       debugPrint("💥 Error Type : ${e.runtimeType}");
      //       debugPrint("💥 Error : $e");
      //       debugPrint("📚 StackTrace : $stackTrace");
      //       debugPrint("⏱ Failed After : $duration ms");

      try {
        final err = e as dynamic;
        //
        //         debugPrint("\n🔥 EXTRA ERROR DETAILS");
        //         debugPrint("📛 Message : ${err.message}");

        if (err.response != null) {
          //           debugPrint("🔢 Error Status : ${err.response?.statusCode}");
          //           debugPrint("📄 Error Body : ${err.response?.data}");
          //           debugPrint("📑 Error Headers : ${err.response?.headers}");
        }
        //
        //         debugPrint("📤 Request Data : ${err.requestOptions?.data}");
        //         debugPrint("🌐 Request URL : ${err.requestOptions?.uri}");
        //         debugPrint("📑 Request Headers : ${err.requestOptions?.headers}");
        //         debugPrint("📡 Method : ${err.requestOptions?.method}");
      } catch (_) {}
    }
    //
    //     debugPrint("================ LIKE ANALYTICS END =================\n");
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
      // ignore: empty_catches
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
      // ignore: empty_catches
    } catch (e) {}
  }

  // 🔥 Submit Enquiry API
  static Future<bool> submitEnquiry({
    required int campaignId,
    required String customerId,
    required String name,
    required String email,
    required String phone,
    required String callToAction, // ✅ FIXED
  }) async {
    const String endpoint = "api/user/promotional-leads"; // ✅ FIXED

    final body = {
      "campaignId": campaignId,
      "customerId": customerId,
      "enquiryName": name,
      "enquiryEmail": email,
      "enquiryPhoneNumber": phone,
      "callToAction": callToAction,
    };

    // 🔥 DEBUG START
    //     debugPrint("🚀 ===== SUBMIT ENQUIRY API =====");
    //     debugPrint("📍 Endpoint: $endpoint");
    //     debugPrint("📦 Request Body: $body");

    try {
      final response = await ApiClient.post(
        endpoint,
        body,
        service: "promotions",
      );
      //
      //       debugPrint("📡 Response Status: ${response.statusCode}");
      //       debugPrint("📨 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        //         debugPrint("✅ Enquiry API SUCCESS");
        return true;
      } else {
        //         debugPrint("❌ Enquiry API FAILED");
        return false;
      }
    } catch (e, stack) {
      //       debugPrint("❌ Exception Occurred: $e");
      //       debugPrint("📚 Stack Trace: $stack");
      return false;
    } finally {
      //       debugPrint("🏁 ===== END ENQUIRY API =====");
    }
  }
}
