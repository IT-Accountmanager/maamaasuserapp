import '../../../Models/promotions_model/promotions_model.dart';
import 'package:flutter/material.dart';

class PromotionPopup {
  static void show(BuildContext context, Campaign ads) {
    final screenHeight = MediaQuery.of(context).size.height;
    final _ = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // allows custom height
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: screenHeight * 0.60,
          width: double.infinity,
          // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              /// IMAGE SECTION
              Expanded(
                flex: 9,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: SizedBox.expand(
                        child: Image.network(
                          ads.imageUrl ?? '',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    /// Close button
                    Positioned(
                      right: 12,
                      top: 12,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    /// Hot deal badge
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.red, Colors.orange],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          '🔥 Hot Deal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
