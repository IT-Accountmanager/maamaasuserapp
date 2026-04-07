import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/Auth_service/catering_authservice.dart';
import '../../Services/paymentservice/razorpayservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/widgets/skeleton/cart_skeleton.dart';
import '../../Models/caterings/catering_cart_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Models/subscrptions/wallet_model.dart';
import '../../providers/addressmodel_provider.dart';
import '../../widgets/widgets/cart wallet.dart';
import 'package:flutter/material.dart';
import '../screens/saved_address.dart';
import 'package:intl/intl.dart';
import 'catering_invoice.dart';

import 'package:maamaas/Services/App_color_service/app_colours.dart';

// ignore: camel_case_types
class catering_cart extends ConsumerStatefulWidget {
  const catering_cart({super.key});

  @override
  ConsumerState<catering_cart> createState() => _catering_cartState();
}

// ignore: camel_case_types
class _catering_cartState extends ConsumerState<catering_cart> {
  catering_Cart? cart;
  String? appliedCouponCode;
  bool isExpanded = false;
  String selectedPaymentMethod = " ";
  String selectedSubWallet = " ";
  bool isPlacingOrder = false;
  DateTime? selectedDate;
  DateTime? selectedDateTime;
  String? selectedAddress;
  bool isLoading = true;
  Map<String, dynamic>? checkoutData;
  late List<CartPackage> items = [];
  Wallet? wallet;
  int? cartId;
  bool _isCateringSummaryExpanded = false;
  // late ScrollController _scrollController;
  Set<String> selectedSubWallets = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadCartData();
    _loadWallet();
    refreshCart();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ScrollController _scrollController = ScrollController();

  // Only scroll on button click
  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadWallet() async {
    try {
      final fetchedWallet = await subscription_AuthService
          .fetchWallet(); // API call
      if (!mounted) return; // safety
      setState(() {
        wallet = fetchedWallet;
      });
    } catch (e) {
      debugPrint("⚠️ _loadWallet failed: $e");
      if (!mounted) return;
      AppAlert.error(context, "❌ Failed to load wallet");
    }
  }

  Future<void> _onRefresh() async {
    final updatedCart = await catering_authservice.fetchUserCart();
    final updatedwallet = await subscription_AuthService.fetchWallet();

    if (!mounted) return;

    setState(() {
      cart = updatedCart;
      wallet = updatedwallet;
    });
  }

