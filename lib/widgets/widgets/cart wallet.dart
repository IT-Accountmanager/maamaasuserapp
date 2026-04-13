// ignore: file_names
// ignore: file_names
// ignore: file_names
// ignore: file_names
// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:shimmer/shimmer.dart';
import '../../Models/food/cart_model.dart';
import '../../Models/subscrptions/wallet_model.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/Auth_service/food_authservice.dart';
import '../../Services/paymentservice/razorpayservice.dart';

// ignore: camel_case_types
class cartwallet extends StatefulWidget {
  final Wallet? wallet; // add this
  final void Function(String paymentMethod, Set<String> subWallets)
  onSelectionChanged;

  const cartwallet({
    super.key,
    required this.onSelectionChanged,
    this.wallet, // add this
  });

  @override
  State<cartwallet> createState() => _cartwalletState();
}

// ignore: camel_case_types
class _cartwalletState extends State<cartwallet> {
  late TextEditingController _amountController; // ✅ declare it
  CartModel? cartData;
  bool isLoading = true;
  String selectedPaymentMethod = "";
  String? selectedSubWallet = "";
  Map<String, dynamic>? checkoutData;
  late ScrollController _scrollController;
  Set<String> selectedSubWallets = {};

  bool _isPaymentProcessing = false;
  String _loadingText = "Processing...";

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _amountController = TextEditingController(); // ✅ FIX
    _loadCart();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double getSelectedWalletBalance() {
    if (widget.wallet == null) return 0;

    double total = 0;

    if (selectedSubWallets.contains("Company Loaded")) {
      total += widget.wallet!.companyLoadedAmount;
    }

    if (selectedSubWallets.contains("Self Loaded")) {
      total += widget.wallet!.selfLoadedAmount;
    }

    if (selectedSubWallets.contains("Cashbacks")) {
      total += widget.wallet!.cashbackAmount;
    }

    if (selectedSubWallets.contains("Postpaid used amount")) {
      total += widget.wallet!.postPaidUsage;
    }

    return total;
  }

