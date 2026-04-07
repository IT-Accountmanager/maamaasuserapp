import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/scaffoldmessenger/messenger.dart';
import 'otpscreen.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final subscription_AuthService _authService = subscription_AuthService();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _refferalcodecontroller = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isTermsAccepted = false;

  // Design tokens
  static const Color _ink = Color(0xFF0F0F0F);
  static const Color _accent = Color(0xFF2563EB);
  static const Color _surface = Color(0xFFFAFAFA);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _error = Color(0xFFEF4444);

  Future<void> _handleSignup() async {
    if (!_isTermsAccepted) return;
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _authService.registerUser(
        userName: _userNameController.text.trim(),
        password: _passwordController.text.trim(),
        referralCodeUsed: _refferalcodecontroller.text.trim(),
        emailId: _emailController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        userType: "PERSONAL",
      );

      setState(() => _isLoading = false);

      if (result == "success") {
        // ignore: use_build_context_synchronously
        AppAlert.success(context, "Signup successful! Please verify OTP.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationPage(
              mobileNumber: _mobileController.text.trim(),
            ),
          ),
        );
      } else {
        AppAlert.error(context, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),

                  // ── Header ──────────────────────────────────────────────
                  Text(
                    "Create account",
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),

                  // SizedBox(height: 8.h),
                  // Text(
                  //   "Sign up to get started today",
                  //   style: TextStyle(
                  //     fontSize: 14.sp,
                  //     color: _muted,
                  //     fontWeight: FontWeight.w400,
                  //   ),
                  // ),
                  SizedBox(height: 36.h),

                  // ── Fields ───────────────────────────────────────────────
                  _field(
                    controller: _emailController,
                    label: "Email",
                    hint: "you@example.com/.in",
                    icon: Icons.alternate_email_rounded,
                    type: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Email is required";
                      // if (!RegExp(r'^[a-z0-9.]+@[a-z]+\.[a-z]+$').hasMatch(v))
                      //   return "Enter a valid email";
                      if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@(gmail|yahoo|outlook)\.(com|in|co\.in)$'
                      ).hasMatch(v)) {
                        return "Only Gmail, Yahoo, Outlook (.com, .in, .co.in) allowed";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 14.h),

                  _field(
                    controller: _userNameController,
                    label: "Full Name",
                    hint: "John Doe",
                    icon: Icons.person_outline_rounded,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Name is required";
                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v))
                        return "Letters only";
                      return null;
                    },
                  ),
                  SizedBox(height: 14.h),

                  _field(
                    controller: _mobileController,
                    label: "Phone",
                    hint: "10-digit number",
                    icon: Icons.phone_outlined,
                    type: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Phone is required";
                      if (!RegExp(r'^[0-9]{10}$').hasMatch(v))
                        return "Enter a valid 10-digit number";
                      return null;
                    },
                  ),
                  SizedBox(height: 14.h),

                  _passwordFieldWidget(),
                  SizedBox(height: 14.h),

                  _confirmPasswordFieldWidget(),
                  SizedBox(height: 14.h),

                  _field(
                    controller: _refferalcodecontroller,
                    label: "Referral Code",
                    hint: "Optional",
                    icon: Icons.card_giftcard_outlined,
                  ),

                  SizedBox(height: 24.h),

                  // ── Terms ────────────────────────────────────────────────
                  _termsRow(),

                  SizedBox(height: 28.h),

                  // ── Button ───────────────────────────────────────────────
                  _submitButton(),

                  SizedBox(height: 20.h),

                  // ── Login link ───────────────────────────────────────────
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 13.sp, color: _muted),
                        children: [
                          const TextSpan(text: "Already have an account?  "),
                          TextSpan(
                            text: "Sign in",
                            style: TextStyle(
                              color: _accent,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Reusable text field ────────────────────────────────────────────────────
  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: _ink,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: type,
          style: TextStyle(fontSize: 14.sp, color: _ink),
          decoration: _inputDeco(hint, icon),
          validator: validator,
        ),
      ],
    );
  }

  // ── Password field ─────────────────────────────────────────────────────────
  Widget _passwordFieldWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: _ink,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(fontSize: 14.sp, color: _ink),
          decoration:
              _inputDeco(
                "Min. 6 characters",
                Icons.lock_outline_rounded,
              ).copyWith(
                suffixIcon: _eyeIcon(
                  visible: _obscurePassword,
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
          validator: (v) {
            if (v == null || v.isEmpty) return "Password is required";
            if (v.length < 6) return "At least 6 characters";
            return null;
          },
        ),
      ],
    );
  }

  // ── Confirm password field ─────────────────────────────────────────────────
  Widget _confirmPasswordFieldWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Confirm Password",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: _ink,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          style: TextStyle(fontSize: 14.sp, color: _ink),
          decoration:
              _inputDeco(
                "Re-enter password",
                Icons.lock_outline_rounded,
              ).copyWith(
                suffixIcon: _eyeIcon(
                  visible: _obscureConfirmPassword,
                  onTap: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
              ),
          validator: (v) {
            if (v == null || v.isEmpty) return "Please confirm your password";
            if (v != _passwordController.text) return "Passwords do not match";
            return null;
          },
        ),
      ],
    );
  }

  // ── Shared InputDecoration ─────────────────────────────────────────────────
  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _muted, fontSize: 13.sp),
      prefixIcon: Icon(icon, color: _muted, size: 18.sp),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: _border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: _error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: _error, width: 1.5),
      ),
      errorStyle: TextStyle(fontSize: 11.sp, color: _error),
    );
  }

  // ── Eye toggle icon ────────────────────────────────────────────────────────
  Widget _eyeIcon({required bool visible, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: Icon(
          visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: _muted,
          size: 18.sp,
        ),
      ),
    );
  }

  // ── Terms row ──────────────────────────────────────────────────────────────
  Widget _termsRow() {
    return GestureDetector(
      onTap: () => setState(() => _isTermsAccepted = !_isTermsAccepted),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: _isTermsAccepted ? _accent : Colors.white,
              borderRadius: BorderRadius.circular(5.r),
              border: Border.all(
                color: _isTermsAccepted ? _accent : _border,
                width: 1.5,
              ),
            ),
            child: _isTermsAccepted
                ? Icon(Icons.check_rounded, color: Colors.white, size: 13.sp)
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12.sp, color: _muted, height: 1.4),
                children: [
                  const TextSpan(text: "I agree to the "),
                  TextSpan(
                    text: "Terms & Conditions",
                    style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w500,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launchUrl(
                        Uri.parse("https://maamaas.com/privacy-policy"),
                      ),
                  ),
                  const TextSpan(text: " and "),
                  TextSpan(
                    text: "Privacy Policy",
                    style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w500,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launchUrl(
                        Uri.parse("https://maamaas.com/privacy-policy"),
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

  // ── Submit button ──────────────────────────────────────────────────────────
  Widget _submitButton() {
    final bool enabled = _isTermsAccepted && !_isLoading;

    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: enabled ? _handleSignup : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _accent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20.h,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  "Create account",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
        ),
      ),
    );
  }
}
