import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Models/caterings/catering_enquiry_model.dart';
import '../../../../Models/caterings/vendor_quotation_model.dart';
import '../../../../Services/Auth_service/catering_authservice.dart';
import '../../../../Services/paymentservice/razorpayservice.dart';
import 'Enquiry_helper.dart';

class EnquiryCard extends StatefulWidget {
  final CateringEnquiry enquiry;
  const EnquiryCard({super.key, required this.enquiry});

  @override
  State<EnquiryCard> createState() => _EnquiryCardState();
}

class _EnquiryCardState extends State<EnquiryCard> {
  String get leadId => widget.enquiry.id.toString();

  @override
  Widget build(BuildContext context) {
    final enquiry = widget.enquiry;
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
          borderRadius: BorderRadius.circular(20),

          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EnquiryDetailsScreen(enquiry: enquiry),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[400]!, Colors.blue[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ENQ#${enquiry.id}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EnquiryDetailsScreen(enquiry: enquiry),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize
                                .min, // 👈 important to avoid stretching
                            children: [
                              Text(
                                enquiry.eventType,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.keyboard_arrow_right,
                                size: 18.w,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildInfoItem(
                        Icons.calendar_today_outlined,
                        enquiry.eventDate,
                      ),
                      SizedBox(width: 16.w),
                      _buildInfoItem(
                        Icons.access_time_outlined,
                        enquiry.eventTime,
                      ),
                    ],
                  ),
                ],
              ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Enquiry #${widget.enquiry.id}"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
        shape: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildDetailCard(
              icon: Icons.person_outline,
              iconColor: Colors.purple,
              children: [
                _buildDetailRow(
                  "Full Name",
                  widget.enquiry.fullName.toUpperCase(),
                ),
                _buildDetailRow("Email", widget.enquiry.email),
                _buildDetailRow("Phone", widget.enquiry.phoneNumber),

                _buildDetailRow("Event Type", widget.enquiry.eventType),
                _buildDetailRow(
                  "Event Date",
                  Enquiry_helpers.formatDate(widget.enquiry.eventDate),
                ),
                _buildDetailRow(
                  "Event Time",
                  Enquiry_helpers.formatTime(widget.enquiry.eventTime),
                ),

                _buildDetailRow("Address", widget.enquiry.fullAddress),
                _buildDetailRow(
                  "City",
                  Enquiry_helpers.capitalizeFirst(widget.enquiry.city),
                ),
                _buildDetailRow(
                  "State",
                  Enquiry_helpers.capitalizeFirst(widget.enquiry.state),
                ),
                _buildDetailRow(
                  "Country",
                  Enquiry_helpers.capitalizeFirst(widget.enquiry.country),
                ),
                SizedBox(height: 10),

                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    if (widget.enquiry.vegPlates > 0)
                      _buildPlateCount(
                        'Veg',
                        widget.enquiry.vegPlates,
                        Colors.green,
                      ),
                    if (widget.enquiry.nonVegPlates > 0)
                      _buildPlateCount(
                        'Non-Veg',
                        widget.enquiry.nonVegPlates,
                        Colors.red,
                      ),
                    if (widget.enquiry.mixedPlates > 0)
                      _buildPlateCount(
                        'Mixed',
                        widget.enquiry.mixedPlates,
                        Colors.orange,
                      ),
                  ],
                ),
              ],
            ),

            if (widget.enquiry.items.isNotEmpty)
              _buildItemsCard(widget.enquiry.items),
            SizedBox(height: 10),

            _buildAddOnsCard(widget.enquiry.addOns),

            VendorQuotationContent(
              leadId: leadId,
              items: widget.enquiry.flattenedItems,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlateCount(String type, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            '$type: $count',
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnsCard(List<AddOn> addOns) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.add_circle_outline, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Add-ons",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ If no add-ons selected
            if (addOns.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "No add-ons selected.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...addOns.map((addOn) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          addOn.addOnType.replaceAll('_', ' '),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        "Qty: ${addOn.quantity}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(Map<String, List<String>> items) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.list_alt_outlined, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Requested Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ If no items selected
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "You have not chosen any items.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              // 🔹 Loop categories
              ...items.entries.map((entry) {
                final category = entry.key;
                final categoryItems = entry.value;

                // Initialize default state
                expandedCategories.putIfAbsent(category, () => false);

                final isExpanded = expandedCategories[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Clickable Category Header
                    InkWell(
                      onTap: () {
                        setState(() {
                          expandedCategories[category] = !isExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6, top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),

                            // 🔸 Animated Arrow
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 🔹 Expandable Items
                    AnimatedCrossFade(
                      firstChild: const SizedBox(),
                      secondChild: Column(
                        children: categoryItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  // 🔹 Helper: Builds a section card
  Widget _buildDetailCard({
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...children],
        ),
      ),
    );
  }

  // 🔹 Helper: Builds a single detail row
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

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
  bool isPrepaid = true;
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
  void dispose() {
    super.dispose();
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

      if (userId == null) {
        throw Exception('User not found');
      }

      setState(() => isLoading = true);

      final success = await catering_authservice.recordPayment(
        quotationId: quotation.quotationId,
        leadId: quotation.leadId,
        userId: userId,
        amount: _paymentAmount,
        // paymentType: paymentTypeToEnum(paymentType),
        paymentType: Enquiry_helpers.paymentTypeToEnum(paymentType),
        paymentMethod: paymentMethod,
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
      );

      if (success) {
        setState(() {
          _paymentCompleted = true;
        });

        AppAlert.success(context, "Payment recorded successfully");
      }
    } catch (e) {
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
      // 1️⃣ Create Razorpay order via backend
      final orderId = await catering_authservice.createOrder(amount);
      if (orderId == null) throw Exception("Failed to create order");

      final razorpay = RazorpayService();

      // 2️⃣ Register success callback
      razorpay.onSuccess = (PaymentSuccessResponse response) async {
        debugPrint("✅ Payment Success: ${response.paymentId}");

        try {
          // 2a️⃣ Capture payment via API
          final captured = await catering_authservice.capturePayment(
            paymentId: response.paymentId!,
            amount: _paymentAmount,
          );
          debugPrint("💰 Capture status: $captured");

          // 2b️⃣ Record payment in backend
          await _recordPayment(
            _selectedPaymentType ?? "full",
            'Online_Payment',
            razorpayPaymentId: response.paymentId,
            razorpayOrderId: response.orderId,
          );

          // 2c️⃣ Update UI
          if (mounted) {
            setState(() {
              _paymentCompleted = true;
            });
          }
        } catch (e) {
          debugPrint("❌ Payment capture/record failed: $e");
          AppAlert.error(context, "Payment completed but recording failed.");
        } finally {
          setState(() => isLoading = false);
        }
      };

      // 3️⃣ Error callback
      razorpay.onError = (PaymentFailureResponse response) {
        debugPrint("❌ Payment Failed: ${response.message}");
        AppAlert.error(context, "Payment Failed: ${response.message}");
        setState(() => isLoading = false);
      };

      razorpay.onExternalWallet = (ExternalWalletResponse response) {
        debugPrint("👛 External Wallet: ${response.walletName}");
        AppAlert.info(context, "External Wallet: ${response.walletName}");
      };

      // 4️⃣ Start Razorpay checkout
      razorpay.startPayment(
        orderId: orderId,
        amount: amount,
        description: "Online Payment via Razorpay",
      );
    } catch (e) {
      debugPrint("❌ Error in _confirmOrder: $e");
      AppAlert.error(context, "Failed to initiate payment: $e");
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

  Widget _buildQuotationCard(VendorQuotation quotation) {
    return Card(
      color: Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  quotation.vendorName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (quotation.status.toUpperCase() != "SUBMITTED")
                  Chip(
                    label: Text(
                      quotation.status.toUpperCase(),
                      style: TextStyle(
                        color: Enquiry_helpers.getStatusColor(quotation.status),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Enquiry_helpers.getStatusColor(
                      quotation.status,
                    ).withOpacity(0.1),
                    avatar: Icon(
                      Enquiry_helpers.getStatusIcon(quotation.status),
                      size: 14,
                      color: Enquiry_helpers.getStatusColor(quotation.status),
                    ),
                  ),
              ],
            ),
            _buildKeyValue('Total Plates', quotation.totalPlates),
            _buildKeyValue('Veg / Plate', quotation.vegPerPlatePrice),
            _buildKeyValue('Non-Veg / Plate', quotation.nonVegPerPlatePrice),

            if (quotation.addOnPrices.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                "Add-Ons",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ...quotation.addOnPrices.map((addOn) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${Enquiry_helpers.formatAddOnType(addOn.addOnType)} ",
                          // "(x${addOn.quantity})",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        "₹${addOn.totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 16),

            // ✅ Highlighted Total Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange, width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Quoted Amount",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₹${quotation.quotedAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            if (quotation.status.toUpperCase() == "SELECTED" &&
                !_paymentCompleted) ...[
              Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(
                    backgroundColor: Colors.white,
                    label: Text(
                      "Pay Advance (₹${quotation.partialAmount.toStringAsFixed(1)})",
                    ),
                    selected: _selectedPaymentType == "partial",
                    selectedColor: Colors.orange.shade200,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPaymentType = "partial"; // internal value
                        _paymentAmount = quotation.partialAmount;
                      });
                    },
                  ),

                  ChoiceChip(
                    label: Text(
                      "Pay Full (₹${quotation.grandTotal.toStringAsFixed(1)})",
                    ),
                    selected: _selectedPaymentType == "full",
                    selectedColor: Colors.green.shade200,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPaymentType = "full"; // internal value
                        _paymentAmount = quotation.grandTotal;
                      });
                    },
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (quotation.status.toUpperCase() == "SELECTED" &&
                    !_paymentCompleted)
                  OutlinedButton(
                    onPressed: () {
                      _showQuotationDetailsBottomSheet(context, quotation);
                    },
                    child: const Text(
                      "View Price Breakdown",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),

                if (quotation.status.toUpperCase() == "SUBMITTED")
                  ElevatedButton(
                    onPressed: () async {
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
                          AppAlert.success(
                            context,
                            'Quotation accepted successfully',
                          );
                        }
                      } catch (e) {
                        AppAlert.error(context, e.toString());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),

                    child: const Text('Accept'),
                  ),

                // ✅ PAY NOW button → only for SELECTED
                if (quotation.status.toUpperCase() == "SELECTED" &&
                    !_paymentCompleted)
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedPaymentType == null) {
                        AppAlert.error(context, "Please select payment type");
                        return;
                      }

                      _confirmOrder(quotation, _paymentAmount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Pay Now'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showQuotationDetailsBottomSheet(
    BuildContext context,
    VendorQuotation quotation,
  ) {
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
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Drag Indicator
                Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const Text(
                  "Quotation Price Breakdown",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                _buildDetailRow("Quoted Amount", quotation.quotedAmount),
                _buildDetailRow("CGST", quotation.cgstAmount),
                _buildDetailRow("SGST", quotation.sgstAmount),
                _buildDetailRow("Platform Fee", quotation.platformFee),
                _buildDetailRow("Delivery Fee", quotation.deliveryFee),

                const Divider(height: 30),

                _buildDetailRow("Grand Total", total, isBold: true),

                const SizedBox(height: 20),

                /// Pay Now Button
                Row(
                  children: [
                    if (quotation.status.toUpperCase() == "SELECTED") ...[
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _confirmOrder(quotation, _paymentAmount);
                          },
                          child: const Text(
                            "Pay Now",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12), // ✅ correct spacing
                    ],

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
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

  Widget _buildDetailRow(String title, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyValue(String label, num value) {
    String displayValue;

    // Only show currency for Veg / Plate and Non-Veg / Plate
    if (label.contains("Veg / Plate") || label.contains("Non-Veg / Plate")) {
      displayValue = "₹${value.toStringAsFixed(2)}";
    } else {
      displayValue = value is double
          ? value.toStringAsFixed(2)
          : value.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            displayValue,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0), // matches outer screen padding
      child: isLoading || errorMessage != null || quotations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No Vendor Quotations',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You don\'t have any vendor quotations yet',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ) // icons, text etc inside column
          : RefreshIndicator(
              onRefresh: _loadQuotations,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Vendor Quotations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Column(
                    children: quotations
                        .map((q) => _buildQuotationCard(q))
                        .toList(),
                  ),
                ],
              ),
            ),
    );
  }
}
