import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  factory WebSocketManager() => _instance;

  WebSocketManager._internal();

  StompClient? _foodClient;
  StompClient? _deliveryClient;

  // --------------------------
  // FOOD WS (Order Status)
  // --------------------------

  final Map<int, StompUnsubscribe> _foodSubscriptions = {};
  bool _foodConnecting = false;
  final List<Function()> _pendingFoodSubscriptions = [];

  void connectFoodSocket() {
    if (_foodClient != null && _foodClient!.connected) {
      return;
    }

    if (_foodConnecting) return;

    _foodConnecting = true;

    _foodClient = StompClient(
      config: StompConfig(
        // url: 'ws://testing.maamaas.com:8080/food/ws',
        url: 'ws://backend.maamaas.com/food/ws',
        onConnect: (frame) {
          _foodConnecting = false;

          for (var callback in _pendingFoodSubscriptions) {
            callback();
          }
          _pendingFoodSubscriptions.clear();
        },
        onWebSocketError: (error) {
          _foodConnecting = false;
        },
        onDisconnect: (_) {},
      ),
    );

    _foodClient!.activate();
  }

  void subscribeOrderStatus(
    int orderId,
    Function(Map<String, dynamic>) onMessage,
  ) {
    if (_foodSubscriptions.containsKey(orderId)) {
      debugPrint("⚠️ Already subscribed to order $orderId");
      return;
    }

    void subscribe() {
      final subscription = _foodClient?.subscribe(
        destination: '/topic/order-updates/$orderId',
        callback: (frame) {
          if (frame.body != null) {
            final data = json.decode(frame.body!);
            debugPrint("📩 Order update for $orderId: $data");
            onMessage(data);
          }
        },
      );

      if (subscription != null) {
        _foodSubscriptions[orderId] = subscription;
        debugPrint("🔔 Subscribed to order $orderId");
      }
    }

    if (_foodClient != null && _foodClient!.connected) {
      subscribe();
    } else {
      _pendingFoodSubscriptions.add(subscribe);
      connectFoodSocket();
    }
  }

  void unsubscribeOrderStatus(int orderId) {
    if (_foodSubscriptions.containsKey(orderId)) {
      _foodSubscriptions[orderId]?.call();
      _foodSubscriptions.remove(orderId);
      debugPrint("❌ Unsubscribed from Food order $orderId");
    } else {
      debugPrint("⚠️ No subscription found for Food order $orderId");
    }
  }

  // --------------------------
  // DELIVERY WS (Partner Location)
  // --------------------------
  final Map<int, StompUnsubscribe> _deliverySubscriptions = {};

  void connectDeliverySocket(Function()? onConnected) {
    if (_deliveryClient != null && _deliveryClient!.connected) {
      onConnected?.call();
      return;
    }

    _deliveryClient = StompClient(
      config: StompConfig(
        url: 'ws://delivery.maamaas.com/delivery/ws/websocket',
        // url: 'ws://testing.maamaas.com:8080/delivery/ws',
        onConnect: (frame) {
          debugPrint("✅ Delivery WebSocket Connected");
          onConnected?.call();
        },
        onWebSocketError: (error) => debugPrint("❌ Delivery WS Error: $error"),
      ),
    );

    _deliveryClient!.activate();
  }

  void subscribePartnerLocation(
    int partnerId,
    Function(Map<String, dynamic>) onMessage,
  ) {
    connectDeliverySocket(() {
      final subscription = _deliveryClient?.subscribe(
        destination: '/topic/partner-location/$partnerId',
        callback: (frame) {
          if (frame.body != null) {
            final data = json.decode(frame.body!);
            onMessage(data);
          }
        },
      );

      if (subscription != null) {
        _deliverySubscriptions[partnerId] = subscription;
        debugPrint("🔔 Subscribed to Delivery partner $partnerId");
      }
    });
  }

  void unsubscribePartnerLocation(int partnerId) {
    if (_deliverySubscriptions.containsKey(partnerId)) {
      _deliverySubscriptions[partnerId]?.call();
      _deliverySubscriptions.remove(partnerId);
      debugPrint("❌ Unsubscribed from Delivery partner $partnerId location");
    } else {
      debugPrint("⚠️ No subscription found for partner $partnerId");
    }
  }

  // --------------------------
  // Disconnect All
  // --------------------------
  void disconnectAll() {
    _foodClient?.deactivate();
    _deliveryClient?.deactivate();
    _foodSubscriptions.clear();
    _deliverySubscriptions.clear();
    debugPrint(
      "🛑 All WebSocket connections deactivated and subscriptions cleared",
    );
  }

  // --------------------------
  // Cart WS
  // --------------------------
  final Map<int, StompUnsubscribe> _cartSubscriptions = {};

  /// Safely converts any JSON value to String.
  /// Returns null if the value is a Map, List, or truly null.
  static String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    // Map / List → not a valid string field, discard
    debugPrint(
      "⚠️ _safeString: unexpected type ${value.runtimeType} → dropping value",
    );
    return null;
  }

  /// Safely parses the cart JSON frame, logging each field that is mistyped.
  static Map<String, dynamic>? _safeParseCartFrame(String body) {
    try {
      final raw = json.decode(body);
      if (raw is! Map<String, dynamic>) {
        debugPrint("❌ Cart frame is not a JSON object: ${raw.runtimeType}");
        return null;
      }

      // Sanitise top-level string fields that the backend sometimes sends as objects
      const stringFields = [
        'orderType',
        'tableCode',
        'orderStatus',
        'deliveryAddress',
        'mobileNo',
        'name',
        'userCompany',
      ];
      for (final field in stringFields) {
        if (raw.containsKey(field) &&
            raw[field] is! String &&
            raw[field] != null) {
          debugPrint(
            "⚠️ Field '$field' arrived as ${raw[field].runtimeType} → coercing to String",
          );
          raw[field] = _safeString(raw[field]);
        }
      }

      // Sanitise couponCode (server sometimes sends full coupon object)
      final rawCoupon = raw['couponCode'];
      if (rawCoupon is Map) {
        raw['couponCode'] = rawCoupon['code']?.toString();
        debugPrint(
          "⚠️ couponCode was a Map → extracted code: ${raw['couponCode']}",
        );
      } else if (rawCoupon != null && rawCoupon is! String) {
        raw['couponCode'] = rawCoupon.toString();
      }

      // Sanitise each cartItem's string fields
      final items = raw['cartItems'];
      if (items is List) {
        const itemStringFields = [
          'dishName',
          'chefType',
          'dishImage',
          'note',
          'orderStatus',
          'category',
        ];
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          if (item is! Map<String, dynamic>) continue;
          for (final field in itemStringFields) {
            if (item.containsKey(field) &&
                item[field] is! String &&
                item[field] != null) {
              debugPrint(
                "⚠️ cartItems[$i].'$field' arrived as ${item[field].runtimeType} → coercing",
              );
              item[field] = _safeString(item[field]);
            }
          }
        }
      }

      return raw;
    } catch (e, stack) {
      debugPrint("❌ JSON PARSE ERROR: $e");
      debugPrint("$stack");
      return null;
    }
  }

  void subscribeUserCart(int userId, Function(Map<String, dynamic>) onMessage) {
    debugPrint("🚀 Trying to subscribe cart for userId: $userId");

    if (_cartSubscriptions.containsKey(userId)) {
      debugPrint("⚠️ Already subscribed to cart $userId");
      return;
    }

    void subscribe() {
      debugPrint("📡 Subscribing to /topic/user-cart-updates/$userId");

      final subscription = _foodClient?.subscribe(
        destination: '/topic/user-cart-updates/$userId',
        callback: (frame) {
          // Flutter's debugPrint truncates at ~1000 chars — this is display-only,
          // frame.body itself is always the complete STOMP message body.
          debugPrint(
            "📥 RAW FRAME (first 500 chars): ${frame.body?.substring(0, frame.body!.length.clamp(0, 500))}",
          );

          if (frame.body == null) {
            debugPrint("⚠️ Frame body is NULL");
            return;
          }

          final data = _safeParseCartFrame(frame.body!);
          if (data == null) return;

          debugPrint(
            "🛒 Parsed Cart Update: cartId=${data['cartId']}, items=${(data['cartItems'] as List?)?.length}",
          );
          onMessage(data);
        },
      );

      if (subscription != null) {
        _cartSubscriptions[userId] = subscription;
        debugPrint("🔔 Subscribed SUCCESS for user $userId");
      } else {
        debugPrint("❌ Subscription FAILED for user $userId");
      }
    }

    if (_foodClient != null && _foodClient!.connected) {
      debugPrint("✅ Socket already connected → subscribing now");
      subscribe();
    } else {
      debugPrint("⏳ Socket not connected → adding to queue");
      _pendingFoodSubscriptions.add(subscribe);
      connectFoodSocket();
    }
  }

  void unsubscribeUserCart(int userId) {
    if (_cartSubscriptions.containsKey(userId)) {
      _cartSubscriptions[userId]?.call();
      _cartSubscriptions.remove(userId);
      debugPrint("❌ Unsubscribed from cart $userId");
    }
  }
}
