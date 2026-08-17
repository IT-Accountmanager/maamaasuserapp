import 'package:maamaas/screens/Food&beverages/foodmainscreen.dart';

import '../../Models/food/restaurent_banner_model.dart';
import '../../Services/App_color_service/app_colours.dart';
import '../../Services/Auth_service/promotion_services_Authservice.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../widgets/paymentstatus.dart';
import '../../widgets/safearea.dart';
import '../../widgets/widgets/food/currentcart_notifier.dart';
import '../../Models/promotions_model/promotions_model.dart';
import '../screens/advertisements/banneradvertisement.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/paymentservice/razorpayservice.dart';
import '../../Services/Auth_service/food_authservice.dart';
import '../../Services/websockets/web_socket_manager.dart';
import '../../Services/scaffoldmessenger/messenger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maamaas/widgets/signinrequired.dart';
import '../../Models/subscrptions/coupon_model.dart';
import '../../Models/subscrptions/wallet_model.dart';
import '../../providers/addressmodel_provider.dart';
import 'package:maamaas/Mainscreen.dart';
import '../../widgets/widgets/cart wallet.dart';
import '../../Models/food/cart_model.dart';
import '../screens/ordertypebutton.dart';
import '../skeleton/cart_skeleton.dart';
import 'package:flutter/material.dart';
import '../screens/saved_address.dart';
import 'Menu/menu_screen.dart';
import 'food_invoice.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
class cartuser {
  // Backgrounds
  static const bg = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);

  // Brand — warm orange (Zomato/Swiggy energy)
  static const brand = Color(0xFFFF6B35);
  static const brandLight = Color(0xFFFFF0EB);
  static const brandDark = Color(0xFFE55A27);

  // Text
  static const textPrimary = Color(0xFF1C1C1E);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFFB0B8C8);

  // Semantic
  static const green = Color(0xFF22C55E);
  static const greenLight = Color(0xFFDCFCE7);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEE2E2);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const blue = Color(0xFF3B82F6);
  static const blueLight = Color(0xFFEFF6FF);

  // Borders / shadow
  static const border = Color(0xFFEEF0F5);
  static final shadow = Colors.black.withOpacity(0.05);
  static const violet = Color(0xFF6C63FF);
  static const violetDim = Color(0x1A6C63FF);
}

// ─── Enums ────────────────────────────────────────────────────────────────────

// ─── Main Widget ──────────────────────────────────────────────────────────────
// ignore: camel_case_types
class food_cartScreen extends ConsumerStatefulWidget {
  final int? vendorId;
  final int? cartId;
  final double? savedAmount;
  final bool showSavedPopup;

  const food_cartScreen({
    super.key,
    this.vendorId,
    this.cartId,
    this.savedAmount,
    this.showSavedPopup = false,
  });

  @override
  ConsumerState<food_cartScreen> createState() => _food_cartScreenState();
}

// ignore: camel_case_types
class _food_cartScreenState extends ConsumerState<food_cartScreen> {
  CartModel? cartData;
  bool isLoading = true;
  bool isPlacingOrder = false;
  bool couponApplied = false;
  String selectedPaymentMethod = "";
  String couponCode = "";
  bool isExpanded = false;
  Wallet? wallet;
  int? appliedCouponId;
  String? appliedCouponCode;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late ScrollController _scrollController;
  String _orderType = "";
  bool isCouponLoading = false;
  Set<String> selectedSubWallets = {};
  int userId = 0;
  List<Campaign> homepageAds = [];
  bool _isSummaryExpanded = false;
  final List<Map<String, dynamic>> _pendingSocketUpdates = [];

  PaymentOverlayState _overlayState = PaymentOverlayState.none;

  bool _isLoadingCart = false;
  // ignore: prefer_final_fields
  int _socketVersion = 0;
  String? _lastSocketEventKey;

  bool _orderCreationStarted = false;

  PaymentStatus _paymentStatus = PaymentStatus.created;

  String paymentMessage = "Preparing payment...";

  String paymentStatusTitle = "Payment Created";

  String paymentStatusDescription =
      "Your payment request has been created. Please complete the payment.";
  Restaurent_Banner? vendorBanner;
  bool isLoadingVendorName = false;

  int _paymentStatusIndex(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.created:
        return 0;

      case PaymentStatus.authenticated:
        return 1;

      case PaymentStatus.authorized:
        return 2;

      case PaymentStatus.captured:
        return 3;

      case PaymentStatus.refunded:
        return 4;

      case PaymentStatus.failed:
        return 4;

      case PaymentStatus.unknown:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadAllData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WebSocketManager().unsubscribeUserCart(userId);
    super.dispose();
  }

