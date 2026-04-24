import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:maamaas/widgets/datetimehelper.dart';
import '../../Models/subscrptions/transaction_model.dart';
import '../../Models/subscrptions/wallet_model.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/paymentservice/razorpayservice.dart';
import '../skeleton/walletSkelton.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
class Walletcolour {
  static const bg = Color(0xFFF5F6FA);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE8ECF4);

  static const violet = Color(0xFF6C63FF);
  static const violetDim = Color(0x1A6C63FF);

  static const textPrimary = Color(0xFF1A1D2E);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFFB0B8CC);

  static const credit = Color(0xFF10B981);
  static const debit = Color(0xFFEF4444);
  static const cashback = Color(0xFFF59E0B);
}

// ═══════════════════════════════════════════════════════════════════════════════
// WalletScreen
// ═══════════════════════════════════════════════════════════════════════════════
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late TextEditingController _amountController;

  double _balance = 0;
  double _companyCreditedAmount = 0;
  double _selfCreditedAmount = 0;
  double _cashbackAmount = 0;
  double _postPaidUsage = 0;
  double _creditLimit = 0;
  bool _isLoading = true;
  bool _postPaid = true;

  String? selectedYear, selectedMonth, selectedWeek, selectedDate;
  List<String> years = [], months = [], dates = [];

  List<Transactions> _transactions = [];
  List<Transactions> _filteredTransactions = [];

  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _loadInitialData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await loadWallet();
    _loadTransactions();
  }

  Future<void> _refreshData() async {
    await Future.wait([loadWallet(), _loadTransactions()]);
  }

  Future<void> loadWallet() async {
    try {
      final Wallet? data = await subscription_AuthService.fetchWallet();
      if (data != null) {
        setState(() {
          _balance = data.totalBalance;
          _selfCreditedAmount = data.selfLoadedAmount;
          _companyCreditedAmount = data.companyLoadedAmount;
          _cashbackAmount = data.cashbackAmount;
          _creditLimit = data.creditLimit;
          _postPaidUsage = data.postPaidUsage;
          _postPaid = data.postPaid;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final txns = await subscription_AuthService.fetchTransactions();
      _initializeDateFilters(txns);
      setState(() {
        _transactions = txns;
        _filteredTransactions = _applyFilters(txns);
      });
    } catch (_) {}
  }

  void _initializeDateFilters(List<Transactions> txns) {
    years = txns.map((t) => t.transactionDate.year.toString()).toSet().toList()
      ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
    months = txns
        .map((t) => DateFormat('MMMM').format(t.transactionDate))
        .toSet()
        .toList();
    dates = txns.map((t) => t.transactionDate.day.toString()).toSet().toList();
  }

  List<Transactions> _applyFilters(List<Transactions> txns) {
    return txns.where((t) {
      final d = t.transactionDate;
      return (selectedYear == null || d.year.toString() == selectedYear) &&
          (selectedMonth == null ||
              DateFormat('MMMM').format(d) == selectedMonth) &&
          (selectedDate == null || d.day.toString() == selectedDate);
    }).toList();
  }

  bool get _hasFilter =>
      selectedYear != null ||
      selectedMonth != null ||
      selectedWeek != null ||
      selectedDate != null;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Walletcolour.bg,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refreshData,
        color: Walletcolour.violet,
        backgroundColor: Walletcolour.surface,
        child: CustomScrollView(
          slivers: [
            // ── Hero balance card ───────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeroCard()),

            // ── Wallet breakdown ────────────────────────────────────────
            SliverToBoxAdapter(child: _buildBreakdownGrid()),

            // ── History header + filter bar ─────────────────────────────
            SliverToBoxAdapter(child: _buildHistoryHeader()),

            // ── Transaction list ────────────────────────────────────────
            _isLoading
                ? SliverPadding(
                    padding: EdgeInsets.all(16.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => txnShimmer(),
                        childCount: 6,
                      ),
                    ),
                  )
                : _filteredTransactions.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48.sp,
                            color: Walletcolour.textMuted,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No transactions found',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Walletcolour.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((_, i) {
                        final list = _filteredTransactions.reversed.toList();
                        final show = i < list.length;
                        if (!show) return null;
                        return _buildTxnCard(list[i]);
                      }, childCount: _filteredTransactions.length),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Walletcolour.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Wallet',
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: Walletcolour.textPrimary,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
        ), // iOS-style back arrow
        color: Color(0xFF1A1D2E),
        onPressed: () => Navigator.of(context).pop(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Walletcolour.border),
      ),
    );
  }

  // ── Hero balance card ───────────────────────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF8A50), Color(0xFFE65100)],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Walletcolour.violet.withOpacity(0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _isLoading
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 12.h, width: 120.w),
                SizedBox(height: 16.h),
                ShimmerBox(height: 32.h, width: 180.w),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: ShimmerBox(height: 36.h, width: 120.w),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Text(
                      '₹${_balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    // SizedBox(width: 20.h),
                    Spacer(),
                    // Load money button
                    GestureDetector(
                      onTap: () => _showAmountBottomSheet(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              size: 18.sp,
                              color: Colors.black,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              'Load Money',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  // ── Breakdown grid ──────────────────────────────────────────────────────
  Widget _buildBreakdownGrid() {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 2.2,
          children: List.generate(
            4,
            (_) => Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Walletcolour.surface,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  ShimmerBox(height: 34.r, width: 34.r, radius: 10),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(height: 10.h, width: 80.w),
                        SizedBox(height: 6.h),
                        ShimmerBox(height: 12.h, width: 60.w),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final items = <_BreakdownItem>[
      _BreakdownItem(
        'Self',
        _selfCreditedAmount,
        Icons.account_balance_wallet_rounded,
        Walletcolour.violet,
      ),
      _BreakdownItem(
        'Company',
        _companyCreditedAmount,
        Icons.business_rounded,
        const Color(0xFF3B82F6),
      ),
      _BreakdownItem(
        'Cashback',
        _cashbackAmount,
        Icons.wallet_giftcard_rounded,
        Walletcolour.cashback,
      ),
      if (_postPaid) ...[
        _BreakdownItem(
          'Postpaid Usage',
          _postPaidUsage,
          Icons.data_usage_rounded,
          Walletcolour.debit,
        ),
        _BreakdownItem(
          'Credit Limit',
          _creditLimit,
          Icons.credit_card_rounded,
          Walletcolour.credit,
        ),
      ],
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 2.2,
        children: items.map(_breakdownCard).toList(),
      ),
    );
  }

  Widget _breakdownCard(_BreakdownItem item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Walletcolour.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Walletcolour.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(item.icon, size: 16.sp, color: item.color),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  style: TextStyle(fontSize: 10.sp, color: Walletcolour.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '₹${item.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Walletcolour.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── History header ──────────────────────────────────────────────────────
  Widget _buildHistoryHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Row(
        children: [
          Text(
            'Transaction History',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Walletcolour.textPrimary,
            ),
          ),
          const Spacer(),
          if (_hasFilter)
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedYear = selectedMonth = selectedWeek = selectedDate =
                      null;
                  _filteredTransactions = _applyFilters(_transactions);
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Walletcolour.debit.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Walletcolour.debit.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close_rounded, size: 12.sp, color: Walletcolour.debit),
                    SizedBox(width: 4.w),
                    Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Walletcolour.debit,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: _openFilterSheet,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: Walletcolour.violetDim,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Walletcolour.violet.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune_rounded, size: 13.sp, color: Walletcolour.violet),
                  SizedBox(width: 5.w),
                  Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Walletcolour.violet,
                      fontWeight: FontWeight.w600,
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

  // ── Transaction card ────────────────────────────────────────────────────
  Widget _buildTxnCard(Transactions t) {
    final isDebit = t.transactionType == 'DEBIT';
    final isCashback = t.transactionType == 'CASHBACK';
    final color = isCashback ? Walletcolour.cashback : (isDebit ? Walletcolour.debit : Walletcolour.credit);
    final icon = isCashback
        ? Icons.wallet_giftcard_rounded
        : (isDebit ? Icons.shopping_bag_rounded : Icons.add_circle_rounded);

    final amount =
        '${isDebit ? "-" : "+"}₹${t.amount.abs().toStringAsFixed(2)}';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Walletcolour.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Walletcolour.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon circle with left accent bar
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18.sp, color: color),
          ),
          SizedBox(width: 12.w),

          // Title + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.transactionType.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Walletcolour.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  t.description,
                  style: TextStyle(fontSize: 11.sp, color: Walletcolour.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  DateTimeHelper.formatDateTimeFull(t.transactionDate),
                  style: TextStyle(fontSize: 10.sp, color: Walletcolour.textMuted),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            amount,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Load money bottom sheet ─────────────────────────────────────────────
  void _showAmountBottomSheet(BuildContext context) {
    final ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Walletcolour.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24.h,
            left: 20.w,
            right: 20.w,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Walletcolour.border,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              Text(
                'Enter the amount you want to load',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: Walletcolour.textPrimary,
                ),
              ),
              SizedBox(height: 20.h),

              // Amount input
              Container(
                decoration: BoxDecoration(
                  color: Walletcolour.bg,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Walletcolour.border),
                ),
                child: TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 16.sp, color: Walletcolour.textPrimary),
                  cursorColor: Walletcolour.violet,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Walletcolour.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0),
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Walletcolour.textMuted, fontSize: 16.sp),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Quick amounts
              Row(
                children: [100, 200, 500, 1000]
                    .map(
                      (v) => Expanded(
                        child: GestureDetector(
                          onTap: () => ctrl.text = v.toString(),
                          child: Container(
                            margin: EdgeInsets.only(right: v == 1000 ? 0 : 8.w),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: Walletcolour.violetDim,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: Walletcolour.violet.withOpacity(0.2),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '₹$v',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Walletcolour.violet,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

              SizedBox(height: 20.h),

              // Proceed button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(ctrl.text);
                    if (amount == null || amount <= 0) return;
                    Navigator.pop(context);

                    final orderId = await subscription_AuthService.createOrder(
                      amount,
                    );
                    if (orderId == null) {
                      // ignore: use_build_context_synchronously
                      AppAlert.error(context, 'Failed to create order ❌');
                      return;
                    }

                    final razorpay = RazorpayService();
                    razorpay.onSuccess = (res) async {
                      final pid = res.paymentId!;
                      final captured = await subscription_AuthService
                          .capturePayment(paymentId: pid, amount: amount);
                      if (captured) {
                        await subscription_AuthService.addCashToWallet(
                          paymentId: pid,
                          orderId: orderId,
                          amount: amount,
                        );
                        // ignore: use_build_context_synchronously
                        AppAlert.success(context, 'Wallet recharged 🎉');
                        await loadWallet();
                      } else {
                        // ignore: use_build_context_synchronously
                        AppAlert.error(context, 'Capture failed ❌');
                      }
                    };
                    razorpay.onError = (res) {
                      AppAlert.error(context, 'Payment Failed: ${res.message}');
                    };
                    razorpay.startPayment(
                      orderId: orderId,
                      amount: amount,
                      description: 'Wallet recharge',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Walletcolour.violet,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_rounded, size: 16.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Proceed to Pay',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Filter sheet ────────────────────────────────────────────────────────
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Walletcolour.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
            left: 20.w,
            right: 20.w,
            top: 20.h,
          ),
          child: _FilterSheet(
            selectedYear: selectedYear,
            selectedMonth: selectedMonth,
            selectedDate: selectedDate,
            years: years,
            months: months,
            dates: dates,
            onApply: (year, month, week, date) {
              setState(() {
                selectedYear = year;
                selectedMonth = month;
                selectedWeek = week;
                selectedDate = date;
                _filteredTransactions = _applyFilters(_transactions);
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BreakdownItem helper
// ─────────────────────────────────────────────────────────────────────────────
class _BreakdownItem {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  const _BreakdownItem(this.label, this.amount, this.icon, this.color);
}

// ═══════════════════════════════════════════════════════════════════════════════
// Filter bottom sheet
// ═══════════════════════════════════════════════════════════════════════════════
class _FilterSheet extends StatefulWidget {
  final String? selectedYear, selectedMonth, selectedDate;
  final List<String> years, months, dates;
  final Function(String?, String?, String?, String?) onApply;

  const _FilterSheet({
    required this.selectedYear,
    required this.selectedMonth,
    required this.selectedDate,
    required this.years,
    required this.months,
    required this.dates,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _year, _month, _week, _date;

  @override
  void initState() {
    super.initState();
    _year = widget.selectedYear;
    _month = widget.selectedMonth;
    _date = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Walletcolour.border,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Filter Transactions',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: Walletcolour.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Narrow down by year, month or date',
          style: TextStyle(fontSize: 12.sp, color: Walletcolour.textSecondary),
        ),
        SizedBox(height: 20.h),

        Row(
          children: [
            Expanded(
              child: _dropdown(
                'Year',
                _year,
                widget.years,
                (v) => setState(() => _year = v),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _dropdown(
                'Month',
                _month,
                widget.months,
                (v) => setState(() => _month = v),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _dropdown(
          'Date',
          _date,
          widget.dates,
          (v) => setState(() => _date = v),
        ),

        SizedBox(height: 24.h),

        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () => widget.onApply(_year, _month, _week, _date),
            style: ElevatedButton.styleFrom(
              backgroundColor: Walletcolour.violet,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Apply Filter',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _dropdown(
    String hint,
    String? value,
    List<String> opts,
    ValueChanged<String> onChange,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Walletcolour.bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Walletcolour.border),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: Walletcolour.surface,
        style: TextStyle(fontSize: 13.sp, color: Walletcolour.textPrimary),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Walletcolour.textMuted,
          size: 18.sp,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        hint: Text(
          hint,
          style: TextStyle(fontSize: 13.sp, color: Walletcolour.textMuted),
        ),
        items: opts
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChange(v);
        },
      ),
    );
  }
}
