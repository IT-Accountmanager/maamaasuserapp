import 'package:flutter/material.dart';
import '../../Models/food/orders_model.dart';
import '../../Services/Auth_service/food_authservice.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late Future<List<Order>> ordersFuture;

  @override
  void initState() {
    super.initState();
    ordersFuture = _loadOrders();
  }

  Future<List<Order>> _loadOrders() async {
    try {
      final response = await food_Authservice.getAllOrders();
      final orders = response
          .map<Order>((json) => Order.fromJson(json))
          .where((order) => (order.ratings) > 0)
          .toList();

      orders.sort((a, b) {
        final dateTimeA = DateTime.parse("${a.date} ${a.time}");
        final dateTimeB = DateTime.parse("${b.date} ${b.time}");
        return dateTimeB.compareTo(dateTimeA); // latest first
      });

      return orders;
    } catch (e) {
      throw Exception("Error loading orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFF6F7FB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Color(0xFF111827),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "My Reviews",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1B18),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          // ignore: deprecated_member_use
          child: Container(height: 0.5, color: Colors.black.withOpacity(0.06)),
        ),
      ),
      body: FutureBuilder<List<Order>>(
        future: ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF5A623),
                strokeWidth: 2,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Couldn't load reviews",
                style: TextStyle(color: Colors.grey.shade500),
              ),
            );
          }
          final reviews = snapshot.data!;
          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("✍️", style: TextStyle(fontSize: 40)),
                  SizedBox(height: 12),
                  Text(
                    "No reviews yet",
                    style: TextStyle(fontSize: 15, color: Color(0xFF9B9890)),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) => _buildReviewCard(reviews[index]),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(Order order) {
    final int rating = (order.ratings).toInt().clamp(0, 5);
    final hasRating = (order.ratings) > 0;
    final hasCategory =
        order.ratingCategory.toLowerCase() != 'null' &&
        order.ratingCategory.trim().isNotEmpty;
    final hasFeedback = order.feedback.trim().isNotEmpty;
    final hasRestaurantName =
        order.vendorRegisteredName.trim().isNotEmpty &&
        order.vendorRegisteredName.toLowerCase() != 'null';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.black.withOpacity(0.07), width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text("🍜", style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant name (prominent, top line)
                    if (hasRestaurantName)
                      Text(
                        order.vendorRegisteredName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1B18),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),
                    // Order ID and date on the same row
                    Row(
                      children: [
                        Text(
                          "Order #${order.orderId}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8A8780),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Color(0xFFCECBC4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          order.date,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFB0ADA6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Stars row
          if (hasRating) ...[
            Row(
              children: List.generate(5, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: i < rating
                        ? const Color(0xFFF5A623)
                        : const Color(0xFFE8E5DF),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
          ],

          if (hasCategory) ...[
            Text(
              order.ratingCategory.replaceAll('_', ' ').toLowerCase(),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF52504B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Feedback bubble
          if (hasFeedback)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAF8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '"${order.feedback}"',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF52504B),
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
