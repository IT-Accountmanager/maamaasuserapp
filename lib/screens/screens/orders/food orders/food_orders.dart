import 'package:maamaas/screens/screens/orders/food%20orders/food_helper.dart';
import '../../../../Services/Auth_service/delivery_service.dart';
import '../../../../Services/Auth_service/food_authservice.dart';
import '../../../../Services/websockets/web_socket_manager.dart';
import '../../../../Services/scaffoldmessenger/messenger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaas/widgets/widgets/phonecall.dart';
import '../../../../Models/delivery/fooddelivery.dart';
import '../../../../Models/food/orders_model.dart';
import '../../supportteam/tickets_screen.dart';
import '../../../Invoices/food_pdf.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../live_tracking.dart';
import 'dart:async';

// ── Design Tokens ─────────────────────────────────────────────────────────────
class _T {
  static const bg = Color(0xFFF6F7F9);
  static const surface = Colors.white;
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const accent = Color(0xFFFF5722);
  static const green = Color(0xFF16A34A);
  static const amber = Color(0xFFF59E0B);
  static const blue = Color(0xFF2563EB);
  static const Color _brandOrange = Color(0xFFFF6B35);

  static const h1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: ink,
    letterSpacing: -0.5,
  );
  static const h2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ink,
    letterSpacing: -0.2,
  );
  static const body = TextStyle(fontSize: 13, color: muted, height: 1.4);
  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: muted,
    letterSpacing: 0.5,
  );
}

// ignore: camel_case_types
class food_orders extends StatefulWidget {
  const food_orders({super.key});

  @override
  State<food_orders> createState() => _food_ordersState();
}

// ignore: camel_case_types
class _food_ordersState extends State<food_orders> with WidgetsBindingObserver {
  bool isLoading = true;
  List<Order> orders = [];

  // Track which order IDs are currently subscribed so we never double-subscribe
  final Set<int> _subscribedOrderIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadOrders();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-subscribe when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _resubscribeAll();
    }
  }

  Future<void> _loadOrders() async {
    if (mounted) setState(() => isLoading = true);
    try {
      final response = await food_Authservice.getAllOrders();
      final fetchedOrders = response
          .map((json) => Order.fromJson(json))
          .toList();
      if (!mounted) return;
      setState(() => orders = fetchedOrders);
      _subscribeActiveOrders();
    } catch (e) {
      if (mounted) AppAlert.error(context, 'Error loading orders: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _subscribeActiveOrders() {
    for (final order in orders.where((o) => o.isActive)) {
      _listenOrderStatus(order.orderId);
    }
  }

  void _resubscribeAll() {
    // Clear tracked set and re-subscribe to make sure connections are alive
    _subscribedOrderIds.clear();
    _subscribeActiveOrders();
  }

  void _listenOrderStatus(int orderId) {
    // Prevent duplicate subscriptions for the same orderId
    if (_subscribedOrderIds.contains(orderId)) return;
    _subscribedOrderIds.add(orderId);

    WebSocketManager().subscribeOrderStatus(orderId, (data) {
      if (!mounted) return;
      final newStatus = OrderStatus.fromString(data['status'] as String? ?? '');
      setState(() {
        final index = orders.indexWhere((o) => o.orderId == orderId);
        if (index == -1) return;
        final updatedOrder = orders[index].copyWith(status: newStatus);
        orders[index] = updatedOrder;

        // If order is no longer active, unsubscribe and remove from tracked set
        if (!updatedOrder.isActive) {
          WebSocketManager().unsubscribeOrderStatus(orderId);
          _subscribedOrderIds.remove(orderId);
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Unsubscribe all tracked orders
    for (final orderId in _subscribedOrderIds) {
      WebSocketManager().unsubscribeOrderStatus(orderId);
    }
    _subscribedOrderIds.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _buildFoodOrderList();

  Widget _buildFoodOrderList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _T.accent, strokeWidth: 2),
      );
    }

    final activeOrders = orders
        .where((o) => o.isActive)
        .toList()
        .reversed
        .toList();
    final pastOrders = orders
        .where((o) => !o.isActive)
        .toList()
        .reversed
        .toList();

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: _T.border),
            const SizedBox(height: 12),
            const Text("No orders yet", style: _T.h2),
            const SizedBox(height: 4),
            const Text("Your food orders will appear here", style: _T.body),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: _T.accent,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        children: [
          if (activeOrders.isNotEmpty) ...[
            _sectionLabel("Active Orders", dot: _T.accent),
            SizedBox(height: 10.h),
            ...activeOrders.map(
              (order) => OrderCard(
                key: ValueKey('order_${order.orderId}'),
                order: order,
                isActive: true,
                onTap: () => _navigateToOrderDetails(context, order),
              ),
            ),
            SizedBox(height: 24.h),
          ],
          if (pastOrders.isNotEmpty) ...[
            _sectionLabel("Past Orders"),
            SizedBox(height: 10.h),
            ...pastOrders.map(
              (order) => OrderCard(
                key: ValueKey('order_${order.orderId}'),
                order: order,
                isActive: false,
                onTap: () => _navigateToOrderDetails(context, order),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, {Color dot = _T.muted}) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: _T.label.copyWith(color: _T.ink, fontSize: 11),
        ),
      ],
    );
  }

  void _navigateToOrderDetails(BuildContext context, Order order) {
    // Do NOT unsubscribe here — the list screen should keep its own
    // subscription independent of the detail screen.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(
          orderId: order.orderId,
          order: order,
          formattedDate: DateFormat('dd MMM yyyy').format(order.parsedDateTime),
          formattedTime: DateFormat('hh:mm a').format(order.parsedDateTime),
          items: order.items,
          isActive: order.isActive,
          date: order.date,
          time: order.time,
        ),
      ),
    ).then((_) {
      // When returning from detail screen, refresh the list to pick up
      // any status changes that happened while we were away.
      _loadOrders();
    });
  }
}

