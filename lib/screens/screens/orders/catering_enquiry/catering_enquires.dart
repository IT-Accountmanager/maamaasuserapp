import '../../../../Services/Auth_service/catering_authservice.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import '../../../../Models/caterings/catering_enquiry_model.dart';
import '../../../../Models/caterings/vendor_quotation_model.dart';
import '../../../../Services/paymentservice/razorpayservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../widgets/datetimehelper.dart';
import 'package:flutter/material.dart';
import 'Enquiry_helper.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
class catenquiycolour {
  static const primary = Color(0xFF1A56DB);
  static const primaryLight = Color(0xFFEEF2FF);
  static const accent = Color(0xFFF97316);
  static const accentLight = Color(0xFFFFF7ED);
  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFFF0FDF4);
  static const error = Color(0xFFDC2626);
  static const errorLight = Color(0xFFFEF2F2);
  static const surface = Color(0xFFF8FAFC);
  static const card = Colors.white;
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);
  static const border = Color(0xFFE2E8F0);
}

class _AppText {
  static const TextStyle h2 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: catenquiycolour.textPrimary,
    letterSpacing: -0.2,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: catenquiycolour.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: catenquiycolour.textSecondary,
    height: 1.5,
  );
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: catenquiycolour.textSecondary,
    letterSpacing: 0.1,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: catenquiycolour.textSecondary,
    letterSpacing: 0.2,
  );
}

// ─── Enquiry Card ──────────────────────────────────────────────────────────────
class EnquiryCard extends StatefulWidget {
  final CateringEnquiry enquiry;
  const EnquiryCard({super.key, required this.enquiry});

  @override
  State<EnquiryCard> createState() => _EnquiryCardState();
}

