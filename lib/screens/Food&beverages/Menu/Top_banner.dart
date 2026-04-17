import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Models/food/aboutus_model.dart';
import '../../../Models/food/restaurent_banner_model.dart';
import '../../../Models/food/team_model.dart';
import 'Menuhelper.dart';
import 'colours.dart';
import 'menu_screen.dart';

class BannerSection extends StatefulWidget {
  final bool isVeg;
  final int vendorId;
  final Function(bool) onToggle;
  final Function(String) onSearch;
  final Restaurent_Banner? bannerItem;
  final AboutUsModel? aboutus;
  final List<vendorteam> team;
  final Function(BannerContentType) onContentSelected;

  const BannerSection({
    super.key,
    required this.isVeg,
    required this.vendorId,
    required this.onToggle,
    required this.onSearch,
    required this.bannerItem,
    required this.aboutus,
    required this.team,
    required this.onContentSelected,
  });

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  late bool _isVeg;
  String orderType = "";

  @override
  void initState() {
    super.initState();
    _isVeg = widget.isVeg;
    _loadOrderType();
  }

  ImageProvider _getImage(String img) {
    if (img.startsWith('http')) return NetworkImage(img);
    return MemoryImage(base64Decode(img));
  }

  bool _hasValidLink(String? url) {
    if (url == null) return false;
    final clean = url.trim();
    return clean.isNotEmpty &&
        (clean.startsWith('http://') || clean.startsWith('https://'));
  }

  Future<void> _openLink(String url) async {
    try {
      final uri = Uri.parse(url.trim());
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('URL Launch Error: $e');
    }
  }

  Widget _socialIcon(IconData icon, String url) {
    return GestureDetector(
      onTap: () => _openLink(url),
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
        ),
        child: Center(
          child: FaIcon(icon, color: Colors.white, size: 15.sp),
        ),
      ),
    );
  }

  Future<void> _loadOrderType() async {
    final prefs = await SharedPreferences.getInstance();
    final type = prefs.getString("orderType") ?? "";

    if (mounted) {
      setState(() {
        orderType = type;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final banner = widget.bannerItem;

    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background
              if (banner != null && banner.companyBanner.isNotEmpty)
                Image(image: _getImage(banner.companyBanner), fit: BoxFit.cover)
              else
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A1208), Color(0xFF2A1A0C)],
                    ),
                  ),
                ),

              // Glow overlay
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.4, -0.3),
                    radius: 1.0,
                    colors: [
                      const Color(0xFFC88C3C).withOpacity(0.30),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Bottom-heavy scrim
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.45, 1.0],
                    colors: [
                      Color(0x22000000),
                      Color(0x88000000),
                      Color(0xF5060300),
                    ],
                  ),
                ),
              ),

              // Top: Year & Name
              Positioned(
                top: 80.h,
                left: 16.w,
                right: 16.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'EST. ${banner?.establishedYear ?? "2003"}',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                        color: const Color(0xFFC88C3C),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      banner?.companyName.toUpperCase() ?? 'TEST RESTAURANT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'YourSerifFont',
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              // Social icons below name
              Positioned(
                top: 150.h,
                left: 16.w,
                right: 16.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_hasValidLink(banner?.whatsappLink))
                      _socialIcon(
                        FontAwesomeIcons.whatsapp,
                        banner!.whatsappLink,
                      ),
                    if (_hasValidLink(banner?.instagramLink))
                      _socialIcon(
                        FontAwesomeIcons.instagram,
                        banner!.instagramLink,
                      ),
                    if (_hasValidLink(banner?.facebookLink))
                      _socialIcon(
                        FontAwesomeIcons.facebook,
                        banner!.facebookLink,
                      ),
                    if (_hasValidLink(banner?.twitterLink))
                      _socialIcon(
                        FontAwesomeIcons.twitter,
                        banner!.twitterLink,
                      ),
                    if (_hasValidLink(banner?.youtubeLink))
                      _socialIcon(
                        FontAwesomeIcons.youtube,
                        banner!.youtubeLink,
                      ),
                    if (_hasValidLink(banner?.linkedinLink))
                      _socialIcon(
                        FontAwesomeIcons.linkedin,
                        banner!.linkedinLink,
                      ),
                  ],
                ),
              ),

              // Time and distance
              Positioned(
                bottom: 10.h,
                left: 16.w,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // if (banner?.distance != null)
                      //   Text(
                      //     " ${Distancehelpermethod.formatDistance(banner!.distance)}",
                      //     style: TextStyle(
                      //       fontSize: 12.sp,
                      //       fontWeight: FontWeight.w600,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      if ((banner?.addressLine ?? '').isNotEmpty)
                        Text(
                          "📍${banner!.addressLine}, ${banner.city}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Action buttons at bottom
              if (orderType != "CATERING")
                Positioned(
                  bottom: 50.h,
                  left: 16.w,
                  right: 16.w,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // ⏰ Timing Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (banner?.startTime != null &&
                              banner!.startTime.trim().isNotEmpty)
                            Row(
                              children: [
                                Text(
                                  "Opening: ",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  banner.startTime,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                          SizedBox(height: 4.h),

                          if (banner?.lastTime != null &&
                              banner!.lastTime.trim().isNotEmpty)
                            Row(
                              children: [
                                Text(
                                  "Closing: ",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  banner.lastTime,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      const Spacer(),

                      // 🎯 Buttons
                      Row(
                        children: [
                          _actionButton(
                            'About Us',
                            () => widget.onContentSelected(
                              BannerContentType.about,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _actionButton(
                            'Gallery',
                            () => widget.onContentSelected(
                              BannerContentType.gallery,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Filter bar (unchanged)
        Container(
          height: 60.h,
          color: Menucolours.surface,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            children: [
              Expanded(
                child: SearchField(
                  onSearch: widget.onSearch,
                  fillColor: Menucolours.surfaceAlt,
                ),
              ),
              SizedBox(width: 10.w),
              VegToggle(
                isVeg: _isVeg,
                onToggle: (v) {
                  setState(() => _isVeg = v);
                  widget.onToggle(v);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    String text,
    VoidCallback onTap, {
    bool primary = false,
  }) {
    return GestureDetector(
      onTap: () {
        // print("tapped"); // ✅ correct place
        onTap(); // call original function
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: primary
              ? const Color(0xFFC88C3C).withOpacity(0.20)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: primary
                ? const Color(0xFFC88C3C).withOpacity(0.50)
                : Colors.white.withOpacity(0.12),
            width: 0.8,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