// ── Order Card ────────────────────────────────────────────────────────────────
class OrderCard extends StatefulWidget {
  final Order order;
  final bool isActive;
  final VoidCallback onTap;

  // ignore: use_super_parameters
  const OrderCard({
    Key? key,
    required this.order,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  int currentRating = 0;
  bool isLoadingRating = true;
  late bool isCancelled;
  final Map<int, bool> _submittedOrders = {};
  final Map<int, TextEditingController> _feedbackControllers = {};

  final Map<int, String> _submittedFeedback = {};
  final Map<int, int> _submittedRatings = {};
  final Map<int, int> _currentRatings = {};
  final Map<int, RatingCategory> _selectedCategories = {};
  final Map<int, RatingCategory> _submittedCategories = {};

  @override
  void initState() {
    super.initState();
    isCancelled = widget.order.status == OrderStatus.cancelled;
  }

  Future<bool> _submitRating(
    int orderId,
    int rating,
    String feedback,
    RatingCategory category,
  ) async {
    final success = await food_Authservice.submitRating(
      orderId,
      rating,
      feedback,
      ratingCategoryToString(category), // ✅ NEW
    );

    if (!mounted) return false;

    if (success) {
      AppAlert.success(context, "Thanks for your feedback!");
    } else {
      AppAlert.error(context, "Failed to submit feedback.");
    }

    return success;
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    // ✅ AUTO MARK AS SUBMITTED IF API HAS DATA
    final bool isAlreadyRated =
        (order.ratings ?? 0) > 0 ||
        (order.feedback != null && order.feedback!.trim().isNotEmpty) ||
        (order.ratingCategory != null &&
            order.ratingCategory!.trim().isNotEmpty);

    if (isAlreadyRated) {
      _submittedOrders.putIfAbsent(order.orderId, () => true);

      _submittedRatings.putIfAbsent(
        order.orderId,
        () => (order.ratings ?? 0).toInt(),
      );

      _submittedFeedback.putIfAbsent(order.orderId, () => order.feedback ?? '');

      _submittedCategories.putIfAbsent(
        order.orderId,
        () => RatingCategory.values.firstWhere(
          (e) => e.toString() == order.ratingCategory,
          orElse: () => RatingCategory.FOOD_QUALITY,
        ),
      );
    }
    final bool isSubmitted = _submittedOrders[order.orderId] ?? isAlreadyRated;
    final statusColor = FoodOrdersHelper.getStatusColor(order.status);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isCancelled ? _T.border : statusColor.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(order, statusColor),
                if (widget.isActive && !isCancelled) ...[
                  SizedBox(height: 14.h),
                  _buildProgressBar(order),
                ],
                if (isCancelled) ...[
                  SizedBox(height: 10.h),
                  _buildCancelledTag(),
                ],
                if (!widget.isActive &&
                    order.status == OrderStatus.completed &&
                    !isCancelled) ...[
                  Divider(height: 24.h, color: _T.border),

                  isSubmitted
                      ? _buildSubmittedReview(order)
                      : _buildRatingRow(order.orderId),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getOrderTypeLabel(OrderType type) {
    switch (type) {
      case OrderType.DINE_IN:
        return "Dine In";
      case OrderType.DELIVERY:
        return "Delivery";
      case OrderType.TAKEAWAY:
        return "Takeaway";
      case OrderType.TABLE_DINE_IN:
        return "Dine Out"; // your custom mapping
      default:
        return type.name.replaceAll('_', ' ');
    }
  }

  Widget _buildHeader(Order order, Color statusColor) {
    final parsed = order.parsedDateTime;

    final dateTime = parsed != null
        ? DateTime.utc(
            parsed.year,
            parsed.month,
            parsed.day,
            parsed.hour,
            parsed.minute,
            parsed.second,
            parsed.millisecond,
          ).toLocal()
        : null;

    final formattedDate = (dateTime == null || dateTime.year == 1970)
        ? "Invalid date"
        : DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    final orderTypeLabel = getOrderTypeLabel(order.orderType);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Order #${order.id}", style: _T.h2),
              SizedBox(height: 4.h),
              Text(formattedDate, style: _T.body),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                orderTypeLabel,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right_rounded, size: 18, color: _T.muted),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(Order order) {
    final steps = [
      _ProgressStep("Confirmed", OrderStatus.confirmed),
      _ProgressStep("Preparing", OrderStatus.beingPrepared),
      _ProgressStep("Ready", OrderStatus.orderIsReady),
      _ProgressStep("Delivered", OrderStatus.completed),
    ];

    final currentIndex = _stepIndex(order.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _statusLabel(order.status).toUpperCase(),
          style: _T.label.copyWith(color: _T.accent, fontSize: 10),
        ),
        SizedBox(height: 8.h),
        Row(
          children: List.generate(steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final filled = i ~/ 2 < currentIndex;
              return Expanded(
                child: Container(
                  height: 2,
                  color: filled ? _T.accent : _T.border,
                ),
              );
            }
            final stepI = i ~/ 2;
            final done = stepI < currentIndex;
            final active = stepI == currentIndex;
            return _dot(done: done, active: active);
          }),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps
              .map(
                (s) => SizedBox(
                  width: 60.w,
                  child: Text(
                    s.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: _T.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _dot({required bool done, required bool active}) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: done
            ? _T.accent
            : active
            ? _T.accent.withOpacity(0.15)
            : _T.border,
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? _T.accent : Colors.transparent,
          width: 2,
        ),
      ),
      child: done
          ? const Icon(Icons.check_rounded, size: 10, color: Colors.white)
          : null,
    );
  }

  int _stepIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return 0;
      case OrderStatus.beingPrepared:
        return 1;
      case OrderStatus.orderIsReady:
      case OrderStatus.waitingForPickup:
        return 2;
      case OrderStatus.ontheway:
      case OrderStatus.completed:
        return 3;
      default:
        return 0;
    }
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.hold:
        return "On hold";
      case OrderStatus.pending:
        return "Not accepted";
      case OrderStatus.confirmed:
        return "Order confirmed";
      case OrderStatus.beingPrepared:
        return "Preparing your food";
      case OrderStatus.orderIsReady:
        return "Order ready";
      case OrderStatus.waitingForPickup:
        return "Waiting for pickup";
      case OrderStatus.ontheway:
        return "On the way";
      case OrderStatus.completed:
        return "Delivered";
      default:
        return "Processing";
    }
  }

