import 'package:maamaas/screens/Food&beverages/distancehelpermethod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Services/App_color_service/app_colours.dart';
import '../../Services/Auth_service/guest_Authservice.dart';
import '../../Models/food/restaurent_banner_model.dart';
import 'package:flutter/material.dart';
import 'Catering_vedor_screen.dart';
import 'customised_menu.dart';

class CateringsPage extends StatefulWidget {
  const CateringsPage({super.key});
  @override
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
          height: MediaQuery.of(context).size.height * 0.55,
          child: selectedIndex == 0
              ? buildpackagedcards()
              : CustomisedMenu(),
        ),
      ],
    );
  }Widget _buildButton(String text, int index) {
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
          color: isSelected
              ? Colors.green
              : AppColors.primary,
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
            child: Text(
              "Top Caterers",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
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
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Banner image
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  banner.companyBanner,
                                  height: 120.h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      banner.companyName.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),

                                    // ── Chips row (address + city + distance) ──
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        _infoChip(
                                          icon: Icons.location_on_outlined,
                                          label: banner.addressLine,
                                        ),
                                        _infoChip(
                                          icon: Icons.location_city_outlined,
                                          label: banner.city,
                                        ),
                                        _infoChip(
                                          icon: Icons.near_me_outlined,
                                          label:
                                              Distancehelpermethod.formatDistance(
                                                banner.distance,
                                              ),
                                          highlighted: true,
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),
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
        color: highlighted ? accent.withOpacity(0.10) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
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
