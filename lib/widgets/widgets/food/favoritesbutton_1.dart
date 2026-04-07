import 'package:flutter/material.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';

import '../../../Services/Auth_service/food_authservice.dart';

class FavoriteButton1 extends StatefulWidget {
  final int? favId;
  final VoidCallback? onFavoriteToggled; // <-- Add this

  const FavoriteButton1({
    required this.favId,
    this.onFavoriteToggled, // <-- Add this
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton1> {
  bool isFavorite = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // If there's a favId, we assume it's already favorited
    isFavorite = widget.favId != null && widget.favId != 0;
  }

  void toggleFavorite() async {
    // print("pp");
    if (!isFavorite) return;

    final success = await food_Authservice.unfavoriteDish(widget.favId ?? 0);

    if (success) {
      setState(() {
        isFavorite = false;
      });

      if (widget.onFavoriteToggled != null) {
        widget.onFavoriteToggled!(); // <-- Trigger the callback
      }
    } else {
      // ignore: use_build_context_synchronously
      AppAlert.error(context, "Failed to remove from favorites");
    }
  }

  @override
  Widget build(BuildContext context) {
    return
    //   IconButton(
    //   icon: Icon(
    //     isFavorite ? Icons.favorite : Icons.favorite_border,
    //     color: isFavorite ? Colors.red : Colors.grey,
    //   ),
    //   onPressed: toggleFavorite,
    // );
    GestureDetector(
      onTap: toggleFavorite,
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
              size: 18,
            ),
    );
  }
}
