import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/scaffoldmessenger/messenger.dart';
import 'login_page.dart';
import 'loginscreensas.dart';

class otpscrncolour {
  static const Color _brand = Color(0xFF6C63FF);
  static const Color _brandLight = Color(0xFFEEEDFF);
  static const Color _surface = Color(0xFFF8F9FA);
  static const Color _textPrimary = Color(0xFF1A1A2E);
  static const Color _textSecondary = Color(0xFF7B7B8F);
}

class OTPVerificationPage extends StatefulWidget {
  final String mobileNumber;

  const OTPVerificationPage({super.key, required this.mobileNumber});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage>
    with SingleTickerProviderStateMixin {
  final subscription_AuthService _authService = subscription_AuthService();

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _resendTimer = 60;
  Timer? _timer;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Design tokens


  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    _startResendTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendTimer = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          t.cancel();
        }
      });
    });
  }

  Future<void> _verifyOTP() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      AppAlert.error(context, 'Please enter the complete 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.verifyOTP(
      mobile: widget.mobileNumber,
      otp: otp,
    );

    setState(() => _isLoading = false);

    if (result.toLowerCase().trim() == 'success') {
      // ignore: use_build_context_synchronously
      AppAlert.success(context, 'OTP verified successfully!');
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      // ignore: use_build_context_synchronously
      AppAlert.error(context, result);
      for (final c in _controllers) {
        c.clear();
      }
      // ignore: use_build_context_synchronously
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: otpscrncolour._surface,
      body: Stack(
        children: [
          // ── Top gradient strip
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.32,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B84FF), Color(0xFF5A52E0)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 8.h),

                      // ── Top bar
                      Row(
                        children: [
                          _circleButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // ── Header card
                      _buildHeader(),

                      SizedBox(height: 24.h),

                      // ── OTP card
                      _buildOtpCard(),

                      SizedBox(height: 24.h),

                      // ── Resend row
                      // _buildResendRow(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header (sits over gradient strip)
  Widget _buildHeader() {
    return Column(
      children: [
        // Icon badge
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: otpscrncolour._brand.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(Icons.lock_open_rounded, color: otpscrncolour._brand, size: 38.sp),
        ),

        SizedBox(height: 20.h),

        Text(
          'Verify OTP',
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Enter the 6-digit code sent to',
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.phone_android_outlined,
                size: 14,
                color: Colors.white.withOpacity(0.9),
              ),
              SizedBox(width: 6.w),
              Text(
                widget.mobileNumber,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // String _maskMobile(String number) {
  //   if (number.length <= 4) return number;
  //   return 'XXXXXX${number.substring(number.length - 4)}';
  // }

  // ── White card with OTP boxes + button
  Widget _buildOtpCard() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Column(
          //   children: [
          //     Text(
          //       'Enter verification code has been sent to',
          //       textAlign: TextAlign.center,
          //       style: TextStyle(
          //         fontSize: 15.sp,
          //         fontWeight: FontWeight.w600,
          //         color: _textPrimary,
          //       ),
          //     ),
          //     SizedBox(height: 4.h),
          //     Text(
          //       _maskMobile(widget.mobileNumber),
          //       textAlign: TextAlign.center,
          //       style: TextStyle(
          //         fontSize: 16.sp,
          //         fontWeight: FontWeight.w700,
          //         color: _brand,
          //       ),
          //     ),
          //   ],
          // ),
          // SizedBox(height: 6.h),
          Text(
            'The code expires in a 5 minutes',
            style: TextStyle(fontSize: 12.sp, color: otpscrncolour._textSecondary),
          ),

          SizedBox(height: 28.h),

          // ── 6 OTP boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) => _otpBox(i)),
          ),

          SizedBox(height: 32.h),

          // ── Verify button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: otpscrncolour._brand,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : _verifyOTP,
              child: _isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Single OTP digit box
  Widget _otpBox(int index) {
    return SizedBox(
      width: 46.w,
      height: 54.h,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        showCursor: false,
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          color: otpscrncolour._textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: otpscrncolour._brandLight,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: otpscrncolour._brand, width: 2),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
              _verifyOTP(); // auto-submit on last digit
            }
          } else if (index > 0) {
            _focusNodes[index - 1].requestFocus();
            _controllers[index - 1].clear();
          }
        },
      ),
    );
  }

  // ── Resend row

  // ── Small circle icon button
  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
