import 'package:flutter/material.dart';

import '../../Models/subscrptions/coupon_model.dart';

class CouponsOffersSection extends StatelessWidget {
  CouponsOffersSection({super.key});

  @override
  // Widget build(BuildContext context) {
  //   return FutureBuilder<List<CouponModel>>(
  //     future: subscription_AuthService.fetchCoupons(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const SizedBox(
  //           height: 140,
  //           child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
  //         );
  //       }
  //
  //       if (snapshot.hasError) {
  //         return Container(
  //           height: 140,
  //           alignment: Alignment.center,
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Icon(Icons.error_outline, color: Colors.grey[400], size: 40),
  //               const SizedBox(height: 8),
  //               Text(
  //                 "Failed to load offers",
  //                 style: TextStyle(color: Colors.grey[600]),
  //               ),
  //             ],
  //           ),
  //         );
  //       }
  //
  //       snapshot.data!.where((c) => c.active && !c.isExpired).toList();
  //
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // const Padding(
  //           //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  //           //   child: Row(
  //           //     children: [
  //           //       Icon(
  //           //         Icons.local_offer_outlined,
  //           //         size: 20,
  //           //         color: Color(0xFF6B7280),
  //           //       ),
  //           //       SizedBox(width: 8),
  //           //       Text(
  //           //         "Offers & Coupons",
  //           //         style: TextStyle(
  //           //           fontSize: 18,
  //           //           fontWeight: FontWeight.w600,
  //           //           color: Color(0xFF111827),
  //           //         ),
  //           //       ),
  //           //     ],
  //           //   ),
  //           // ),
  //
  //           // SizedBox(
  //           //   height: 140,
  //           //   child: ListView.separated(
  //           //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //           //     scrollDirection: Axis.horizontal,
  //           //     physics: const BouncingScrollPhysics(),
  //           //     itemCount: coupons.length + 2,
  //           //     separatorBuilder: (_, __) => const SizedBox(width: 16),
  //           //     itemBuilder: (context, index) {
  //           //       const double cardWidth = 280;
  //           //
  //           //       if (index < coupons.length) {
  //           //         return SizedBox(
  //           //           width: cardWidth,
  //           //           child: CouponCard(coupon: coupons[index], index: index)
  //           //         );
  //           //       }
  //           //
  //           //       return SizedBox(
  //           //         width: cardWidth,
  //           //         child: _staticCouponCard(index - coupons.length),
  //           //       );
  //           //     },
  //           //   ),
  //           // ),
  //           SizedBox(
  //             height: 120,
  //             child: ListView.separated(
  //               padding: const EdgeInsets.symmetric(horizontal: 10),
  //               scrollDirection: Axis.horizontal,
  //               physics: const BouncingScrollPhysics(),
  //               itemCount: 2, // 👈 number of static cards
  //               separatorBuilder: (_, __) => const SizedBox(width: 16),
  //               itemBuilder: (context, index) {
  //                 const double cardWidth = 280;
  //
  //                 return SizedBox(
  //                   width: cardWidth,
  //                   child: _staticCouponCard(index),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 2, // 👈 number of static cards
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              const double cardWidth = 280;

              return SizedBox(
                width: cardWidth,
                child: _staticCouponCard(index),
              );
            },
          ),
        ),
      ],
    );
  }

  final List<Map<String, dynamic>> staticCoupons = [
    {
      "headline": "Authentic Taste. Fantastic Savings.",
      "title": "First Order",
      "offer": "Get Flat ₹25 OFF on Your First Order!",
      // "description": "",
      "type": "REFER",
      // "icon": Icons.group_add_outlined,
      "gradient": const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber
      ),
      "iconBg": Color(0xFFEEF2FF),
      "badge": "LIMITLESS",
    },
    // {
    //   "headline": "Invite Friends. Unlock Rewards.",
    //   "title": "Refer & Earn",
    //   "offer": "Earn ₹25 Cashback Per Referral!",
    //   // "description": "",
    //   "type": "REFER",
    //   // "icon": Icons.group_add_outlined,
    //   "gradient": const LinearGradient(
    //     begin: Alignment.topLeft,
    //     end: Alignment.bottomRight,
    //     colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    //   ),
    //   "iconBg": Color(0xFFEEF2FF),
    //   "badge": "LIMITLESS",
    // },
    {
      "headline": "Recharge More. Earn More.",
      "title": "Wallet Recharge",
      "offer": "Get a Flat 10% Cashback!",
      // "description": "",
      "type": "WALLET",
      // "icon": Icons.account_balance_wallet_outlined,
      "gradient": const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF059669), Color(0xFF10B981)],
      ),
      "iconBg": Color(0xFFECFDF5),
      "badge": "HOT DEAL",
    },
  ];

  Widget _staticCouponCard(int index) {
    final data = staticCoupons[index];

    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: data["gradient"] as LinearGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative Circle
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data["headline"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // const Spacer(),
                const SizedBox(height: 6),

                // Offer
                Text(
                  data["offer"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final int index;

  const CouponCard({super.key, required this.coupon, required this.index});

  LinearGradient get _cardGradient {
    final gradients = [
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFC026D3), Color(0xFF7C3AED)], // Purple
      ),
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)], // Blue
      ),
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF059669), Color(0xFF10B981)], // Green
      ),
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber
      ),
    ];

    return gradients[index % gradients.length];
  }

  Color get _iconBackground {
    if (coupon.couponType == "PERCENTAGE") {
      return const Color(0xFFF3E8FF);
    } else if (coupon.couponType == "FLAT") {
      return const Color(0xFFFEF3C7);
    } else {
      return const Color(0xFFE0F2FE);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: _cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative Circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: 10,
            bottom: -40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _iconBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.local_offer_outlined,
                      size: 24,
                      color: _cardGradient.colors[0],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            coupon.couponType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          // ),
                          const SizedBox(width: 3),

                          // Discount Amount
                          Text(
                            coupon.discountType == "PERCENTAGE"
                                ? "${coupon.discountPercentage.toStringAsFixed(0)}% OFF"
                                : "₹${coupon.discountPercentage.toStringAsFixed(0)} OFF",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Coupon Code
                      Text(
                        coupon.code,
                        style: TextStyle(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Minimum Order
                      Row(
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 12,
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            coupon.minimumOrderValue <= 0
                                ? "No minimum order"
                                : "Min. order ₹${coupon.minimumOrderValue.toInt()}",
                            style: TextStyle(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
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
        ],
      ),
    );
  }
}