class _EnquiryCardState extends State<EnquiryCard> {
  @override
  Widget build(BuildContext context) {
    final enquiry = widget.enquiry;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EnquiryDetailsScreen(enquiry: enquiry),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: catenquiycolour.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: catenquiycolour.border, width: 1),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              // Left accent bar
              Container(
                width: 4.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: catenquiycolour.primary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ENQ #${enquiry.id}', style: _AppText.h3),
                        _EventTypeBadge(label: enquiry.eventType),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _IconLabel(
                          icon: Icons.calendar_today_rounded,
                          text: DateTimeHelper.formatDateString(
                            enquiry.eventDate,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        _IconLabel(
                          icon: Icons.schedule_rounded,
                          text: DateTimeHelper.to12Hour(enquiry.eventTime),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: catenquiycolour.textSecondary,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Enquiry Details Screen ────────────────────────────────────────────────────
class EnquiryDetailsScreen extends StatefulWidget {
  final CateringEnquiry enquiry;
  const EnquiryDetailsScreen({super.key, required this.enquiry});

  @override
  State<EnquiryDetailsScreen> createState() => _EnquiryDetailsScreenState();
}

class _EnquiryDetailsScreenState extends State<EnquiryDetailsScreen> {
  late String leadId;
  Map<String, bool> expandedCategories = {};

  @override
  void initState() {
    super.initState();
    leadId = widget.enquiry.id.toString();
  }

  @override
  Widget build(BuildContext context) {
    final enquiry = widget.enquiry;

    return Scaffold(
      backgroundColor: catenquiycolour.surface,
      appBar: _ModernAppBar(title: 'Enquiry #${enquiry.id}'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            // ── Contact & Event Info ──
            _SectionCard(
              title: 'Event Details',
              icon: Icons.event_rounded,
              iconColor: catenquiycolour.primary,
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Full Name',
                    value: enquiry.fullName.toUpperCase(),
                  ),
                  _InfoRow(label: 'Email', value: enquiry.email),
                  _InfoRow(label: 'Phone', value: enquiry.phoneNumber),
                  _Divider(),
                  _InfoRow(label: 'Event Type', value: enquiry.eventType),
                  _InfoRow(
                    label: 'Event Date',
                    value: Enquiry_helpers.formatDate(enquiry.eventDate),
                  ),
                  _InfoRow(
                    label: 'Event Time',
                    value: DateTimeHelper.to12Hour(enquiry.eventTime),
                  ),
                  _Divider(),
                  _InfoRow(label: 'Address', value: enquiry.fullAddress),
                  _InfoRow(
                    label: 'City',
                    value: Enquiry_helpers.capitalizeFirst(enquiry.city),
                  ),
                  _InfoRow(
                    label: 'State',
                    value: Enquiry_helpers.capitalizeFirst(enquiry.state),
                  ),
                  _InfoRow(
                    label: 'Country',
                    value: Enquiry_helpers.capitalizeFirst(enquiry.country),
                  ),
                  SizedBox(height: 12.h),
                  // Plate Counts
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      if (enquiry.vegPlates > 0)
                        _PlateBadge(
                          type: 'Veg',
                          count: enquiry.vegPlates,
                          color: catenquiycolour.success,
                        ),
                      if (enquiry.nonVegPlates > 0)
                        _PlateBadge(
                          type: 'Non-Veg',
                          count: enquiry.nonVegPlates,
                          color: catenquiycolour.error,
                        ),
                      if (enquiry.mixedPlates > 0)
                        _PlateBadge(
                          type: 'Mixed',
                          count: enquiry.mixedPlates,
                          color: catenquiycolour.accent,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // ── Requested Items ──
            if (enquiry.items.isNotEmpty) ...[
              _ItemsCard(
                items: enquiry.items,
                expandedCategories: expandedCategories,
                onToggle: (cat) {
                  setState(() {
                    expandedCategories[cat] =
                        !(expandedCategories[cat] ?? false);
                  });
                },
              ),
              SizedBox(height: 12.h),
            ],

            // ── Add-Ons ──
            _AddOnsCard(addOns: enquiry.addOns),

            SizedBox(height: 12.h),

            // ── Vendor Quotations ──
            VendorQuotationContent(
              leadId: leadId,
              items: enquiry.flattenedItems,
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

// ─── Items Card ────────────────────────────────────────────────────────────────
class _ItemsCard extends StatelessWidget {
  final Map<String, List<String>> items;
  final Map<String, bool> expandedCategories;
  final void Function(String) onToggle;

  const _ItemsCard({
    required this.items,
    required this.expandedCategories,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Requested Items',
      icon: Icons.restaurant_menu_rounded,
      iconColor: catenquiycolour.accent,
      child: items.isEmpty
          ? _EmptyHint(text: 'No items selected.')
          : Column(
              children: items.entries.map((entry) {
                final category = entry.key;
                final categoryItems = entry.value;
                final isExpanded = expandedCategories[category] ?? false;

                return Column(
                  children: [
                    InkWell(
                      onTap: () => onToggle(category),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category,
                              style: _AppText.h3.copyWith(
                                color: catenquiycolour.primary,
                              ),
                            ),
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: catenquiycolour.primary,
                                size: 20.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        children: categoryItems.map((item) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 16.sp,
                                  color: catenquiycolour.success,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(item, style: _AppText.body),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 250),
                    ),
                    if (entry.key != items.keys.last) _Divider(),
                  ],
                );
              }).toList(),
            ),
    );
  }
}

// ─── Add-Ons Card ──────────────────────────────────────────────────────────────
class _AddOnsCard extends StatelessWidget {
  final List<AddOn> addOns;
  const _AddOnsCard({required this.addOns});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Add-ons',
      icon: Icons.add_circle_rounded,
      iconColor: catenquiycolour.success,
      child: addOns.isEmpty
          ? _EmptyHint(text: 'No add-ons selected.')
          : Column(
              children: addOns.map((addOn) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: catenquiycolour.surface,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: catenquiycolour.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            addOn.addOnType.replaceAll('_', ' '),
                            style: _AppText.body.copyWith(
                              color: catenquiycolour.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: catenquiycolour.primaryLight,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Qty: ${addOn.quantity}',
                            style: _AppText.caption.copyWith(
                              color: catenquiycolour.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

// ─── Vendor Quotation Content ─────────────────────────────────────────────────
class VendorQuotationContent extends StatefulWidget {
  final String leadId;
  final List<String> items;

  const VendorQuotationContent({
    super.key,
    required this.leadId,
    required this.items,
  });

  @override
  State<VendorQuotationContent> createState() => _VendorQuotationContentState();
}

class _VendorQuotationContentState extends State<VendorQuotationContent> {
  List<VendorQuotation> quotations = [];
  bool isLoading = false;
  bool _paymentCompleted = false;
  VendorQuotation? _selectedQuotation;
  String? errorMessage;
  String? _selectedPaymentType;
  double _paymentAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadQuotations();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _LoadingState();
    }

    if (errorMessage != null || quotations.isEmpty) {
      return const _EmptyQuotationsState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vendor Quotations', style: _AppText.h2),
        SizedBox(height: 12.h),
        RefreshIndicator(
          onRefresh: _loadQuotations,
          child: Column(
            children: quotations.map((q) => _buildQuotationCard(q)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuotationCard(VendorQuotation quotation) {
    final isSelected = quotation.status.toUpperCase() == 'SELECTED';
    final isSubmitted = quotation.status.toUpperCase() == 'SUBMITTED';
    final showPayment = isSelected && !_paymentCompleted;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: catenquiycolour.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: catenquiycolour.border),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(quotation.vendorName, style: _AppText.h2)),
                if (!isSubmitted) _StatusBadge(status: quotation.status),
              ],
            ),

            SizedBox(height: 14.h),

            // ── Plate Info ──
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: catenquiycolour.surface,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: catenquiycolour.border),
              ),
              child: Column(
                children: [
                  _AmountRow(
                    label: 'Total Plates',
                    value: quotation.totalPlates.toString(),
                  ),
                  SizedBox(height: 6.h),
                  _AmountRow(
                    label: 'Veg / Plate',
                    value: '₹${quotation.vegPerPlatePrice.toStringAsFixed(2)}',
                  ),
                  SizedBox(height: 6.h),
                  _AmountRow(
                    label: 'Non-Veg / Plate',
                    value:
                        '₹${quotation.nonVegPerPlatePrice.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),

            // ── Add-Ons ──
            if (quotation.addOnPrices.isNotEmpty) ...[
              SizedBox(height: 14.h),
              Text('Add-Ons', style: _AppText.h3),
              SizedBox(height: 8.h),
              ...quotation.addOnPrices.map((addOn) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: _AmountRow(
                    label: Enquiry_helpers.formatAddOnType(addOn.addOnType),
                    value: '₹${addOn.totalAmount.toStringAsFixed(2)}',
                  ),
                );
              }),
            ],

            SizedBox(height: 14.h),

            // ── Quoted Amount Highlight ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: catenquiycolour.accentLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: catenquiycolour.accent.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quoted Amount', style: _AppText.h3),
                  Text(
                    '₹${quotation.quotedAmount.toStringAsFixed(2)}',
                    style: _AppText.h2.copyWith(color: catenquiycolour.accent),
                  ),
                ],
              ),
            ),

            // ── Payment Options ──
            if (showPayment) ...[
              SizedBox(height: 14.h),
              Text('Select Payment', style: _AppText.h3),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: _PaymentOption(
                      label: 'Advance',
                      amount: quotation.partialAmount,
                      isSelected: _selectedPaymentType == 'partial',
                      color: catenquiycolour.accent,
                      onTap: () => setState(() {
                        _selectedPaymentType = 'partial';
                        _paymentAmount = quotation.partialAmount;
                      }),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _PaymentOption(
                      label: 'Full Pay',
                      amount: quotation.grandTotal,
                      isSelected: _selectedPaymentType == 'full',
                      color: catenquiycolour.success,
                      onTap: () => setState(() {
                        _selectedPaymentType = 'full';
                        _paymentAmount = quotation.grandTotal;
                      }),
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 14.h),

            // ── Actions ──
            Row(
              children: [
                if (showPayment) ...[
                  Expanded(
                    child: _OutlineButton(
                      label: 'Price Breakdown',
                      onTap: () => _showPriceBreakdown(context, quotation),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _PrimaryButton(
                      label: 'Pay Now',
                      color: catenquiycolour.primary,
                      onTap: () {
                        if (_selectedPaymentType == null) {
                          AppAlert.error(
                            context,
                            'Please select a payment type',
                          );
                          return;
                        }
                        _confirmOrder(quotation, _paymentAmount);
                      },
                    ),
                  ),
                ],
                if (isSubmitted)
                  Expanded(
                    child: _PrimaryButton(
                      label: 'Accept Quotation',
                      color: catenquiycolour.success,
                      onTap: () async {
                        try {
                          final success = await catering_authservice
                              .selectQuotation(quotation.quotationId);
                          if (success) {
                            setState(() {
                              quotations = quotations.map((q) {
                                if (q.quotationId == quotation.quotationId) {
                                  return q.copyWith(status: 'selected');
                                }
                                return q;
                              }).toList();
                            });
                            // ignore: use_build_context_synchronously
                            AppAlert.success(
                              context,
                              'Quotation accepted successfully',
                            );
                          }
                        } catch (e) {
                          // ignore: use_build_context_synchronously
                          AppAlert.error(context, e.toString());
                        }
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceBreakdown(BuildContext context, VendorQuotation quotation) {
    final double total =
        quotation.quotedAmount +
        quotation.cgstAmount +
        quotation.sgstAmount +
        quotation.platformFee +
        quotation.deliveryFee;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
          decoration: BoxDecoration(
            color: catenquiycolour.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  height: 4.h,
                  width: 40.w,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: catenquiycolour.divider,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                Text('Price Breakdown', style: _AppText.h2),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: catenquiycolour.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: catenquiycolour.border),
                  ),
                  child: Column(
                    children: [
                      _BreakdownRow(
                        label: 'Quoted Amount',
                        amount: quotation.quotedAmount,
                      ),
                      _BreakdownRow(
                        label: 'CGST',
                        amount: quotation.cgstAmount,
                      ),
                      _BreakdownRow(
                        label: 'SGST',
                        amount: quotation.sgstAmount,
                      ),
                      _BreakdownRow(
                        label: 'Platform Fee',
                        amount: quotation.platformFee,
                      ),
                      _BreakdownRow(
                        label: 'Delivery Fee',
                        amount: quotation.deliveryFee,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: const Divider(color: catenquiycolour.divider),
                      ),
                      _BreakdownRow(
                        label: 'Grand Total',
                        amount: total,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    if (quotation.status.toUpperCase() == 'SELECTED') ...[
                      Expanded(
                        child: _PrimaryButton(
                          label: 'Pay Now',
                          color: catenquiycolour.primary,
                          onTap: () {
                            Navigator.pop(context);
                            _confirmOrder(quotation, _paymentAmount);
                          },
                        ),
                      ),
                      SizedBox(width: 10.w),
                    ],
                    Expanded(
                      child: _OutlineButton(
                        label: 'Close',
                        onTap: () => Navigator.pop(context),
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
      final quotation = _selectedQuotation!;

      if (userId == null) throw Exception('User not found');

      setState(() => isLoading = true);

      final success = await catering_authservice.recordPayment(
        quotationId: quotation.quotationId,
        leadId: quotation.leadId,
        userId: userId,
        amount: _paymentAmount,
        paymentType: Enquiry_helpers.paymentTypeToEnum(paymentType),
        paymentMethod: paymentMethod,
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
      );

      if (success) {
        setState(() => _paymentCompleted = true);
        // ignore: use_build_context_synchronously
        AppAlert.success(context, 'Payment recorded successfully');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      AppAlert.error(context, e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _confirmOrder(VendorQuotation quotation, double amount) async {
    setState(() {
      isLoading = true;
      _selectedQuotation = quotation;
    });

    try {
      final orderId = await catering_authservice.createOrder(amount);
      if (orderId == null) throw Exception('Failed to create order');

      final razorpay = RazorpayService();

      razorpay.onSuccess = (PaymentSuccessResponse response) async {
        try {
          final captured = await catering_authservice.capturePayment(
            paymentId: response.paymentId!,
            amount: _paymentAmount,
          );
          //           debugPrint('Capture status: $captured');

          await _recordPayment(
            _selectedPaymentType ?? 'full',
            'Online_Payment',
            razorpayPaymentId: response.paymentId,
            razorpayOrderId: response.orderId,
          );

          if (mounted) setState(() => _paymentCompleted = true);
        } catch (e) {
          // ignore: use_build_context_synchronously
          AppAlert.error(context, 'Payment completed but recording failed.');
        } finally {
          setState(() => isLoading = false);
        }
      };

      razorpay.onError = (PaymentFailureResponse response) {
        AppAlert.error(context, 'Payment Failed: ${response.message}');
        setState(() => isLoading = false);
      };

      razorpay.onExternalWallet = (ExternalWalletResponse response) {
        AppAlert.info(context, 'External Wallet: ${response.walletName}');
      };

      razorpay.startPayment(
        orderId: orderId,
        amount: amount,
        description: 'Online Payment via Razorpay',
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      AppAlert.error(context, 'Failed to initiate payment: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadQuotations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await catering_authservice.loadQuotations(
        leadId: widget.leadId,
      );
      setState(() {
        quotations = result.reversed.toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }
}

// ─── Reusable Small Widgets ───────────────────────────────────────────────────

class _ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _ModernAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: catenquiycolour.card,
      elevation: 0,
      centerTitle: true,
      title: Text(title, style: _AppText.h2),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: catenquiycolour.textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: catenquiycolour.border),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: catenquiycolour.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: catenquiycolour.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, size: 16.sp, color: iconColor),
                ),
                SizedBox(width: 8.w),
                Text(title, style: _AppText.h3),
              ],
            ),
            SizedBox(height: 14.h),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  const _InfoRow({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(label, style: _AppText.label),
          ),
          Expanded(
            child: Text(
              value ?? '–',
              style: _AppText.body.copyWith(color: catenquiycolour.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  const _AmountRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: _AppText.label),
        Text(value, style: _AppText.h3),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;
  const _BreakdownRow({
    required this.label,
    required this.amount,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? _AppText.h3
        : _AppText.body.copyWith(color: catenquiycolour.textPrimary);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('₹${amount.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IconLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13.sp, color: catenquiycolour.textSecondary),
        SizedBox(width: 4.w),
        Text(text, style: _AppText.caption),
      ],
    );
  }
}

class _EventTypeBadge extends StatelessWidget {
  final String label;
  const _EventTypeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: catenquiycolour.primaryLight,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: _AppText.caption.copyWith(
          color: catenquiycolour.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = Enquiry_helpers.getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Enquiry_helpers.getStatusIcon(status),
            size: 12.sp,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            status.toUpperCase(),
            style: _AppText.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlateBadge extends StatelessWidget {
  final String type;
  final int count;
  final Color color;
  const _PlateBadge({
    required this.type,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 5.w),
          Text(
            '$type: $count',
            style: _AppText.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final double amount;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.label,
    required this.amount,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : catenquiycolour.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? color : catenquiycolour.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : catenquiycolour.textSecondary,
                      width: isSelected ? 4 : 1.5,
                    ),
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: _AppText.label.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              '₹${amount.toStringAsFixed(1)}',
              style: _AppText.h3.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: catenquiycolour.border, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: catenquiycolour.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: const Divider(color: catenquiycolour.divider, height: 1),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Text(
        text,
        style: _AppText.body.copyWith(fontStyle: FontStyle.italic),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyQuotationsState extends StatelessWidget {
  const _EmptyQuotationsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: catenquiycolour.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: catenquiycolour.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 48.sp,
            color: catenquiycolour.divider,
          ),
          SizedBox(height: 12.h),
          Text('No Quotations Yet', style: _AppText.h3),
          SizedBox(height: 6.h),
          Text(
            'Vendor quotations will appear here',
            style: _AppText.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
