import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef SessionExpiredHandler = Future<void> Function();

class ApiClient {
  static const String subscription =
      // "http://testing.maamaas.com:8080/subscription";
      "https://backend.maamaas.com/subscription";
  static const String food_beverages =
      // "http://testing.maamaas.com:8080/food";
      "https://backend.maamaas.com/food";

  static const String notification =
      // "http://testing.maamaas.com:8080/notify";
      "https://delivery.maamaas.com/notify";

  static const String catering =
      // "http://testing.maamaas.com:8080/catering";
      "https://backend.maamaas.com/catering";

  static const String delivery =
      // "http://testing.maamaas.com:8080/delivery";
      "https://delivery.maamaas.com/delivery";

  static const String promotions =
      // "http://testing.maamaas.com:8080/promotions";
      "https://backend.maamaas.com/promotions";

  static SessionExpiredHandler? onSessionExpired;

  // 🔒 Refresh lock — prevents parallel refresh calls
  static Completer<String?>? _refreshCompleter;

  static String _resolveBaseUrl(String service) {
    switch (service) {
      case 'subscription':
        return subscription;
      case 'catering':
        return catering;
      case 'food':
        return food_beverages;
      case 'notification':
        return notification;
      case 'delivery':
        return delivery;

      case 'promotions':
        return promotions;
      default:
        return subscription;
    }
  }

  static const _secureStorage = FlutterSecureStorage();
  static final Dio _dio = Dio();

  static void initialize() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        // onError: (error, handler) async {
        //   if (error.response?.statusCode == 401 &&
        //       !error.requestOptions.path.contains("/auth/refresh") &&
        //       !error.requestOptions.path.contains("/auth/login")) {
        //     final newToken = await _safeRefresh();
        //
        //     if (newToken != null) {
        //       final options = error.requestOptions;
        //       options.headers["Authorization"] = "Bearer $newToken";
        //       final retry = await _dio.fetch(options);
        //       return handler.resolve(retry);
        //     }
        //
        //     await _triggerSessionExpired();
        //     return;
        //   }
        //   return handler.next(error);
        // },
        onError: (error, handler) async {
          // ✅ SKIP SESSION HANDLING FOR GUEST
          if (ApiClient.isGuestUser) {
            return handler.next(error);
          }

          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains("/auth/refresh") &&
              !error.requestOptions.path.contains("/auth/login")) {
            final newToken = await _safeRefresh();

            if (newToken != null) {
              final options = error.requestOptions;
              options.headers["Authorization"] = "Bearer $newToken";
              final retry = await _dio.fetch(options);
              return handler.resolve(retry);
            }

            await _triggerSessionExpired();
            return;
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// 🔒 Thread-safe refresh — only ONE refresh runs at a time.
  /// All concurrent callers await the same Completer.
  static Future<String?> _safeRefresh() async {
    // If a refresh is already in progress, wait for it
    if (_refreshCompleter != null) {
      debugPrint('⏳ Refresh already in progress, waiting...');
      return _refreshCompleter!.future;
    }

    // We are the first — own the lock
    _refreshCompleter = Completer<String?>();

    try {
      final newToken = await refreshAccessToken();
      _refreshCompleter!.complete(newToken);
      return newToken;
    } catch (e) {
      _refreshCompleter!.complete(null);
      return null;
    } finally {
      // Release the lock after a short delay so late waiters still get the result
      Future.delayed(Duration.zero, () => _refreshCompleter = null);
    }
  }

  static bool _sessionHandled = false;
  static bool isGuestUser = false;

  // static Future<void> _triggerSessionExpired() async {
  //   if (_sessionHandled) return;
  //
  //   debugPrint("🚨 SESSION EXPIRED TRIGGERED");
  //
  //   _sessionHandled = true;
  //
  //   if (onSessionExpired != null) {
  //     await onSessionExpired!();
  //   }
  // }

  static Future<void> _triggerSessionExpired() async {
    // 🚫 STOP for guest users
    if (isGuestUser) {
      debugPrint("🚫 Guest user → skip session expired");
      return;
    }

    if (_sessionHandled) return;

    debugPrint("🚨 SESSION EXPIRED TRIGGERED");

    _sessionHandled = true;

    if (onSessionExpired != null) {
      await onSessionExpired!();
    }
  }

  static void resetSessionFlag() {
    _sessionHandled = false;
  }

  static Future<void> clearSession() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refreshToken');
      debugPrint('🔍 Attempting refresh...');

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('❌ No refresh token found');
        return null;
      }

