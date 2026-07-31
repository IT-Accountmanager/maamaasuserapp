import 'package:maamaas/screens/Food&beverages/distancehelpermethod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Services/App_color_service/app_colours.dart';
import '../../Services/Auth_service/guest_Authservice.dart';
import '../../Models/food/restaurent_banner_model.dart';
import 'package:flutter/material.dart';
import '../Food&beverages/RestaurentsScreen/RestaurentsHelper.dart';
import 'Catering_vedor_screen.dart';
import 'customised_menu.dart';

class CateringsPage extends StatefulWidget {
  const CateringsPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _CateringsPageState createState() => _CateringsPageState();
}

class _CateringsPageState extends State<CateringsPage> {
  late Future<List<Restaurent_Banner>> _bannersFuture;
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _bannersFuture = Authservice.fetchnearbyresturents();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(child: _buildButton("Packages", 0)),
              const SizedBox(width: 10),
              Expanded(child: _buildButton("Custom Menu", 1)),
            ],
          ),
        ),

        SizedBox(
          height: MediaQuery.of(context).size.height * 0.50,
          child: selectedIndex == 0 ? buildpackagedcards() : CustomisedMenu(),
        ),
      ],
    );
  }

  Widget _buildButton(String text, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : AppColors.primary,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget buildpackagedcards() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildtopcaterers()],
      ),
    );
  }

  Widget _buildtopcaterers() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FutureBuilder<List<Restaurent_Banner>>(
              future: _bannersFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No banners available"));
                }

                final banners = snapshot.data!
                    .where(
                      (banner) => banner.orderTypes
                          .map((e) => e.toLowerCase())
                          .contains("catering"),
                    )
                    .toList();

                if (banners.isEmpty) {
                  return const Center(child: Text("No catering vendors found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    final banner = banners[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CateringVendorScreen(vendorId: banner.vendorId),
                          ),
                        );
                      },
                      child: IntrinsicHeight(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: restaurentsnewcolour.surface,
                            borderRadius: BorderRadius.circular(
                              restaurentsnewcolour.cardRadius.r,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // IMAGE
                              AspectRatio(
                                aspectRatio: 10 / 4,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                          restaurentsnewcolour.cardRadius.r,
                                        ),
                                      ),
                                      child: banner.companyBanner.isNotEmpty
                                          ? Image.network(
                                              banner.companyBanner,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _placeholder(),
                                            )
                                          : _placeholder(),
                                    ),

                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      height: 60,
                                      child: const DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Color(0x66000000),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // INFO
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 10.h,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            banner.companyName.toUpperCase(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              color: restaurentsnewcolour.text,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 6.h),

                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${banner.addressLine}, ${banner.city}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: restaurentsnewcolour
                                                  .textLight,
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 8.w),

                                        Text(
                                          Distancehelpermethod.formatDistance(
                                            banner.distance,
                                          ),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                restaurentsnewcolour.textMuted,
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    color: restaurentsnewcolour.bg,
    child: Center(
      child: Icon(
        Icons.restaurant_rounded,
        size: 32.sp,
        color: restaurentsnewcolour.textLight,
      ),
    ),
  );

  /// Small read-only info chip used in the caterer card.
  Widget _infoChip({
    required IconData icon,
    required String label,
    bool highlighted = false,
  }) {
    const accent = Color(0xFFFF7043);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: highlighted ? accent.withOpacity(0.10) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          // ignore: deprecated_member_use
          color: highlighted ? accent.withOpacity(0.40) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11.sp,
            color: highlighted ? accent : Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400,
              color: highlighted ? accent : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
