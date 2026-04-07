import 'package:maamaas/screens/Food&beverages/distancehelpermethod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  @override
  void initState() {
    super.initState();
    _bannersFuture = Authservice.fetchnearbyresturents();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            indicatorColor: const Color(0xFFFF7043),
            tabs: const [
              Tab(text: "Packages"),
              Tab(text: "Custom Menu"),
            ],
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: TabBarView(
              children: [buildpackagedcards(), CustomisedMenu()],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildpackagedcards() {
    return Container(
      color: Colors.white,
      // padding: const EdgeInsets.all(10),
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
                            builder: (_) => RestaurantDetailScreen(
                              vendorId: banner.vendorId.toString(),
                            ),
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
                              /// Image
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

                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${banner.addressLine}, ${banner.city}",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        Text(
                                          Distancehelpermethod.formatDistance(
                                            banner.distance,
                                          ),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
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
}
