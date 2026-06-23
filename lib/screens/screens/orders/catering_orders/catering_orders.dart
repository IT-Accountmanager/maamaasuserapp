import 'package:maamaas/screens/screens/supportteam/tickets_screen.dart';
import '../../../../Services/Auth_service/catering_authservice.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import '../../../../Services/paymentservice/razorpayservice.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maamaas/widgets/widgets/phonecall.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../Models/caterings/orders_model.dart';
import '../catering_enquiry/catering_enquires.dart';
import '../../../../widgets/datetimehelper.dart';
import '../../../Invoices/cateringPdf.dart';
import 'package:flutter/material.dart';

// ─── Shared Design Tokens ──────────────────────────────────────────────────

class catorders {
  static const primary = Color(0xFF1B7A50);
  static const primaryLight = Color(0xFFE8F5EE);
  static const surface = Colors.white;
  static const bg = Color(0xFFF4F5F7);
  static const border = Color(0xFFF0F0F0);
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF888888);
  static const textMuted = Color(0xFFAAAAAA);
  static const danger = Color(0xFFDC2626);
  static const dangerLight = Color(0xFFFEF2F2);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFFF8EC);
  static const info = Color(0xFF4F46E5);
  static const infoLight = Color(0xFFEEF2FF);
  static const delivered = Color(0xFF6366F1);
}

// ─── Combined Item ─────────────────────────────────────────────────────────

class _CombinedItem {
  final String type;
  final dynamic data;
  _CombinedItem({required this.type, required this.data});
}

// ═══════════════════════════════════════════════════════════════════════════
// SCREEN 1: Orders List
// ═══════════════════════════════════════════════════════════════════════════

class CateringOrdersScreen extends StatefulWidget {
  const CateringOrdersScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CateringOrdersScreenState createState() => _CateringOrdersScreenState();
}

