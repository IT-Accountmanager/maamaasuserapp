// // // import 'package:flutter/material.dart';
// // // import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// // //
// // // import '../../../Services/Auth_service/food_authservice.dart';
// // //
// // // class FavoriteButton extends StatefulWidget {
// // //   // ignore: prefer_typing_uninitialized_variables
// // //   final dish;
// // //
// // //   const FavoriteButton({required this.dish, Key? key}) : super(key: key);
// // //
// // //   @override
// // //   // ignore: library_private_types_in_public_api
// // //   _FavoriteButtonState createState() => _FavoriteButtonState();
// // // }
// // //
// // // class _FavoriteButtonState extends State<FavoriteButton> {
// // //   bool isFavorite = false;
// // //
// // //   Future<void> _handleFavorite() async {
// // //     bool success = await food_Authservice.addToFavorites(widget.dish.dishId ?? 0);
// // //     if (success) {
// // //       setState(() => isFavorite = true);
// // //       AppAlert.success(context, 'Added to favorites');
// // //     } else {
// // //       AppAlert.error(context, 'Failed to add to favorites');
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return IconButton(
// // //       padding: EdgeInsets.zero, // remove default padding
// // //       constraints: const BoxConstraints(), // shrink wrap the icon
// // //       icon: Icon(
// // //         isFavorite ? Icons.favorite : Icons.favorite_border,
// // //         color: isFavorite ? Colors.red : Colors.grey,
// // //         size: 20, // adjust size to fit CircleAvatar
// // //       ),
// // //       onPressed: _handleFavorite,
// // //     );
// // //   }
// // // }
// //
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import '../../../Models/food/dish.dart';
// // import '../../../Services/Auth_service/food_authservice.dart';
// // import '../../../Services/scaffoldmessenger/messenger.dart';
// //
// // class FavoriteButton extends StatefulWidget {
// //   final Dish dish;
// //
// //   const FavoriteButton({required this.dish, Key? key}) : super(key: key);
// //
// //   @override
// //   State<FavoriteButton> createState() => _FavoriteButtonState();
// // }
// //
// // class _FavoriteButtonState extends State<FavoriteButton> {
// //   late bool isFavorite;
// //   bool _loading = false;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     isFavorite = widget.dish.favorite ?? false; // 🔥 from API
// //   }
// //
// //   Future<void> _handleFavorite() async {
// //     if (_loading) return;
// //
// //     setState(() => _loading = true);
// //
// //     final newValue = !isFavorite;
// //
// //     final success = await food_Authservice.updateFavorite(
// //       widget.dish.dishId ?? 0,
// //       newValue,
// //     );
// //
// //     if (!mounted) return;
// //
// //     if (success) {
// //       setState(() => isFavorite = newValue);
// //     } else {
// //       AppAlert.error(context, 'Failed to update favorite');
// //     }
// //
// //     setState(() => _loading = false);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: _handleFavorite,
// //       child: _loading
// //           ? SizedBox(
// //               width: 18,
// //               height: 18,
// //               child: CircularProgressIndicator(strokeWidth: 2),
// //             )
// //           : Icon(
// //               isFavorite ? Icons.favorite : Icons.favorite_border,
// //               color: isFavorite ? Colors.red : Colors.grey,
// //               size: 20,
// //             ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
//
// import '../../../Services/Auth_service/food_authservice.dart';
//
// class FavoriteButton extends StatefulWidget {
//   // ignore: prefer_typing_uninitialized_variables
//   final dish;
//
//   const FavoriteButton({required this.dish, Key? key}) : super(key: key);
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _FavoriteButtonState createState() => _FavoriteButtonState();
// }
//
// class _FavoriteButtonState extends State<FavoriteButton> {
//   bool isFavorite = false;
//
//   Future<void> _handleFavorite() async {
//     bool success = await food_Authservice.addToFavorites(widget.dish.dishId ?? 0);
//     if (success) {
//       setState(() => isFavorite = true);
//       AppAlert.success(context, 'Added to favorites');
//     } else {
//       AppAlert.error(context, 'Failed to add to favorites');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       padding: EdgeInsets.zero, // remove default padding
//       constraints: const BoxConstraints(), // shrink wrap the icon
//       icon: Icon(
//         isFavorite ? Icons.favorite : Icons.favorite_border,
//         color: isFavorite ? Colors.red : Colors.grey,
//         size: 20, // adjust size to fit CircleAvatar
//       ),
//       onPressed: _handleFavorite,
//     );
//   }
// }
//
import 'package:flutter/material.dart';
import 'package:maamaas/Services/Auth_service/food_authservice.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import '../../../Models/food/dish.dart';

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

  Future<void> toggleFavorite() async {
    if (isLoading) return;

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

        // ⚠️ Ideally API should return favId
        newFavId = null;

        AppAlert.success(context, "Added to favorites ❤️");
      } else {
        if (widget.favId != null) {
          final res =
          await food_Authservice.unfavoriteDish(widget.favId!);

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
        size: 18,
      ),
    );
  }
}
