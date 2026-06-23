import '../../../Models/food/orders_model.dart';
import '../../../widgets/datetimehelper.dart';
import 'package:flutter/material.dart';
import 'food orders/food_orders.dart';

class OrderTrackingBanner extends StatelessWidget {
  final Order order;
  final bool visible;
  final VoidCallback onDismiss;
  final VoidCallback? onRefresh;

  const OrderTrackingBanner({
    super.key,
    required this.order,
    required this.visible,
    required this.onDismiss,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Dismissible(
      key: const ValueKey('order_tracking_banner'),
      direction: DismissDirection.horizontal,

      onDismissed: (_) {
        onDismiss();
      },

      background: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.close, color: Colors.white),
      ),

      secondaryBackground: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.close, color: Colors.white),
      ),

      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(
                orderId: order.orderId,
                order: order,
                formattedDate: DateTimeHelper.formatDate(
                  order.parsedDateTime.toUtc(),
                ),
                formattedTime: DateTimeHelper.formatTime(
                  order.parsedDateTime.toUtc(),
                ),
                items: order.items,
                isActive: order.isActive,
                date: order.date,
                time: order.time,
              ),
            ),
          ).then((_) {
            if (onRefresh != null) {
              onRefresh!();
            }
          });
        },

        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
          ),

          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "Order #${order.id}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          getOrderStatusText(order.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              OrderProgressStepper(status: order.status),
            ],
          ),
        ),
      ),
    );
  }

  static String getOrderStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return "Waiting for confirmation";

      case OrderStatus.confirmed:
        return "Order confirmed";

      case OrderStatus.beingPrepared:
        return "Preparing your food";

      case OrderStatus.orderIsReady:
        return "Order ready";

      case OrderStatus.waitingForPickup:
        return "Waiting for pickup";

      case OrderStatus.ontheway:
        return "On the way";

      case OrderStatus.completed:
        return "Delivered";

      default:
        return "Processing";
    }
  }
}

class OrderProgressStepper extends StatelessWidget {
  final OrderStatus status;

  const OrderProgressStepper({super.key, required this.status});

  int get currentStep {
    switch (status) {
      case OrderStatus.pending:
        return 0;

      case OrderStatus.confirmed:
        return 1;

      case OrderStatus.beingPrepared:
      case OrderStatus.orderIsReady:
        return 2;

      case OrderStatus.waitingForPickup:
      case OrderStatus.ontheway:
        return 3;

      case OrderStatus.completed:
        return 4;

      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    const steps = [
      {'label': 'Placed', 'icon': Icons.receipt_long_rounded},
      {'label': 'Confirmed', 'icon': Icons.check_circle_outline_rounded},
      {'label': 'Preparing', 'icon': Icons.restaurant_rounded},
      {'label': 'On the way', 'icon': Icons.directions_bike_rounded},
      {'label': 'Delivered', 'icon': Icons.inventory_2_rounded},
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final isDone = (i ~/ 2) < currentStep;

          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 18),
              color: isDone ? const Color(0xFF22C55E) : Colors.grey.shade200,
            ),
          );
        }

        final stepIndex = i ~/ 2;

        final isDone = stepIndex <= currentStep;

        final isActive = stepIndex == currentStep;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? const Color(0xFF22C55E) : Colors.grey.shade100,
                border: Border.all(
                  color: isDone
                      ? const Color(0xFF22C55E)
                      : Colors.grey.shade300,
                  width: 0.5,
                ),
              ),

              child: Center(
                child: Icon(
                  isDone && !isActive
                      ? Icons.check_rounded
                      : steps[stepIndex]['icon'] as IconData,
                  size: 13,
                  color: isDone ? Colors.white : Colors.grey.shade400,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              steps[stepIndex]['label'] as String,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        );
      }),
    );
  }
}