class _CateringOrdersScreenState extends State<CateringOrdersScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<_CombinedItem> _combinedList = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final orders = await catering_authservice.getAllCateringOrders();
      final enquiries = await catering_authservice.getAllEnquiries();
      _combinedList = [
        ...orders.map((o) => _CombinedItem(type: 'order', data: o)),
        ...enquiries.map((e) => _CombinedItem(type: 'enquiry', data: e)),
      ].reversed.toList();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: catorders.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _isLoading ? _buildLoader() : _buildTabViews()),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: catorders.surface,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            labelColor: catorders.surface,
            unselectedLabelColor: catorders.textSecondary,
            labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 13.sp),
            indicator: BoxDecoration(
              color: catorders.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 16.sp),
                    SizedBox(width: 6.w),
                    const Text('Orders'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline_rounded, size: 16.sp),
                    SizedBox(width: 6.w),
                    const Text('Enquiries'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab Views ────────────────────────────────────────────────────────────

  Widget _buildTabViews() {
    return TabBarView(
      controller: _tabController,
      children: [_buildList('order'), _buildList('enquiry')],
    );
  }

  Widget _buildList(String type) {
    final items = _combinedList.where((i) => i.type == type).toList();
    if (items.isEmpty) return _buildEmpty(type);
    return RefreshIndicator(
      color: catorders.primary,
      onRefresh: _loadData,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, i) => type == 'order'
            ? CateringOrderCard(order: items[i].data, onRefresh: _loadData)
            : EnquiryCard(enquiry: items[i].data),
      ),
    );
  }

  // ── Empty / Loader ───────────────────────────────────────────────────────

  Widget _buildLoader() {
    return Center(
      child: CircularProgressIndicator(
        color: catorders.primary,
        strokeWidth: 2.5,
      ),
    );
  }

  Widget _buildEmpty(String type) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            type == 'order'
                ? Icons.receipt_long_outlined
                : Icons.help_outline_rounded,
            size: 56.sp,
            color: catorders.textMuted,
          ),
          SizedBox(height: 16.h),
          Text(
            type == 'order' ? 'No orders yet' : 'No enquiries yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: catorders.textSecondary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Pull down to refresh',
            style: TextStyle(fontSize: 13.sp, color: catorders.textMuted),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ORDER CARD
// ═══════════════════════════════════════════════════════════════════════════

class CateringOrderCard extends StatelessWidget {
  final CateringOrder order;
  final VoidCallback? onRefresh;

  const CateringOrderCard({super.key, required this.order, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.orderStatus == OrderStatus.delivered;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(order: order, onRefresh: onRefresh),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: catorders.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: catorders.border),
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Badge + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _OrderBadge(id: order.id),
                _StatusChip(status: order.orderStatus),
              ],
            ),
            SizedBox(height: 12.h),

            // Row 2: Date + Time
            // Row 2: Date + Time
            Row(
              children: [
                _MetaTag(
                  icon: Icons.calendar_today_outlined,
                  label: DateTimeHelper.formatDate(
                    DateTime.utc(
                      order.orderDateTime.year,
                      order.orderDateTime.month,
                      order.orderDateTime.day,
                      order.orderDateTime.hour,
                      order.orderDateTime.minute,
                      order.orderDateTime.second,
                      order.orderDateTime.millisecond,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                _MetaTag(
                  icon: Icons.access_time_outlined,
                  label: DateTimeHelper.formatTime(
                    DateTime.utc(
                      order.orderDateTime.year,
                      order.orderDateTime.month,
                      order.orderDateTime.day,
                      order.orderDateTime.hour,
                      order.orderDateTime.minute,
                      order.orderDateTime.second,
                      order.orderDateTime.millisecond,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Items
            ...order.items
                .take(2)
                .map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.packageName} (${item.quantity})',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: catorders.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '₹${item.packagePrice}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: catorders.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            if (order.items.length > 2)
              Text(
                '+ ${order.items.length - 2} more items',
                style: TextStyle(fontSize: 11.sp, color: catorders.textMuted),
              ),

            // Rating bar for delivered orders
            if (isDelivered) ...[
              SizedBox(height: 10.h),
              _RatingBar(order: order),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Small Reusable Widgets ────────────────────────────────────────────────

class _OrderBadge extends StatelessWidget {
  final int id;
  const _OrderBadge({required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: catorders.primaryLight,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 13.sp,
            color: catorders.primary,
          ),
          SizedBox(width: 5.w),
          Text(
            'ORDER #$id',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: catorders.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  Color get _bg {
    switch (status) {
      case OrderStatus.delivered:
        return catorders.delivered;
      case OrderStatus.confirmed:
        return catorders.primary;
      default:
        return catorders.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13.sp, color: catorders.textMuted),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: catorders.textSecondary),
        ),
      ],
    );
  }
}

class _RatingBar extends StatelessWidget {
  final CateringOrder order;
  const _RatingBar({required this.order});

  @override
  Widget build(BuildContext context) {
    final hasRating = order.rating > 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: catorders.warningLight,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rounded, size: 15.sp, color: catorders.warning),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              hasRating
                  ? 'You rated ${order.rating} stars'
                  : 'Rate your experience',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFB45309),
              ),
            ),
          ),
          if (!hasRating)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: catorders.warning,
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Text(
                'Rate Now',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SCREEN 2: Order Detail
// ═══════════════════════════════════════════════════════════════════════════

class OrderDetailScreen extends StatefulWidget {
  final CateringOrder order;
  final VoidCallback? onRefresh;

  const OrderDetailScreen({super.key, required this.order, this.onRefresh});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _submittingRating = false;
  int _selectedRating = 0;
  bool _isLoading = false;

  // ── Rating ───────────────────────────────────────────────────────────────

  Future<void> _submitRating(int rating) async {
    setState(() => _submittingRating = true);
    try {
      await catering_authservice.submitUserFeedback(
        orderId: widget.order.id,
        feedback: 'No feedback',
        rating: rating,
      );
      if (mounted) {
        AppAlert.success(context, 'Thank you for your $rating★ rating!');
      }
      widget.onRefresh?.call();
    } catch (_) {
      if (mounted) {
        AppAlert.error(context, 'Failed to submit feedback. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _submittingRating = false);
    }
  }

  // ── Payment ──────────────────────────────────────────────────────────────

  void _payRemaining() async {
    try {
      setState(() => _isLoading = true);
      final orderId = await catering_authservice.createOrder(
        widget.order.amountRemaining,
      );
      if (orderId == null) throw Exception('Failed to create order');

      final rp = RazorpayService();
      rp.onSuccess = (PaymentSuccessResponse r) async {
        try {
          await catering_authservice.capturePayment(
            paymentId: r.paymentId!,
            amount: widget.order.amountRemaining,
          );
          await _recordPayment(
            'remaining',
            'Online_Payment',
            razorpayPaymentId: r.paymentId,
            razorpayOrderId: r.orderId,
          );
          if (mounted) AppAlert.success(context, 'Payment successful');
        } catch (_) {
          if (mounted) {
            AppAlert.error(context, 'Payment captured but recording failed');
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      };
      rp.onError = (PaymentFailureResponse r) {
        AppAlert.error(context, r.message ?? 'Payment Failed');
        setState(() => _isLoading = false);
      };
      rp.startPayment(
        orderId: orderId,
        amount: widget.order.amountRemaining,
        description: 'Remaining payment for Order #${widget.order.id}',
      );
    } catch (_) {
      if (mounted) AppAlert.error(context, 'Failed to start payment');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _recordPayment(
    String paymentType,
    String paymentMethod, {
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) throw Exception('User not found');

    setState(() => _isLoading = true);
    try {
      final ok = await catering_authservice.recordPayment(
        quotationId: widget.order.quotationId,
        leadId: widget.order.leadId,
        userId: userId,
        amount: widget.order.amountRemaining,
        paymentType: 'FINAL_PAYMENT',
        paymentMethod: paymentMethod,
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
      );
      if (ok && mounted) {
        AppAlert.success(context, 'Payment recorded successfully');
      }
    } catch (e) {
      if (mounted) AppAlert.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Help Sheet ───────────────────────────────────────────────────────────

  void _showHelp() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          decoration: BoxDecoration(
            color: catorders.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'How can we help you?',
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 20.h),
              _HelpTile(
                icon: Icons.support_agent_outlined,
                color: Colors.blue,
                title: 'Call Support',
                subtitle: 'Talk to our 24/7 support team',
                onTap: () {
                  Navigator.pop(context);
                  phonecall.makePhoneCall('+919063888450');
                },
              ),
              _HelpTile(
                icon: Icons.chat_bubble_outline_rounded,
                color: Colors.green,
                title: 'Live Chat',
                subtitle: 'Chat with our support team',
                onTap: () => Navigator.pop(context),
              ),
              _HelpTile(
                icon: Icons.report_problem_outlined,
                color: Colors.orange,
                title: 'Report an Issue',
                subtitle: 'Facing a problem with your order?',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateTicketScreen(
                        orderId: widget.order.id,
                        serviceType: 'CATERING',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final utc = DateTime.utc(
      order.orderDateTime.year,
      order.orderDateTime.month,
      order.orderDateTime.day,
      order.orderDateTime.hour,
      order.orderDateTime.minute,
      order.orderDateTime.second,
      order.orderDateTime.millisecond,
    );

    final fDate = DateTimeHelper.formatDate(utc);
    final fTime = DateTimeHelper.formatTime(utc);

    return Scaffold(
      backgroundColor: catorders.bg,
      appBar: AppBar(
        backgroundColor: catorders.surface,
        elevation: 0,
        centerTitle: true,
        foregroundColor: catorders.textPrimary,
        title: Text(
          'Order #${order.id}',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: catorders.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: catorders.border),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              AppAlert.info(context, 'Generating invoice...');
              await cateringpdf().downloadInvoice(order.id);
            },
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: catorders.infoLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_outlined,
                    size: 14.sp,
                    color: catorders.info,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'Invoice',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: catorders.info,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: catorders.primary,
                strokeWidth: 2.5,
              ),
            )
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              children: [
                // Order hero card
                _Section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _DateChip(
                                icon: Icons.calendar_today_outlined,
                                label: fDate,
                              ),
                              SizedBox(width: 10.w),
                              _DateChip(
                                icon: Icons.access_time_outlined,
                                label: fTime,
                              ),
                            ],
                          ),
                          _StatusChip(status: order.orderStatus),
                        ],
                      ),

                      // SizedBox(height: 14.h),
                    ],
                  ),
                ),

                _SectionLabel(label: 'Delivery Details'),
                _Section(
                  color: const Color(0xFFF0FAF5),
                  borderColor: const Color(0xFFC6F0DA),
                  child: Column(
                    children: [
                      if (order.cateringDate.isNotEmpty)
                        _InfoRow(
                          icon: Icons.event_outlined,
                          label: 'Event Date',
                          value: DateTimeHelper.formatDateString(
                            order.cateringDate,
                          ),
                        ),
                      if (order.cateringTime.isNotEmpty)
                        _InfoRow(
                          icon: Icons.schedule_outlined,
                          label: 'Event Time',
                          value: DateTimeHelper.to12Hour(order.cateringTime),
                        ),
                      if (order.deliveryUserName.isNotEmpty)
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Name',
                          value: order.deliveryUserName.toUpperCase(),
                        ),
                      if (order.mobileNo.isNotEmpty)
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Mobile',
                          value: order.mobileNo,
                        ),
                      if (order.deliveryAddress.isNotEmpty)
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Address',
                          value: order.deliveryAddress,
                        ),
                    ],
                  ),
                ),

                _SectionLabel(label: 'Ordered Items'),
                _Section(
                  child: Column(
                    children: order.items
                        .map((item) => _ItemRow(item: item))
                        .toList(),
                  ),
                ),

                if (order.addOns.isNotEmpty) ...[
                  _SectionLabel(label: 'Add-ons'),
                  _Section(
                    child: Column(
                      children: order.addOns
                          .map((a) => _AddonRow(addOn: a))
                          .toList(),
                    ),
                  ),
                ],

                _SectionLabel(label: 'Order Summary'),
                _Section(
                  child: Column(
                    children: [
                      _SummaryRow(label: 'Subtotal', amount: order.subtotal),
                      _SummaryRow(label: 'SGST', amount: order.sgst),
                      _SummaryRow(label: 'CGST', amount: order.cgst),
                      _SummaryRow(label: 'Delivery', amount: order.deliveryFee),
                      _SummaryRow(
                        label: 'Platform Fee',
                        amount: order.platformFeeAmount,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Divider(color: catorders.border, height: 1),
                      ),
                      _SummaryRow(
                        label: 'Total',
                        amount: order.total,
                        bold: true,
                      ),
                    ],
                  ),
                ),

                if (order.paymentStatus.toLowerCase() == 'partially_paid' &&
                    order.amountRemaining > 0) ...[
                  SizedBox(height: 4.h),
                  _PendingPaymentCard(
                    amount: order.amountRemaining,
                    onPay: _payRemaining,
                  ),
                ],

                if (order.orderStatus == OrderStatus.delivered) ...[
                  SizedBox(height: 4.h),
                  _RatingSection(
                    order: order,
                    selectedRating: _selectedRating,
                    isSubmitting: _submittingRating,
                    onRate: (r) {
                      setState(() => _selectedRating = r);
                      _submitRating(r);
                    },
                  ),
                ],

                SizedBox(height: 4.h),
                GestureDetector(
                  onTap: _showHelp,
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.support_agent_outlined,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need Help?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Call, chat or report an issue',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
    );
  }
}

// ─── Detail Screen Sub-widgets ─────────────────────────────────────────────

class _Section extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;

  const _Section({required this.child, this.color, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color ?? catorders.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor ?? catorders.border),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h, left: 2.w),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: catorders.textMuted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DateChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: catorders.bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12.sp, color: catorders.textSecondary),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: catorders.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15.sp, color: catorders.primary),
          SizedBox(width: 8.w),
          SizedBox(
            width: 70.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: catorders.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp, color: catorders.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final CateringOrderItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.packageName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (item.packagePrice > 0)
                Text(
                  '₹${item.packagePrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: catorders.primary,
                  ),
                ),
            ],
          ),
          if (item.itemsName.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                '• ${item.itemsName}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: catorders.textSecondary,
                ),
              ),
            ),
          ...item.packageItems.map(
            (p) => Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                '• ${p.itemName}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: catorders.textSecondary,
                ),
              ),
            ),
          ),
          // ignore: unrelated_type_equality_checks
          if (item != (context.findAncestorWidgetOfExactType<_Section>()))
            Divider(height: 10.h, color: catorders.border),
        ],
      ),
    );
  }
}