      final response = await _dio.post(
        '$subscription/api/auth/refresh',
        queryParameters: {'refreshTokenmobile': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('🔴 Refresh token invalid/expired');
        return null;
      }

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newToken = data['token'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newToken != null && newToken.isNotEmpty) {
          await _secureStorage.write(key: 'token', value: newToken);
          debugPrint('✅ New access token stored');
        }
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await _secureStorage.write(
            key: 'refreshToken',
            value: newRefreshToken,
          );
          debugPrint('✅ New refresh token stored');
        }
        return newToken;
      }

      debugPrint('🔴 Refresh failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('🔴 Refresh exception: $e');
      return null;
    }
  }

  /// All http.* requests go through here with the shared refresh lock
  static Future<http.Response> _handleRequestWithRefreshRetry(
    Future<http.Response> Function() requestFunc,
  ) async {
    http.Response response = await requestFunc();

    if (response.statusCode == 401 || response.statusCode == 403) {
      final newToken = await _safeRefresh(); // 🔒 uses shared lock

      if (newToken != null) {
        response = await requestFunc();
      } else {
        await _triggerSessionExpired();
      }
    }

    return response;
  }

  static Future<Map<String, String>> _headers({
    bool isMultipart = false,
  }) async {
    final token = await _secureStorage.read(key: 'token');
    final headers = <String, String>{};
    if (!isMultipart) headers['Content-Type'] = 'application/json';
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> get(
    String endpoint, {
    String service = 'subscription',
    bool requiresAuth = true,
  }) async {
    return _handleRequestWithRefreshRetry(() async {
      final baseUrl = _resolveBaseUrl(service);
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = requiresAuth
          ? await _headers()
          : {"Content-Type": "application/json"};
      return http.get(url, headers: headers);
    });
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic>? body, {
    String service = 'subscription',
    bool sendJson = true,
  }) async {
    return _handleRequestWithRefreshRetry(() async {
      final baseUrl = _resolveBaseUrl(service);
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _headers();
      if (body == null || body.isEmpty || !sendJson) {
        headers.remove('Content-Type');
      }
      return http.post(
        url,
        headers: headers,
        body: body == null ? null : (sendJson ? jsonEncode(body) : body),
      );
    });
  }

  static Future<http.Response> put(
    String endpoint,
    dynamic body, {
    String service = "subscription",
  }) async {
    return _handleRequestWithRefreshRetry(() async {
      final baseUrl = _resolveBaseUrl(service);
      final url = Uri.parse("$baseUrl/$endpoint");
      final headers = await _headers();
      return http.put(url, headers: headers, body: jsonEncode(body));
    });
  }

  static Future<http.Response> delete(
    String endpoint, {
    String service = 'subscription',
  }) async {
    return _handleRequestWithRefreshRetry(() async {
      final baseUrl = _resolveBaseUrl(service);
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _headers();
      return http.delete(url, headers: headers);
    });
  }

  static Future<http.Response> sendMultipartRequest({
    required String endpoint,
    required String method,
    required String service,
    Map<String, dynamic>? data,
    Map<String, File>? files,
  }) async {
    return _handleRequestWithRefreshRetry(() async {
      final token = await _secureStorage.read(key: 'token');
      if (token == null || token.isEmpty) {
        throw Exception("❌ Authentication token not found.");
      }

      final baseUrl = _resolveBaseUrl(service);
      final uri = Uri.parse("$baseUrl/$endpoint");
      final request = http.MultipartRequest(method, uri);

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      if (data != null) {
        for (final entry in data.entries) {
          final value = entry.value;
          if (value is String && value.trim().startsWith("{")) {
            request.files.add(
              http.MultipartFile.fromString(
                entry.key,
                value,
                contentType: MediaType("application", "json"),
              ),
            );
          } else {
            request.fields[entry.key] = value.toString();
          }
        }
      }

      if (files != null && files.isNotEmpty) {
        for (final entry in files.entries) {
          final file = entry.value;
          final mimeType =
              lookupMimeType(file.path) ?? "application/octet-stream";
          final parts = mimeType.split("/");
          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              filename: file.path.split('/').last,
              contentType: parts.length == 2
                  ? MediaType(parts[0], parts[1])
                  : MediaType("application", "octet-stream"),
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      return http.Response.fromStream(streamedResponse);
    });
  }
}