  // ── All data / socket logic (unchanged) ───────────────────────────────────
  Future<void> _loadAllData() async {
    if (mounted) setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId') ?? 0;
    WebSocketManager().subscribeUserCart(userId, _updateCartFromSocket);

    _isLoadingCart = true;

    try {
      final results = await Future.wait([
        food_Authservice.fetchCart(),
        subscription_AuthService.fetchWallet(),
        promotion_Authservice.fetchcampaign(),
      ]);

      if (!mounted) return;

      final freshCart = results[0] as CartModel?;
      final walletData = results[1] as Wallet;
      final ads = results[2] as List<Campaign>;
      // debugPrint("freshCart items: ${freshCart?.cartItems.length}");
      // debugPrint("current cartData items: ${cartData?.cartItems.length}");

      setState(() {
        if (cartData == null) {
          cartData = freshCart;
        } else {
          if (freshCart != null) {
            cartData!.grandTotal = freshCart.grandTotal;
            cartData!.subtotal = freshCart.subtotal;
            cartData!.gstTotal = freshCart.gstTotal;
            cartData!.deliveryCharges = freshCart.deliveryCharges;
            cartData!.discountAmount = freshCart.discountAmount;
            cartData!.platformCharges = freshCart.platformCharges;
            cartData!.deliveryAddress = freshCart.deliveryAddress;
            cartData!.packingTotal = freshCart.packingTotal;
          }
        }
        if (cartData?.hasAnyScheduledItem ?? false) _orderType = 'schedule';
        wallet = walletData;
        homepageAds = ads
            .where(
              (c) =>
                  c.medium == Medium.APP &&
                  c.addDisplayPosition == AddDisplayPosition.CHECKOUT_PAGE,
            )
            .toList();
        isLoading = false;
      });

      _isLoadingCart = false;
      _flushPendingSocketUpdates();
    } catch (e) {
      _isLoadingCart = false;
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<String> mapWalletsToEnum(List<String> s) => s.map((w) {
    switch (w) {
      case "Cashbacks":
        return "CASHBACK";
      case "Self Loaded":
        return "SELF_LOADED";
      case "Postpaid used amount":
        return "POST_PAID";
      case "Company Loaded":
        return "COMPANY_LOADED";
      case "Earned Amount":
        return "EARNED_AMOUNT";
      default:
        return w.toUpperCase().replaceAll(' ', '_');
    }
  }).toList();

  void _updateCartFromSocket(Map<String, dynamic> data) {
    final socketItems = data['cartItems'] as List? ?? [];
    final allUpdatedAt = socketItems
        .map((i) => (i as Map)['updatedAt']?.toString() ?? '')
        .join(',');
    final eventKey = '${data['cartId']}_$allUpdatedAt';
    if (eventKey == _lastSocketEventKey) return;
    _lastSocketEventKey = eventKey;
    Future.delayed(
      const Duration(milliseconds: 400),
      () => _lastSocketEventKey = null,
    );

    if (!mounted) return;
    if (cartData == null) {
      setState(() {
        cartData = CartModel.fromJson(data);
        isLoading = false;
      });
      return;
    }
    if (_isLoadingCart) {
      _pendingSocketUpdates
        ..clear()
        ..add(data);
      return;
    }
    _applySocketUpdate(data);
  }

  void _flushPendingSocketUpdates() {
    if (_pendingSocketUpdates.isEmpty) return;
    final latest = _pendingSocketUpdates.last;
    _pendingSocketUpdates.clear();
    _applySocketUpdate(latest);
  }

  void _applySocketUpdate(Map<String, dynamic> data) {
    final List socketItems = data['cartItems'] ?? [];
    if (!mounted) return;
    final oldItems = List<CartItem>.from(cartData!.cartItems);
    setState(() {
      cartData!.cartItems = socketItems.map((json) {
        final map = json as Map<String, dynamic>;
        // debugPrint("========== SOCKET ITEM ==========");
        map.forEach((key, value) {
          // debugPrint("$key -> ${value.runtimeType} : $value");
        });
        final idx = oldItems.indexWhere((i) => i.itemId == map['itemId']);
        if (idx != -1) {
          final old = oldItems[idx];
          return CartItem(
            itemId: old.itemId,
            dishName: old.dishName,
            dishId: old.dishId,
            chefType: old.chefType,
            dishImage: old.dishImage,
            // actualPrice: (map['actualPrice'] ?? old.actualPrice).toDouble(),
            actualPrice:
                (map['actualPrice'] as num?)?.toDouble() ?? old.actualPrice,
            // gst: (map['gst'] ?? old.gst).toDouble(),
            gst: (map['gst'] as num?)?.toDouble() ?? old.gst,

            // quantity: map['quantity'] ?? old.quantity,
            quantity: (map['quantity'] as num?)?.toInt() ?? old.quantity,
            // price: (map['price'] ?? old.price).toDouble(),
            price: (map['price'] as num?)?.toDouble() ?? old.price,
            // totalPrice: (map['totalPrice'] ?? old.totalPrice).toDouble(),
            totalPrice:
                (map['totalPrice'] as num?)?.toDouble() ?? old.totalPrice,
            // packingCharges: (map['packingCharges'] ?? old.packingCharges)
            //     .toDouble(),
            packingCharges:
                (map['packingCharges'] as num?)?.toDouble() ??
                old.packingCharges,

            // balanceQuantity: map['balanceQuantity'] ?? old.balanceQuantity,
            balanceQuantity:
                (map['balanceQuantity'] as num?)?.toInt() ??
                old.balanceQuantity,
            available: map['available'] ?? old.available,
            shedule: map.containsKey('shedule')
                ? map['shedule'] == true
                : old.shedule,
            addons: old.addons,
            metrics: map['metrics'] ?? old.metrics,
            // metricQuantity: (map['metricQuantity'] ?? old.metricQuantity)
            //     .toDouble(),
            metricQuantity:
                (map['metricQuantity'] as num?)?.toInt() ?? old.metricQuantity,
          );
        }
        return CartItem.fromJson(map);
      }).toList();

      // cartData!.subtotal = (data['subtotal'] ?? 0).toDouble();
      cartData!.subtotal = (data['subtotal'] as num?)?.toDouble() ?? 0;
      // cartData!.gstTotal = (data['gstTotal'] ?? 0).toDouble();
      cartData!.gstTotal = (data['gstTotal'] as num?)?.toDouble() ?? 0;
      // cartData!.packingTotal = (data['packingTotal'] ?? 0).toDouble();
      cartData!.packingTotal = (data['packingTotal'] as num?)?.toDouble() ?? 0;
      // cartData!.platformCharges = (data['platformCharges'] ?? 0).toDouble();
      cartData!.platformCharges =
          (data['platformCharges'] as num?)?.toDouble() ?? 0;
      // cartData!.deliveryCharges = (data['deliveryCharges'] ?? 0).toDouble();
      cartData!.deliveryCharges =
          (data['deliveryCharges'] as num?)?.toDouble() ?? 0;
      // cartData!.discountAmount = (data['discountAmount'] ?? 0).toDouble();
      cartData!.discountAmount =
          (data['discountAmount'] as num?)?.toDouble() ?? 0;
      // cartData!.grandTotal = (data['grandTotal'] ?? 0).toDouble();
      cartData!.grandTotal = (data['grandTotal'] as num?)?.toDouble() ?? 0;
      // cartData!.cgst = (data['cgst'] ?? 0).toDouble();
      cartData!.cgst = (data['cgst'] as num?)?.toDouble() ?? 0;
      // cartData!.sgst = (data['sgst'] ?? 0).toDouble();
      cartData!.sgst = (data['sgst'] as num?)?.toDouble() ?? 0;
      cartData!.deliveryAddress =
          data['deliveryAddress'] ?? cartData!.deliveryAddress;
      cartData!.mobileNo = data['mobileNo'] ?? cartData!.mobileNo;
      cartData!.name = data['name'] ?? cartData!.name;

      final rawCoupon = data['couponCode'];
      cartData!.couponCode = rawCoupon is String
          ? rawCoupon
          : rawCoupon is Map
          ? rawCoupon['code']
          : null;
    });
  }

  Future<void> _loadCart() async {
    _isLoadingCart = true;
    setState(() => isLoading = true);
    final versionAtStart = _socketVersion;
    try {
      final c = await food_Authservice.fetchCart();
      if (mounted) {
        setState(() {
          if (_socketVersion == versionAtStart) {
            cartData = c;
            if (cartData?.hasAnyScheduledItem ?? false) _orderType = 'schedule';
          }
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    } finally {
      _isLoadingCart = false;
      _flushPendingSocketUpdates();
    }
  }

  double getSelectedWalletBalance() {
    if (wallet == null) return 0;
    double t = 0;
    if (selectedSubWallets.contains("Company Loaded")) {
      t += wallet!.companyLoadedAmount;
    }
    if (selectedSubWallets.contains("Self Loaded")) {
      t += wallet!.selfLoadedAmount;
    }
    if (selectedSubWallets.contains("Cashbacks")) t += wallet!.cashbackAmount;
    if (selectedSubWallets.contains("Postpaid used amount")) {
      t += wallet!.postPaidUsage;
    }
    return t;
  }

  void _updatePaymentStatus(PaymentStatus status) {
    if (!mounted) return;

    setState(() {
      _paymentStatus = status;

      switch (status) {
        case PaymentStatus.created:
          paymentStatusTitle = "Payment Created";
          paymentStatusDescription =
              "Your payment request has been created. Please complete the payment.";
          paymentMessage = "Preparing payment...";

          break;

        case PaymentStatus.authenticated:
          paymentStatusTitle = "Payment Authenticated";
          paymentStatusDescription =
              "Your bank has authenticated the payment. We are waiting for the payment authorization to complete.";
          paymentMessage = "Waiting for bank confirmation...";

          break;

        case PaymentStatus.authorized:
          paymentStatusTitle = "Payment Authorized";
          paymentStatusDescription =
              "Your bank has approved the payment, but the amount has not been captured yet. We are finalizing the payment.";

          paymentMessage = "Finalizing payment...";

          break;

        case PaymentStatus.captured:
          paymentStatusTitle = "Payment Successful";
          paymentStatusDescription =
              "Your payment has been successfully captured. We can now create your order.";

          paymentMessage = "Payment successful. Creating your order...";

          break;

        case PaymentStatus.failed:
          paymentStatusTitle = "Payment Failed";
          paymentStatusDescription =
              "The payment could not be completed. Your order will not be placed.";

          paymentMessage = "Payment failed.";

          break;

        case PaymentStatus.refunded:
          paymentStatusTitle = "Payment Refunded";
          paymentStatusDescription =
              "The payment was not captured successfully. If money was debited from your account, it will be reversed/refunded according to the payment provider and bank processing time.";

          paymentMessage = "Payment refunded.";

          break;

        case PaymentStatus.unknown:
          paymentStatusTitle = "Checking Payment";
          paymentStatusDescription =
              "We are checking the latest status of your payment. Please wait.";

          paymentMessage = "Verifying payment...";
          break;
      }
    });
  }

  Future<void> placeOrder() async {
    final hasScheduledItems = cartData?.hasAnyScheduledItem ?? false;
    if (hasScheduledItems && (_selectedDate == null || _selectedTime == null)) {
      AppAlert.error(
        context,
        "Please select date & time to schedule your order",
      );
      return;
    }
    if ((cartData?.orderType ?? '').trim().toLowerCase() == 'delivery') {
      if ((cartData?.deliveryAddress ?? '').trim().isEmpty) {
        AppAlert.error(context, "Please select a delivery address");
        return;
      }
    }
    if (selectedPaymentMethod == "Maamaas_Wallet") {
      final wb = getSelectedWalletBalance();
      final gt = (cartData?.grandTotal ?? 0).toDouble();
      if (wb < gt) {
        AppAlert.error(
          context,
          "Insufficient wallet balance\nWallet: ₹${wb.toStringAsFixed(2)}\nOrder Total: ₹${gt.toStringAsFixed(2)}",
        );
        return;
      }
    }
    if (selectedPaymentMethod.isEmpty) {
      AppAlert.error(context, "Please select a payment method");
      return;
    }

    setState(() => isPlacingOrder = true);
    try {
      final bool isUserScheduled =
          _selectedDate != null || _selectedTime != null;

      if (selectedPaymentMethod == "Online_Payment") {
        final amount = (cartData?.grandTotal ?? 0).toDouble();
        if (mounted) {
          setState(() => _overlayState = PaymentOverlayState.openingGateway);
        }
        final orderId = await food_Authservice.createOrder(amount);
        if (orderId == null) {
          AppAlert.error(context, "Failed to create payment order");
          return;
        }
        final rp = RazorpayService();

        // rp.onSuccess = (res) async {
        //   final pid = res.paymentId!;
        //   final oid = res.orderId!;
        //
        //   if (mounted) {
        //     setState(() => _overlayState = PaymentOverlayState.processing);
        //   }
        //
        //   // Capture payment first
        //   final captured = await food_Authservice.capturePayment(
        //     paymentId: pid,
        //     amount: amount,
        //   );
        //
        //   if (!captured) {
        //     AppAlert.error(
        //       context,
        //       "Unable to capture payment. We'll verify automatically.",
        //     );
        //     return;
        //   }
        //
        //   // Wait until Razorpay confirms CAPTURED
        //   for (int i = 0; i < 15; i++) {
        //     final payment = await food_Authservice.verifyPayment(pid);
        //
        //     print("========== PAYMENT VERIFY ==========");
        //     print("Attempt      : ${i + 1}");
        //     print("Payment ID   : $pid");
        //
        //     if (payment == null) {
        //       print("Response     : NULL");
        //       print("====================================");
        //
        //       await Future.delayed(const Duration(seconds: 2));
        //       continue;
        //     }
        //
        //     print("Status       : ${payment.status}");
        //     print("Captured     : ${payment.captured}");
        //     print("====================================");
        //
        //     switch (payment.status?.toLowerCase()) {
        //       case "created":
        //         print("Payment Status -> CREATED");
        //         if (mounted) {
        //           setState(() {
        //             paymentMessage = "Preparing payment...";
        //           });
        //         }
        //         break;
        //
        //       case "authenticated":
        //         print("Payment Status -> AUTHENTICATED");
        //         if (mounted) {
        //           setState(() {
        //             paymentMessage =
        //                 "Payment authenticated.\nWaiting for bank confirmation...";
        //           });
        //         }
        //         break;
        //
        //       case "authorized":
        //         print("Payment Status -> AUTHORIZED");
        //         if (mounted) {
        //           setState(() {
        //             paymentMessage =
        //                 "Payment authorized.\nFinalizing payment...";
        //           });
        //         }
        //         break;
        //
        //       case "captured":
        //         print("Payment Status -> CAPTURED");
        //         if (mounted) {
        //           setState(() {
        //             paymentMessage =
        //                 "Payment successful.\nCreating your order...";
        //           });
        //         }
        //
        //         final ok = isUserScheduled
        //             ? await _placeScheduledOrder(
        //                 paymentMethod: "Online_Payment",
        //                 razorpayPaymentId: pid,
        //                 razorpayOrderId: oid,
        //                 amount: amount,
        //               )
        //             : await _placeDirectOrder(
        //                 paymentMethod: "Online_Payment",
        //                 razorpayPaymentId: pid,
        //                 razorpayOrderId: oid,
        //                 amount: amount,
        //               );
        //
        //         print("Order Created : $ok");
        //
        //         if (!ok) {
        //           AppAlert.error(
        //             context,
        //             "Payment completed but order creation failed.\nPayment ID: $pid",
        //           );
        //         }
        //
        //         return;
        //
        //       case "refunded":
        //         print("Payment Status -> REFUNDED");
        //         AppAlert.info(
        //           context,
        //           "Payment refunded.\nAmount will be credited in 3-5 business days.",
        //         );
        //         return;
        //
        //       case "failed":
        //         print("Payment Status -> FAILED");
        //         AppAlert.error(context, "Payment failed.");
        //         return;
        //
        //       default:
        //         print("Unknown Payment Status -> ${payment.status}");
        //     }
        //
        //     await Future.delayed(const Duration(seconds: 2));
        //   }
        //
        //   AppAlert.info(
        //     context,
        //     "Payment is still being verified. Please wait a moment.",
        //   );
        // };
        rp.onSuccess = (res) async {
          final pid = res.paymentId!;
          final oid = res.orderId!;

          if (mounted) {
            setState(() {
              _overlayState = PaymentOverlayState.processing;
              _paymentStatus = PaymentStatus.created;
            });
          }

          try {
            print("====================================");
            print("STARTING PAYMENT CAPTURE");
            print("Payment ID : $pid");
            print("Order ID   : $oid");
            print("Amount     : $amount");
            print("====================================");

            final capturedRequest = await food_Authservice.capturePayment(
              paymentId: pid,
              amount: amount,
            );

            print("Capture API result : $capturedRequest");

            for (int i = 0; i < 15; i++) {
              print("");
              print("====================================");
              print("PAYMENT VERIFICATION");
              print("Attempt    : ${i + 1}/15");
              print("Payment ID : $pid");
              print("====================================");

              final payment = await food_Authservice.verifyPayment(pid);

              if (payment == null) {
                print("Payment verification returned NULL");

                if (mounted) {
                  _updatePaymentStatus(PaymentStatus.unknown);
                }

                await Future.delayed(const Duration(seconds: 2));

                continue;
              }

              final status = paymentstatus.parsePaymentStatus(payment.status);

              print("Status   : ${payment.status}");
              print("Captured : ${payment.captured}");

              // --------------------------------------------------
              // STEP 3: Update UI
              // --------------------------------------------------

              if (mounted) {
                _updatePaymentStatus(status);
              }

              // --------------------------------------------------
              // STEP 4: ONLY CAPTURED CAN CREATE ORDER
              // --------------------------------------------------

              if (status == PaymentStatus.captured ||
                  payment.captured == true) {
                print("====================================");
                print("PAYMENT CAPTURED");
                print("CREATING ORDER...");
                print("====================================");

                if (_orderCreationStarted) {
                  print("Order creation already started.");
                  return;
                }

                _orderCreationStarted = true;

                if (mounted) {
                  setState(() {
                    paymentMessage =
                        "Payment successful.\nCreating your order...";
                  });
                }

                final bool ok = isUserScheduled
                    ? await _placeScheduledOrder(
                        paymentMethod: "Online_Payment",
                        razorpayPaymentId: pid,
                        razorpayOrderId: oid,
                        amount: amount,
                      )
                    : await _placeDirectOrder(
                        paymentMethod: "Online_Payment",
                        razorpayPaymentId: pid,
                        razorpayOrderId: oid,
                        amount: amount,
                      );

                print("====================================");
                print("ORDER CREATED : $ok");
                print("====================================");

                if (!ok) {
                  if (mounted) {
                    AppAlert.error(
                      context,
                      "Payment was successful, but we could not create your order.\n"
                      "Payment ID: $pid",
                    );
                  }
                }

                return;
              }

              // --------------------------------------------------
              // FAILED
              // --------------------------------------------------

              if (status == PaymentStatus.failed) {
                print("PAYMENT FAILED");

                if (mounted) {
                  setState(() {
                    paymentMessage =
                        "Payment failed. Your order has not been placed.";
                  });
                }

                return;
              }

              // --------------------------------------------------
              // REFUNDED
              // --------------------------------------------------

              if (status == PaymentStatus.refunded) {
                print("PAYMENT REFUNDED");

                if (mounted) {
                  setState(() {
                    paymentMessage =
                        "Payment was refunded. Your order has not been placed.";
                  });
                }

                return;
              }

              // --------------------------------------------------
              // CREATED / AUTHENTICATED / AUTHORIZED
              // --------------------------------------------------

              await Future.delayed(const Duration(seconds: 2));
            }

            // --------------------------------------------------
            // STEP 5: Still not captured
            // --------------------------------------------------

            print("PAYMENT NOT CAPTURED AFTER POLLING");

            print("====================================");
            print("PAYMENT VERIFICATION TIMEOUT");
            print("Payment ID : $pid");
            print("Attempts   : 15");
            print("====================================");

            if (mounted) {
              setState(() {
                _overlayState = PaymentOverlayState.none;
                isPlacingOrder = false;
              });

              AppAlert.info(
                context,
                "Payment status could not be confirmed.\n\n"
                "Your order has NOT been placed.\n\n"
                "If money was debited from your account, "
                "the amount will be automatically refunded "
                "within 2–3 working days.",
                duration: Duration(seconds: 5),
              );
            }

            // catch (e) {
            //   print("PAYMENT ERROR: $e");
            //
            //   if (mounted) {
            //     setState(() {
            //       paymentStatusTitle = "Payment Verification Error";
            //
            //       paymentStatusDescription =
            //           "We couldn't confirm the payment status right now. "
            //           "Your order has not been placed. "
            //           "Please check your payment status before trying again.";
            //
            //       paymentMessage = "Unable to verify payment.";
            //     });
            //   }
            // }
          } catch (e) {
            print("====================================");
            print("PAYMENT VERIFICATION ERROR");
            print("Error : $e");
            print("====================================");

            if (mounted) {
              setState(() {
                _overlayState = PaymentOverlayState.none;
                isPlacingOrder = false;

                paymentStatusTitle = "Payment Verification Failed";

                paymentStatusDescription =
                    "We couldn't confirm the payment status.\n\n"
                    "Your order has NOT been placed.\n\n"
                    "If money was debited from your account, "
                    "the amount will be automatically refunded "
                    "within 2–3 working days.";

                paymentMessage = "Payment status could not be confirmed.";
              });

              AppAlert.info(
                context,
                "We couldn't confirm your payment status.\n\n"
                "Your order has NOT been placed.\n\n"
                "If money was debited, the amount will be "
                "automatically refunded within 2–3 working days.",
                duration: Duration(seconds: 4),
              );
            }

            return;
          }
        };
        rp.onError = (res) {
          if (!mounted) return;

          setState(() {
            _overlayState = PaymentOverlayState.none;

            paymentStatusTitle = "Payment Failed";

            paymentStatusDescription =
                "The payment process was cancelled or failed. "
                "Your order has not been placed.";

            paymentMessage = "Payment failed.";
          });

          AppAlert.error(context, "Payment failed: ${res.message}");
        };
        rp.startPayment(
          orderId: orderId,
          amount: amount,
          description: "Online Payment via Razorpay",
        );
        return;
      }

      final amt = cartData!.grandTotal.toDouble();
      if (isUserScheduled) {
        await _placeScheduledOrder(
          paymentMethod: selectedPaymentMethod,
          razorpayPaymentId: "",
          razorpayOrderId: "",
          amount: amt,
        );
      } else {
        await _placeDirectOrder(
          paymentMethod: selectedPaymentMethod,
          razorpayPaymentId: "",
          razorpayOrderId: "",
          amount: amt,
        );
      }
    } catch (e) {
      String message = e.toString().contains("Exception:")
          ? e.toString().replaceFirst("Exception: ", "")
          : e.toString();
      if (mounted) setState(() => _overlayState = PaymentOverlayState.none);
      AppAlert.error(context, message);
    } finally {
      if (mounted) setState(() => isPlacingOrder = false);
    }
  }

  Future<bool> _placeScheduledOrder({
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required double amount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');
    if (cartId == null) return false;
    final result = await food_Authservice.scheduleOrder(
      cartId: cartId,
      date: _selectedDate ?? DateTime.now(),
      time: _selectedTime ?? TimeOfDay.now(),
      paymentMethod: paymentMethod,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
      amount: amount,
    );
    if (result.containsKey('orderId')) {
      final oid = result['orderId'];
      await prefs.setInt('orderId', oid);
      if (mounted) {
        setState(() => _overlayState = PaymentOverlayState.processing);
        await Future.delayed(const Duration(milliseconds: 2200));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
          );
        }
      }
      return true;
    }
    return false;
  }

  Future<bool> _placeDirectOrder({
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required double amount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');
    if (cartId == null) return false;
    final result = await food_Authservice.placeDirectOrder(
      cartId: cartId,
      paymentMethod: paymentMethod,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
      amount: amount,
    );
    if (result.containsKey('orderId')) {
      final oid = result['orderId'];
      await prefs.setInt('orderId', oid);
      if (mounted) {
        setState(() => _overlayState = PaymentOverlayState.processing);
        await Future.delayed(const Duration(milliseconds: 2200));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => food_Invoice(orderId: oid)),
          );
        }
      }
      return true;
    }
    return false;
  }

  Future<void> changeQuantity(CartItem item, int newQty) async {
    final old = item.quantity;
    setState(() => item.quantity = newQty);
    _isLoadingCart = true;
    final ok = await food_Authservice.updateCartQuantity(item.itemId, newQty);
    if (!ok) {
      setState(() {
        item.quantity = old;
        item.totalPrice = item.price * old;
      });
    }
    _isLoadingCart = false;
    _flushPendingSocketUpdates();
  }

  Future<void> _onRefresh() async => _loadAllData();

  String _fmt(num? v) => (v ?? 0).toStringAsFixed(2);

  Future<void> _clearCartLocally() async {
    CartNotifier.count.value = 0;
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith('dish_')) await prefs.remove(key);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: cartuser.bg,
          appBar: _buildAppBar(),
          body: AuthGuard(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: cartuser.brand,
                backgroundColor: cartuser.surface,
                strokeWidth: 2.5,
                child: isLoading
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(16.w),
                        child: const CartSkeleton(
                          type: CartSkeletonType.fullCart,
                        ),
                      )
                    : SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (cartData == null || cartData!.cartItems.isEmpty)
                              _buildEmptyCart()
                            else ...[
                              _buildCartItems(),
                              SizedBox(height: 8.h),
                              _buildAddMoreRow(),
                              SizedBox(height: 14.h),

                              OrderCartFooter(
                                onOrderTypeChanged: () async =>
                                    await _loadCart(),
                              ),

                              // Ads banner
                              if (homepageAds.isNotEmpty) ...[
                                SizedBox(height: 14.h),
                                _sectionLabel('Recommended for you'),
                                SizedBox(height: 8.h),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14.r),
                                  child: BannerAdvertisement(
                                    ads: homepageAds,
                                    height: 180,
                                  ),
                                ),
                              ],

                              SizedBox(height: 14.h),
                              _buildCouponRow(),
                              SizedBox(height: 10.h),

                              if ((cartData?.orderType ?? '')
                                      .trim()
                                      .toLowerCase() ==
                                  'delivery')
                                _buildDeliveryAddress(),

                              SizedBox(height: 10.h),
                              _buildSummaryCard(),
                              SizedBox(height: 12.h),
                              _buildScheduleOrder(),
                              SizedBox(height: 12.h),
                              _buildPaymentToggle(),
                              if (isExpanded) ...[
                                SizedBox(height: 12.h),
                                _buildCheckoutDetails(),
                              ],
                              SizedBox(height: 24.h),
                            ],
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
        if (_overlayState != PaymentOverlayState.none)
          Positioned.fill(
            child: AbsorbPointer(
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  color: Colors.black.withOpacity(0.65),
                  child: Center(child: _overlayContent()),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    final bool isEmpty = (cartData?.cartItems.isEmpty ?? true);

    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        decoration: const BoxDecoration(
          color: cartuser.surface,
          border: Border(bottom: BorderSide(color: cartuser.border)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: cartuser.textPrimary,
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const foodMainScreen()),
                    );
                  }
                },
              ),
              Expanded(
                child: Text(
                  isEmpty ? 'Cart' : 'Your Cart',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: cartuser.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (isEmpty)
                Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => foodMainScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: cartuser.brandLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.restaurant_menu_rounded,
                            size: 14,
                            color: cartuser.brand,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Browse',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: cartuser.brand,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () async {
                    final ok = await food_Authservice.deleteCart();
                    if (!mounted) return;
                    if (ok) {
                      await _clearCartLocally();
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => foodMainScreen()),
                      );
                      AppAlert.success(context, 'Cart cleared');
                    } else {
                      AppAlert.error(context, 'Failed to clear cart');
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12.w),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cartuser.redLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: cartuser.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Overlay ───────────────────────────────────────────────────────────────
  Widget _overlayContent() {
    switch (_overlayState) {
      case PaymentOverlayState.placingOrder:
        return _dialogLoader(
          "Placing your order...",
          Icons.shopping_bag_outlined,
        );
      case PaymentOverlayState.openingGateway:
        return _dialogLoader(
          "Opening payment gateway...",
          Icons.lock_outline_rounded,
        );
      case PaymentOverlayState.processing:
        return _dialogLoader("Confirming payment...", Icons.verified_outlined);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _dialogLoader(String text, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: Container(
        key: ValueKey(text),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        decoration: BoxDecoration(
          color: cartuser.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: cartuser.brandLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: cartuser.brand,
                  strokeWidth: 2.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cartuser.textPrimary,
                decoration: TextDecoration.none,
              ),
              child: Text(text),
            ),
            const SizedBox(height: 4),
            const DefaultTextStyle(
              style: TextStyle(
                fontSize: 12,
                color: cartuser.textSecondary,
                decoration: TextDecoration.none,
              ),
              child: Text("Please don't close this screen"),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Label ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: cartuser.textPrimary,
      ),
    );
  }

  // ── Empty Cart ────────────────────────────────────────────────────────────
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 40.h),
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: cartuser.brandLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 44,
              color: cartuser.brand,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: cartuser.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add some delicious items to get started',
            style: TextStyle(fontSize: 14, color: cartuser.textSecondary),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => foodMainScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: cartuser.brand,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: cartuser.brand.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'Browse Menu',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (homepageAds.isNotEmpty) ...[
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: BannerAdvertisement(ads: homepageAds, height: 180),
            ),
          ],
        ],
      ),
    );
  }

  // ── Cart Items ────────────────────────────────────────────────────────────
  Widget _buildCartItems() {
    if (cartData == null || cartData!.cartItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...cartData!.cartItems.map((item) {
            final isLast = item == cartData!.cartItems.last;
            return Column(
              key: ValueKey(item.itemId),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${item.dishName} ${item.metricQuantity} ${item.metrics}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: cartuser.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),

                            Row(
                              children: [
                                if (item.addons.isNotEmpty)
                                  GestureDetector(
                                    onTap: () => _showAddonBottomSheet(item),
                                    child: const Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Text(
                                        "Edit",
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.addons.isNotEmpty
                                        ? item.addons
                                              .map((e) => e.addonName)
                                              .join(', ')
                                        : 'No Addons',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: cartuser.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        children: [
                          _buildQtyControl(item),
                          SizedBox(height: 10.w),
                          SizedBox(
                            width: 72.w,
                            child: Text(
                              '₹${item.totalPrice.toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: cartuser.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isLast) Divider(height: 1, color: cartuser.border),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showAddonBottomSheet(CartItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return PlatformSafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.dishName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ...item.addons.map((addon) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    addon.addonName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  Text(
                                    "₹${addon.addonPrice}",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () async {
                                if (addon.quantity == 0) return;

                                await food_Authservice.updateAddon(
                                  item.itemId,
                                  addon.addonId,
                                  addon.quantity - 1,
                                );

                                setSheetState(() {
                                  addon.quantity--;
                                });

                                setState(() {});
                              },
                            ),

                            Text(
                              addon.quantity.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),

                            IconButton(
                              icon: const Icon(Icons.add_circle),
                              onPressed: () async {
                                await food_Authservice.updateAddon(
                                  item.itemId,
                                  addon.addonId,
                                  addon.quantity + 1,
                                );

                                setSheetState(() {
                                  addon.quantity++;
                                });

                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQtyControl(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: cartuser.bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: cartuser.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(
            Icons.remove_rounded,
            cartuser.red,
            () => changeQuantity(item, item.quantity - 1),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              '${item.quantity}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: cartuser.textPrimary,
              ),
            ),
          ),
          _qtyBtn(
            Icons.add_rounded,
            cartuser.green,
            () => changeQuantity(item, item.quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(7.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 14.sp, color: color),
      ),
    );
  }

  // ── Add More Row ──────────────────────────────────────────────────────────
  Widget _buildAddMoreRow() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MenuScreen(vendorId: cartData!.vendorId),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cartuser.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cartuser.brand.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              size: 17,
              color: cartuser.brand,
            ),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                text: 'Missed something? ',
                style: TextStyle(fontSize: 13, color: cartuser.textSecondary),
                children: [
                  TextSpan(
                    text: 'Add more items',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cartuser.brand,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Coupon Row ────────────────────────────────────────────────────────────
  // Widget _buildCouponRow() {
  //   final applied = (cartData?.couponCode ?? '').isNotEmpty;
  //
  //   return GestureDetector(
  //     onTap: applied ? null : _showCouponBottomSheet,
  //     child: _card(
  //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
  //       child: Column(
  //         children: [
  //           Row(
  //             children: [
  //               Container(
  //                 width: 40,
  //                 height: 40,
  //                 decoration: BoxDecoration(
  //                   color: applied ? cartuser.greenLight : cartuser.brandLight,
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 child: Icon(
  //                   applied
  //                       ? Icons.check_circle_rounded
  //                       : Icons.local_offer_rounded,
  //                   size: 20,
  //                   color: applied ? cartuser.green : cartuser.brand,
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       applied ? 'Coupon Applied' : 'Apply Coupon',
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w700,
  //                         color: applied
  //                             ? cartuser.green
  //                             : cartuser.textPrimary,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               if (applied)
  //                 GestureDetector(
  //                   onTap: () async {
  //                     if (cartData?.cartId == null) return;
  //
  //                     final result = await food_Authservice.updateCartSettings(
  //                       cartId: cartData!.cartId,
  //                       couponId: cartData!.couponId,
  //                       applyCoupon: "NOT_APPLIED",
  //                     );
  //
  //                     if (!result.success) {
  //                       AppAlert.error(
  //                         context,
  //                         result.error ?? "Failed to remove coupon",
  //                       );
  //                       return;
  //                     }
  //
  //                     setState(() {
  //                       appliedCouponCode = null;
  //                       appliedCouponId = null;
  //                     });
  //
  //                     AppAlert.success(context, "Coupon removed");
  //                   },
  //                   child: Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 12,
  //                       vertical: 6,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: cartuser.redLight,
  //                       borderRadius: BorderRadius.circular(20),
  //                     ),
  //                     child: const Text(
  //                       'Remove',
  //                       style: TextStyle(
  //                         fontSize: 12,
  //                         color: cartuser.red,
  //                         fontWeight: FontWeight.w700,
  //                       ),
  //                     ),
  //                   ),
  //                 )
  //               else
  //                 const Icon(
  //                   Icons.chevron_right_rounded,
  //                   color: cartuser.textMuted,
  //                 ),
  //             ],
  //           ),
  //           Center(
  //             child: Text(
  //               applied
  //                   ? (cartData!.couponCode ?? '')
  //                   : 'Save more on your order',
  //               style: const TextStyle(
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.bold,
  //                 color: cartuser.textSecondary,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCouponRow() {
    final applied = (cartData?.couponCode ?? '').isNotEmpty;

    return _card(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Top accent strip when applied
            if (applied)
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cartuser.green.withOpacity(0.6), cartuser.green],
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  // Icon container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: applied
                          ? cartuser.greenLight
                          : cartuser.brandLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      applied
                          ? Icons.check_circle_rounded
                          : Icons.local_offer_rounded,
                      size: 22,
                      color: applied ? cartuser.green : cartuser.brand,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Labels
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          applied ? 'Coupon Applied' : 'Apply Coupon',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: applied
                                ? cartuser.green
                                : cartuser.textPrimary,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          applied
                              ? cartData!.couponCode ?? ''
                              : 'Save more on your order',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: applied
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: applied
                                ? cartuser.green.withOpacity(0.8)
                                : cartuser.textSecondary,
                            letterSpacing: applied ? 0.5 : 0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Right action
                  if (applied)
                    GestureDetector(
                      onTap: () async {
                        if (cartData?.cartId == null) return;

                        final result = await food_Authservice
                            .updateCartSettings(
                              cartId: cartData!.cartId,
                              couponId: cartData!.couponId,
                              applyCoupon: "NOT_APPLIED",
                            );

                        if (!result.success) {
                          AppAlert.error(
                            context,
                            result.error ?? "Failed to remove coupon",
                          );
                          return;
                        }

                        setState(() {
                          appliedCouponCode = null;
                          appliedCouponId = null;
                        });

                        AppAlert.success(context, "Coupon removed");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cartuser.redLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: cartuser.red.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: cartuser.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Remove',
                              style: TextStyle(
                                fontSize: 12,
                                color: cartuser.red,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _showCouponBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: cartuser.brandLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: cartuser.brand.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Apply',
                          style: TextStyle(
                            fontSize: 12,
                            color: cartuser.brand,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCouponBottomSheet() async {
    setState(() => isCouponLoading = true);
    final coupons = await food_Authservice.fetchCoupons();
    final cartVendor = cartData?.vendorId;
    setState(() => isCouponLoading = false);

    coupons.sort((a, b) {
      if (a.isCurrentlyAvailable != b.isCurrentlyAvailable) {
        return a.isCurrentlyAvailable ? -1 : 1;
      }

      final am = !a.isApplicableForVendor(cartVendor);
      final bm = !b.isApplicableForVendor(cartVendor);

      if (am != bm) return am ? 1 : -1;

      return 0;
    });
    coupons.removeWhere((c) => !c.isCurrentlyAvailable);

    showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Scaffold(
        backgroundColor: Colors.transparent,
        body: PlatformSafeArea(
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.99,
            decoration: BoxDecoration(
              color: cartuser.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                // drag handle
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cartuser.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _couponHeader(),
                coupons.isEmpty
                    ? Expanded(child: _emptyCouponView())
                    : Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(16.w, 8, 16.w, 24),
                          itemCount: coupons.length,
                          itemBuilder: (_, i) {
                            final c = coupons[i];
                            return _couponTile(
                              coupon: c,
                              isExpired: c.isExpired,
                              isMismatch: !c.isApplicableForVendor(cartVendor),
                              // isDisabled:
                              //     c.isExpired ||
                              //     !c.isApplicableForVendor(cartVendor),
                              isDisabled:
                                  !c.isCurrentlyAvailable ||
                                  !c.isApplicableForVendor(cartVendor),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _couponHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 12.h),
      child: Row(
        children: [
          const Text(
            'Available Coupons',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cartuser.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: cartuser.textSecondary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _couponTile({
    required CouponModel coupon,
    required bool isExpired,
    required bool isMismatch,
    required bool isDisabled,
  }) {
    final Color accent = isExpired
        ? cartuser.red
        : isMismatch
        ? cartuser.amber
        : cartuser.green;
    final Color accentBg = isExpired
        ? cartuser.redLight
        : isMismatch
        ? cartuser.amberLight
        : cartuser.greenLight;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: cartuser.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: accent.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: cartuser.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: isDisabled
              ? () => AppAlert.error(
                  context,
                  isExpired
                      ? 'Coupon expired'
                      : 'Not applicable for this restaurant',
                )
              : () => _applyCoupon(coupon),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accentBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.local_offer_rounded,
                    color: accent,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            coupon.code,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: cartuser.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cartuser.brandLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              coupon.couponType,
                              style: const TextStyle(
                                fontSize: 10,
                                color: cartuser.brand,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isExpired
                            ? 'Expired'
                            : isMismatch
                            ? 'Not applicable for this restaurant'
                            : coupon.discountType == "PERCENTAGE"
                            ? '${coupon.discountPercentage.toStringAsFixed(0)}% off your order'
                            : '₹${coupon.discountPercentage.toStringAsFixed(0)} off your order',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDisabled
                              ? cartuser.textMuted
                              : cartuser.textSecondary,
                        ),
                      ),
                      if (!isExpired && !isMismatch)
                        Text(
                          coupon.minimumOrderValue <= 0
                              ? 'Applicable on any order'
                              : 'Min order ₹${coupon.minimumOrderValue.toInt()}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: cartuser.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  isDisabled
                      ? Icons.block_rounded
                      : Icons.chevron_right_rounded,
                  size: 18,
                  color: isDisabled ? cartuser.textMuted : accent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyCouponView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: cartuser.bg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 32,
              color: cartuser.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No coupons available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cartuser.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check back later for new offers',
            style: TextStyle(fontSize: 13, color: cartuser.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _applyCoupon(CouponModel coupon) async {
    if (cartData?.cartId == null) {
      AppAlert.error(context, "Cart is empty");
      return;
    }
    final result = await food_Authservice.updateCartSettings(
      cartId: cartData!.cartId,
      couponId: coupon.id,
      applyCoupon: "APPLIED",
    );
    if (!result.success) {
      // ignore: use_build_context_synchronously
      AppAlert.error(context, result.error ?? "Failed to apply coupon");
      return;
    }
    await _loadCart();
    setState(() {
      appliedCouponCode = coupon.code;
      appliedCouponId = coupon.id;
    });
    // ignore: use_build_context_synchronously
    AppAlert.success(context, "🎉 ${coupon.code} applied!");
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  // ── Delivery Address ──────────────────────────────────────────────────────
  Widget _buildDeliveryAddress() {
    ref.watch(addressProvider);
    final hasAddr = (cartData?.deliveryAddress ?? '').trim().isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SavedAddress(
            hideExtraWidgets: true,
            onAddressSelected: (address) async {
              await ref
                  .read(addressProvider.notifier)
                  .updateLocalAddress(
                    city: address.city,
                    stateName: address.state,
                    pincode: address.pincode,
                    latitude: address.latitude,
                    longitude: address.longitude,
                    fullAddress: address.fullAddress,
                    category: address.category,
                  );
              if (address.addressId != 0) {
                final errorMessage =
                    await AddressNotifier.updateDeliveryAddress(
                      cartId: cartData!.cartId,
                      addressId: address.addressId,
                    );
                if (errorMessage != null && mounted)
                  AppAlert.error(context, errorMessage);
              }
            },
          ),
        ),
      ),
      child: _card(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: hasAddr ? cartuser.brandLight : cartuser.redLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 22,
                color: hasAddr ? cartuser.brand : cartuser.red,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasAddr ? 'Delivery Address' : 'Select Delivery Address',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cartuser.textPrimary,
                    ),
                  ),
                  if (hasAddr) ...[
                    const SizedBox(height: 3),
                    Text(
                      [
                        cartData!.deliveryAddress,
                        cartData!.name,
                        cartData!.mobileNo,
                      ].where((e) => e.toString().trim().isNotEmpty).join(', '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: cartuser.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tap to change',
                      style: TextStyle(
                        fontSize: 12,
                        color: cartuser.brand,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else
                    const Text(
                      'Required for delivery',
                      style: TextStyle(fontSize: 12, color: cartuser.red),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: cartuser.textMuted),
          ],
        ),
      ),
    );
  }

  // ── Summary Card ──────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    if (cartData == null || isLoading) {
      return CartSkeleton(type: CartSkeletonType.summary);
    }

    final orderType = cartData?.orderType ?? '';
    final subtotal = cartData?.subtotal ?? 0;
    final packing = cartData?.packingTotal ?? 0;
    final delivery = cartData?.deliveryCharges ?? 0;
    final platform = cartData?.platformCharges ?? 0;
    final discount = cartData?.discountAmount ?? 0;
    final gst = cartData?.gstTotal ?? 0;
    // final cgst = (cartData?.gstTotal ?? 0) / 2;
    // final sgst = (cartData?.gstTotal ?? 0) / 2;
    final grandTotal = cartData?.grandTotal ?? 0;
    final type = orderType.toUpperCase();
    final firstOrder = cartData?.firstOrderFreeDelivery ?? false;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (tappable to expand)
          GestureDetector(
            onTap: () =>
                setState(() => _isSummaryExpanded = !_isSummaryExpanded),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: cartuser.brandLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    size: 18,
                    color: cartuser.brand,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Bill Summary',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cartuser.textPrimary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isSummaryExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: cartuser.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isSummaryExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                const SizedBox(height: 12),
                Divider(height: 1, color: cartuser.border),
                const SizedBox(height: 10),
                _billRow('Subtotal', subtotal),
                if (platform > 0) _billRow('Platform Charges', platform),
                if ((type == 'DELIVERY' || type == 'TAKEAWAY') && packing > 0)
                  _billRow('Packing Charges', packing),
                // if (type == 'DELIVERY'  ) _billRow('Delivery Charges', delivery),
                if (type == 'DELIVERY')
                  _billRow(
                    firstOrder == true
                        ? 'Delivery Charges (First Order FREE)'
                        : 'Delivery Charges',
                    firstOrder == true ? 0 : delivery,
                    isDiscount: firstOrder == true,
                  ),
                if (discount > 0)
                  _billRow('Discount', -discount, isDiscount: true),
                if (gst > 0)
                  _billRow('GST', gst, onInfo: () => _showGstDialog('GST')),
                // if (gst > 0)
                //   _billRow('SGST', sgst, onInfo: () => _showGstDialog('SGST')),
                const SizedBox(height: 4),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),

          Divider(height: 16, color: cartuser.border),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: cartuser.textPrimary,
                ),
              ),
              Text(
                '₹${_fmt(grandTotal)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: cartuser.brand,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _billRow(
    String label,
    num value, {
    bool isDiscount = false,
    VoidCallback? onInfo,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: cartuser.textSecondary,
                ),
              ),
              // if (onInfo != null) ...[
              //   const SizedBox(width: 4),
              //   GestureDetector(
              //     onTap: onInfo,
              //     child: const Icon(
              //       Icons.info_outline_rounded,
              //       size: 14,
              //       color: cartuser.textMuted,
              //     ),
              //   ),
              // ],
              // if (onInfo != null) ...[
              //   const SizedBox(width: 6),
              //   GestureDetector(
              //     onTap: onInfo,
              //     child: const Text(
              //       "Know more",
              //       style: TextStyle(
              //         fontSize: 12,
              //         color: Colors.blue,
              //         fontWeight: FontWeight.w500,
              //         decoration: TextDecoration.underline,
              //         decorationColor: Colors.blue,
              //       ),
              //     ),
              //   ),
              // ],
              if (onInfo != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onInfo,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    child: const Center(
                      child: Text(
                        'i',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          Text(
            value < 0 ? '-₹${_fmt(-value)}' : '₹${_fmt(value)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDiscount ? cartuser.green : cartuser.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showGstDialog(String type) {
    final itemGst =
        (cartData?.gstTotal ?? 0) -
        ((cartData?.platformChargeGst ?? 0) +
            (cartData?.packingChargeGst ?? 0) +
            (cartData?.serviceChargeGst ?? 0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '$type Breakdown',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.close_rounded,
                size: 20,
                color: cartuser.textSecondary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (itemGst > 0) _dialogRow('Item GST', itemGst),
            if ((cartData?.platformChargeGst ?? 0) > 0)
              _dialogRow('Platform GST', (cartData?.platformChargeGst ?? 0)),
            if ((cartData?.packingChargeGst ?? 0) > 0)
              _dialogRow('Packing GST', (cartData?.packingChargeGst ?? 0)),
            if ((cartData?.serviceChargeGst ?? 0) > 0)
              _dialogRow('Service GST', (cartData?.serviceChargeGst ?? 0)),
            const Divider(height: 20),
            // _dialogRow('Total GST', (cartData?.gstTotal ?? 0), isBold: true),
            _dialogRow(
              'Total $type',
              ((cartData?.gstTotal ?? 0)),
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogRow(String label, num value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: cartuser.textSecondary,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          Text(
            '₹${_fmt(value)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              color: isBold ? cartuser.textPrimary : cartuser.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Schedule Order ────────────────────────────────────────────────────────
  Widget _buildScheduleOrder() {
    final isUserScheduled =
        _orderType == "schedule" &&
        _selectedDate != null &&
        _selectedTime != null;
    final hasScheduledItems = cartData?.hasAnyScheduledItem ?? false;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUserScheduled)
            const Text(
              'Schedule Order',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: cartuser.textPrimary,
              ),
            ),

          if (hasScheduledItems) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cartuser.amberLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: cartuser.amber,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Some items in your cart require scheduling.',
                      style: TextStyle(
                        fontSize: 12,
                        color: cartuser.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (!isUserScheduled) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                setState(() => _orderType = 'schedule');
                await _pickScheduleDateTime();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: cartuser.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cartuser.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: cartuser.brandLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: cartuser.brand,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        hasScheduledItems
                            ? 'Schedule to continue'
                            : 'Choose date & time',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cartuser.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: cartuser.textMuted,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (isUserScheduled) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cartuser.greenLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cartuser.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: cartuser.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scheduled',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cartuser.green,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}  •  ${_selectedTime!.format(context)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: cartuser.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickScheduleDateTime,
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cartuser.brand,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickScheduleDateTime() async {
    final now = DateTime.now();
    final first = now.add(const Duration(minutes: 25));
    final date = await showDatePicker(
      context: context,
      initialDate: first,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: cartuser.brand,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: cartuser.brand),
          ),
        ),
        child: child!,
      ),
    );
    if (date == null) return;
    while (true) {
      final time = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: cartuser.brand,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: cartuser.brand),
            ),
          ),
          child: child!,
        ),
      );
      if (time == null) return;
      final selected = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (selected.isBefore(now.add(const Duration(minutes: 25)))) {
        AppAlert.error(context, "Select a time at least 25 minutes from now");
        continue;
      }
      setState(() {
        _selectedDate = date;
        _selectedTime = time;
      });
      break;
    }
  }

  // ── Payment Toggle ────────────────────────────────────────────────────────
  Widget _buildPaymentToggle() {
    return GestureDetector(
      onTap: () {
        setState(() => isExpanded = !isExpanded);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isExpanded) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFE84E1B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: cartuser.brand.withOpacity(0.28),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.payment_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isExpanded ? 'Hide Payment Options' : 'Choose Payment Method',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutDetails() {
    return Column(
      children: [
        cartwallet(
          wallet: wallet,
          cartData: cartData,
          onSelectionChanged: (method, subWallets) {
            setState(() {
              selectedPaymentMethod = method;
              selectedSubWallets = subWallets;
            });
          },
        ),
        SizedBox(height: 14.h),
        _buildPlaceOrderButton(),
      ],
    );
  }

  // ── Place Order Button ────────────────────────────────────────────────────
  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: isPlacingOrder ? null : placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: cartuser.green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: cartuser.textMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: isPlacingOrder
            ? SizedBox(
                width: 22,
                height: 22,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹${(cartData?.grandTotal ?? 0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Shared card shell ─────────────────────────────────────────────────────
  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cartuser.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cartuser.border),
        boxShadow: [
          BoxShadow(
            color: cartuser.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _paymentOverlay() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            paymentStatusTitle,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
          ),

          SizedBox(height: 12.h),

          Text(
            paymentStatusDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),

          SizedBox(height: 25.h),

          _paymentStep(title: "Created", status: PaymentStatus.created),

          _paymentStep(
            title: "Authenticated",
            status: PaymentStatus.authenticated,
          ),

          _paymentStep(title: "Authorized", status: PaymentStatus.authorized),

          _paymentStep(title: "Captured", status: PaymentStatus.captured),

          _paymentStep(title: "Refunded", status: PaymentStatus.refunded),

          _paymentStep(title: "Failed", status: PaymentStatus.failed),
        ],
      ),
    );
  }

  Widget _paymentStep({required String title, required PaymentStatus status}) {
    final currentIndex = _paymentStatusIndex(_paymentStatus);
    final stepIndex = _paymentStatusIndex(status);

    final bool isCurrent = _paymentStatus == status;

    final bool isCompleted =
        currentIndex > stepIndex &&
        _paymentStatus != PaymentStatus.failed &&
        _paymentStatus != PaymentStatus.refunded;

    Color circleColor;

    if (isCurrent) {
      if (status == PaymentStatus.failed) {
        circleColor = Colors.red;
      } else if (status == PaymentStatus.refunded) {
        circleColor = Colors.orange;
      } else {
        circleColor = AppColors.primary;
      }
    } else if (isCompleted) {
      circleColor = Colors.green;
    } else {
      circleColor = Colors.grey.shade300;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : isCurrent
                ? const Icon(Icons.circle, color: Colors.white, size: 10)
                : null,
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isCurrent ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ),

          if (isCurrent &&
              status != PaymentStatus.failed &&
              status != PaymentStatus.refunded)
            SizedBox(
              width: 18.w,
              height: 18.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}