  Future<void> _loadCart() async {
    setState(() => isLoading = true);

    try {
      final fetchedCart = await food_Authservice.fetchCart();

      if (mounted) {
        setState(() {
          cartData = fetchedCart;

          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _notifyParent() {
    widget.onSelectionChanged(selectedPaymentMethod, selectedSubWallets);
  }

  void _showAmountBottomSheet(BuildContext parentContext) {
    final TextEditingController amountController = TextEditingController();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true, // ✅ REQUIRED
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            // ✅ IMPORTANT
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom + 20, // ✅ KEY FIX
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Enter Amount",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    hintText: "Enter amount to load",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final amount = double.tryParse(amountController.text);
                      if (amount == null || amount <= 0) return;

                      Navigator.pop(context);

                      /// ✅ START LOADER HERE
                      setState(() {
                        _isPaymentProcessing = true;
                        _loadingText = "Creating order...";
                      });

                      final orderId = await subscription_AuthService
                          .createOrder(amount);

                      if (orderId == null) {
                        setState(() {
                          _isPaymentProcessing = false;
                        });

                        AppAlert.error(context, "Failed to create order ❌");
                        return;
                      }

                      final razorpay = RazorpayService();

                      /// ✅ BEFORE OPENING RAZORPAY
                      setState(() {
                        _loadingText = "Opening payment gateway...";
                      });

                      razorpay.onSuccess = (response) async {
                        setState(() {
                          _loadingText = "Verifying payment...";
                        });

                        final paymentId = response.paymentId!;

                        final captured = await subscription_AuthService
                            .capturePayment(
                              paymentId: paymentId,
                              amount: amount,
                            );

                        if (captured) {
                          setState(() {
                            _loadingText = "Updating wallet...";
                          });

                          await subscription_AuthService.addCashToWallet(
                            paymentId: paymentId,
                            orderId: orderId,
                            amount: amount,
                          );

                          setState(() {
                            _isPaymentProcessing = false;
                          });

                          if (!mounted) return;

                          AppAlert.success(
                            parentContext,
                            "Wallet recharged 🎉",
                          );
                        } else {
                          setState(() {
                            _isPaymentProcessing = false;
                          });

                          AppAlert.error(parentContext, "Capture failed ❌");
                        }
                      };

                      razorpay.onError = (response) {
                        setState(() {
                          _isPaymentProcessing = false;
                        });

                        AppAlert.error(
                          context,
                          "Payment Failed: ${response.message}",
                        );
                      };

                      razorpay.startPayment(
                        orderId: orderId,
                        amount: amount,
                        // name: "Wallet Topup",
                        description: "Wallet recharge",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment_rounded, size: 22),
                        SizedBox(width: 10),
                        Text(
                          "Proceed to Pay",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: _buildPaymentSection(theme, colorScheme),
          ),
        ),

        /// ✅ Overlay on top
        _buildOverlay(),
      ],
    );
  }

  Widget _buildOverlay() {
    if (!_isPaymentProcessing) return const SizedBox();

    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              _loadingText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection(ThemeData theme, ColorScheme colorScheme) {
    if (cartData == null || isLoading) {
      return _paymentSkeleton();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _buildPaymentOption(
              "Maamaas_Wallet",
              Icons.account_balance_wallet_outlined,
              "Maamaas_Wallet",
              theme,
              colorScheme,
            ),
            if (selectedPaymentMethod == "Maamaas_Wallet" &&
                widget.wallet != null) ...[
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.only(left: 32.w),
                child: Column(
                  children: [
                    _buildSubWalletOption(
                      "Company Loaded",
                      widget.wallet!.companyLoadedAmount,
                      theme,
                      colorScheme,
                    ),
                    _buildSubWalletselfloadedOption(
                      "Self Loaded",
                      widget.wallet!.selfLoadedAmount,
                      theme,
                      colorScheme,
                      onAdd: () {
                        debugPrint("Add Self Loaded Amount");

                        _showAmountBottomSheet(context);
                      },
                    ),
                    _buildSubWalletOption(
                      "Cashbacks",
                      widget.wallet!.cashbackAmount,
                      theme,
                      colorScheme,
                    ),
                    if ((cartData?.userCompany ?? '').isNotEmpty)
                      _buildSubWalletOption(
                        "Postpaid used amount",
                        widget.wallet!.postPaidUsage,
                        theme,
                        colorScheme,
                      ),
                  ],
                ),
              ),
            ],
            _buildPaymentOption(
              "Online Payment",
              Icons.credit_card_outlined,
              "Online_Payment",
              theme,
              colorScheme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    String title,
    IconData icon,
    String value,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isSelected = selectedPaymentMethod == value;
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      // ignore: deprecated_member_use
      color: isSelected ? colorScheme.primary.withOpacity(0.05) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          setState(() {
            selectedPaymentMethod = value;
            if (value != "Maamaas_Wallet") {
              selectedSubWallets.clear();
            }
          });
          _notifyParent(); // 🔥 send to cart

          if (value == "Maamaas_Wallet" && selectedSubWallets.isEmpty) {
            AppAlert.error(context, "Please select at least one sub wallet");
          }

          // Scroll after the UI updates
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
            }
          });
        },

        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? colorScheme.primary : Colors.grey[600],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.replaceAll('_', ' '),
                      style: theme.textTheme.titleMedium,
                    ),
                    if (value == "Maamaas_Wallet")
                      Container(
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: widget.wallet != null
                              ? Text(
                                  "₹${widget.wallet!.totalBalance.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? colorScheme.primary
                                        : Colors.grey[700],
                                  ),
                                )
                              : Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    height: 16,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubWalletselfloadedOption(
    String title,
    double amount,
    ThemeData theme,
    ColorScheme colorScheme, {
    required VoidCallback onAdd,
  }) {
    final isSelected = selectedSubWallets.contains(title);

    return Material(
      color: isSelected
          // ignore: deprecated_member_use
          ? colorScheme.primary.withOpacity(0.05)
          : Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          setState(() {
            isSelected
                ? selectedSubWallets.remove(title)
                : selectedSubWallets.add(title);
          });
          _notifyParent();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ☑ Checkbox
              Checkbox(
                value: isSelected,
                activeColor: colorScheme.primary,
                onChanged: (val) {
                  setState(() {
                    val!
                        ? selectedSubWallets.add(title)
                        : selectedSubWallets.remove(title);
                  });
                  _notifyParent();
                },
              ),

              // 👉 Content section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Title + Amount in same row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: theme.textTheme.bodyMedium),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            "₹${amount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? colorScheme.primary
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 🔹 Add button below
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: onAdd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Add"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubWalletOption(
    String title,
    double amount,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isSelected = selectedSubWallets.contains(title);

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      // ignore: deprecated_member_use
      color: isSelected ? colorScheme.primary.withOpacity(0.05) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: () {
          setState(() {
            isSelected
                ? selectedSubWallets.remove(title)
                : selectedSubWallets.add(title);
          });

          _notifyParent();
        },
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // ✅ Checkbox (NOT CheckboxListTile)
              Checkbox(
                value: isSelected,
                activeColor: colorScheme.primary,
                onChanged: (val) {
                  setState(() {
                    val!
                        ? selectedSubWallets.add(title)
                        : selectedSubWallets.remove(title);
                  });

                  _notifyParent();
                },
              ),

              // Title
              Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),

              // Amount
              Container(
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: const EdgeInsets.all(8),
                child: Text(
                  "₹${amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? colorScheme.primary : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _paymentSkeleton() {
  return Column(
    children: List.generate(
      3,
      (_) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    ),
  );
}
