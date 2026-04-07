import '../../widgets/widgets/catering/catering_cart_count.dart';
import '../../Services/Auth_service/catering_authservice.dart';
import '../../widgets/widgets/catering/cartbutton.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '../../Models/caterings/packages_model.dart';
import '../../Models/caterings/aboutusmodel.dart';
import '../../Models/caterings/banner_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class RestaurantDetailScreen extends StatefulWidget {
  final String? vendorId;
  const RestaurantDetailScreen({super.key, this.vendorId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  Set<String> selectedItems = {};
  bool isVeg = true;
  int selectedTabIndex = 0;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            backgroundColor: Colors.white,
            expandedHeight: 50,
            toolbarHeight: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                child: SafeArea(
                  bottom: false,
                  child: AppBar(title: const Text("Menu"), centerTitle: true),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                TopRestaurantCard(
                  onExpandChange: (expanded) {
                    debugPrint("Card expanded: $expanded");
                  },
                  vendorId: widget.vendorId!,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // 🔹 Sticky tabs only
          SliverPersistentHeader(
            pinned: true,
            delegate: _MenuFilterTabsDelegate(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: MenuFilterBar(
                  isVeg: isVeg,
                  onToggle: (val) => setState(() => isVeg = val),
                  onSearch: (val) => setState(() => searchQuery = val),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MenuTabContent(
                  isVeg: isVeg,
                  vendorId: widget.vendorId!,
                  searchQuery: searchQuery,
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 120, // your button width
        child: catering_Cart_count(),
      ),
    );
  }
}

class TopRestaurantCard extends StatefulWidget {
  final String vendorId;
  final void Function(bool isExpanded) onExpandChange;

  const TopRestaurantCard({
    super.key,
    required this.onExpandChange,
    required this.vendorId,
  });

  @override
  State<TopRestaurantCard> createState() => _TopRestaurantCardState();
}

class _TopRestaurantCardState extends State<TopRestaurantCard> {
  final bool _showKnowMore = false;
  final bool _showGallery = false;
  final List<String> _images = [];
  bool _isLoading = true;
  catering_BannerModel? _banner;
  AboutUsModel? _aboutUsModel;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    _loadBanner();
    _loadAboutUs();
  }

  Future<void> _loadBanner() async {
    try {
      final banner = await catering_authservice.fetchBannerById(
        widget.vendorId,
      );
      if (mounted) {
        setState(() {
          _banner = banner;
          _isLoading = false; // ✅ stop loading
        });
      }
    } catch (e) {
      debugPrint("⚠️ Error loading banner: $e");
      if (mounted) {
        setState(() {
          _isLoading = false; // ✅ even if error, stop loading
        });
      }
    }
  }

  Future<void> _loadAboutUs() async {
    final result = await catering_authservice.fetchAboutUsData(widget.vendorId);
    if (result != null && mounted) {
      setState(() {
        _aboutUsModel = result;
        _images
          ..clear()
          ..addAll(result.allImages);
      });
    }
  }


  ImageProvider _getImageProvider(String imageString) {
    if (imageString.startsWith('http')) {
      return NetworkImage(imageString);
    } else {
      return MemoryImage(base64Decode(imageString));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_banner == null) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text("No banner available")),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerSection(),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildAboutUsSection(),
              crossFadeState: _showKnowMore
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),

            // Gallery Section
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildGallerySection(),
              crossFadeState: _showGallery
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    if (_banner == null) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with overlay
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _banner!.companyBanner.isNotEmpty
                      ? _getImageProvider(_banner!.companyBanner) // ✅ FIX HERE
                      : const AssetImage('assets/gallery-img-1.jpg')
                            as ImageProvider,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),

            // Positioned(
            //   bottom: 10, // above social icons
            //   left: 0,
            //   right: 0,
            //   child: Center(child: _buildInfoAndActionsSection(context)),
            // ),

            // Company name & year
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      _banner!.companyName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _banner!.establishedYear,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            // Social icons row
            // Positioned(
            //   bottom: 10,
            //   left: 0,
            //   right: 0,
            //   child: Center(child: _buildSocialIconsRow(_banner!)),
            // ),
          ],
        ),
      ),
    );
  }



  Widget _buildAboutUsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "ABOUT US",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              _aboutUsModel?.aboutUs ?? "No About Us info available.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),

          // Row for Mission and Vision
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // MISSION
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/misionn.jpg',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Mission",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _aboutUsModel?.mission ?? "No mission data is available",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // VISION
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/vision.jpg',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Vision",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _aboutUsModel?.vision ?? "No mission data is available.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    if (_images.isEmpty) {
      return Center(
        child: Text(
          "No images available",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      height: 80,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final img = imageUrls[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildNetworkImage(img),
          );
        },
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackImage(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            width: 80,
            height: 80,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

}

class _MenuFilterTabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _MenuFilterTabsDelegate({
    required this.child,
    this.height = 65, // default height
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant _MenuFilterTabsDelegate oldDelegate) {
    // Return true if the widget should rebuild when the delegate changes
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

class MenuFilterBar extends StatefulWidget {
  final bool isVeg;
  final Function(bool) onToggle; // required
  // final int selectedFilterIndex;
  // final Function(int) onTabChange; // required
  // final bool showOnlyTabs;
  final Function(String) onSearch;
  const MenuFilterBar({
    super.key,
    required this.isVeg,
    required this.onToggle,
    // required this.onTabChange,
    // this.selectedFilterIndex = 0,
    // this.showOnlyTabs = false,
    required this.onSearch,
  });

  @override
  State<MenuFilterBar> createState() => _MenuFilterBarState();
}

class _MenuFilterBarState extends State<MenuFilterBar> {
  bool _isVeg = true;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _isVeg = widget.isVeg;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Veg/Non-Veg Switch
              FlutterSwitch(
                width: 85.0,
                height: 40.0,
                toggleSize: 30.0,
                borderRadius: 20.0,
                value: _isVeg,
                showOnOff: true,
                activeColor: Colors.green,
                inactiveColor: Colors.red,
                activeToggleColor: Colors.white,
                inactiveToggleColor: Colors.white,
                activeText: "Veg",
                inactiveText: "Non-Veg",
                valueFontSize: 10.0,
                toggleColor: Colors.white70,
                onToggle: (val) {
                  setState(() => _isVeg = val);
                  widget.onToggle(val);
                },
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: widget.onSearch,
                  decoration: InputDecoration(
                    hintText: "Search dishes or packages",
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class MenuTabContent extends StatefulWidget {
  final String vendorId;
  final bool isVeg;
  final String searchQuery;

  const MenuTabContent({
    super.key,
    required this.isVeg,
    required this.vendorId,
    required this.searchQuery,
  });

  @override
  State<MenuTabContent> createState() => _MenuTabContentState();
}

class _MenuTabContentState extends State<MenuTabContent> {
  List<Package> _packages = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadPackage();
  }

  Future<void> _loadPackage() async {
    final packages = await catering_authservice.fetchPackageById(
      widget.vendorId,
    );
    setState(() {
      _packages = packages;
      _isLoading = false;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredPackages = _packages.where((pkg) {
      final type = pkg.packageType.toLowerCase();
      final matchesVeg = widget.isVeg ? type == "veg" : type == "non_veg";

      final query = widget.searchQuery.toLowerCase();

      final matchesPackageName = pkg.packageName.toLowerCase().contains(query);

      final matchesItemName = pkg.items.any(
        (item) => item.itemName.toLowerCase().contains(query),
      );

      return matchesVeg &&
          (query.isEmpty || matchesPackageName || matchesItemName);
    }).toList();

    if (filteredPackages.isEmpty) {
      return Center(
        child: Text(
          widget.isVeg ? "No Veg packages found" : "No Non-Veg packages found",
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      shrinkWrap: true, // 👈 fix
      physics:
          const NeverScrollableScrollPhysics(), // 👈 prevent nested scrolling
      itemCount: filteredPackages.length,
      itemBuilder: (context, index) {
        final package = filteredPackages[index];
        return Card(
          color: Colors.white,
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Title + Type
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${package.packageName} (${package.items.length} items)",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        VegNonVegIcon(type: package.packageType),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 🔹 Item list
                    ...package.items.map(
                      (item) => Row(
                        children: [
                          const Icon(Icons.circle, size: 6, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(item.itemName),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 🔹 Price + Add to Cart
                    Row(
                      children: [
                        Text(
                          "₹${package.totalPrice}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        const Spacer(),
                        // _buildAddToCartButton(package, context),
                        CateringCartButton(package: package),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class VegNonVegIcon extends StatelessWidget {
  final String type; // "Veg" or "Non_veg"
  final double size;

  const VegNonVegIcon({super.key, required this.type, this.size = 20});

  @override
  Widget build(BuildContext context) {
    final bool isVeg = type.toLowerCase() == "veg";

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: isVeg ? Colors.green : Colors.red, width: 2),
        shape: BoxShape.rectangle,
      ),
      child: Center(
        child: Container(
          width: size / 2,
          height: size / 2,
          decoration: BoxDecoration(
            color: isVeg ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
