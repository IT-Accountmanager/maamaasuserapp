


import 'package:maamaas/screens/screens/supportteam/tickets_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// ── Design Tokens ─────────────────────────────────────────────────────────────
class _T {
  static const bg = Color(0xFFF6F7F9);
  static const surface = Colors.white;
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const accent = Color(0xFF2563EB);
  static const accentLight = Color(0xFFEFF6FF);
  static const green = Color(0xFF16A34A);

  static const h2 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: ink,
    letterSpacing: -0.2,
  );
  static const body = TextStyle(fontSize: 13, color: muted, height: 1.5);
  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: muted,
    letterSpacing: 0.6,
  );
}

// ── FAQ Data ──────────────────────────────────────────────────────────────────
const _faqs = {
  "Coupons & Offers": {
    "icon": Icons.local_offer_outlined,
    "items": [
      "Coupon not working / expired coupon",
      "How do I apply a coupon?",
      "Why can't I use multiple offers?",
    ],
  },
  "General Enquiry": {
    "icon": Icons.help_outline_rounded,
    "items": [
      "How do I sign up or log in?",
      "Can I change my email or phone number?",
      "How do I delete my account?",
    ],
  },
  "Orders & Products": {
    "icon": Icons.shopping_bag_outlined,
    "items": [
      "How do I place or cancel an order?",
      "What if I received the wrong item?",
      "How to track my order?",
    ],
  },
  "Payment": {
    "icon": Icons.credit_card_outlined,
    "items": [
      "My payment failed, what should I do?",
      "How do I request a refund?",
      "What payment methods are supported?",
    ],
  },
  "Feedback": {
    "icon": Icons.rate_review_outlined,
    "items": [
      "How do I submit feedback?",
      "Where can I suggest new features?",
      "Is my feedback rewarded?",
    ],
  },
};

class Supportteam extends StatefulWidget {
  const Supportteam({super.key});
  @override
  State<Supportteam> createState() => _SupportteamState();
}

class _SupportteamState extends State<Supportteam> {
  String? _openFaq;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: _T.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _T.ink),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "How can we help you?",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _T.ink,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: _T.border),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _heroBanner(),
            Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Quick Actions ───────────────────────────────────
                  // _sectionLabel("Services"),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: _actionCard(
                          icon: Icons.confirmation_number_outlined,
                          label: "Raise Ticket",
                          color: _T.accent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CreateTicketScreen()),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _actionCard(
                          icon: Icons.list_alt_outlined,
                          label: "My Tickets",
                          color: _T.green,
                          onTap: () async {
                            final prefs =
                            await SharedPreferences.getInstance();
                            final userId = prefs.getInt('userId') ?? 0;
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      TicketListScreen(userId: userId)),
                            );
                          },
                        ),
                      ),
                      // SizedBox(width: 10.w),
                      // Expanded(
                      //   child: _actionCard(
                      //     icon: Icons.phone_outlined,
                      //     label: "Call Us",
                      //     color: _T.amber,
                      //     onTap: _makeSupportCall,
                      //   ),
                      // ),
                    ],
                  ),

                  SizedBox(height: 28.h),

                  // ── FAQ ─────────────────────────────────────────────
                  _sectionLabel("FAQs"),
                  SizedBox(height: 10.h),
                  ..._faqs.entries.map((e) => _faqItem(e.key, e.value)),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────


  // ── Section Label ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
              color: _T.ink, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Text(text.toUpperCase(), style: _T.label.copyWith(color: _T.ink)),
      ],
    );
  }

  // ── Action Cards ──────────────────────────────────────────────────────────
  Widget _actionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _T.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _T.ink,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── FAQ Item ──────────────────────────────────────────────────────────────
  Widget _faqItem(String title, Map<String, dynamic> data) {
    final isOpen = _openFaq == title;
    final icon = data["icon"] as IconData;
    final items = data["items"] as List<String>;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isOpen ? _T.accent.withOpacity(0.3) : _T.border,
          width: isOpen ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () =>
                setState(() => _openFaq = isOpen ? null : title),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(12.r),
              bottom: Radius.circular(isOpen ? 0 : 12.r),
            ),
            child: Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? _T.accentLight
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(icon,
                        size: 16,
                        color: isOpen ? _T.accent : _T.muted),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(title, style: _T.h2),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: _T.muted,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen) ...[
            Divider(height: 1, color: _T.border),
            Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Column(
                children: items
                    .map((q) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        margin: EdgeInsets.only(top: 5.h, right: 10.w),
                        decoration: const BoxDecoration(
                          color: _T.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(q,
                            style: _T.body.copyWith(fontSize: 13)),
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}