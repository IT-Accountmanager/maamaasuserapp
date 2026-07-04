import 'package:flutter/material.dart';
import 'package:maamaas/Services/Auth_service/food_authservice.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import '../../../Models/food/dish.dart';
import '../../../Services/Auth_service/Subscription_authservice.dart';
import '../../signinrequired.dart';

class FavoriteButton extends StatefulWidget {
  final Dish dish;
  final bool isInitiallyLiked;
  final int? favId;

  // dishId, isLiked, favId
  final Function(int dishId, bool isLiked, int? favId)? onChanged;

  const FavoriteButton({
    super.key,
    required this.dish,
    required this.isInitiallyLiked,
    this.favId,
    this.onChanged,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool isLiked;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isInitiallyLiked;
  }

  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isInitiallyLiked != widget.isInitiallyLiked) {
      isLiked = widget.isInitiallyLiked;
    }
  }

  Future<bool> _checkLogin(BuildContext context) async {
    final isLoggedIn = await subscription_AuthService.isLoggedIn();

    if (!isLoggedIn) {
      // ignore: use_build_context_synchronously
      showAuthRequiredSheet(context);
      return false;
    }

    return true;
  }

  void showAuthRequiredSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AuthRequiredWidget(),
    );
  }

  Future<void> toggleFavorite() async {
    if (isLoading) return;

    // ✅ FIRST: check login
    final allowed = await _checkLogin(context);
    if (!allowed) return;

    // ✅ THEN update UI
    setState(() {
      isLoading = true;
      isLiked = !isLiked;
    });

    final wasLiked = !isLiked;

    try {
      int? newFavId = widget.favId;

      if (isLiked) {
        final res = await food_Authservice.addToFavorites(widget.dish.dishId);

        if (!res) throw Exception();

        newFavId = null;

        AppAlert.success(context, "Added to favorites ❤️");
      } else {
        if (widget.favId != null) {
          final res = await food_Authservice.unfavoriteDish(widget.favId!);

          if (!res) throw Exception();
        }

        newFavId = null;

        AppAlert.success(context, "Removed from favorites 💔");
      }

      widget.onChanged?.call(widget.dish.dishId, isLiked, newFavId);
    } catch (e) {
      setState(() {
        isLiked = wasLiked;
      });

      AppAlert.error(context, "Something went wrong");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleFavorite,
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Colors.grey,
              size: 25,
            ),
    );
  }
}