class _AddonRow extends StatelessWidget {
  final CateringAddOn addOn;
  const _AddonRow({required this.addOn});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              addOn.addOnType.replaceAll('_', ' '),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            'Qty: ${addOn.quantity}',
            style: TextStyle(fontSize: 12.sp, color: catorders.textSecondary),
          ),
          SizedBox(width: 12.w),
          Text(
            '₹${addOn.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: catorders.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;
  const _SummaryRow({
    required this.label,
    required this.amount,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 15.sp : 13.sp,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold ? catorders.textPrimary : catorders.textSecondary,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: bold ? 15.sp : 13.sp,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: bold ? catorders.textPrimary : catorders.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingPaymentCard extends StatelessWidget {
  final double amount;
  final VoidCallback onPay;
  const _PendingPaymentCard({required this.amount, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: catorders.dangerLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: catorders.danger,
            size: 22.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Payment',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: catorders.danger,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '₹${amount.toStringAsFixed(2)} remaining',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onPay,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: catorders.danger,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Pay Now',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  final CateringOrder order;
  final int selectedRating;
  final bool isSubmitting;
  final ValueChanged<int> onRate;

  const _RatingSection({
    required this.order,
    required this.selectedRating,
    required this.isSubmitting,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final hasRating = order.rating > 0;

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: catorders.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: catorders.border),
      ),
      child: hasRating
          ? Column(
              children: [
                Text(
                  'Thank you for your rating!',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: catorders.primary,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return Icon(
                      i < order.rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: catorders.warning,
                      size: 30.sp,
                    );
                  }),
                ),
                SizedBox(height: 6.h),
                Text(
                  '${order.rating}/5 Stars',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: catorders.textSecondary,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How was your experience?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 14.h),
                if (isSubmitting)
                  Center(
                    child: CircularProgressIndicator(
                      color: catorders.warning,
                      strokeWidth: 2.5,
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => onRate(i + 1),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            i < selectedRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: catorders.warning,
                            size: 38.sp,
                          ),
                        ),
                      );
                    }),
                  ),
              ],
            ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: catorders.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: catorders.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: catorders.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: catorders.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
