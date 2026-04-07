import 'package:maamaas/screens/screens/supportteam/tickets_screen.dart';
import '../../../../Services/Auth_service/catering_authservice.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import '../../../../Services/paymentservice/razorpayservice.dart';
import '../../../../Services/App_color_service/app_colours.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maamaas/widgets/widgets/phonecall.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../Models/caterings/orders_model.dart';
import '../../../Invoices/catering Invoices.dart';
import '../catering_enquiry/catering_enquires.dart';
import 'package:flutter/material.dart';
import 'catering_ordershelper.dart';
import 'package:intl/intl.dart';

class CateringOrdersScreen extends StatefulWidget {
  const CateringOrdersScreen({super.key});

  @override
  _CateringOrdersScreenState createState() => _CateringOrdersScreenState();
}

class _CateringOrdersScreenState extends State<CateringOrdersScreen> {
  bool _isLoading = true;
  List<_CombinedItem> _combinedList = [];
  String selectedFilter = 'order';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final orders = await catering_authservice.getAllCateringOrders();
      final enquiries = await catering_authservice.getAllEnquiries();

      _combinedList = [
        ...orders.map((o) => _CombinedItem(type: 'order', data: o)),
        ...enquiries.map((e) => _CombinedItem(type: 'enquiry', data: e)),
      ].reversed.toList();
      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Header
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _combinedList.isEmpty
                  ? _buildEmptyState()
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: 12, // slight reduction for scroll
        right: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Row(
            children: [
              _buildFilterChip('Orders', 'order'),
              SizedBox(width: 8.w),
              _buildFilterChip('Enquiries', 'enquiry'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? cateringorders_helper.getChipColor(value)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: cateringorders_helper.getChipColor(value),
                  width: 2,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: cateringorders_helper
                        .getChipColor(value)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              cateringorders_helper.getChipIcon(value),
              size: 16.w,
              color: isSelected
                  ? Colors.white
                  : cateringorders_helper.getChipColor(value),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : cateringorders_helper.getChipColor(value),
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60.w,
            height: 60.h,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFFFF6B35),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Loading ${cateringorders_helper.getLoadingText(selectedFilter)}...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            cateringorders_helper.getEmptyStateIcon(selectedFilter),
            size: 100.w,
            color: Colors.grey[300],
          ),
          SizedBox(height: 24.h),
          Text(
            cateringorders_helper.getEmptyStateTitle(selectedFilter),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            cateringorders_helper.getEmptyStateSubtitle(selectedFilter),
            style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: cateringorders_helper.getChipColor(
                selectedFilter,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Refresh',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final filteredList = _combinedList
        .where((item) => item.type == selectedFilter)
        .toList();

    return Column(
      children: [
        SizedBox(height: 10),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: cateringorders_helper.getChipColor(selectedFilter),
            child: filteredList.isEmpty
                ? _buildNoResultsForFilter()
                : ListView.separated(
                    itemCount: filteredList.length,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return _buildItemCard(item);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(_CombinedItem item) {
    switch (item.type) {
      case 'order':
        return CateringOrderCard(
          order: item.data,
          onRatingSubmitted: _loadData,
        );
      case 'enquiry':
        return EnquiryCard(enquiry: item.data);
      default:
        return const SizedBox();
    }
  }

  Widget _buildNoResultsForFilter() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            cateringorders_helper.getEmptyStateIcon(selectedFilter),
            size: 80.w,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            cateringorders_helper.getNoResultsTitle(selectedFilter),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            cateringorders_helper.getNoResultsSubtitle(selectedFilter),
            style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CombinedItem {
  final String type; // 'order', 'enquiry', or 'enquiry_order'
  final dynamic data;

  _CombinedItem({required this.type, required this.data});
}

class CateringOrderCard extends StatelessWidget {
  final CateringOrder order;
  final VoidCallback? onRatingSubmitted;

  const CateringOrderCard({
    super.key,
    required this.order,
    this.onRatingSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.orderStatus == OrderStatus.delivered;
    final hasRating = order.rating > 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailsFullScreen(
                  order: order,
                  onRatingSubmitted: onRatingSubmitted,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Badge and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LEFT: Order badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[400]!, Colors.green[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 14.w,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'ORDER:#${order.id}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // RIGHT: Status
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: cateringorders_helper.getStatusColor(
                          order.orderStatus,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            order.orderStatus.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12.w,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Date and Time
                Row(
                  children: [
                    _buildInfoItem(
                      Icons.calendar_today_outlined,
                      cateringorders_helper.formatDate(order.orderDateTime),
                    ),
                    SizedBox(width: 16.w),
                    _buildInfoItem(
                      Icons.access_time_outlined,
                      cateringorders_helper.formatTime(order.orderDateTime),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Items Preview
                ...order.items
                    .take(2)
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${item.packageName} (${item.quantity})",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "₹${item.packagePrice}",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (order.items.length > 2)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      "+ ${order.items.length - 2} more items",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                SizedBox(height: 16.h),

                // Rating Section for Delivered Orders
                if (isDelivered) ...[
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rate_rounded,
                          size: 16.w,
                          color: Colors.orange[700],
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            hasRating
                                ? 'You rated this order ${order.rating} stars'
                                : 'Rate your order experience',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                        if (!hasRating)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[700],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Rate Now',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: Colors.grey[600]),
        SizedBox(width: 6.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class OrderDetailsFullScreen extends StatefulWidget {
  final CateringOrder order;
  final VoidCallback? onRatingSubmitted;

  const OrderDetailsFullScreen({
    super.key,
    required this.order,
    this.onRatingSubmitted,
  });

  @override
  State<OrderDetailsFullScreen> createState() => _OrderDetailsFullScreenState();
}

class _OrderDetailsFullScreenState extends State<OrderDetailsFullScreen> {
  bool _isSubmittingRating = false;
  int selectedRating = 0;
  bool isLoading = false;

  Future<void> _submitRating(int rating) async {
    setState(() {
      _isSubmittingRating = true;
    });

    try {
      // If you have a text field later, you can replace this
      final feedback = "No feedback";

      await catering_authservice.submitUserFeedback(
        orderId: widget.order.id,
        feedback: feedback,
        rating: rating,
      );
      AppAlert.success(context, 'Thank you for your $rating★ rating!');

      widget.onRatingSubmitted?.call();
    } catch (e) {
      AppAlert.error(context, 'Failed to submit feedback. Please try again.');
    } finally {
      setState(() {
        _isSubmittingRating = false;
      });
    }
  }

  void _payRemainingAmount() async {
    final amount = widget.order.amountRemaining;

    try {
      setState(() => isLoading = true);

      /// 1️⃣ Create Razorpay Order
      final orderId = await catering_authservice.createOrder(amount);

      if (orderId == null) {
        throw Exception("Failed to create Razorpay order");
      }

      final razorpay = RazorpayService();

      /// 2️⃣ Success Callback
      razorpay.onSuccess = (PaymentSuccessResponse response) async {
        try {
          await catering_authservice.capturePayment(
            paymentId: response.paymentId!,
            amount: amount,
          );

          await _recordPayment(
            "remaining",
            "Online_Payment",
            razorpayPaymentId: response.paymentId,
            razorpayOrderId: response.orderId,
          );

          AppAlert.success(context, "Payment successful");
        } catch (e) {
          AppAlert.error(context, "Payment captured but recording failed");
        } finally {
          setState(() => isLoading = false);
        }
      };

      /// 3️⃣ Error
      razorpay.onError = (PaymentFailureResponse response) {
        AppAlert.error(context, response.message ?? "Payment Failed");
        setState(() => isLoading = false);
      };

      /// 4️⃣ Start Payment
      razorpay.startPayment(
        orderId: orderId,
        amount: amount,
        description: "Remaining payment for Order #${widget.order.id}",
      );
    } catch (e) {
      AppAlert.error(context, "Failed to start payment");
      setState(() => isLoading = false);
    }
  }

  Future<void> _recordPayment(
    String paymentType,
    String paymentMethod, {
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception('User not found');
      }

      setState(() => isLoading = true);

      final success = await catering_authservice.recordPayment(
        quotationId: widget.order.quotationId,
        leadId: widget.order.leadId,
        userId: userId,
        amount: widget.order.amountRemaining,
        paymentType: "FINAL_PAYMENT",
        paymentMethod: paymentMethod,
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
      );

      if (success) {
        AppAlert.success(context, "Payment recorded successfully");
      }
    } catch (e) {
      AppAlert.error(context, e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const Text(
                  "How can we help you?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                _buildHelpTile(
                  icon: Icons.support_agent,
                  color: Colors.blue,
                  title: "Call Support",
                  subtitle: "Talk to our 24/7 support team",
                  onTap: () {
                    Navigator.pop(context);
                    phonecall.makePhoneCall('+919063888450');
                  },
                ),

                _buildHelpTile(
                  icon: Icons.chat_bubble_outline,
                  color: Colors.green,
                  title: "Live Chat",
                  subtitle: "Chat with our support team",
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to chat screen
                  },
                ),

                _buildHelpTile(
                  icon: Icons.report_problem_outlined,
                  color: Colors.orange,
                  title: "Report an Issue",
                  subtitle: "Facing a problem with your order?",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateTicketScreen(
                          orderId: widget.order.id,
                          serviceType: "CATERING",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'dd MMM yyyy',
    ).format(widget.order.orderDateTime);
    final formattedTime = DateFormat(
      'hh:mm a',
    ).format(widget.order.orderDateTime);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Order #${widget.order.id}"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
        shape: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order #${widget.order.id}",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Chip(
                label: Text(
                  widget.order.orderStatus.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: cateringorders_helper.getStatusColor(
                  widget.order.orderStatus,
                ),
              ),
            ],
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.grey.shade100,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                children: [
                  _infoRow(Icons.calendar_today, "Date", formattedDate),
                  _infoRow(Icons.access_time, "Time", formattedTime),
                ],
              ),
            ),
          ),

          SizedBox(height: 14.h),
          Text(
            "Delivery Details",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),

          Card(
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                children: [
                  _infoRow(
                    Icons.event,
                    "Catering Date",
                    widget.order.cateringDate,
                  ),
                  _infoRow(
                    Icons.schedule,
                    "Catering Time",
                    widget.order.cateringTime,
                  ),
                  if (widget.order.deliveryUserName.isNotEmpty)
                    _infoRow(
                      Icons.person,
                      "Name",
                      widget.order.deliveryUserName.toUpperCase(),
                    ),

                  if (widget.order.mobileNo.isNotEmpty)
                    _infoRow(Icons.phone, "Mobile", widget.order.mobileNo),

                  if (widget.order.deliveryAddress.isNotEmpty)
                    _infoRow(
                      Icons.location_on,
                      "Address",
                      widget.order.deliveryAddress,
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8.h),

          Text("Ordered Items", style: AppStyles.titleStyle),
          SizedBox(height: 8.h),
          ...widget.order.items.map((item) => buildOrderItem(item)),
          SizedBox(height: 8.h),
          Text("Addons", style: AppStyles.titleStyle),
          SizedBox(height: 8.h),
          ...widget.order.addOns.map((item) => buildOrderaddon(item)).toList(),
          Divider(height: 24.h),

          const SizedBox(height: 16),

          _buildOrderSummary(),
          const SizedBox(height: 20),
          if (widget.order.paymentStatus.toLowerCase() == "partially_paid" &&
              widget.order.amountRemaining > 0)
            _buildPendingPaymentWidget(),

          const SizedBox(height: 20),
          // ignore: unrelated_type_equality_checks
          if (widget.order.orderStatus == OrderStatus.delivered)
            _buildRatingSection(),
          const SizedBox(height: 10),
          _buildNeedHelpSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildOrderItem(CateringOrderItem item) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.packageName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (item.packagePrice > 0)
                  Text(
                    "₹${item.packagePrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 6),

            /// CASE 1 : Single Item
            if (item.itemsName.isNotEmpty)
              Text(
                "• ${item.itemsName}",
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),

            /// CASE 2 : Package Items
            if (item.packageItems.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: item.packageItems.map((pkgItem) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      "• ${pkgItem.itemName}",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderaddon(CateringAddOn addOn) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                addOn.addOnType.replaceAll("_", " "),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Text(
              "Qty: ${addOn.quantity}",
              style: const TextStyle(fontSize: 13),
            ),

            Text(
              "₹${addOn.totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final order = widget.order;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Order Summary",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),

            /// Invoice Button
            // if (order.orderStatus == OrderStatus.delivered)
            InkWell(
              borderRadius: BorderRadius.circular(8.r),
              onTap: () async {
                if (!mounted) return;

                AppAlert.info(context, "Generating invoice...");
                await cateringpdf().downloadInvoice(widget.order.id);

                if (!mounted) return;
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade500],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.receipt, size: 16.sp, color: Colors.white),
                    SizedBox(width: 6.w),
                    Text(
                      "Invoice",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),

        /// Summary rows
        _summaryRow("Subtotal", order.subtotal),
        _summaryRow("SGST", order.sgst),
        _summaryRow("CGST", order.cgst),

        _summaryRow("Delivery charges", order.deliveryFee),

        _summaryRow("Platform Charges", order.platformFeeAmount),

        const Divider(height: 20),

        /// Total
        _summaryRow("Total", order.total, isTotal: true),
      ],
    );
  }

  Widget _summaryRow(String title, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title:",
            style: TextStyle(
              fontSize: isTotal ? 15.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 15.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPaymentWidget() {
    final order = widget.order;

    return Card(
      color: Colors.red.shade50,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Pending Payment",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "You still have a pending amount to complete this order.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Remaining: ₹${order.amountRemaining.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: _payRemainingAmount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: const Text(
                    "Pay Now",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: Colors.grey.shade600),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      color: valueColor ?? Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    final hasRating = widget.order.rating > 0;

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasRating) ...[
              Center(
                child: Column(
                  children: [
                    Text(
                      "Thank you for your rating!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < widget.order.rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.orange,
                          size: 32,
                        );
                      }),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "${widget.order.rating}/5 Stars",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                "How was your order experience?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16),
              Center(child: _buildRatingStars()),
              SizedBox(height: 16),
              if (_isSubmittingRating)
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedRating = index + 1;
            });
            _submitRating(selectedRating);
          },
          child: Icon(
            index < selectedRating
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: Colors.orange,
            size: 40,
          ),
        );
      }),
    );
  }

  Widget _buildNeedHelpSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showHelpBottomSheet(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: const [
              Icon(Icons.support_agent, color: Colors.white, size: 26),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Need Help With Your Order?",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
