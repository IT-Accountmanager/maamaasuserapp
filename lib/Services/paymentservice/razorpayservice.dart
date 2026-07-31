import 'package:flutter/cupertino.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Auth_service/Subscription_authservice.dart';

class RazorpayService {
  static final RazorpayService _instance = RazorpayService._internal();
  factory RazorpayService() => _instance;

  late Razorpay _razorpay;

  String? _email;
  String? _mobile;

  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onError;
  Function(ExternalWalletResponse)? onExternalWallet;

  RazorpayService._internal() {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _loadUserProfile(); // Load user data automatically
  }

  Future<void> _loadUserProfile() async {
    final profile = await subscription_AuthService.getAccount();

    if (profile != null) {
      _email = profile.emailId;
      _mobile = profile.phoneNumber;
      // _name = profile.name;
    }
  }

  Future<void> startPayment({
    required String orderId,
    required double amount,
    required String description,
    // required String name,
  }) async {
    // Ensure profile loaded
    if (_email == null || _mobile == null) {
      await _loadUserProfile();
    }

    var options = {
      // 'key': 'rzp_test_TJECsclCivENpY',
      'key': 'rzp_live_TJDvykibQEsCuN',
      'amount': (amount * 100).toInt(),
      'order_id': orderId,
      'name': "maamaas",
      'description': description,
      'prefill': {'contact': _mobile ?? '', 'email': _email ?? ''},
      // 'image': 'https://yourdomain.com/logo.png',
      'theme': {
        'color': '#FF6F00', // your brand color
      },
    };

    _razorpay.open(options);
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    // debugPrint("Razorpay Success");
    // debugPrint("PaymentId : ${response.paymentId}");
    // debugPrint("OrderId   : ${response.orderId}");
    // debugPrint("Signature : ${response.signature}");
    if (onSuccess != null) onSuccess!(response);
  }

  void _handleError(PaymentFailureResponse response) {
    // debugPrint("Razorpay Error");
    // debugPrint("Code    : ${response.code}");
    // debugPrint("Message : ${response.message}");
    if (onError != null) onError!(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // debugPrint("External Wallet : ${response.walletName}");
    if (onExternalWallet != null) onExternalWallet!(response);
  }

  void dispose() {
    _razorpay.clear();
  }
}
