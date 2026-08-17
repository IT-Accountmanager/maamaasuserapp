import 'package:maamaas/screens/Food&beverages/food_cartscreen.dart';
import 'package:maamaas/screens/Food&beverages/foodmainscreen.dart';
import 'package:maamaas/screens/Food&beverages/table/tablecartpayment.dart';
import '../../../Services/Auth_service/Subscription_authservice.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import '../../../widgets/widgets/food/currentcart_notifier.dart';
import '../../../Services/paymentservice/razorpayservice.dart';
import '../../../Services/websockets/web_socket_manager.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Models/subscrptions/coupon_model.dart';
import '../../../Models/subscrptions/wallet_model.dart';
import '../../../Models/food/tablecartmodel.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Mainscreen.dart';
import '../food_invoice.dart';
import 'TableCart_helper.dart';
import 'table_menu.dart';
import 'dart:async';

class tablecart extends StatefulWidget {
  final int seatingId;
  const tablecart({super.key, required this.seatingId});
  @override
  State<tablecart> createState() => _tablecartState();
}

class _tablecartState extends State<tablecart>
    with SingleTickerProviderStateMixin {
  TableCartModel? tableCartData;
  String selectedPaymentMethod = "";
  bool isPlacingOrder = false;
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  String? _error;
  bool isExpanded = false;
  bool isServiceChargeApplied = true;
  Wallet? wallet;
  int? appliedCouponId;
  String? appliedCouponCode;
  final Map<int, bool> _isSendingMap = {};
  late ScrollController _scrollController;
  bool isCouponLoading = false;
  final Map<int, TextEditingController> _noteControllers = {};
  Set<String> selectedSubWallets = {};
  PaymentOverlayState _overlayState = PaymentOverlayState.none;

  final WebSocketManager _wsManager = WebSocketManager();
  int? _userId;
  Timer? _cartReloadDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadWallet();
    _loadCartItems();
    _initializeData();
    _initializeRealtimeCart();
  }

  @override
  void dispose() {
    if (_userId != null) _wsManager.unsubscribeUserCart(_userId!);
    _scrollController.dispose();
    for (final c in _noteControllers.values) c.dispose();
    _cartReloadDebounce?.cancel();
    super.dispose();
  }

  Future<void> _initializeRealtimeCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;
    _userId = userId;
    _wsManager.subscribeUserCart(userId, (data) async {
      if (!mounted) return;
      try {
        final updatedCart = TableCartModel.fromJson(data);
        setState(() {
          tableCartData = updatedCart;
          _cartItems = List<CartItem>.from(updatedCart.cartItems);
          final delivered =
              updatedCart.cartItems.isNotEmpty &&
              updatedCart.cartItems
                  .where((i) => i.orderStatus != "CANCELLED")
                  .every((i) => i.orderStatus == "DELIVERED");
          if (!delivered) isExpanded = false;
          _isLoading = false;
        });
      } catch (_) {}
    });
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadWallet() async {
    final w = await subscription_AuthService.fetchWallet();
    setState(() => wallet = w);
  }

  Future<void> _onRefresh() async {
    try {
      final updatedCarts = await food_Authservice.fetchTableCart();
      final updatedWallet = await subscription_AuthService.fetchWallet();
      if (!mounted) return;
      setState(() {
        if (updatedCarts.isNotEmpty) {
          final fresh = updatedCarts.first;
          tableCartData = fresh;
          _cartItems = List<CartItem>.from(fresh.cartItems);
          final delivered =
              fresh.cartItems.isNotEmpty &&
              fresh.cartItems
                  .where((i) => i.orderStatus != "CANCELLED")
                  .every((i) => i.orderStatus == "DELIVERED");
          if (!delivered) isExpanded = false;
        } else {
          tableCartData = null;
          _cartItems = [];
        }
        wallet = updatedWallet;
      });
    } catch (_) {}
  }

  Future<void> _initializeData() async {
    try {
      final data = await food_Authservice.fetchTableCart();
      if (data.isEmpty || !mounted) return;
      setState(() => tableCartData = data.first);
    } catch (_) {}
  }

  Future<bool> _deleteCart() async {
    try {
      final success = await food_Authservice.deleteTableDineInCart();
      if (!mounted) return false;
      if (success) {
        CartNotifier.count.value = 0;
        AppAlert.success(context, "Cart cleared");
        setState(() {
          tableCartData = null;
          _cartItems.clear();
        });
        return true;
      }
      return false;
    } catch (e) {
      if (!mounted) return false;
      AppAlert.error(context, e.toString().replaceFirst("Exception: ", ""));
      return false;
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

  Future<void> placeOrder() async {
    if (selectedPaymentMethod.isEmpty) {
      AppAlert.error(context, "Please select a payment method");
      return;
    }
    if (selectedPaymentMethod == "Maamaas_Wallet" &&
        selectedSubWallets.isEmpty) {
      AppAlert.error(context, "Please select at least one wallet type");
      return;
    }
    if (selectedPaymentMethod == "Maamaas_Wallet") {
      final wb = getSelectedWalletBalance();
      final gt = (tableCartData?.grandTotal ?? 0).toDouble();
      if (wb < gt) {
        AppAlert.error(
          context,
          "Insufficient wallet balance\nWallet: ₹${wb.toStringAsFixed(2)}\nOrder Total: ₹${gt.toStringAsFixed(2)}",
        );
        return;
      }
    }
    setState(() => isPlacingOrder = true);
    try {
      if (selectedPaymentMethod == "Online_Payment") {
        final amount = (tableCartData?.grandTotal ?? 0).toDouble();
        if (mounted) {
          setState(() => _overlayState = PaymentOverlayState.openingGateway);
        }
        final orderId = await food_Authservice.createOrder(amount);
        if (orderId == null) {
          AppAlert.error(context, "Failed to create payment order");
          return;
        }
        final rp = RazorpayService();
        rp.onSuccess = (res) async {
          final pid = res.paymentId!, oid = res.orderId!;
          if (mounted) {
            setState(() => _overlayState = PaymentOverlayState.processing);
          }
          await _callOrderApi(
            paymentMethod: "Online_Payment",
            razorpayPaymentId: pid,
            razorpayOrderId: oid,
            amount: amount,
          );
          if (mounted) setState(() => _overlayState = PaymentOverlayState.none);
          if (mounted) {
            food_Authservice
                .capturePayment(paymentId: pid, amount: amount)
                .catchError((_) {});
          } else {
            AppAlert.error(context, "Order failed. Refund in 3–5 days.");
          }
        };
        rp.onError = (res) {
          if (mounted) {
            setState(() {
              _overlayState = PaymentOverlayState.none;
              isPlacingOrder = false;
            });
          }
          AppAlert.error(context, "Payment failed: ${res.message}");
        };
        rp.startPayment(
          orderId: orderId,
          amount: amount,
          description: "Online Payment via Razorpay",
        );
        return;
      }
      await _callOrderApi(
        paymentMethod: selectedPaymentMethod,
        razorpayPaymentId: "",
        razorpayOrderId: "",
        amount: tableCartData!.grandTotal.toDouble(),
      );
    } catch (e) {
      if (mounted) setState(() => _overlayState = PaymentOverlayState.none);
      AppAlert.error(
        context,
        e.toString().contains("Exception:")
            ? e.toString().replaceFirst("Exception: ", "")
            : e.toString(),
      );
    } finally {
      if (mounted) setState(() => isPlacingOrder = false);
    }
  }

  bool get allItemsDelivered {
    if (tableCartData == null) return false;
    return tableCartData!.cartItems.isNotEmpty &&
        tableCartData!.cartItems
            .where((i) => i.orderStatus != "CANCELLED")
            .every((i) => i.orderStatus == "DELIVERED");
  }

  bool _showQuantityControl(String? status) {
    if (status == null) return true; // unsent — always show
    const allowed = {
      'PENDING',
      'CONFIRMED',
      'BEING_PREPARED',
      'PREPARING',
      'PROCESSING',
    };
    return allowed.contains(status.toUpperCase().trim());
  }

  List<String> mapWalletsToEnum(List<String> selected) => selected.map((w) {
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

  Future<void> _callOrderApi({
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required double amount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');
    if (cartId == null) return;
    final result = await food_Authservice.placeDirectOrder(
      cartId: cartId,
      paymentMethod: paymentMethod,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
      amount: amount,
    );
    if (result['success'] == false) {
      AppAlert.error(context, result['error'] ?? "Unknown error");
      return;
    }
    final orderId = result['orderId'];
    if (orderId == null || orderId is! int) {
      AppAlert.error(context, "Invalid Order ID returned");
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
    );
  }

  Future<void> _loadCartItems({int? updatedItemId}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await food_Authservice.fetchTableCart();
      if (result.isNotEmpty) {
        final fresh = result.first;
        final fetched = fresh.cartItems;
        setState(() {
          tableCartData = fresh;
          final delivered =
              fresh.cartItems.isNotEmpty &&
              fresh.cartItems
                  .where((i) => i.orderStatus != "CANCELLED")
                  .every((i) => i.orderStatus == "DELIVERED");
          if (!delivered) isExpanded = false;
          if (updatedItemId != null) {
            final updatedItem = fetched.firstWhere(
              (i) => i.itemId == updatedItemId,
              orElse: () => CartItem.empty(),
            );
            final index = _cartItems.indexWhere(
              (i) => i.itemId == updatedItemId,
            );
            if (index != -1 && updatedItem.itemId != 0) {
              _cartItems[index] = updatedItem;
            } else {
              _cartItems = fetched;
            }
          } else {
            _cartItems = fetched;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _cartItems = [];
          tableCartData = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: tabecartcolour.bg,
          appBar: _buildAppBar(),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: tabecartcolour.brand,
              backgroundColor: Colors.white,
              displacement: 40,
              strokeWidth: 2.5,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isLoading &&
                        (tableCartData == null ||
                            tableCartData!.cartItems.isEmpty))
                      _buildEmptyCart()
                    else ...[
                      _buildCartItems(context),
                      SizedBox(height: 10.h),
                      _buildAddMoreRow(context),
                      SizedBox(height: 16.h),
                      if (tableCartData != null &&
                          tableCartData!.cartItems.isNotEmpty) ...[
                        if (allItemsDelivered) _buildGenerateBillButton(),
                        SizedBox(height: 12.h),
                        if (isExpanded) ...[
                          _buildCouponRow(),
                          SizedBox(height: 12.h),
                          _buildSummaryCard(),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_overlayState != PaymentOverlayState.none)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(child: _overlayContent()),
              ),
            ),
          ),
      ],
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: tabecartcolour.border, width: 1),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: tabecartcolour.textPrimary,
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
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tableCartData?.tableCode != null
                            ? 'Table ${tableCartData!.tableCode}'
                            : 'Your Cart',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: tabecartcolour.brand,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: tabecartcolour.red,
                  size: 22,
                ),
                onPressed: _confirmDeleteCart,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCart() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear Cart?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'All items will be removed from your cart.',
          style: TextStyle(color: tabecartcolour.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: tabecartcolour.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear',
              style: TextStyle(
                color: tabecartcolour.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final vendorId = tableCartData?.vendorId,
          seatingId = tableCartData?.seatingId;
      final deleted = await _deleteCart();
      if (!mounted) return;
      if (deleted && vendorId != null && seatingId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                tablemneuScreen(vendorId: vendorId, seatingId: seatingId),
          ),
        );
      }
    }
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
          "Redirecting To Razorpay...",
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
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
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
                color: tabecartcolour.brandLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: tabecartcolour.brand,
                  strokeWidth: 2.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: tabecartcolour.textPrimary,
                decoration: TextDecoration.none,
              ),
              child: Text(text, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 4),
            const DefaultTextStyle(
              style: TextStyle(
                fontSize: 12,
                color: tabecartcolour.textSecondary,
                decoration: TextDecoration.none,
              ),
              child: Text(
                "Please don't close this screen",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyCart() {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: tabecartcolour.brandLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 44,
                color: tabecartcolour.brand,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: tabecartcolour.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Browse the menu and add something delicious',
              style: TextStyle(
                fontSize: 14,
                color: tabecartcolour.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Cart Items ─────────────────────────────────────────────────────────────
  Widget _buildCartItems(BuildContext context) {
    if (_isLoading) return _buildCartSkeleton();
    if (_error != null) return _buildErrorState();
    if (_cartItems.isEmpty) return _buildEmptyCart();

    final orderedItems = _cartItems
        .where((i) => i.orderStatus != null)
        .toList();
    final pendingItems = _cartItems
        .where((i) => i.orderStatus == null)
        .toList();
    final displayItems = [...orderedItems, ...pendingItems];

    return _surfaceCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...displayItems.asMap().entries.map((entry) {
            final isLast = entry.key == displayItems.length - 1;
            return _buildCartItemRow(entry.value, isLast);
          }),
        ],
      ),
    );
  }

  // ── Single Cart Item Row (REDESIGNED — overflow-safe) ─────────────────────
  Widget _buildCartItemRow(CartItem item, bool isLast) {
    final isCancelled = (item.orderStatus ?? '').toUpperCase() == 'CANCELLED';
    final isSent = item.orderStatus != null;

    return Column(
      key: ValueKey('${item.itemId}_${item.orderStatus}_${item.quantity}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: dish name + price ──────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.dishName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isCancelled
                            ? tabecartcolour.textMuted
                            : tabecartcolour.textPrimary,
                        decoration: isCancelled
                            ? TextDecoration.lineThrough
                            : null,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isSent)
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: tabecartcolour.textPrimary,
                      ),
                    ),
                ],
              ),

              SizedBox(height: 6.h),

              // ── Row 2: unit price + controls ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // const SizedBox(width: 18),
                  Text(
                    '₹${item.price} each',
                    style: const TextStyle(
                      fontSize: 11,
                      color: tabecartcolour.textSecondary,
                    ),
                  ),

                  if (tableCartData != null &&
                      _showQuantityControl(item.orderStatus)) ...[
                    QuantityControl(
                      item: item,
                      onQuantityChanged: () => setState(() {}),
                      cartId: tableCartData!.cartId,
                      tableCode: tableCartData!.tableCode,
                      userId: tableCartData!.userId,
                      vendorId: tableCartData!.vendorId,
                      seatingId: tableCartData!.seatingId,
                    ),
                    const SizedBox(width: 8),
                  ] else ...[
                    Text(
                      'Qty : ${item.quantity}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: tabecartcolour.textPrimary,
                      ),
                    ),
                  ],
                  // Send button OR status badge
                  if (!isSent)
                    SendButton(
                      item: item,
                      isSending: _isSendingMap[item.itemId] == true,
                      onSend: () => _sendItem(item),
                    )
                  else
                    StatusBadge(item.orderStatus),
                ],
              ),

              // ── Note field (only for unsent items) ────────────────────────
              if (!isSent) ...[
                SizedBox(height: 10.h),
                TextField(
                  controller: _getNoteController(item),
                  maxLines: 1,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(fontSize: 13.sp),
                  decoration: InputDecoration(
                    hintText: 'Special instructions...',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: tabecartcolour.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.edit_note_rounded,
                      size: 16,
                      color: tabecartcolour.textMuted,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: tabecartcolour.bg,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: tabecartcolour.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: tabecartcolour.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: tabecartcolour.brand,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (v) => item.note = v,
                ),
              ],
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 1, color: tabecartcolour.border),
      ],
    );
  }

  Future<void> _sendItem(CartItem item) async {
    if (_isSendingMap[item.itemId] == true) return;
    final note = _getNoteController(item).text.trim();
    setState(() => _isSendingMap[item.itemId] = true);
    try {
      final billingData = await food_Authservice.getBillingSettings(
        tableCartData!.vendorId,
      );
      final initialStatus =
          (billingData['userInitialOrderStatus']?.toString() ?? 'PENDING')
              .trim();
      final success = await food_Authservice.updateCartItemStatus(
        itemId: item.itemId,
        quantity: item.quantity,
        status: initialStatus,
        note: note.isNotEmpty ? note : null,
      );
      if (success) {
        setState(() {
          item.previousQuantity = item.quantity;
          item.orderStatus = initialStatus;
        });
        if (!mounted) return;
        AppAlert.success(context, 'Order placed for ${item.dishName}');
      } else {
        if (!mounted) return;
        AppAlert.error(context, 'Failed to send order for ${item.dishName}');
      }
    } finally {
      if (mounted) setState(() => _isSendingMap[item.itemId] = false);
    }
  }

  TextEditingController _getNoteController(CartItem item) =>
      _noteControllers.putIfAbsent(
        item.itemId,
        () => TextEditingController(text: item.note ?? ''),
      );

  Widget _buildCartSkeleton() {
    return _surfaceCard(
      padding: EdgeInsets.all(16.w),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Column(
          children: List.generate(
            3,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return _surfaceCard(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: tabecartcolour.redLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: tabecartcolour.red,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Could not load cart',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: tabecartcolour.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadCartItems,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: tabecartcolour.brand,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Add More ──────────────────────────────────────────────────────────────
  Widget _buildAddMoreRow(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => tablemneuScreen(
              vendorId: tableCartData!.vendorId,
              seatingId: tableCartData!.seatingId,
            ),
          ),
        );
        await _loadCartItems();
        await _initializeData();
        if (mounted) setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tabecartcolour.brand.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              size: 18,
              color: tabecartcolour.brand,
            ),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                text: 'Missed something? ',
                style: TextStyle(
                  fontSize: 14,
                  color: tabecartcolour.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: 'Add more items',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: tabecartcolour.brand,
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

  // ── Generate Bill Button ──────────────────────────────────────────────────
  Widget _buildGenerateBillButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _initializeData();
          setState(() => isExpanded = !isExpanded);
          if (!isExpanded) {
            scrollToTop();
          } else {
            scrollToBottom();
          }
        },
        icon: Icon(
          isExpanded ? Icons.receipt_long_rounded : Icons.receipt_rounded,
          size: 18,
        ),
        label: Text(
          isExpanded ? 'Hide Bill' : 'View & Pay Bill',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: tabecartcolour.brand,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // ── Coupon Row ────────────────────────────────────────────────────────────
  Widget _buildCouponRow() {
    final applied = (tableCartData?.couponCode ?? '').isNotEmpty;
    return GestureDetector(
      onTap: applied ? null : _showCouponBottomSheet,
      child: _surfaceCard(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: applied
                    ? tabecartcolour.greenLight
                    : tabecartcolour.brandLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                applied
                    ? Icons.check_circle_rounded
                    : Icons.local_offer_rounded,
                size: 20,
                color: applied ? tabecartcolour.green : tabecartcolour.brand,
              ),
            ),
            const SizedBox(width: 12),
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
                          ? tabecartcolour.green
                          : tabecartcolour.textPrimary,
                    ),
                  ),
                  Text(
                    applied
                        ? (appliedCouponCode ?? '')
                        : 'Save more on your order',
                    style: const TextStyle(
                      fontSize: 12,
                      color: tabecartcolour.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (applied)
              GestureDetector(
                onTap: () async {
                  if (tableCartData?.cartId == null) return;
                  final result = await food_Authservice.updateCartSettings(
                    cartId: tableCartData!.cartId,
                    couponId: tableCartData!.couponId,
                    applyCoupon: "NOT_APPLIED",
                  );
                  if (!result.success) {
                    AppAlert.error(context, "Failed to remove coupon");
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
                    color: tabecartcolour.redLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: 12,
                      color: tabecartcolour.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: tabecartcolour.textMuted,
              ),
          ],
        ),
      ),
    );
  }

  // ── Summary Card ──────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    final cart = tableCartData;
    if (cart == null) return const SizedBox.shrink();

    return Column(
      children: [
        _surfaceCard(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: tabecartcolour.brandLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 16,
                      color: tabecartcolour.brand,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Bill Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: tabecartcolour.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _billRow('Subtotal', cart.subtotal),
              if ((cart.discountAmount ?? 0) > 0)
                _billRow('Discount', cart.discountAmount!, isDiscount: true),
              _billRow('Smart DineIn Fee', cart.platformCharges),
              if ((cart.cgst + cart.sgst) > 0)
                _billRow(
                  'GST',
                  cart.cgst + cart.sgst,
                  onInfo: () => _showGstDialog('GST'),
                ),
              if (cart.serviceCharges > 0)
                _buildServiceChargeRow(cart.serviceCharges),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(thickness: 1, color: tabecartcolour.border),
              ),
              _billRow(
                'Grand Total',
                cart.grandTotal,
                isBold: true,
                isGrand: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildCheckoutDetails(),
      ],
    );
  }

  Widget _billRow(
    String label,
    num value, {
    bool isBold = false,
    bool isDiscount = false,
    bool isGrand = false,
    VoidCallback? onInfo,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isGrand ? 15 : 14,
                    fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
                    color: isBold
                        ? tabecartcolour.textPrimary
                        : tabecartcolour.textSecondary,
                  ),
                ),
                if (onInfo != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onInfo,
                    child: const Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: tabecartcolour.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            isDiscount
                ? '-₹${value.toStringAsFixed(2)}'
                : '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isGrand ? 16 : 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              color: isDiscount
                  ? tabecartcolour.green
                  : (isGrand
                        ? tabecartcolour.brand
                        : tabecartcolour.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChargeRow(num serviceCharges) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Service Charges',
              style: TextStyle(
                fontSize: 14,
                color: tabecartcolour.textSecondary,
              ),
            ),
          ),
          if (serviceCharges > 0 && isServiceChargeApplied)
            GestureDetector(
              onTap: () async {
                if (tableCartData?.cartId == null) return;
                await food_Authservice.updateServiceCharges(
                  cartId: tableCartData!.cartId,
                  serviceCharge: "NOT_APPLICABLE",
                );
                await _initializeData();
                setState(() => isServiceChargeApplied = false);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tabecartcolour.redLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    fontSize: 11,
                    color: tabecartcolour.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Text(
            serviceCharges > 0
                ? (isServiceChargeApplied
                      ? '₹${serviceCharges.toStringAsFixed(2)}'
                      : '-₹${serviceCharges.toStringAsFixed(2)}')
                : '₹0.00',
            style: TextStyle(
              fontSize: 14,
              color: isServiceChargeApplied
                  ? tabecartcolour.textSecondary
                  : tabecartcolour.red,
              fontWeight: isServiceChargeApplied
                  ? FontWeight.normal
                  : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Checkout ──────────────────────────────────────────────────────────────
  Widget _buildCheckoutDetails() {
    return Column(
      children: [
        tablecartwallet(
          wallet: wallet,
          onSelectionChanged: (method, subWallets) {
            setState(() {
              selectedPaymentMethod = method;
              selectedSubWallets = subWallets;
            });
            scrollToBottom();
          },
        ),
        SizedBox(height: 16.h),
        _buildPlaceOrderButton(),
      ],
    );
  }

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isPlacingOrder ? null : placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: tabecartcolour.brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor: tabecartcolour.textMuted,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
        child: isPlacingOrder
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
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
                      fontSize: 16.sp,
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
                      '₹${(tableCartData?.grandTotal ?? 0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── GST Dialog ────────────────────────────────────────────────────────────
  void _showGstDialog(String type) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'GST Breakdown',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.close_rounded,
                size: 20,
                color: tabecartcolour.textSecondary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if ((tableCartData?.platformChargeGst ?? 0) > 0)
              _dialogRow('Platform GST', tableCartData?.platformChargeGst ?? 0),
            if ((tableCartData?.packingChargeGst ?? 0) > 0)
              _dialogRow('Packing GST', tableCartData?.packingChargeGst ?? 0),
            if ((tableCartData?.serviceChargeGst ?? 0) > 0)
              _dialogRow('Service GST', tableCartData?.serviceChargeGst ?? 0),
            const Divider(height: 20),
            _dialogRow('Total GST', tableCartData?.gstTotal ?? 0, isBold: true),
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
              color: tabecartcolour.textSecondary,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          Text(
            '₹${_fmt(value)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              color: isBold
                  ? tabecartcolour.textPrimary
                  : tabecartcolour.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(num? v) => (v ?? 0).toStringAsFixed(2);

  // ── Coupon Sheet ──────────────────────────────────────────────────────────
  void _showCouponBottomSheet() async {
    setState(() => isCouponLoading = true);
    final coupons = await food_Authservice.fetchCoupons();
    final cartVendor = tableCartData?.vendorId;
    setState(() => isCouponLoading = false);
    coupons.sort((a, b) {
      final aE = a.isExpired, bE = b.isExpired;
      final aM = !a.isApplicableForVendor(cartVendor),
          bM = !b.isApplicableForVendor(cartVendor);
      if (aE != bE) return aE ? 1 : -1;
      if (aM != bM) return aM ? 1 : -1;
      return 0;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
        maxWidth: MediaQuery.of(context).size.width,
      ),
      builder: (sheetCtx) {
        if (coupons.isEmpty)
          return SizedBox(width: double.infinity, child: _emptyCouponView());
        return Container(
          width: double.infinity,
          height: MediaQuery.of(sheetCtx).size.height * 0.95,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: tabecartcolour.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              _couponHeader(),
              Expanded(
                child: isCouponLoading
                    ? _couponSkeletonList()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: coupons.length,
                        itemBuilder: (_, index) {
                          final coupon = coupons[index];
                          final isExpired = coupon.isExpired;
                          final isMismatch = !coupon.isApplicableForVendor(
                            cartVendor,
                          );
                          return _couponTile(
                            coupon: coupon,
                            isExpired: isExpired,
                            isMismatch: isMismatch,
                            isDisabled: isExpired || isMismatch,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyCouponView() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: tabecartcolour.bg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 32,
              color: tabecartcolour.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No coupons available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: tabecartcolour.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check back later for new offers',
            style: TextStyle(fontSize: 13, color: tabecartcolour.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _couponHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          const Text(
            'Available Coupons',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: tabecartcolour.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: tabecartcolour.textSecondary,
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
    Color accent = isExpired
        ? tabecartcolour.red
        : isMismatch
        ? tabecartcolour.amber
        : tabecartcolour.green;
    Color accentLight = isExpired
        ? tabecartcolour.redLight
        : isMismatch
        ? tabecartcolour.amberLight
        : tabecartcolour.greenLight;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: tabecartcolour.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isDisabled
              ? () => _showCouponError(isExpired)
              : () => _applyCoupon(coupon),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.local_offer_rounded,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              coupon.code,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isExpired
                                    ? tabecartcolour.textMuted
                                    : tabecartcolour.textPrimary,
                                decoration: isExpired
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: coupon.couponType == "PERCENTAGE"
                                  ? tabecartcolour.blueLight
                                  : tabecartcolour.brandLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              coupon.couponType,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: coupon.couponType == "PERCENTAGE"
                                    ? tabecartcolour.blue
                                    : tabecartcolour.brand,
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
                          fontSize: 13,
                          color: isDisabled
                              ? tabecartcolour.textMuted
                              : tabecartcolour.textSecondary,
                        ),
                      ),
                      if (coupon.minimumOrderValue > 0)
                        Text(
                          'Min order ₹${coupon.minimumOrderValue.toInt()}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: tabecartcolour.textMuted,
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
                  color: isDisabled ? tabecartcolour.textMuted : accent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCouponError(bool isExpired) {
    AppAlert.error(
      context,
      isExpired
          ? "This coupon has expired"
          : "This coupon is not applicable for this restaurant",
    );
  }

  Future<void> _applyCoupon(CouponModel coupon) async {
    if (tableCartData?.cartId == null) {
      AppAlert.error(context, "Cart is empty");
      return;
    }
    final result = await food_Authservice.updateCartSettings(
      cartId: tableCartData!.cartId,
      couponId: coupon.id,
      applyCoupon: "APPLIED",
    );
    if (!result.success) {
      AppAlert.error(context, result.error ?? "Failed to apply coupon");
      return;
    }
    await _initializeData();
    setState(() {
      appliedCouponCode = coupon.code;
      appliedCouponId = coupon.id;
    });
    AppAlert.success(context, "🎉 ${coupon.code} applied!");
    Navigator.pop(context);
  }

  // ── Surface Card ──────────────────────────────────────────────────────────
  Widget _surfaceCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: tabecartcolour.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: tabecartcolour.border),
        boxShadow: [
          BoxShadow(
            color: tabecartcolour.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Quantity Control (overflow-safe, compact) ────────────────────────────────
class QuantityControl extends StatefulWidget {
  final CartItem item;
  final VoidCallback onQuantityChanged;
  final int cartId;
  final String tableCode;
  final int userId;
  final int vendorId;
  final int seatingId;

  const QuantityControl({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.cartId,
    required this.tableCode,
    required this.userId,
    required this.vendorId,
    required this.seatingId,
  });

  @override
  State<QuantityControl> createState() => _QuantityControlState();
}

class _QuantityControlState extends State<QuantityControl> {
  bool _isUpdating = false;

  bool get _canDecrease {
    if (widget.item.previousQuantity == 0) return widget.item.quantity > 0;
    return widget.item.quantity > widget.item.previousQuantity;
  }

  bool get _isSentItem => widget.item.orderStatus != null;

  Future<void> _updateQuantity(int newQty) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    final success = await food_Authservice.updateCartItemQuantity(
      itemId: widget.item.itemId,
      quantity: newQty,
    );
    if (success) {
      setState(() {
        widget.item.quantity = newQty;
        widget.item.totalPrice = widget.item.price * newQty;
      });
      widget.onQuantityChanged();
    } else {
      if (mounted) AppAlert.error(context, 'Failed to update quantity');
    }
    if (mounted) setState(() => _isUpdating = false);
  }

  Widget _qtyBtn(IconData icon, Color color, VoidCallback? onTap) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(active ? 0.12 : 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 14,
          color: active ? color : Colors.grey.shade300,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: tabecartcolour.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tabecartcolour.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(Icons.remove_rounded, tabecartcolour.red, () async {
            // Prevent below 0
            if (widget.item.quantity <= 0) {
              AppAlert.error(context, 'Quantity cannot be less than 0');
              return;
            }

            // ✅ SENT ITEM → SEND REQUEST ONLY
            if (_isSentItem) {
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (_) =>
                    _QuantityRequestDialog(quantity: widget.item.quantity),
              );

              if (result == null) return;

              final success = await food_Authservice.createTableRequest(
                userId: widget.userId,
                itemId: widget.item.itemId,
                vendorId: widget.vendorId,
                seatingId: widget.seatingId,
                cartId: widget.cartId,
                tableCode: widget.tableCode,
                requestType: result['requestType'],
                reason: result['reason'],
                removalQuantity: result['removalQuantity'],
              );
              // print("REMOVAL QTY => ${result['removalQuantity']}");

              if (!success) {
                AppAlert.error(context, 'Failed to send request');
                return;
              }

              AppAlert.success(context, 'Request sent successfully');
              return;
            }

            // ✅ NORMAL ITEM → DIRECT UPDATE
            final newQty = widget.item.quantity - 1;

            _updateQuantity(newQty);
          }),
          SizedBox(
            width: 32,
            child: Center(
              child: _isUpdating
                  ? SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: tabecartcolour.green,
                      ),
                    )
                  : Text(
                      '${widget.item.quantity}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: tabecartcolour.textPrimary,
                      ),
                    ),
            ),
          ),
          _qtyBtn(
            Icons.add_rounded,
            tabecartcolour.green,
            _isSentItem
                ? null
                : () {
                    if (!(widget.item.available ?? true)) {
                      AppAlert.error(context, 'Not enough stock for this dish');
                      return;
                    }
                    _updateQuantity(widget.item.quantity + 1);
                  },
          ),
        ],
      ),
    );
  }
}

// ─── Quantity Request Dialog ──────────────────────────────────────────────────
class _QuantityRequestDialog extends StatefulWidget {
  final int quantity;
  const _QuantityRequestDialog({required this.quantity});
  @override
  State<_QuantityRequestDialog> createState() => _QuantityRequestDialogState();
}

class _QuantityRequestDialogState extends State<_QuantityRequestDialog> {
  final TextEditingController _reasonCtrl = TextEditingController();
  final TextEditingController _qtyCtrl = TextEditingController();

  String _requestType = 'REMOVE_ITEM';
  final List<String> _types = ['REMOVE_ITEM', 'REMOVAL_QUANTITY'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Send Request',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),

            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _types.map((type) {
                final selected = _requestType == type;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _requestType = type;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade400,
                      ),
                    ),
                    child: Text(
                      _humanize(type),
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            if (_requestType == 'REMOVAL_QUANTITY') ...[
              const SizedBox(height: 14),
              TextField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reason',
                hintText: 'Enter reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_reasonCtrl.text.trim().isEmpty) {
                        AppAlert.error(context, 'Please enter reason');
                        return;
                      }

                      int removalQty = 0;

                      if (_requestType == 'REMOVAL_QUANTITY') {
                        if (_qtyCtrl.text.trim().isEmpty) {
                          AppAlert.error(context, 'Please enter quantity');
                          return;
                        }

                        removalQty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;

                        if (removalQty <= 0) {
                          AppAlert.error(context, 'Enter valid quantity');
                          return;
                        }

                        if (removalQty > widget.quantity) {
                          AppAlert.error(
                            context,
                            'Quantity cannot exceed ${widget.quantity}',
                          );
                          return;
                        }
                      }

                      Navigator.pop(context, {
                        "requestType": _requestType,
                        "reason": _reasonCtrl.text.trim(),
                        "removalQuantity": removalQty,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tabecartcolour.brand,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _humanize(String s) => s
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

// ─── Send Button ──────────────────────────────────────────────────────────────
class SendButton extends StatelessWidget {
  final CartItem item;
  final bool isSending;
  final VoidCallback onSend;

  const SendButton({
    super.key,
    required this.item,
    required this.isSending,
    required this.onSend,
  });

  bool get _isActive => item.quantity > item.previousQuantity;

  @override
  Widget build(BuildContext context) {
    final canTap = _isActive && !isSending;
    return GestureDetector(
      onTap: canTap ? onSend : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: canTap ? tabecartcolour.brand : tabecartcolour.textMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: isSending
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.send_rounded, size: 13, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Coupon Skeleton ──────────────────────────────────────────────────────────
Widget _couponSkeletonList() {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    itemBuilder: (_, __) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ),
  );
}
