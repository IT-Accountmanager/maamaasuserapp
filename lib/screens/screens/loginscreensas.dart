// import 'dart:async';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:maamaas/screens/screens/signup_screen.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Services/Auth_service/Apiclient.dart';
// import '../../Services/Auth_service/Subscription_authservice.dart';
// import '../../Services/Auth_service/notification_service.dart';
// import '../../Services/googleservices/Location_servces.dart';
// import '../../Services/scaffoldmessenger/messenger.dart';
// import '../foodmainscreen.dart';
// import 'forgetpassword_screen.dart';
//
// class logincolour {
//   static const Color primary = Color(0xFFFF5722);
//   static const Color primaryLight = Color(0xFFFFF3EE);
//   static const Color primaryBorder = Color(0xFFFFD0BC);
//   static const Color dark = Color(0xFF1A1A2E);
//   static const Color muted = Color(0xFF9A8F8F);
// }
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   bool _obscurePassword = true;
//   final _formKey = GlobalKey<FormState>();
//   final usernamecontroller = TextEditingController();
//   final passwordcontroller = TextEditingController();
//   bool _isLoading = false;
//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;
//   late Animation<Offset> _slideAnim;
//   final _fcm = FirebaseMessaging.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//     _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
//     _slideAnim = Tween<Offset>(
//       begin: const Offset(0, 0.12),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
//     _animController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animController.dispose();
//     usernamecontroller.dispose();
//     passwordcontroller.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleLogin() async {
//     debugPrint("🔐 Login started");
//
//     if (!_formKey.currentState!.validate()) {
//       debugPrint("❌ Form validation failed");
//       return;
//     }
//
//     HapticFeedback.lightImpact();
//     setState(() => _isLoading = true);
//
//     try {
//       debugPrint("📤 Sending login request...");
//       final result = await subscription_AuthService.login(
//         identifier: usernamecontroller.text.trim(),
//         password: passwordcontroller.text.trim(),
//       );
//
//       debugPrint("📥 Login response: $result");
//
//       if (!mounted) return;
//
//       if (result != 'success') {
//         debugPrint("❌ Login failed: $result");
//         AppAlert.error(context, result);
//         return;
//       }
//
//       debugPrint("✅ Login successful");
//
//       ApiClient.isGuestUser = false;
//       ApiClient.resetSessionFlag();
//
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isLoggedIn', true);
//       debugPrint("💾 Saved isLoggedIn = true");
//
//       // 📍 Location
//       try {
//         debugPrint("📍 Fetching current location...");
//         final location = await LocationService.getCurrentLocationWithAddress();
//
//         if (location != null) {
//           debugPrint("📍 Location fetched:");
//           debugPrint("   Lat: ${location.latitude}");
//           debugPrint("   Lng: ${location.longitude}");
//           debugPrint("   Address: ${location.fullAddress}");
//           debugPrint("   City: ${location.city}");
//
//           final ok = await subscription_AuthService.updateLocation(
//             latitude: location.latitude,
//             longitude: location.longitude,
//             address: location.fullAddress,
//             city: location.city,
//           );
//
//           debugPrint("📡 Location update API status: $ok");
//
//           if (ok) {
//             await prefs.setBool('locationSet', true);
//             debugPrint("💾 locationSet = true");
//           }
//         } else {
//           debugPrint("⚠️ Location is NULL");
//         }
//       } catch (e) {
//         debugPrint("❌ Location error: $e");
//       }
//
//       // 🔔 FCM
//       try {
//         debugPrint("🔔 Fetching FCM token...");
//         final token = await _fcm.getToken();
//
//         if (token != null) {
//           debugPrint("🔑 FCM Token: $token");
//           await NotificationService.registerFcmToken(token);
//           debugPrint("📡 FCM token sent to server");
//         } else {
//           debugPrint("⚠️ FCM token is NULL");
//         }
//       } catch (e) {
//         debugPrint("❌ FCM error: $e");
//       }
//
//       // 🔐 Permissions
//       debugPrint("🔐 Requesting permissions...");
//       final permissions = await [
//         Permission.location,
//         Permission.notification,
//       ].request();
//
//       debugPrint("📊 Permission results: $permissions");
//
//       if (!mounted) return;
//
//       debugPrint("➡️ Navigating to MainScreenfood");
//
//       // Navigator.of(context).pushAndRemoveUntil(
//       //   MaterialPageRoute(builder: (_) => const MainScreenfood()),
//       //   (r) => false,
//       // );
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (_) => MainScreenfood()),
//         (r) => false,
//       );
//     } catch (e, st) {
//       debugPrint("❌ Login exception: $e");
//       debugPrint("📍 StackTrace: $st");
//
//       if (mounted) {
//         AppAlert.error(context, 'Something went wrong');
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//         debugPrint("🔄 Loading stopped");
//       }
//     }
//   }
//
//   Future<bool> requestAllPermissions() async {
//     PermissionStatus locationStatus = await Permission.location.request();
//     if (!locationStatus.isGranted) {
//       if (locationStatus.isPermanentlyDenied) await openAppSettings();
//       return false;
//     }
//     await Permission.notification.request();
//     return true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildIllustration(),
//               FadeTransition(
//                 opacity: _fadeAnim,
//                 child: SlideTransition(
//                   position: _slideAnim,
//                   child: _buildFormSheet(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildIllustration() {
//     return Container(
//       height: 280.h,
//       width: double.infinity,
//       color: logincolour.primary,
//       child: Stack(
//         children: [
//           // Background circles
//           Positioned(top: -60, right: -40, child: _bgCircle(200)),
//           Positioned(top: 40, right: 50, child: _bgCircle(120)),
//           Positioned(top: -20, left: -20, child: _bgCircle(90)),
//           Positioned(bottom: -50, left: 30, child: _bgCircle(150)),
//
//           // Twinkling dots
//           ..._buildStarDots(),
//
//           // Brand title + tagline
//           Align(
//             alignment: Alignment.topCenter,
//             child: Padding(
//               padding: EdgeInsets.only(top: 28.h),
//               child: FadeTransition(
//                 opacity: _fadeAnim,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       "Maamaas",
//                       style: GoogleFonts.nunito(
//                         color: Colors.white,
//                         fontSize: 24.sp,
//                         fontWeight: FontWeight.w900,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     SizedBox(height: 2.h),
//                     Text(
//                       "FRESH  ·  FAST  ·  DELICIOUS",
//                       style: GoogleFonts.nunito(
//                         color: Colors.white.withOpacity(0.75),
//                         fontSize: 10.sp,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 2.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // Floating food icons
//           _floatingIcon(
//             "🍕",
//             top: 70,
//             left: 40,
//             size: 44,
//             duration: 3200,
//             delay: 200,
//           ),
//           _floatingIcon(
//             "🍔",
//             top: 55,
//             right: 45,
//             size: 40,
//             duration: 2800,
//             delay: 800,
//           ),
//           _floatingIcon(
//             "🌮",
//             top: 110,
//             left: 22,
//             size: 34,
//             duration: 3600,
//             delay: 1200,
//           ),
//           _floatingIcon(
//             "🍜",
//             top: 98,
//             right: 28,
//             size: 36,
//             duration: 3000,
//             delay: 500,
//           ),
//
//           // Steaming bowl in center-bottom
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Center(child: _buildSteamingBowl()),
//           ),
//
//           // Delivery scooter sliding across
//           _buildScooter(),
//         ],
//       ),
//     );
//   }
//
//   List<Widget> _buildStarDots() {
//     final positions = [
//       {'top': 60.0, 'left': 30.0, 'delay': 0},
//       {'top': 120.0, 'right': 25.0, 'delay': 700},
//       {'top': 150.0, 'left': 20.0, 'delay': 400},
//     ];
//     return positions.map((p) {
//       return Positioned(
//         top: p['top'] as double?,
//         left: p['left'] as double?,
//         right: p['right'] as double?,
//         child: _TwinklingDot(delay: Duration(milliseconds: p['delay'] as int)),
//       );
//     }).toList();
//   }
//
//   Widget _floatingIcon(
//     String emoji, {
//     double? top,
//     double? left,
//     double? right,
//     required double size,
//     required int duration,
//     required int delay,
//   }) {
//     return Positioned(
//       top: top?.h,
//       left: left?.w,
//       right: right?.w,
//       child: _FloatingFoodItem(
//         emoji: emoji,
//         size: size.sp,
//         duration: Duration(milliseconds: duration),
//         delay: Duration(milliseconds: delay),
//       ),
//     );
//   }
//
//   Widget _buildSteamingBowl() {
//     return SizedBox(
//       height: 130.h,
//       width: 220.w,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Shadow
//           Positioned(
//             bottom: 0,
//             child: Container(
//               width: 160.w,
//               height: 14.h,
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.18),
//                 borderRadius: BorderRadius.circular(50),
//               ),
//             ),
//           ),
//           // Bowl base
//           Positioned(
//             bottom: 8.h,
//             child: Container(
//               width: 150.w,
//               height: 40.h,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFBF360C),
//                 borderRadius: const BorderRadius.vertical(
//                   bottom: Radius.circular(60),
//                   top: Radius.circular(10),
//                 ),
//               ),
//             ),
//           ),
//           // Bowl rim
//           Positioned(
//             bottom: 40.h,
//             child: Container(
//               width: 160.w,
//               height: 22.h,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(50),
//               ),
//             ),
//           ),
//           // Bowl inner fill
//           Positioned(
//             bottom: 44.h,
//             child: Container(
//               width: 140.w,
//               height: 18.h,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFF9F7),
//                 borderRadius: BorderRadius.circular(50),
//               ),
//             ),
//           ),
//           // Noodles / food toppings row
//           Positioned(
//             bottom: 48.h,
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _bowlTopping(const Color(0xFFE53935), 14),
//                 SizedBox(width: 6.w),
//                 _bowlTopping(const Color(0xFFFF7043), 11),
//                 SizedBox(width: 6.w),
//                 _bowlTopping(const Color(0xFF4CAF50), 10),
//                 SizedBox(width: 6.w),
//                 _bowlTopping(const Color(0xFFE53935), 12),
//                 SizedBox(width: 6.w),
//                 _bowlTopping(const Color(0xFF4CAF50), 9),
//               ],
//             ),
//           ),
//           // Steam lines
//           Positioned(
//             bottom: 70.h,
//             left: 60.w,
//             child: _SteamWidget(delay: Duration.zero),
//           ),
//           Positioned(
//             bottom: 70.h,
//             left: 95.w,
//             child: _SteamWidget(delay: const Duration(milliseconds: 300)),
//           ),
//           Positioned(
//             bottom: 70.h,
//             left: 130.w,
//             child: _SteamWidget(delay: const Duration(milliseconds: 600)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _bowlTopping(Color color, double size) {
//     return Container(
//       width: size.w,
//       height: size.w,
//       decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//     );
//   }
//
//   Widget _buildScooter() {
//     return _ScooterWidget();
//   }
//
//   Widget _bgCircle(double size) => Container(
//     width: size,
//     height: size,
//     decoration: BoxDecoration(
//       color: Colors.white.withOpacity(0.07),
//       shape: BoxShape.circle,
//     ),
//   );
//
//   Widget _buildFormSheet() {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
//       ),
//       transform: Matrix4.translationValues(0, -28, 0),
//       padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 32.h),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Welcome back",
//               style: GoogleFonts.nunito(
//                 fontSize: 22.sp,
//                 fontWeight: FontWeight.w900,
//                 color: logincolour.dark,
//                 letterSpacing: -0.3,
//               ),
//             ),
//             SizedBox(height: 4.h),
//             Text(
//               "Sign in to Order your delicious food",
//               style: GoogleFonts.nunito(
//                 fontSize: 13.sp,
//                 color: logincolour.muted,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             SizedBox(height: 22.h),
//
//             // Tab row
//             _buildTabRow(),
//             SizedBox(height: 22.h),
//
//             // Email field
//             _fieldLabel("Email or Phone"),
//             _buildInputField(
//               controller: usernamecontroller,
//               hint: "Enter email or phone number",
//               icon: Icons.email_outlined,
//               keyboardType: TextInputType.emailAddress,
//               validator: (v) => (v == null || v.isEmpty)
//                   ? 'Please enter email or phone'
//                   : null,
//             ),
//             SizedBox(height: 16.h),
//
//             // Password field
//             _fieldLabel("Password"),
//             _buildPasswordField(),
//             SizedBox(height: 14.h),
//
//             // Remember me + Forgot
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const ForgetPasswordScreen(),
//                       ),
//                     );
//                   },
//                   child: Text(
//                     "Forgot Password?",
//                     style: GoogleFonts.nunito(
//                       fontSize: 12.5.sp,
//                       color: logincolour.primary,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 22.h),
//
//             // Login button
//             _buildLoginButton(),
//             SizedBox(height: 20.h),
//
//             // Sign up
//             Center(
//               child: GestureDetector(
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => Signup()),
//                 ),
//                 child: RichText(
//                   text: TextSpan(
//                     style: GoogleFonts.nunito(
//                       fontSize: 13.5.sp,
//                       color: logincolour.muted,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     children: [
//                       const TextSpan(text: "New to Maamaas? "),
//                       TextSpan(
//                         text: "Sign Up",
//                         style: GoogleFonts.nunito(
//                           color: logincolour.primary,
//                           fontWeight: FontWeight.w900,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 22.h),
//
//             // Stats row
//             _buildStatsRow(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTabRow() {
//     return Container(
//       // decoration: BoxDecoration(
//       //   color: primaryLight,
//       //   borderRadius: BorderRadius.circular(14.r),
//       // ),
//       padding: const EdgeInsets.all(4),
//       // child: Row(
//       //   children: [
//       //     _tabItem("Login", true),
//       //     _tabItem("Don't have an account?", false),
//       //   ],
//       // ),
//     );
//   }
//
//   Widget _fieldLabel(String label) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 7.h),
//       child: Text(
//         label.toUpperCase(),
//         style: GoogleFonts.nunito(
//           fontSize: 11.sp,
//           fontWeight: FontWeight.w800,
//           color: const Color(0xFFB0A0A0),
//           letterSpacing: 1.0,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       validator: validator,
//       style: GoogleFonts.nunito(
//         fontSize: 14.5.sp,
//         fontWeight: FontWeight.w600,
//         color: logincolour.dark,
//       ),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: GoogleFonts.nunito(
//           color: const Color(0xFFD0B8B0),
//           fontWeight: FontWeight.w600,
//         ),
//         prefixIcon: Icon(icon, color: logincolour.primary, size: 20.sp),
//         filled: true,
//         fillColor: logincolour.primaryLight,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14.r),
//           borderSide: const BorderSide(
//             color: logincolour.primaryBorder,
//             width: 1.5,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14.r),
//           borderSide: const BorderSide(
//             color: logincolour.primaryBorder,
//             width: 1.5,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14.r),
//           borderSide: const BorderSide(color: logincolour.primary, width: 1.8),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14.r),
//           borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
//         ),
//         contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
//       ),
//     );
//   }
//
//   Widget _buildPasswordField() {
//     return TextFormField(
//       controller: passwordcontroller,
//       obscureText: _obscurePassword,
//       style: GoogleFonts.nunito(
//         fontSize: 14.5.sp,
//         fontWeight: FontWeight.w600,
//         color: logincolour.dark,
//       ),
//       validator: (v) {
//         if (v == null || v.isEmpty) return 'Please enter password';
//         if (v.length < 6) return 'Min 6 characters';
//         return null;
//       },
//       decoration: InputDecoration(
//         hintText: "Enter your password",
//         hintStyle: GoogleFonts.nunito(
//           color: const Color(0xFFD0B8B0),
//           fontWeight: FontWeight.w600,
//         ),
//         prefixIcon: Icon(
//           Icons.lock_outline_rounded,
//           color: logincolour.primary,
//           size: 20.sp,
//         ),
//         suffixIcon: IconButton(
//           icon: Icon(
//             _obscurePassword
//                 ? Icons.visibility_off_outlined
//                 : Icons.visibility_outlined,
//             color: logincolour.muted,
//             size: 20.sp,
//           ),
//           onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//         ),
//         filled: true,
//         fillColor: logincolour.primaryLight,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14.r),
//           borderSide: const BorderSide(
//             color: logincolour.primaryBorder,
//             width: 1.5,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14.r),
//           borderSide: const BorderSide(
//             color: logincolour.primaryBorder,
//             width: 1.5,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14.r),
//           borderSide: const BorderSide(color: logincolour.primary, width: 1.8),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14.r),
//           borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
//         ),
//         contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
//       ),
//     );
//   }
//
//   Widget _buildLoginButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : _handleLogin,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: logincolour.primary,
//           disabledBackgroundColor: logincolour.primary.withOpacity(0.6),
//           padding: EdgeInsets.symmetric(vertical: 16.h),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.r),
//           ),
//           elevation: 0,
//         ),
//         child: _isLoading
//             ? SizedBox(
//                 width: 22.w,
//                 height: 22.w,
//                 child: const CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2.5,
//                 ),
//               )
//             : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Login",
//                     style: GoogleFonts.nunito(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w900,
//                       color: Colors.white,
//                       letterSpacing: 0.2,
//                     ),
//                   ),
//                   SizedBox(width: 10.w),
//                   Container(
//                     width: 28.w,
//                     height: 28.w,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(9.r),
//                     ),
//                     child: Icon(
//                       Icons.arrow_forward_rounded,
//                       color: Colors.white,
//                       size: 16.sp,
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
//
//   Widget _buildStatsRow() {
//     final stats = [
//       // {"num": "4.9★", "lbl": "Avg Rating"},
//       // {"num": "2min", "lbl": "Avg Pickup"},
//       // {"num": "₹850", "lbl": "Daily Avg"},
//     ];
//     return Row(
//       children: stats
//           .map(
//             (s) => Expanded(
//               child: Container(
//                 margin: EdgeInsets.only(
//                   right: s["lbl"] != "Daily Avg" ? 10.w : 0,
//                 ),
//                 padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
//                 decoration: BoxDecoration(
//                   color: logincolour.primaryLight,
//                   borderRadius: BorderRadius.circular(14.r),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       s["num"]!,
//                       style: GoogleFonts.nunito(
//                         fontSize: 17.sp,
//                         fontWeight: FontWeight.w900,
//                         color: logincolour.primary,
//                       ),
//                     ),
//                     SizedBox(height: 2.h),
//                     Text(
//                       s["lbl"]!,
//                       style: GoogleFonts.nunito(
//                         fontSize: 10.5.sp,
//                         color: const Color(0xFFC09080),
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           )
//           .toList(),
//     );
//   }
// }
//
// class _FloatingFoodItem extends StatefulWidget {
//   final String emoji;
//   final double size;
//   final Duration duration;
//   final Duration delay;
//   const _FloatingFoodItem({
//     required this.emoji,
//     required this.size,
//     required this.duration,
//     required this.delay,
//   });
//   @override
//   State<_FloatingFoodItem> createState() => _FloatingFoodItemState();
// }
//
// class _FloatingFoodItemState extends State<_FloatingFoodItem>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _c;
//   late Animation<double> _y;
//
//   @override
//   void initState() {
//     super.initState();
//     _c = AnimationController(vsync: this, duration: widget.duration)
//       ..repeat(reverse: true);
//     _y = Tween<double>(
//       begin: 0,
//       end: -8,
//     ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
//     Future.delayed(widget.delay, () {
//       if (mounted) _c.forward();
//     });
//   }
//
//   @override
//   void dispose() {
//     _c.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _y,
//       builder: (_, __) => Transform.translate(
//         offset: Offset(0, _y.value),
//         child: Container(
//           width: widget.size + 20.w,
//           height: widget.size + 20.w,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.13),
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: Colors.white.withOpacity(0.25),
//               width: 1.5,
//             ),
//           ),
//           child: Center(
//             child: Text(widget.emoji, style: TextStyle(fontSize: widget.size)),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _TwinklingDot extends StatefulWidget {
//   final Duration delay;
//   const _TwinklingDot({required this.delay});
//   @override
//   State<_TwinklingDot> createState() => _TwinklingDotState();
// }
//
// class _TwinklingDotState extends State<_TwinklingDot>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _c;
//   @override
//   void initState() {
//     super.initState();
//     _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))
//       ..repeat(reverse: true);
//   }
//
//   @override
//   void dispose() {
//     _c.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: Tween(
//         begin: 0.3,
//         end: 0.9,
//       ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
//       child: Container(
//         width: 5,
//         height: 5,
//         decoration: const BoxDecoration(
//           color: Colors.white54,
//           shape: BoxShape.circle,
//         ),
//       ),
//     );
//   }
// }
//
// class _SteamWidget extends StatefulWidget {
//   final Duration delay;
//   const _SteamWidget({required this.delay});
//   @override
//   State<_SteamWidget> createState() => _SteamWidgetState();
// }
//
// class _SteamWidgetState extends State<_SteamWidget>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _c;
//   late Animation<double> _opacity;
//   late Animation<double> _offset;
//
//   @override
//   void initState() {
//     super.initState();
//     _c = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     );
//     _opacity = TweenSequence([
//       TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.7), weight: 20),
//       TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.4), weight: 60),
//       TweenSequenceItem(tween: Tween(begin: 0.4, end: 0.0), weight: 20),
//     ]).animate(_c);
//     _offset = Tween(
//       begin: 0.0,
//       end: -22.0,
//     ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
//     Future.delayed(widget.delay, () {
//       if (mounted) _c.repeat();
//     });
//   }
//
//   @override
//   void dispose() {
//     _c.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _c,
//       builder: (_, __) => Transform.translate(
//         offset: Offset(0, _offset.value),
//         child: Opacity(
//           opacity: _opacity.value,
//           child: Container(
//             width: 4,
//             height: 18,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _ScooterWidget extends StatefulWidget {
//   const _ScooterWidget();
//   @override
//   State<_ScooterWidget> createState() => _ScooterWidgetState();
// }
//
// class _ScooterWidgetState extends State<_ScooterWidget>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _c;
//   late Animation<double> _x;
//   late Animation<double> _opacity;
//
//   @override
//   void initState() {
//     super.initState();
//     _c = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 4000),
//     )..repeat();
//
//     _x = Tween(
//       begin: -80.0,
//       end: 500.0,
//     ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
//     _opacity = TweenSequence([
//       TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
//       TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 80),
//       TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 10),
//     ]).animate(_c);
//   }
//
//   @override
//   void dispose() {
//     _c.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _c,
//       builder: (_, __) => Positioned(
//         bottom: 28.h,
//         left: _x.value,
//         child: Opacity(
//           opacity: _opacity.value,
//           child: SizedBox(
//             width: 72.w,
//             height: 44.h,
//             child: CustomPaint(painter: _ScooterPainter()),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _ScooterPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final p = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 2.5
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;
//
//     final fill = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.fill;
//
//     // Wheels
//     canvas.drawCircle(Offset(14, 34), 8, p);
//     canvas.drawCircle(Offset(57, 34), 8, p);
//     canvas.drawCircle(Offset(14, 34), 2.5, fill);
//     canvas.drawCircle(Offset(57, 34), 2.5, fill);
//
//     // Spokes
//     final spokeP = Paint()
//       ..color = Colors.white.withOpacity(0.5)
//       ..strokeWidth = 1;
//     canvas.drawLine(Offset(8, 34), Offset(20, 34), spokeP);
//     canvas.drawLine(Offset(14, 28), Offset(14, 40), spokeP);
//     canvas.drawLine(Offset(51, 34), Offset(63, 34), spokeP);
//     canvas.drawLine(Offset(57, 28), Offset(57, 40), spokeP);
//
//     // Frame
//     canvas.drawLine(Offset(14, 34), Offset(28, 20), p);
//     canvas.drawLine(Offset(28, 20), Offset(50, 20), p);
//     canvas.drawLine(Offset(50, 20), Offset(57, 34), p);
//     canvas.drawLine(Offset(36, 20), Offset(36, 34), p);
//
//     // Handlebar
//     canvas.drawLine(Offset(52, 20), Offset(52, 12), p);
//     canvas.drawLine(Offset(48, 12), Offset(58, 12), p);
//
//     // Package box
//     final boxFill = Paint()
//       ..color = Colors.white.withOpacity(0.25)
//       ..style = PaintingStyle.fill;
//     final boxRect = RRect.fromRectAndRadius(
//       const Rect.fromLTWH(22, 6, 26, 18),
//       const Radius.circular(5),
//     );
//     canvas.drawRRect(boxRect, boxFill);
//     canvas.drawRRect(
//       boxRect,
//       Paint()
//         ..color = Colors.white
//         ..strokeWidth = 2.0
//         ..style = PaintingStyle.stroke,
//     );
//
//     // Box cross lines
//     final linePaint = Paint()
//       ..color = Colors.white.withOpacity(0.5)
//       ..strokeWidth = 1;
//     canvas.drawLine(Offset(35, 6), Offset(35, 24), linePaint);
//     canvas.drawLine(Offset(22, 15), Offset(48, 15), linePaint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter old) => false;
// }
