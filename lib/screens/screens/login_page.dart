import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaas/Services/App_color_service/app_colours.dart';
import 'package:maamaas/screens/screens/signup_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/Auth_service/Apiclient.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/Auth_service/notification_service.dart';
import '../../Services/scaffoldmessenger/messenger.dart';
import '../../Services/googleservices/Location_servces.dart';
import '../../widgets/app_navigator.dart';
import '../foodmainscreen.dart';
import 'forgetpassword_screen.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF6F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF111827);
  static const sub = Color(0xFF6B7280);
  static const muted = Color(0xFFD1D5DB);
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _fcm = FirebaseMessaging.instance;

  bool _obscure = true;
  bool _isLoading = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    debugPrint("🔐 Login started");

    if (!_formKey.currentState!.validate()) {
      debugPrint("❌ Form validation failed");
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      debugPrint("📤 Sending login request...");
      final result = await subscription_AuthService.login(
        identifier: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      debugPrint("📥 Login response: $result");

      if (!mounted) return;

      if (result != 'success') {
        debugPrint("❌ Login failed: $result");
        AppAlert.error(context, result);
        return;
      }

      debugPrint("✅ Login successful");

      ApiClient.isGuestUser = false;
      ApiClient.resetSessionFlag();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      debugPrint("💾 Saved isLoggedIn = true");

      // 📍 Location
      try {
        debugPrint("📍 Fetching current location...");
        final location = await LocationService.getCurrentLocationWithAddress();

        if (location != null) {
          debugPrint("📍 Location fetched:");
          debugPrint("   Lat: ${location.latitude}");
          debugPrint("   Lng: ${location.longitude}");
          debugPrint("   Address: ${location.fullAddress}");
          debugPrint("   City: ${location.city}");

          final ok = await subscription_AuthService.updateLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            address: location.fullAddress,
            city: location.city,
          );

          debugPrint("📡 Location update API status: $ok");

          if (ok) {
            await prefs.setBool('locationSet', true);
            debugPrint("💾 locationSet = true");
          }
        } else {
          debugPrint("⚠️ Location is NULL");
        }
      } catch (e) {
        debugPrint("❌ Location error: $e");
      }

      // 🔔 FCM
      try {
        debugPrint("🔔 Fetching FCM token...");
        final token = await _fcm.getToken();

        if (token != null) {
          debugPrint("🔑 FCM Token: $token");
          await NotificationService.registerFcmToken(token);
          debugPrint("📡 FCM token sent to server");
        } else {
          debugPrint("⚠️ FCM token is NULL");
        }
      } catch (e) {
        debugPrint("❌ FCM error: $e");
      }

      // 🔐 Permissions
      debugPrint("🔐 Requesting permissions...");
      final permissions = await [
        Permission.location,
        Permission.notification,
      ].request();

      debugPrint("📊 Permission results: $permissions");

      if (!mounted) return;

      debugPrint("➡️ Navigating to MainScreenfood");

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreenfood()),
        (r) => false,
      );
    } catch (e, st) {
      debugPrint("❌ Login exception: $e");
      debugPrint("📍 StackTrace: $st");

      if (mounted) {
        AppAlert.error(context, 'Something went wrong');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint("🔄 Loading stopped");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: SafeArea(
          child: Stack(
            children: [
              // ── Scrollable content ─────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 60.h),
                        _buildBrand(),
                        SizedBox(height: 32.h),
                        _buildCard(),
                        SizedBox(height: 32.h),
                        _buildSignUpRow(),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Skip pill ──────────────────────────────────────────
              Positioned(
                top: 12.h,
                right: 16.w,
                child: _SkipButton(
                  onTap: () async {
                    ApiClient.isGuestUser = true;

                    navigatorKey.currentState!.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainScreenfood()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Brand block ────────────────────────────────────────────────────────────
  Widget _buildBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: _C.ink,
            letterSpacing: -0.6,
            height: 1.15,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Sign in to your Maamaas account',
          style: TextStyle(fontSize: 14.sp, color: _C.sub, height: 1.4),
        ),
      ],
    );
  }

  // ── Form card ──────────────────────────────────────────────────────────────
  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InputField(
              label: 'Phone / Email',
              hint: 'Enter phone or email',
              icon: Icons.person_outline_rounded,
              controller: _emailCtrl,
              focusNode: _emailFocus,
              nextFocus: _passFocus,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'This field is required';
                final email = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                final phone = RegExp(r'^[6-9]\d{9}$');
                if (!email.hasMatch(v) && !phone.hasMatch(v)) {
                  return 'Enter a valid email or phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 14.h),
            _PasswordField(
              controller: _passCtrl,
              focusNode: _passFocus,
              obscure: _obscure,
              onToggle: () => setState(() => _obscure = !_obscure),
            ),
            SizedBox(height: 10.h),
            _ForgotLink(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ForgetPasswordScreen()),
              ),
            ),
            SizedBox(height: 22.h),
            _LoginButton(isLoading: _isLoading, onPressed: _handleLogin),
          ],
        ),
      ),
    );
  }

  // ── Sign-up row ────────────────────────────────────────────────────────────
  Widget _buildSignUpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?  ",
          style: TextStyle(fontSize: 15.sp, color: _C.sub),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Signup()),
          ),
          child: Text(
            'Sign-up',
            style: TextStyle(
              fontSize: 20.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              // decoration: TextDecoration.underline,
              // decorationColor: AppColors.primary, // underline color
              // decorationThickness: 2, // thickness
              // decorationStyle: TextDecorationStyle.solid, // or dotted, dashed
            ),
          ),
        ),
      ],
    );
  }
}