  Future<void> _loadCartData() async {
    setState(() => isLoading = true);

    try {
      final catering_Cart? cart = await catering_authservice.fetchUserCart();
      debugPrint("🛒 cart from API: $cart");

      if (cart == null) {
        debugPrint("❌ Cart is null (no cart for user)");
        items = [];
      } else {
        items = cart.items;
        debugPrint("🛍️ Cart items: $items");
      }
    } catch (e) {
      debugPrint("❌ Error fetching cart: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> placeOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    final double grandTotal = cart?.total ?? 0.0;

    if (selectedPaymentMethod.isEmpty) {
      AppAlert.error(context, "⚠️ Please select a payment method");
      return;
    }

    setState(() => isPlacingOrder = true);

    final razorpay = RazorpayService();

    try {
      final String paymentMethod = selectedPaymentMethod;

      final String? walletType = paymentMethod == "Maamaas_Wallet"
          ? _mapSubWalletToBackend(selectedSubWallet)
          : null;

      /// 🪙 WALLET VALIDATION
      if (paymentMethod == "Maamaas_Wallet") {
        double required = grandTotal;
        double available = 0;

        switch (walletType) {
          case "COMPANY_LOADED":
            available = wallet!.companyLoadedAmount;
            break;
          case "SELF_LOADED":
            available = wallet!.selfLoadedAmount;
            break;
          case "CASHBACK":
            available = wallet!.cashbackAmount;
            break;
        }

        if (available < required) {
          AppAlert.error(
            context,
            "Insufficient wallet balance! Available ₹${available.toStringAsFixed(2)}, Required ₹${required.toStringAsFixed(2)}",
          );
          return;
        }
      }

      /// 🌐 ONLINE PAYMENT
      if (paymentMethod == "Online_Payment") {
        final orderId = await catering_authservice.createOrder(grandTotal);

        if (orderId == null) {
          AppAlert.error(context, "Failed to create Razorpay order ❌");
          return;
        }

        /// HANDLE SUCCESS
        razorpay.onSuccess = (response) async {
          /// CAPTURE PAYMENT
          final bool captured = await catering_authservice.capturePayment(
            paymentId: response.paymentId!,
            amount: grandTotal,
          );

          if (!captured) {
            AppAlert.error(context, "Payment capture failed ❌");
            return;
          }

          /// CALL ORDER API AFTER SUCCESS
          await _callOrderApi(
            userId: userId,
            paymentMethod: paymentMethod,
            razorpayPaymentId: response.paymentId!,
            razorpayOrderId: response.orderId ?? "",
            grandTotal: grandTotal,
          );
        };

        /// HANDLE FAILURE
        // razorpay.onError = (error) {
        //   AppAlert.error(context, "Payment Failed ❌");
        // };

        razorpay.startPayment(
          orderId: orderId,
          amount: grandTotal,
          // name: "Food Order Payment",
          description: "Online Payment via Razorpay",
        );

        return;
      }

      /// 🧾 COD / WALLET ORDER
      await _callOrderApi(
        userId: userId,
        paymentMethod: paymentMethod,
        razorpayPaymentId: "",
        razorpayOrderId: "",
        grandTotal: grandTotal,
      );
    } catch (e) {
      AppAlert.error(context, "Error placing order: $e");
    } finally {
      setState(() => isPlacingOrder = false);
    }
  }

  String? _mapSubWalletToBackend(String? subWallet) {
    switch (subWallet) {
      case "Company Credited Amount":
        return "COMPANY_LOADED";
      case "Self Credited Amount":
        return "SELF_LOADED";
      case "Cashbacks":
        return "CASHBACK";
      case "Earned Amount":
        return "EARNED_AMOUNT";
      default:
        return null;
    }
  }

  List<String> mapWalletsToEnum(List<String> selectedWallets) {
    return selectedWallets.map((wallet) {
      switch (wallet) {
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
          return wallet.toUpperCase().replaceAll(' ', '_');
      }
    }).toList();
  }

  double getSelectedWalletBalance() {
    if (wallet == null) return 0;

    double total = 0;

    if (selectedSubWallets.contains("Company Loaded")) {
      total += wallet!.companyLoadedAmount;
    }
    if (selectedSubWallets.contains("Self Loaded")) {
      total += wallet!.selfLoadedAmount;
    }
    if (selectedSubWallets.contains("Cashbacks")) {
      total += wallet!.cashbackAmount;
    }
    if (selectedSubWallets.contains("Postpaid used amount")) {
      total += wallet!.postPaidUsage;
    }

    return total;
  }

  Future<void> _callOrderApi({
    required int userId,
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required double grandTotal,
    // String? walletType,
    List<String>? walletTypes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');

    if (cartId == null || cartId <= 0) {
      AppAlert.error(context, "❌ Cart ID missing or invalid");
      return;
    }

    debugPrint("📦 [Order API] cartId: $cartId, userId: $userId");
    debugPrint("💳 paymentMethod: $paymentMethod");
    debugPrint("💰 grandTotal: $grandTotal");
    debugPrint("🏦 walletType: $walletTypes");

    final result = await catering_authservice.placeOrder(
      userId: userId,
      cartId: cartId,
      paymentMethod: paymentMethod,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      // walletType: walletType,
      walletTypes: mapWalletsToEnum(selectedSubWallets.toList()), // <-- FIXED
      grandTotal: grandTotal,
    );

    // 🔥 FIX HERE
    final int? orderId = result?['orderId'];

    if (orderId != null && orderId > 0) {
      await prefs.setInt('cateringorderId', orderId);

      debugPrint("✅ Order placed successfully → Order ID: $orderId");

      // Optional: clear cart after successful order
      await prefs.remove('cartId');
      AppAlert.success(context, "✅ Order placed successfully");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => catering_invoice(orderId: orderId),
        ),
      );
    } else {
      debugPrint("❌ Failed to place order → Response: $result");
      AppAlert.error(context, "❌ Failed to place order");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(child: Text("Catering Cart")),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.white,
        backgroundColor: Colors.blueAccent,
        displacement: 40,
        strokeWidth: 3,

        /// 👇 THIS IS REQUIRED
        child: isLoading
            ? CartSkeleton(type: CartSkeletonType.fullCart)
            : SingleChildScrollView(
                controller: _scrollController,
                physics:
                    const AlwaysScrollableScrollPhysics(), // 🔥 IMPORTANT for RefreshIndicator
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    items.isEmpty ? _buildEmptyCart() : _buildCartItems(),

                    const SizedBox(height: 16),

                    if (cart != null)
                      buildCateringSummaryCard(
                        cart!,
                        Theme.of(context),
                        Theme.of(context).colorScheme,
                      ),

                    const SizedBox(height: 16),

                    _buildDateAndTime(),

                    const SizedBox(height: 16),

                    _buildDeliveryAddress(),

                    const SizedBox(height: 16),

                    _buildCheckoutCard(),

                    if (isExpanded) _buildCheckoutDetails(theme, colorScheme),

                    const SizedBox(height: 30), // bottom spacing
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    DateTime today = DateTime.now();
    DateTime firstAllowedDate = today.add(
      Duration(days: 2),
    ); // Only after 2 days
    DateTime lastAllowedDate = today.add(Duration(days: 365));
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: firstAllowedDate, // Start picker from allowed date
      firstDate: firstAllowedDate, // Disable all before this
      lastDate: lastAllowedDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // buttons color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    // ⏰ Pick Time
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // buttons color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    // Combine date & time
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() => selectedDateTime = combined);

    // 🔄 Call API to update backend
    await _updateDateTimeOnServer(combined);
  }

  Future<void> _updateDateTimeOnServer(DateTime dateTime) async {
    final success = await catering_authservice.updateDateTime(
      context,
      selectedDateTime!,
    );

    if (!mounted) return;
    if (success) {
      AppAlert.success(context, "Date & Time updated successfully!");
    } else {
      AppAlert.error(context, "Failed to update date & time.");
    }
  }

  Widget _buildDateAndTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Date & Time *",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDateTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: AppColors.of(context).primary),
                const SizedBox(width: 12),
                Text(
                  selectedDateTime == null
                      ? "Select Date & Time"
                      : DateFormat(
                          'MMM dd, yyyy - hh:mm a',
                        ).format(selectedDateTime!),
                  style: TextStyle(
                    color: selectedDateTime == null
                        ? Colors.grey[500]
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress() {
    ref.watch(addressProvider);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SavedAddress(
              hideExtraWidgets: true,
              onAddressSelected: (address) async {
                // 1️⃣ Update local provider
                await ref
                    .read(addressProvider.notifier)
                    .updateLocalAddress(
                      city: address.city,
                      stateName: address.state,
                      pincode: address.pincode,
                      latitude: address.latitude,
                      longitude: address.longitude,
                      fullAddress: address.fullAddress,
                      category: address.category, // ✅ important
                    );

                // 2️⃣ Update catering cart address
                if (address.addressId != 0) {
                  final success =
                      await AddressNotifier.updatecateringDeliveryAddress(
                        cartId: cart!.id,
                        addressId: address.addressId,
                      );

                  if (success && mounted) {
                    // 🔥 REFRESH CART IMMEDIATELY
                    final updatedCart = await catering_authservice
                        .fetchUserCart();

                    if (mounted) {
                      setState(() {
                        cart = updatedCart;
                      });
                    }
                  }
                }

                // 3️⃣ Close screen
                if (mounted) Navigator.pop(context);
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(color: Colors.grey.shade300),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ✅ SHOW ONLY IF ADDRESS EXISTS
                  if ((cart?.deliveryAddress ?? '').trim().isNotEmpty) ...[
                    Text(
                      [
                        cart!.deliveryAddress,
                        cart!.name,
                        cart!.mobileNo,
                      ].where((e) => e.toString().trim().isNotEmpty).join(", "),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        // fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Change location",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else
                    const Text(
                      "Select delivery address",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Your catering cart is empty',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some delicious items',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildCartItemCard(items[index], index);
      },
    );
  }

  Future<void> refreshCart() async {
    final catering_Cart? updatedCart = await catering_authservice
        .fetchUserCart();

    if (updatedCart != null) {
      setState(() {
        cart = updatedCart;
      });
    }
  }

  Widget _buildCartItemCard(CartPackage item, int index) {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            // border: Border.all(color: Colors.grey, width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(
                  13,
                  0,
                  0,
                  0,
                ), // 13 ≈ 5% opacity (0.05 * 255)
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.packageName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        item.isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                      onPressed: () {
                        setInnerState(() {
                          item.isExpanded = !item.isExpanded;
                        });
                      },
                    ),
                  ],
                ),

                // Expandable items
                if (item.isExpanded) ...[
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: item.packageItems
                        .map(
                          (i) => Text(
                            "• ${i.itemName}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],

                const Divider(),

                // Price + Quantity Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${(item.packagePrice * item.quantity).toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          // Decrement Button
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final userId = prefs.getInt('userId') ?? 0;
                              final cartId = prefs.getInt('cartId') ?? 0;

                              if (item.quantity > 1) {
                                // Reduce quantity
                                setInnerState(() => item.quantity--);

                                final success = await catering_authservice
                                    .updateCartQuantity(
                                      cartId: cartId,
                                      userId: userId,
                                      packageId: item.packageId,
                                      quantity: item.quantity,
                                    );

                                if (success) {
                                  await refreshCart(); // 🔥 Fetch updated cart
                                }
                              } else {
                                // Remove item if quantity becomes 0
                                final success = await catering_authservice
                                    .deletePackageFromCart(
                                      cartId: cartId,
                                      packageId: item.packageId,
                                    );

                                if (success) {
                                  setState(() {
                                    items.remove(item); // remove from UI list
                                  });
                                  await refreshCart();
                                }
                              }
                            },
                          ),

                          // Quantity Text
                          Text(
                            item.quantity.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          // Increment Button
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () async {
                              setInnerState(() => item.quantity++);

                              final prefs =
                                  await SharedPreferences.getInstance();
                              final userId = prefs.getInt('userId') ?? 0;
                              final cartId = prefs.getInt('cartId') ?? 0;

                              final success = await catering_authservice
                                  .updateCartQuantity(
                                    cartId: cartId,
                                    userId: userId,
                                    packageId: item.packageId,
                                    quantity: item.quantity,
                                  );

                              if (success) {
                                await refreshCart(); // 🔥 Fetch updated cart
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dynamic Bill Summary Widget
  Widget buildCateringSummaryCard(
    catering_Cart cart,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final subtotal = cart.subtotal;
    final gstAmount = cart.gstAmount;
    final platformFee = cart.platformFeeAmount;
    final deliveryFee = cart.deliveryFee;
    final total = cart.total;

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔽 Header with expand/collapse
            InkWell(
              onTap: () {
                setState(() {
                  _isCateringSummaryExpanded = !_isCateringSummaryExpanded;
                });
              },
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Order Summary",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isCateringSummaryExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),

            /// 🔹 Expandable section
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _isCateringSummaryExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                children: [
                  const Divider(height: 24),

                  _buildBillRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),

                  _buildBillRow("GST", "₹${gstAmount.toStringAsFixed(2)}"),

                  _buildBillRow(
                    "Platform Fee",
                    "₹${platformFee.toStringAsFixed(2)}",
                  ),

                  if (deliveryFee > 0)
                    _buildBillRow(
                      "Delivery Fee",
                      "₹${deliveryFee.toStringAsFixed(2)}",
                    ),
                ],
              ),
              secondChild: const SizedBox.shrink(),
            ),

            const Divider(height: 24),

            /// 💰 Total (ALWAYS visible)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  "₹${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCheckoutCard() {
    return ElevatedButton(
      onPressed: () {
        setState(() => isExpanded = !isExpanded);
        WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.of(context).primary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        isExpanded ? 'Hide payment options' : 'Show payment options',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildCheckoutDetails(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // _buildPaymentSection(theme, colorScheme),
        cartwallet(
          wallet: wallet,
          onSelectionChanged: (method, subWallets) {
            setState(() {
              selectedPaymentMethod = method;
              selectedSubWallets = subWallets;
            });

            debugPrint("Payment: $selectedPaymentMethod");
            debugPrint("Sub-wallets: $selectedSubWallets");
          },
        ),
        const SizedBox(height: 16),
        _buildPlaceOrderButton(theme, colorScheme),
      ],
    );
  }

  Widget _buildPlaceOrderButton(ThemeData theme, ColorScheme colorScheme) {
    double total = cart?.total ?? 0.0;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (cart == null || isPlacingOrder)
            ? null
            : () {
                if (selectedDateTime == null) {
                  AppAlert.error(
                    context,
                    "⚠️ Please select a date and time before placing the order.",
                  );
                  return; // ⛔ Stop here
                }
                placeOrder();
              },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
        ),
        child: isPlacingOrder
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: CircularProgressIndicator(
                  color: colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: colorScheme.onPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "₹${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class DateTimePickerField extends StatefulWidget {
  final String label;
  const DateTimePickerField({super.key, required this.label});

  @override
  State<DateTimePickerField> createState() => _DateTimePickerFieldState();
}

class _DateTimePickerFieldState extends State<DateTimePickerField> {
  DateTime? selectedDateTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Date & Time",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                setState(() {
                  selectedDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                });
              }
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: AppColors.of(context).primary),
                SizedBox(width: 12),
                Text(
                  selectedDateTime == null
                      ? widget.label
                      : DateFormat(
                          'MMM dd, yyyy - hh:mm a',
                        ).format(selectedDateTime!),
                  style: TextStyle(
                    color: selectedDateTime == null
                        ? Colors.grey[500]
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget buildCartSkeleton() {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    shrinkWrap: true,
    itemCount: 3,
    itemBuilder: (context, index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    },
  );
}
