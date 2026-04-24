// // import 'dart:convert';
// // import 'package:flutter/cupertino.dart';
// // import 'package:stomp_dart_client/stomp_dart_client.dart';
// //
// // class WebSocketManager {
// //   static final WebSocketManager _instance = WebSocketManager._internal();
// //   factory WebSocketManager() => _instance;
// //
// //   WebSocketManager._internal();
// //
// //   StompClient? _foodClient;
// //   StompClient? _deliveryClient;
// //
// //
// //   String? _lastCartFrameBody;
// //
// //   // --------------------------
// //   // FOOD WS (Order Status)
// //   // --------------------------
// //
// //   final Map<int, StompUnsubscribe> _foodSubscriptions = {};
// //   bool _foodConnecting = false;
// //   final List<Function()> _pendingFoodSubscriptions = [];
// //
// //   void connectFoodSocket() {
// //     if (_foodClient != null && _foodClient!.connected) {
// //       return;
// //     }
// //
// //     if (_foodConnecting) return;
// //
// //     _foodConnecting = true;
// //
// //     _foodClient = StompClient(
// //       config: StompConfig(
// //         url: 'ws://testing.maamaas.com:8080/food/ws',
// //         // url: 'ws://backend.maamaas.com/food/ws',
// //         onConnect: (frame) {
// //           _foodConnecting = false;
// //
// //           for (var callback in _pendingFoodSubscriptions) {
// //             callback();
// //           }
// //           _pendingFoodSubscriptions.clear();
// //         },
// //         onWebSocketError: (error) {
// //           _foodConnecting = false;
// //         },
// //         onDisconnect: (_) {},
// //       ),
// //     );
// //
// //     _foodClient!.activate();
// //   }
// //
// //   void subscribeOrderStatus(
// //     int orderId,
// //     Function(Map<String, dynamic>) onMessage,
// //   ) {
// //     if (_foodSubscriptions.containsKey(orderId)) {
// //       debugPrint("⚠️ Already subscribed to order $orderId");
// //       return;
// //     }
// //
// //     void subscribe() {
// //       final subscription = _foodClient?.subscribe(
// //         destination: '/topic/order-updates/$orderId',
// //         callback: (frame) {
// //           if (frame.body != null) {
// //             final data = json.decode(frame.body!);
// //             debugPrint("📩 Order update for $orderId: $data");
// //             onMessage(data);
// //           }
// //         },
// //       );
// //
// //       if (subscription != null) {
// //         _foodSubscriptions[orderId] = subscription;
// //         debugPrint("🔔 Subscribed to order $orderId");
// //       }
// //     }
// //
// //     if (_foodClient != null && _foodClient!.connected) {
// //       subscribe();
// //     } else {
// //       _pendingFoodSubscriptions.add(subscribe);
// //       connectFoodSocket();
// //     }
// //   }
// //
// //   void unsubscribeOrderStatus(int orderId) {
// //     if (_foodSubscriptions.containsKey(orderId)) {
// //       _foodSubscriptions[orderId]?.call();
// //       _foodSubscriptions.remove(orderId);
// //       debugPrint("❌ Unsubscribed from Food order $orderId");
// //     } else {
// //       debugPrint("⚠️ No subscription found for Food order $orderId");
// //     }
// //   }
// //
// //   // --------------------------
// //   // DELIVERY WS (Partner Location)
// //   // --------------------------
// //   final Map<int, StompUnsubscribe> _deliverySubscriptions = {};
// //
// //   void connectDeliverySocket(Function()? onConnected) {
// //     if (_deliveryClient != null && _deliveryClient!.connected) {
// //       onConnected?.call();
// //       return;
// //     }
// //
// //     _deliveryClient = StompClient(
// //       config: StompConfig(
// //         // url: 'ws://delivery.maamaas.com/delivery/ws/websocket',
// //         url: 'ws://testing.maamaas.com:8080/delivery/ws',
// //         onConnect: (frame) {
// //           debugPrint("✅ Delivery WebSocket Connected");
// //           onConnected?.call();
// //         },
// //         onWebSocketError: (error) => debugPrint("❌ Delivery WS Error: $error"),
// //       ),
// //     );
// //
// //     _deliveryClient!.activate();
// //   }
// //
// //   void subscribePartnerLocation(
// //     int partnerId,
// //     Function(Map<String, dynamic>) onMessage,
// //   ) {
// //     connectDeliverySocket(() {
// //       final subscription = _deliveryClient?.subscribe(
// //         destination: '/topic/partner-location/$partnerId',
// //         callback: (frame) {
// //           if (frame.body != null) {
// //             final data = json.decode(frame.body!);
// //             onMessage(data);
// //           }
// //         },
// //       );
// //
// //       if (subscription != null) {
// //         _deliverySubscriptions[partnerId] = subscription;
// //         debugPrint("🔔 Subscribed to Delivery partner $partnerId");
// //       }
// //     });
// //   }
// //
// //   void unsubscribePartnerLocation(int partnerId) {
// //     if (_deliverySubscriptions.containsKey(partnerId)) {
// //       _deliverySubscriptions[partnerId]?.call();
// //       _deliverySubscriptions.remove(partnerId);
// //       debugPrint("❌ Unsubscribed from Delivery partner $partnerId location");
// //     } else {
// //       debugPrint("⚠️ No subscription found for partner $partnerId");
// //     }
// //   }
// //
// //   // --------------------------
// //   // Disconnect All
// //   // --------------------------
// //   void disconnectAll() {
// //     _foodClient?.deactivate();
// //     _deliveryClient?.deactivate();
// //     _foodSubscriptions.clear();
// //     _deliverySubscriptions.clear();
// //     debugPrint(
// //       "🛑 All WebSocket connections deactivated and subscriptions cleared",
// //     );
// //   }
// //
// //   // --------------------------
// //   // Cart WS
// //   // --------------------------
// //   final Map<int, StompUnsubscribe> _cartSubscriptions = {};
// //
// //   /// Safely converts any JSON value to String.
// //   /// Returns null if the value is a Map, List, or truly null.
// //   static String? _safeString(dynamic value) {
// //     if (value == null) return null;
// //     if (value is String) return value;
// //     if (value is num || value is bool) return value.toString();
// //     // Map / List → not a valid string field, discard
// //     debugPrint(
// //       "⚠️ _safeString: unexpected type ${value.runtimeType} → dropping value",
// //     );
// //     return null;
// //   }
// //
// //   /// Safely parses the cart JSON frame, logging each field that is mistyped.
// //   static Map<String, dynamic>? _safeParseCartFrame(String body) {
// //     try {
// //       final raw = json.decode(body);
// //       if (raw is! Map<String, dynamic>) {
// //         debugPrint("❌ Cart frame is not a JSON object: ${raw.runtimeType}");
// //         return null;
// //       }
// //
// //       // Sanitise top-level string fields that the backend sometimes sends as objects
// //       const stringFields = [
// //         'orderType',
// //         'tableCode',
// //         'orderStatus',
// //         'deliveryAddress',
// //         'mobileNo',
// //         'name',
// //         'userCompany',
// //       ];
// //       for (final field in stringFields) {
// //         if (raw.containsKey(field) &&
// //             raw[field] is! String &&
// //             raw[field] != null) {
// //           debugPrint(
// //             "⚠️ Field '$field' arrived as ${raw[field].runtimeType} → coercing to String",
// //           );
// //           raw[field] = _safeString(raw[field]);
// //         }
// //       }
// //
// //       // Sanitise couponCode (server sometimes sends full coupon object)
// //       final rawCoupon = raw['couponCode'];
// //       if (rawCoupon is Map) {
// //         raw['couponCode'] = rawCoupon['code']?.toString();
// //         debugPrint(
// //           "⚠️ couponCode was a Map → extracted code: ${raw['couponCode']}",
// //         );
// //       } else if (rawCoupon != null && rawCoupon is! String) {
// //         raw['couponCode'] = rawCoupon.toString();
// //       }
// //
// //       // Sanitise each cartItem's string fields
// //       final items = raw['cartItems'];
// //       if (items is List) {
// //         const itemStringFields = [
// //           'dishName',
// //           'chefType',
// //           'dishImage',
// //           'note',
// //           'orderStatus',
// //           'category',
// //         ];
// //         for (int i = 0; i < items.length; i++) {
// //           final item = items[i];
// //           if (item is! Map<String, dynamic>) continue;
// //           for (final field in itemStringFields) {
// //             if (item.containsKey(field) &&
// //                 item[field] is! String &&
// //                 item[field] != null) {
// //               debugPrint(
// //                 "⚠️ cartItems[$i].'$field' arrived as ${item[field].runtimeType} → coercing",
// //               );
// //               item[field] = _safeString(item[field]);
// //             }
// //           }
// //         }
// //       }
// //
// //       return raw;
// //     } catch (e, stack) {
// //       debugPrint("❌ JSON PARSE ERROR: $e");
// //       debugPrint("$stack");
// //       return null;
// //     }
// //   }
// //
// //   void subscribeUserCart(int userId, Function(Map<String, dynamic>) onMessage) {
// //     debugPrint("🚀 Trying to subscribe cart for userId: $userId");
// //
// //     if (_cartSubscriptions.containsKey(userId)) {
// //       debugPrint("⚠️ Already subscribed to cart $userId");
// //       return;
// //     }
// //
// //     void subscribe() {
// //       debugPrint("📡 Subscribing to /topic/user-cart-updates/$userId");
// //
// //       final subscription = _foodClient?.subscribe(
// //         destination: '/topic/user-cart-updates/$userId',
// //         callback: (frame) {
// //           if (frame.body == null) return;
// //
// //           // True dedup: drop if body is byte-for-byte identical to last frame
// //           if (frame.body == _lastCartFrameBody) {
// //             debugPrint("🔁 Duplicate cart frame dropped at socket level");
// //             _lastCartFrameBody = null; // reset so the next real event isn't blocked
// //             return;
// //           }
// //           _lastCartFrameBody = frame.body;
// //           // Reset after short window so next genuine update isn't blocked
// //           Future.delayed(const Duration(milliseconds: 500), () {
// //             _lastCartFrameBody = null;
// //           });
// //
// //           final data = _safeParseCartFrame(frame.body!);
// //           if (data == null) return;
// //           onMessage(data);
// //         },
// //       );
// //
// //       if (subscription != null) {
// //         _cartSubscriptions[userId] = subscription;
// //         debugPrint("🔔 Subscribed SUCCESS for user $userId");
// //       } else {
// //         debugPrint("❌ Subscription FAILED for user $userId");
// //       }
// //     }
// //
// //     if (_foodClient != null && _foodClient!.connected) {
// //       debugPrint("✅ Socket already connected → subscribing now");
// //       subscribe();
// //     } else {
// //       debugPrint("⏳ Socket not connected → adding to queue");
// //       _pendingFoodSubscriptions.add(subscribe);
// //       connectFoodSocket();
// //     }
// //   }
// //
// //   void unsubscribeUserCart(int userId) {
// //     if (_cartSubscriptions.containsKey(userId)) {
// //       _cartSubscriptions[userId]?.call();
// //       _cartSubscriptions.remove(userId);
// //       debugPrint("❌ Unsubscribed from cart $userId");
// //     }
// //   }
// // }
//
//
//
// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:stomp_dart_client/stomp_dart_client.dart';
//
// class WebSocketManager {
//   static final WebSocketManager _instance = WebSocketManager._internal();
//   factory WebSocketManager() => _instance;
//
//   WebSocketManager._internal();
//
//   StompClient? _foodClient;
//   StompClient? _deliveryClient;
//
//   // --------------------------
//   // FOOD WS (Order Status)
//   // --------------------------
//
//   final Map<int, StompUnsubscribe> _foodSubscriptions = {};
//   bool _foodConnecting = false;
//   final List<Function()> _pendingFoodSubscriptions = [];
//
//   void connectFoodSocket() {
//     if (_foodClient != null && _foodClient!.connected) {
//       return;
//     }
//
//     if (_foodConnecting) return;
//
//     _foodConnecting = true;
//
//     _foodClient = StompClient(
//       config: StompConfig(
//         url: 'ws://testing.maamaas.com:8080/food/ws',
//         // url: 'ws://backend.maamaas.com/food/ws',
//         onConnect: (frame) {
//           _foodConnecting = false;
//
//           for (var callback in _pendingFoodSubscriptions) {
//             callback();
//           }
//           _pendingFoodSubscriptions.clear();
//         },
//         onWebSocketError: (error) {
//           _foodConnecting = false;
//         },
//         onDisconnect: (_) {},
//       ),
//     );
//
//     _foodClient!.activate();
//   }
//
//   void subscribeOrderStatus(
//       int orderId,
//       Function(Map<String, dynamic>) onMessage,
//       ) {
//     if (_foodSubscriptions.containsKey(orderId)) {
//       debugPrint("⚠️ Already subscribed to order $orderId");
//       return;
//     }
//
//     void subscribe() {
//       final subscription = _foodClient?.subscribe(
//         destination: '/topic/order-updates/$orderId',
//         callback: (frame) {
//           if (frame.body != null) {
//             final data = json.decode(frame.body!);
//             debugPrint("📩 Order update for $orderId: $data");
//             onMessage(data);
//           }
//         },
//       );
//
//       if (subscription != null) {
//         _foodSubscriptions[orderId] = subscription;
//         debugPrint("🔔 Subscribed to order $orderId");
//       }
//     }
//
//     if (_foodClient != null && _foodClient!.connected) {
//       subscribe();
//     } else {
//       _pendingFoodSubscriptions.add(subscribe);
//       connectFoodSocket();
//     }
//   }
//
//   void unsubscribeOrderStatus(int orderId) {
//     if (_foodSubscriptions.containsKey(orderId)) {
//       _foodSubscriptions[orderId]?.call();
//       _foodSubscriptions.remove(orderId);
//       debugPrint("❌ Unsubscribed from Food order $orderId");
//     } else {
//       debugPrint("⚠️ No subscription found for Food order $orderId");
//     }
//   }
//
//   // --------------------------
//   // DELIVERY WS (Partner Location)
//   // --------------------------
//   final Map<int, StompUnsubscribe> _deliverySubscriptions = {};
//
//   void connectDeliverySocket(Function()? onConnected) {
//     if (_deliveryClient != null && _deliveryClient!.connected) {
//       onConnected?.call();
//       return;
//     }
//
//     _deliveryClient = StompClient(
//       config: StompConfig(
//         // url: 'ws://delivery.maamaas.com/delivery/ws/websocket',
//         url: 'ws://testing.maamaas.com:8080/delivery/ws',
//         onConnect: (frame) {
//           debugPrint("✅ Delivery WebSocket Connected");
//           onConnected?.call();
//         },
//         onWebSocketError: (error) => debugPrint("❌ Delivery WS Error: $error"),
//       ),
//     );
//
//     _deliveryClient!.activate();
//   }
//
//   void subscribePartnerLocation(
//       int partnerId,
//       Function(Map<String, dynamic>) onMessage,
//       ) {
//     connectDeliverySocket(() {
//       final subscription = _deliveryClient?.subscribe(
//         destination: '/topic/partner-location/$partnerId',
//         callback: (frame) {
//           if (frame.body != null) {
//             final data = json.decode(frame.body!);
//             onMessage(data);
//           }
//         },
//       );
//
//       if (subscription != null) {
//         _deliverySubscriptions[partnerId] = subscription;
//         debugPrint("🔔 Subscribed to Delivery partner $partnerId");
//       }
//     });
//   }
//
//   void unsubscribePartnerLocation(int partnerId) {
//     if (_deliverySubscriptions.containsKey(partnerId)) {
//       _deliverySubscriptions[partnerId]?.call();
//       _deliverySubscriptions.remove(partnerId);
//       debugPrint("❌ Unsubscribed from Delivery partner $partnerId location");
//     } else {
//       debugPrint("⚠️ No subscription found for partner $partnerId");
//     }
//   }
//
//   // --------------------------
//   // Disconnect All
//   // --------------------------
//   void disconnectAll() {
//     _foodClient?.deactivate();
//     _deliveryClient?.deactivate();
//     _foodSubscriptions.clear();
//     _deliverySubscriptions.clear();
//     debugPrint(
//       "🛑 All WebSocket connections deactivated and subscriptions cleared",
//     );
//   }
//
//   // --------------------------
//   // Cart WS
//   // --------------------------
//   final Map<int, StompUnsubscribe> _cartSubscriptions = {};
//   final Map<int, Function(Map<String, dynamic>)> _cartCallbacks = {};
//
//   /// Safely converts any JSON value to String.
//   /// Returns null if the value is a Map, List, or truly null.
//   static String? _safeString(dynamic value) {
//     if (value == null) return null;
//     if (value is String) return value;
//     if (value is num || value is bool) return value.toString();
//     // Map / List → not a valid string field, discard
//     debugPrint(
//       "⚠️ _safeString: unexpected type ${value.runtimeType} → dropping value",
//     );
//     return null;
//   }
//
//   /// Safely parses the cart JSON frame, logging each field that is mistyped.
//   static Map<String, dynamic>? _safeParseCartFrame(String body) {
//     try {
//       final raw = json.decode(body);
//       if (raw is! Map<String, dynamic>) {
//         debugPrint("❌ Cart frame is not a JSON object: ${raw.runtimeType}");
//         return null;
//       }
//
//       // Sanitise top-level string fields that the backend sometimes sends as objects
//       const stringFields = [
//         'orderType',
//         'tableCode',
//         'orderStatus',
//         'deliveryAddress',
//         'mobileNo',
//         'name',
//         'userCompany',
//       ];
//       for (final field in stringFields) {
//         if (raw.containsKey(field) &&
//             raw[field] is! String &&
//             raw[field] != null) {
//           debugPrint(
//             "⚠️ Field '$field' arrived as ${raw[field].runtimeType} → coercing to String",
//           );
//           raw[field] = _safeString(raw[field]);
//         }
//       }
//
//       // Sanitise couponCode (server sometimes sends full coupon object)
//       final rawCoupon = raw['couponCode'];
//       if (rawCoupon is Map) {
//         raw['couponCode'] = rawCoupon['code']?.toString();
//         debugPrint(
//           "⚠️ couponCode was a Map → extracted code: ${raw['couponCode']}",
//         );
//       } else if (rawCoupon != null && rawCoupon is! String) {
//         raw['couponCode'] = rawCoupon.toString();
//       }
//
//       // Sanitise each cartItem's string fields
//       final items = raw['cartItems'];
//       if (items is List) {
//         const itemStringFields = [
//           'dishName',
//           'chefType',
//           'dishImage',
//           'note',
//           'orderStatus',
//           'category',
//         ];
//         for (int i = 0; i < items.length; i++) {
//           final item = items[i];
//           if (item is! Map<String, dynamic>) continue;
//           for (final field in itemStringFields) {
//             if (item.containsKey(field) &&
//                 item[field] is! String &&
//                 item[field] != null) {
//               debugPrint(
//                 "⚠️ cartItems[$i].'$field' arrived as ${item[field].runtimeType} → coercing",
//               );
//               item[field] = _safeString(item[field]);
//             }
//           }
//         }
//       }
//
//       return raw;
//     } catch (e, stack) {
//       debugPrint("❌ JSON PARSE ERROR: $e");
//       debugPrint("$stack");
//       return null;
//     }
//   }
//
//   void subscribeUserCart(int userId, Function(Map<String, dynamic>) onMessage) {
//     debugPrint("🚀 Trying to subscribe cart for userId: $userId");
//
//     // ✅ Always update the callback — the cart screen may have been recreated
//     //    (new instance = new _updateCartFromSocket function pointer).
//     //    Without this, the STOMP subscription stays alive but calls a dead
//     //    callback from the previous, disposed screen instance.
//     _cartCallbacks[userId] = onMessage;
//
//     if (_cartSubscriptions.containsKey(userId)) {
//       debugPrint("🔄 Callback updated for existing cart subscription $userId");
//       return;
//     }
//
//     void subscribe() {
//       debugPrint("📡 Subscribing to /topic/user-cart-updates/$userId");
//
//       final subscription = _foodClient?.subscribe(
//         destination: '/topic/user-cart-updates/$userId',
//         callback: (frame) {
//           debugPrint(
//             "📥 RAW FRAME (first 500 chars): ${frame.body?.substring(0, frame.body!.length.clamp(0, 500))}",
//           );
//
//           if (frame.body == null) {
//             debugPrint("⚠️ Frame body is NULL");
//             return;
//           }
//
//           final data = _safeParseCartFrame(frame.body!);
//           if (data == null) return;
//
//           debugPrint(
//             "🛒 Parsed Cart Update: cartId=${data['cartId']}, items=${(data['cartItems'] as List?)?.length}",
//           );
//
//           // ✅ Always call the CURRENT callback, not the one captured at subscribe time
//           _cartCallbacks[userId]?.call(data);
//         },
//       );
//
//       if (subscription != null) {
//         _cartSubscriptions[userId] = subscription;
//         debugPrint("🔔 Subscribed SUCCESS for user $userId");
//       } else {
//         debugPrint("❌ Subscription FAILED for user $userId");
//       }
//     }
//
//     if (_foodClient != null && _foodClient!.connected) {
//       debugPrint("✅ Socket already connected → subscribing now");
//       subscribe();
//     } else {
//       debugPrint("⏳ Socket not connected → adding to queue");
//       _pendingFoodSubscriptions.add(subscribe);
//       connectFoodSocket();
//     }
//   }
//
//   void unsubscribeUserCart(int userId) {
//     if (_cartSubscriptions.containsKey(userId)) {
//       _cartSubscriptions[userId]?.call();
//       _cartSubscriptions.remove(userId);
//       _cartCallbacks.remove(userId);
//       debugPrint("❌ Unsubscribed from cart $userId");
//     }
//   }
// }

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

  /// One STOMP subscription per orderId (the actual WS channel).
  final Map<int, StompUnsubscribe> _foodSubscriptions = {};

  /// Multiple named listeners per orderId.
  /// Key: orderId  →  Value: { listenerId → callback }
  final Map<int, Map<String, Function(Map<String, dynamic>)>> _orderListeners =
      {};

  bool _foodConnecting = false;
  final List<Function()> _pendingFoodSubscriptions = [];

  void connectFoodSocket() {
    if (_foodClient != null && _foodClient!.connected) return;
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

  /// Subscribe [listenerId] to status updates for [orderId].
  ///
  /// - If no STOMP channel exists for this [orderId] yet, one is created.
  /// - If a channel already exists, [onMessage] is simply added as an extra
  ///   listener — the existing channel is **not** recreated.
  /// - Use a unique [listenerId] per screen/widget (e.g. `'list'`, `'details'`).
  void subscribeOrderStatus(
    int orderId,
    Function(Map<String, dynamic>) onMessage, {
    String listenerId = 'default',
  }) {
    // Register the listener regardless of whether the STOMP channel exists yet.
    _orderListeners.putIfAbsent(orderId, () => {});
    _orderListeners[orderId]![listenerId] = onMessage;
    debugPrint('🔔 Listener "$listenerId" added for order $orderId');

    // If STOMP channel already exists, nothing more to do.
    if (_foodSubscriptions.containsKey(orderId)) {
      debugPrint('✅ STOMP channel for order $orderId already open');
      return;
    }

    void subscribe() {
      final subscription = _foodClient?.subscribe(
        destination: '/topic/order-updates/$orderId',
        callback: (frame) {
          if (frame.body == null) return;
          final data = json.decode(frame.body!) as Map<String, dynamic>;
          debugPrint('📩 Order update for $orderId: $data');
          // Fan-out to every registered listener for this orderId
          final listeners = Map.of(_orderListeners[orderId] ?? {});
          for (final cb in listeners.values) {
            cb(data);
          }
        },
      );

      if (subscription != null) {
        _foodSubscriptions[orderId] = subscription;
        debugPrint('📡 STOMP channel opened for order $orderId');
      }
    }

    if (_foodClient != null && _foodClient!.connected) {
      subscribe();
    } else {
      _pendingFoodSubscriptions.add(subscribe);
      connectFoodSocket();
    }
  }

  /// Remove the listener identified by [listenerId] for [orderId].
  ///
  /// The STOMP channel is only closed when **all** listeners have been removed.
  void unsubscribeOrderStatus(int orderId, {String listenerId = 'default'}) {
    _orderListeners[orderId]?.remove(listenerId);
    debugPrint('🗑 Listener "$listenerId" removed for order $orderId');

    final remaining = _orderListeners[orderId]?.length ?? 0;
    if (remaining == 0) {
      // No more listeners — close the STOMP channel too.
      _orderListeners.remove(orderId);
      if (_foodSubscriptions.containsKey(orderId)) {
        _foodSubscriptions[orderId]?.call();
        _foodSubscriptions.remove(orderId);
        debugPrint(
          '❌ STOMP channel closed for order $orderId (no listeners left)',
        );
      }
    } else {
      debugPrint(
        'ℹ️ $remaining listener(s) still active for order $orderId — channel kept open',
      );
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
          debugPrint('✅ Delivery WebSocket Connected');
          onConnected?.call();
        },
        onWebSocketError: (error) => debugPrint('❌ Delivery WS Error: $error'),
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
        debugPrint('🔔 Subscribed to Delivery partner $partnerId');
      }
    });
  }

  void unsubscribePartnerLocation(int partnerId) {
    if (_deliverySubscriptions.containsKey(partnerId)) {
      _deliverySubscriptions[partnerId]?.call();
      _deliverySubscriptions.remove(partnerId);
      debugPrint('❌ Unsubscribed from Delivery partner $partnerId location');
    } else {
      debugPrint('⚠️ No subscription found for partner $partnerId');
    }
  }

  // --------------------------
  // Disconnect All
  // --------------------------
  void disconnectAll() {
    _foodClient?.deactivate();
    _deliveryClient?.deactivate();
    _foodSubscriptions.clear();
    _orderListeners.clear();
    _deliverySubscriptions.clear();
    debugPrint(
      '🛑 All WebSocket connections deactivated and subscriptions cleared',
    );
  }

  // --------------------------
  // Cart WS
  // --------------------------
  final Map<int, StompUnsubscribe> _cartSubscriptions = {};
  final Map<int, Function(Map<String, dynamic>)> _cartCallbacks = {};

  /// Safely converts any JSON value to String.
  static String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    debugPrint(
      '⚠️ _safeString: unexpected type ${value.runtimeType} → dropping value',
    );
    return null;
  }

  /// Safely parses the cart JSON frame, logging each field that is mistyped.
  static Map<String, dynamic>? _safeParseCartFrame(String body) {
    try {
      final raw = json.decode(body);
      if (raw is! Map<String, dynamic>) {
        debugPrint('❌ Cart frame is not a JSON object: ${raw.runtimeType}');
        return null;
      }

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

      final rawCoupon = raw['couponCode'];
      if (rawCoupon is Map) {
        raw['couponCode'] = rawCoupon['code']?.toString();
      } else if (rawCoupon != null && rawCoupon is! String) {
        raw['couponCode'] = rawCoupon.toString();
      }

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
              item[field] = _safeString(item[field]);
            }
          }
        }
      }

      return raw;
    } catch (e, stack) {
      debugPrint('❌ JSON PARSE ERROR: $e');
      debugPrint('$stack');
      return null;
    }
  }

  void subscribeUserCart(int userId, Function(Map<String, dynamic>) onMessage) {
    debugPrint('🚀 Trying to subscribe cart for userId: $userId');
    _cartCallbacks[userId] = onMessage;

    if (_cartSubscriptions.containsKey(userId)) {
      debugPrint('🔄 Callback updated for existing cart subscription $userId');
      return;
    }

    void subscribe() {
      debugPrint('📡 Subscribing to /topic/user-cart-updates/$userId');

      final subscription = _foodClient?.subscribe(
        destination: '/topic/user-cart-updates/$userId',
        callback: (frame) {
          if (frame.body == null) return;
          final data = _safeParseCartFrame(frame.body!);
          if (data == null) return;
          _cartCallbacks[userId]?.call(data);
        },
      );

      if (subscription != null) {
        _cartSubscriptions[userId] = subscription;
        debugPrint('🔔 Subscribed SUCCESS for user $userId');
      } else {
        debugPrint('❌ Subscription FAILED for user $userId');
      }
    }

    if (_foodClient != null && _foodClient!.connected) {
      subscribe();
    } else {
      _pendingFoodSubscriptions.add(subscribe);
      connectFoodSocket();
    }
  }

  void unsubscribeUserCart(int userId) {
    if (_cartSubscriptions.containsKey(userId)) {
      _cartSubscriptions[userId]?.call();
      _cartSubscriptions.remove(userId);
      _cartCallbacks.remove(userId);
      debugPrint('❌ Unsubscribed from cart $userId');
    }
  }
}