// ── Skip button ────────────────────────────────────────────────────────────────
class _SkipButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SkipButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _C.muted),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'Skip',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: _C.ink,
          ),
        ),
      ),
    );
  }
}

// ── Generic input field ────────────────────────────────────────────────────────
class _InputField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final TextInputType keyboardType;
  final String? Function(String?) validator;

  const _InputField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.focusNode,
    this.nextFocus,
    required this.keyboardType,
    required this.validator,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: _C.ink,
          ),
        ),
        SizedBox(height: 6.h),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _focused ? AppColors.primary : _C.bg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _focused ? AppColors.primary : _C.muted,
              width: _focused ? 1.5 : 1.5,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.nextFocus != null
                ? TextInputAction.next
                : TextInputAction.done,
            onFieldSubmitted: (_) {
              if (widget.nextFocus != null) {
                FocusScope.of(context).requestFocus(widget.nextFocus);
              }
            },
            style: TextStyle(fontSize: 14.sp, color: _C.ink),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(fontSize: 14.sp, color: _C.muted),
              prefixIcon: Icon(
                widget.icon,
                size: 18.sp,
                color: _focused ? AppColors.primary : _C.muted,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}

// ── Password field ─────────────────────────────────────────────────────────────
class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.obscure,
    required this.onToggle,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: _C.ink,
          ),
        ),
        SizedBox(height: 6.h),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _focused ? AppColors.primary : _C.bg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _focused ? AppColors.primary : _C.muted,
              width: _focused ? 1.5 : 1,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: widget.obscure,
            textInputAction: TextInputAction.done,
            style: TextStyle(fontSize: 14.sp, color: _C.ink),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: TextStyle(fontSize: 14.sp, color: _C.muted),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                size: 18.sp,
                color: _focused ? AppColors.primary : _C.muted,
              ),
              suffixIcon: GestureDetector(
                onTap: widget.onToggle,
                child: Padding(
                  padding: EdgeInsets.only(right: 4.w),
                  child: Icon(
                    widget.obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18.sp,
                    color: _C.muted,
                  ),
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              return null;
            },
          ),
        ),
      ],
    );
  }
}

// ── Forgot password link ───────────────────────────────────────────────────────
class _ForgotLink extends StatelessWidget {
  final VoidCallback onTap;
  const _ForgotLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          'Forgot password?',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Login button ───────────────────────────────────────────────────────────────
class _LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _LoginButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loader'),
                  width: 20.r,
                  height: 20.r,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  key: const ValueKey('label'),
                  'Sign In',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }
}
