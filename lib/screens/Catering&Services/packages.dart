import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:flutter/material.dart';


import 'package:maamaas/Services/App_color_service/app_colours.dart';
// ignore: camel_case_types
class packages extends StatefulWidget {
  const packages({super.key});

  @override
  State<packages> createState() => _packagesState();
}

// ignore: camel_case_types
class _packagesState extends State<packages> {
  final List<Map<String, dynamic>> packages = const [
    {
      "title": "Veg Thali -Maamaa's",
      "items": ["Paneer Curry", "Dal Tadka", "Rice", "Roti", "Salad"],
      "price": "₹199",
    },
    {
      "title": "Non-Veg Combo-Kritunga",
      "items": ["Chicken Curry", "Jeera Rice", "Naan", "Raita"],
      "price": "₹299",
    },
    {
      "title": "Family Pack-chaitanya",
      "items": ["2 Curries", "Rice", "Naan", "Sweet", "Salad"],
      "price": "₹499",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Packages")),
        body: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final package = packages[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // 🔹 Background image with low opacity
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1, // adjust 0.05 - 0.2 for effect
                        child: Image.asset(
                          "assets/aboutus.jpg", // <-- replace with your image
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // 🔹 Foreground content
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                package["title"],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                package["price"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Items
                          ...package["items"].map<Widget>(
                            (item) => Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(item),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Add to Cart Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.of(context).primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                // cartItems.value = [
                                //   ...cartItems.value,
                                //   package["title"],
                                // ];
                                AppAlert.success(context, "${package["title"]} added to cart");
                              },
                              child: const Text("Add to Cart"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // bottomNavigationBar: catering_footer(),
      ),
    );
  }
}