  Widget _buildCancelledTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cancel_outlined, size: 12.sp, color: _T.muted),
          SizedBox(width: 4.w),
          Text(
            "Cancelled",
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: _T.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(int orderId) {
    _feedbackControllers.putIfAbsent(orderId, () => TextEditingController());
    final feedbackController = _feedbackControllers[orderId]!;

    final isSubmitted = _submittedOrders[orderId] ?? false;
    final feedbackText = _submittedFeedback[orderId] ?? '';
    final submittedCategory = _submittedCategories[orderId];

    return StatefulBuilder(
      builder: (context, localSetState) {
        final currentRating = isSubmitted
            ? (_submittedRatings[orderId] ?? widget.order.ratings)
            : (_currentRatings[orderId] ?? 0);
        final selectedCategory =
            _selectedCategories[orderId] ?? RatingCategory.FOOD_QUALITY;

        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: _T.bg,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: _T.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────
              Text(
                "RATE THIS ORDER",
                style: _T.body.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _T.muted,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 10.h),

              // ── Stars ─────────────────────────────────────────
              Row(
                children: List.generate(5, (i) {
                  final filled = i < currentRating;
                  return GestureDetector(
                    onTap: isSubmitted
                        ? null
                        : () => localSetState(
                            () => _currentRatings[orderId] = i + 1,
                          ),
                    child: Padding(
                      padding: EdgeInsets.only(right: 6.w),
                      child: Icon(
                        filled
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 30,
                        color: filled ? _T.amber : _T.border,
                      ),
                    ),
                  );
                }),
              ),

              // ── Not yet submitted ──────────────────────────────
              if (!isSubmitted) ...[
                SizedBox(height: 14.h),
                DropdownButtonFormField<RatingCategory>(
                  value: selectedCategory,
                  style: _T.body.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _T.surface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: _T.border, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: _T.blue, width: 1),
                    ),
                  ),
                  items: RatingCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(
                        cat.toString().split('.').last.replaceAll('_', ' '),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      localSetState(() => _selectedCategories[orderId] = value);
                    }
                  },
                ),
                SizedBox(height: 10.h),

                // Feedback field
                TextField(
                  controller: feedbackController,
                  maxLines: 2,
                  style: _T.body.copyWith(fontSize: 14),
                  onChanged: (_) => localSetState(() {}),
                  decoration: InputDecoration(
                    hintText: "Write your feedback…",
                    hintStyle: _T.body.copyWith(fontSize: 14, color: _T.muted),
                    filled: true,
                    fillColor: _T.surface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: _T.border, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: _T.blue, width: 1),
                    ),
                  ),
                ),

                // Category dropdown
                SizedBox(height: 14.h),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final feedback = feedbackController.text.trim();
                      final success = await _submitRating(
                        orderId,
                        currentRating,
                        feedback,
                        selectedCategory,
                      );
                      if (success) {
                        setState(() {
                          _submittedOrders[orderId] = true;
                          _submittedFeedback[orderId] = feedback;
                          _submittedRatings[orderId] = currentRating;
                          _submittedCategories[orderId] = selectedCategory;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _T.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                    ),
                    child: Text(
                      "Submit rating",
                      style: _T.body.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],

              // ── Submitted state ────────────────────────────────
              if (isSubmitted) ...[
                SizedBox(height: 10.h),

                // Category badge
                if (submittedCategory != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _T.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                    child: Text(
                      submittedCategory
                          .toString()
                          .split('.')
                          .last
                          .replaceAll('_', ' '),
                      style: _T.body.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _T.blue,
                      ),
                    ),
                  ),

                // Submitted feedback quote
                if (feedbackText.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    '"$feedbackText"',
                    style: _T.body.copyWith(
                      fontSize: 13,
                      color: _T.muted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],

                SizedBox(height: 12.h),
                Divider(color: _T.border, thickness: 0.5, height: 1),
                SizedBox(height: 12.h),

                // Success pill
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: _T.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: _T.green.withOpacity(0.25),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _T.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Thanks for your feedback!",
                        style: _T.body.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _T.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  RatingCategory? parseRatingCategory(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      return RatingCategory.values.firstWhere((e) => e.toString() == raw);
    } catch (_) {
      return null;
    }
  }

  Widget _buildSubmittedReview(Order order) {
    final int orderId = order.orderId;

    final double rawRating = (_submittedRatings[orderId] ?? order.ratings ?? 0)
        .toDouble();

    final int rating = rawRating.toInt().clamp(0, 5);

    final String feedback =
        _submittedFeedback[orderId] ?? (order.feedback ?? '');

    final RatingCategory? category =
        _submittedCategories[orderId] ??
        parseRatingCategory(order.ratingCategory);

    final bool hasRating = rawRating > 0;
    final bool hasFeedback = feedback.trim().isNotEmpty;
    final bool hasCategory = category != null;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _T.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            "YOUR REVIEW",
            style: _T.body.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _T.muted,
              letterSpacing: 0.8,
            ),
          ),

          SizedBox(height: 5.h),

          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (hasRating)
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      Icons.star_rounded,
                      size: 22,
                      color: i < rating ? _T.amber : _T.border,
                    );
                  }),
                ),
              if (hasCategory) ...[
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: _T.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                  child: Text(
                    category.toString().split('.').last.replaceAll('_', ' '),
                    style: _T.body.copyWith(
                      fontSize: 11,
                      color: _T.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (hasFeedback) ...[
            SizedBox(height: 10.h),
            Text(
              '"$feedback"',
              style: _T.body.copyWith(
                fontSize: 13,
                color: _T.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          SizedBox(height: 12.h),

          Divider(color: _T.border, thickness: 0.5),

          SizedBox(height: 10.h),

          // success footer
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _T.green,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "Thanks for your feedback!",
                style: _T.body.copyWith(
                  fontSize: 13,
                  color: _T.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressStep {
  final String label;
  final OrderStatus status;
  const _ProgressStep(this.label, this.status);
}

// ── Order Details Screen ───────────────────────────────────────────────────────
class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  final Order order;
  final String formattedDate;
  final String formattedTime;
  final List<OrderItem> items;
  final bool isActive;
  final String date;
  final String time;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.order,
    required this.formattedDate,
    required this.formattedTime,
    required this.items,
    required this.isActive,
    required this.date,
    required this.time,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with WidgetsBindingObserver {
  DeliveryOrderModel? deliveryModel;
  bool isLoadingDelivery = true;
  late Order order;
  bool _wsSubscribed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    order = widget.order;
    if (widget.order.orderType == OrderType.DELIVERY) {
      _loadDeliveryOrder(); // ✅ only for delivery
    }
    // Only subscribe to status WS in details if order is active
    if (widget.isActive) _listenOrderStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.isActive) {
      if (!_wsSubscribed) _listenOrderStatus();
    }
  }

  void _listenOrderStatus() {
    if (_wsSubscribed) return; // Prevent duplicate subscription
    _wsSubscribed = true;
    WebSocketManager().subscribeOrderStatus(widget.orderId, (data) {
      if (!mounted) return;
      final newStatus = OrderStatus.fromString(data['status'] as String? ?? '');
      setState(() {
        order = order.copyWith(status: newStatus);
      });
      // Auto-reload delivery info when order transitions to ontheway
      if ((newStatus == OrderStatus.ontheway ||
              newStatus == OrderStatus.waitingForPickup) &&
          widget.order.orderType == OrderType.DELIVERY) {
        _loadDeliveryOrder(); // ✅ safe
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Only unsubscribe from the detail screen's own subscription
    if (_wsSubscribed) {
      WebSocketManager().unsubscribeOrderStatus(widget.orderId);
      _wsSubscribed = false;
    }
    super.dispose();
  }

  Future<void> _loadDeliveryOrder() async {
    if (widget.order.orderType != OrderType.DELIVERY) return;
    if (!mounted) return;
    setState(() => isLoadingDelivery = true);
    try {
      final result = await DeliveryOrderService.getOrder(widget.order.orderId);
      if (mounted) {
        setState(() {
          deliveryModel = result;
          isLoadingDelivery = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingDelivery = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = FoodOrdersHelper.getStatusColor(order.status);
    final isScheduled = widget.order.sheduled == true;

    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: _T.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: _T.ink,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Order Details",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _T.ink,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: _T.border),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Order ID + Status ───────────────────────────────────────
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: _cardDecor(),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order #${widget.order.id}", style: _T.h1),
                        SizedBox(height: 4.h),
                        Text(
                          "${widget.formattedDate}  ·  ${widget.formattedTime}",
                          style: _T.body,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // ── Info Row ────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: _cardDecor(),
              child: Column(
                children: [
                  _infoRow(
                    Icons.local_dining_outlined,
                    "Order Type",
                    widget.order.orderType.label,
                  ),
                  if (isScheduled) ...[
                    Divider(height: 16.h, color: _T.border),
                    _infoRow(
                      Icons.event_outlined,
                      "Scheduled Date",
                      widget.order.date,
                    ),
                    _infoRow(
                      Icons.schedule_outlined,
                      "Scheduled Time",
                      widget.order.time,
                    ),
                  ],
                  if (widget.order.orderType == OrderType.DELIVERY) ...[
                    _infoRow(
                      Icons.person,
                      "Name",
                      widget.order.deliveryUserName.toUpperCase(),
                    ),
                    _infoRow(
                      Icons.phone,
                      "Contact Details",
                      widget.order.mobileNo,
                    ),
                    _infoRow(
                      Icons.location_on_rounded,
                      "Delivery Address",
                      widget.order.deliveryAddress,
                    ),
                  ],
                ],
              ),
            ),

            // ── Live Tracking — completely self-contained widget ────────
            if (widget.order.orderType == OrderType.DELIVERY) ...[
              SizedBox(height: 12.h),
              _sectionHeader("Live Tracking"),
              SizedBox(height: 8.h),
              // ModernDeliveryTracking manages its own WS for location
              // and its own WS for order status — independent of this screen.
              ModernDeliveryTracking(
                key: ValueKey('tracking_${widget.order.orderId}'),
                orderId: widget.order.orderId,
                orderStatus: order.status, // pass reactive status
                deliveryModel: deliveryModel,
                onRefresh: _loadDeliveryOrder,
              ),
            ],

            SizedBox(height: 12.h),

            // ── Items ───────────────────────────────────────────────────
            _sectionHeader("Items"),
            SizedBox(height: 8.h),
            Container(
              decoration: _cardDecor(),
              child: Column(
                children: widget.items
                    .asMap()
                    .entries
                    .map(
                      (e) => Column(
                        children: [
                          _buildOrderItem(e.value),
                          if (e.key < widget.items.length - 1)
                            Divider(
                              height: 1,
                              indent: 16.w,
                              endIndent: 16.w,
                              color: _T.border,
                            ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),

            SizedBox(height: 12.h),

            // ── Order Summary ───────────────────────────────────────────
            _sectionHeader("Summary"),
            SizedBox(height: 8.h),
            _buildOrderSummary(),

            SizedBox(height: 16.h),

            _buildDownloadButton(context),
            SizedBox(height: 16.h),

            // ── Help ────────────────────────────────────────────────────
            _buildNeedHelpSection(),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecor() => BoxDecoration(
    color: _T.surface,
    borderRadius: BorderRadius.circular(14.r),
    border: Border.all(color: _T.border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  Widget _sectionHeader(String title) => Text(
    title.toUpperCase(),
    style: _T.label.copyWith(color: _T.ink, fontSize: 11),
  );

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _T.muted),
          SizedBox(width: 10.w),
          Text(label, style: _T.body),
          const Spacer(),
          Expanded(
            // 👈 allows wrapping
            child: Text(
              value,
              maxLines: 3, // 👈 limit to 2 lines
              overflow: TextOverflow.ellipsis, // 👈 "..."
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _T.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: _T.bg,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: _T.border),
            ),
            child: Center(
              child: Text(
                "${item.quantity}×",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: _T.ink,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              item.dishName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _T.ink,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${item.totalPrice.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _T.ink,
                ),
              ),
              Text(
                "₹${item.price.toStringAsFixed(0)} each",
                style: _T.body.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final o = widget.order;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecor(),
      child: Column(
        children: [
          _summaryRow("Subtotal", o.subTotal),
          _summaryRow("SGST", o.sgst),
          _summaryRow("CGST", o.cgst),
          if (o.discountAmount > 0)
            _summaryRow("Discount", -o.discountAmount, color: _T.green),
          _summaryRow("Platform Charges", o.platformCharges),
          if (o.orderType != OrderType.DINE_IN)
            _summaryRow("Packing Charges", o.packingCharges),
          if (o.orderType == OrderType.DELIVERY)
            _summaryRow("Delivery Charges", o.deliveryCharges),
          Divider(height: 20.h, color: _T.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _T.ink,
                ),
              ),
              Text(
                "₹${o.grandTotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _T.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, double amount, {Color? color}) {
    final isNegative = amount < 0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: _T.body),
          Text(
            "${isNegative ? '-' : ''}₹${amount.abs().toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color ?? _T.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: () async {
          AppAlert.info(context, "Generating invoice...");
          await FoodPdf().downloadInvoice(widget.orderId);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _T._brandOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download_rounded, size: 20),
            SizedBox(width: 8.w),
            const Text(
              "Download Invoice",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeedHelpSection() {
    return GestureDetector(
      onTap: () => _showHelpBottomSheet(context),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: _T.ink,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 12.w),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Need help?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "We're available 24/7",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: _T.border,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            const Text(
              "How can we help?",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _T.ink,
              ),
            ),
            SizedBox(height: 16.h),
            _helpTile(
              icon: Icons.phone_outlined,
              color: _T.blue,
              title: "Call Support",
              subtitle: "24/7 support team",
              onTap: () {
                Navigator.pop(context);
                phonecall.makePhoneCall('+919063888450');
              },
            ),
            _helpTile(
              icon: Icons.flag_outlined,
              color: _T.amber,
              title: "Report an Issue",
              subtitle: "Problem with your order?",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateTicketScreen(
                      orderId: widget.orderId,
                      serviceType: "FOOD_AND_BEVERAGES",
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _helpTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _T.border),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _T.ink,
          ),
        ),
        subtitle: Text(subtitle, style: _T.body.copyWith(fontSize: 12)),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: _T.muted,
        ),
        onTap: onTap,
      ),
    );
  }
}
