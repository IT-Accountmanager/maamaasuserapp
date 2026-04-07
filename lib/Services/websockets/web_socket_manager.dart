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
        url: 'ws://testing.maamaas.com:8080/food/ws',
        // url: 'wss://backend.maamaas.com/food/ws',
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
            print("📩 Order update for $orderId: $data");
            onMessage(data);
          }
        },
      );

      if (subscription != null) {
        _foodSubscriptions[orderId] = subscription;
        print("🔔 Subscribed to order $orderId");
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
      print("❌ Unsubscribed from Food order $orderId");
    } else {
      print("⚠️ No subscription found for Food order $orderId");
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
        // url: 'wss://backend.maamaas.com/delivery/ws/websocket',
        url: 'ws://testing.maamaas.com:8080/delivery/ws',
        onConnect: (frame) {
          print("✅ Delivery WebSocket Connected");
          onConnected?.call(); // 🔥 subscribe only after this
        },
        onWebSocketError: (error) => print("❌ Delivery WS Error: $error"),
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
        print("🔔 Subscribed to Delivery partner $partnerId");
      }
    });
  }

  void unsubscribePartnerLocation(int partnerId) {
    if (_deliverySubscriptions.containsKey(partnerId)) {
      _deliverySubscriptions[partnerId]?.call();
      _deliverySubscriptions.remove(partnerId);
      print("❌ Unsubscribed from Delivery partner $partnerId location");
    } else {
      print("⚠️ No subscription found for partner $partnerId");
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
    print("🛑 All WebSocket connections deactivated and subscriptions cleared");
  }

  // --------------------------
  // order update WS
  // --------------------------
  final Map<int, StompUnsubscribe> _cartSubscriptions = {};

  void subscribeUserCart(int userId, Function(Map<String, dynamic>) onMessage) {
    print("🚀 Trying to subscribe cart for userId: $userId");

    if (_cartSubscriptions.containsKey(userId)) {
      print("⚠️ Already subscribed to cart $userId");
      return;
    }

    void subscribe() {
      print("📡 Subscribing to /topic/user-cart-updates/$userId");

      final subscription = _foodClient?.subscribe(
        destination: '/topic/user-cart-updates/$userId',
        callback: (frame) {
          print("📥 RAW FRAME: ${frame.body}");

          if (frame.body != null) {
            try {
              final data = json.decode(frame.body!);

              print("🛒 Parsed Cart Update:");
              print(data);

              onMessage(data);
            } catch (e) {
              print("❌ JSON PARSE ERROR: $e");
            }
          } else {
            print("⚠️ Frame body is NULL");
          }
        },
      );

      if (subscription != null) {
        _cartSubscriptions[userId] = subscription;
        print("🔔 Subscribed SUCCESS for user $userId");
      } else {
        print("❌ Subscription FAILED for user $userId");
      }
    }

    if (_foodClient != null && _foodClient!.connected) {
      print("✅ Socket already connected → subscribing now");
      subscribe();
    } else {
      print("⏳ Socket not connected → adding to queue");
      _pendingFoodSubscriptions.add(subscribe);
      connectFoodSocket();
    }
  }

  void unsubscribeUserCart(int userId) {
    if (_cartSubscriptions.containsKey(userId)) {
      _cartSubscriptions[userId]?.call();
      _cartSubscriptions.remove(userId);
      print("❌ Unsubscribed from cart $userId");
    }
  }
}
