import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Services/Auth_service/food_authservice.dart';
import '../../widgets/widgets/food/favoritesbutton_1.dart';
import '../Food&beverages/Menu/cart_button.dart';
import '../../Models/food/favorites_model.dart';
import 'package:flutter/material.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  // int? userId;
  List<FavoriteDish> favoriteDishes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() => Container(
    color: const Color(0xFFF5F5F0),
    child: Icon(Icons.restaurant, size: 36.sp, color: Colors.black12),
  );

  Future<void> _loadFavorites() async {
    try {
      final fetched = await food_Authservice.getFavoritesByUserId();
      setState(() {
        favoriteDishes = fetched;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error: $e");
    }
  }

  int _crossAxisCount(double width) {
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),

          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16.sp,
            color: const Color(0xFF1A1D2E),
          ),
        ),
        title: Text(
          'My Favourites',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1D2E),
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteDishes.isEmpty
          ? _emptyState()
          : LayoutBuilder(
              builder: (context, constraints) {
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final dish = favoriteDishes[index];
                          return ModernDishCard(
                            key: ValueKey(dish.favId), // ✅ ADD THIS
                            imageWidget: _buildImage(dish.dishImage),
                            name: dish.dishName ?? '',
                            price: '₹${dish.price}',
                            effectivePrice: '₹${dish.effectivePrice}',
                            favoriteButton: FavoriteButton1(
                              favId: dish.favId,
                              onFavoriteToggled: () {
                                setState(() {
                                  favoriteDishes.removeWhere(
                                    (d) => d.favId == dish.favId,
                                  );
                                });
                              },
                            ),
                            cartButton: CartButton(
                              dishId: dish.dishId ?? 0,
                              balanceQuantity: dish.balanceQuantity,
                            ),
                            isOutOfStock: false,
                          );
                        }, childCount: favoriteDishes.length),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _crossAxisCount(constraints.maxWidth),
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 0.72,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                  ],
                );
              },
            ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.favorite_border_rounded, size: 56.sp, color: Colors.black12),
        SizedBox(height: 16.h),
        Text(
          'No favourites yet',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black45,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Dishes you love will appear here',
          style: TextStyle(fontSize: 13.sp, color: Colors.black26),
        ),
      ],
    ),
  );
}

class ModernDishCard extends StatelessWidget {
  final Widget imageWidget;
  final String name;
  final String price;
  final String effectivePrice;
  final Widget favoriteButton;
  final Widget cartButton;
  final bool isOutOfStock;

  const ModernDishCard({
    required this.imageWidget,
    required this.name,
    required this.price,
    required this.effectivePrice,
    required this.favoriteButton,
    required this.cartButton,
    required this.isOutOfStock,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isOutOfStock,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image ────────────────────────────────────────────────
                Expanded(
                  flex: 55,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    child: SizedBox(width: double.infinity, child: imageWidget),
                  ),
                ),

                // ── Favourite icon (top-right overlay handled below) ─────
                // ── Name + Price + Cart ───────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 0),
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: const Color(0xFF1A1D2E),
                    ),
                  ),
                ),

                SizedBox(height: 4.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Text(
                    price,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1D2E),
                    ),
                  ),
                ),

                // SizedBox(height: 8.h),
                //
                // Padding(
                //   padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.h),
                //   child: SizedBox(width: double.infinity, child: cartButton),
                // ),
              ],
            ),

            // ── Favourite button ─────────────────────────────────────────
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                width: 30.r,
                height: 30.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Center(child: favoriteButton),
              ),
            ),

            // ── Out-of-stock overlay ─────────────────────────────────────
            // if (isOutOfStock)
            // Positioned(
            //   top: 0,
            //   left: 0,
            //   right: 0,
            //   bottom: 0,
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(16.r),
            //     child: Container(
            //       color: Colors.white.withOpacity(0.65),
            //       alignment: Alignment.center,
            //       child: Container(
            //         padding: EdgeInsets.symmetric(
            //           horizontal: 12.w,
            //           vertical: 5.h,
            //         ),
            //         decoration: BoxDecoration(
            //           color: Colors.black.withOpacity(0.55),
            //           borderRadius: BorderRadius.circular(20.r),
            //         ),
            //         child: Text(
            //           'Out of Stock',
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 11.sp,
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
