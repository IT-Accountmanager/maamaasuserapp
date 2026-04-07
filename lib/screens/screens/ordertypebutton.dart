import 'package:flutter/material.dart';
import '../../Services/Auth_service/food_authservice.dart';

enum OrderType { delivery, takeaway, dinein }

class OrderCartFooter extends StatefulWidget {
  final VoidCallback? onOrderTypeChanged;

  const OrderCartFooter({super.key, this.onOrderTypeChanged});

  @override
  State<OrderCartFooter> createState() => _OrderCartFooterState();
}

class _OrderCartFooterState extends State<OrderCartFooter> {
  // OrderType selectedType = OrderType.delivery;

  List<OrderType> availableOrderTypes = [];

  OrderType? selectedType;

  @override
  void initState() {
    super.initState();
    loadCartData();
  }

  Future<void> loadCartData() async {
    try {
      final cart = await food_Authservice.fetchCart();

      final vendorTypes = cart?.vendorOrderType ?? [];

      final mappedTypes = vendorTypes
          .map((e) => _mapVendorOrderType(e))
          .whereType<OrderType>()
          .toSet()
          .toList();

      final serverOrderType = _mapVendorOrderType(cart!.orderType);

      if (!mounted) return;

      setState(() {
        availableOrderTypes = mappedTypes.isNotEmpty
            ? mappedTypes
            : [OrderType.dinein];

        /// 🔥 sync from server ONLY once
        selectedType ??= serverOrderType ?? availableOrderTypes.first;
      });
    } catch (e) {
      // handle error
    }
  }

  Future<void> updateOrderTypeOnServer(OrderType type) async {
    try {
      String typeString;
      switch (type) {
        case OrderType.delivery:
          typeString = "DELIVERY";
          break;
        case OrderType.takeaway:
          typeString = "TAKEAWAY";
          break;
        case OrderType.dinein:
          typeString = "DINE_IN";
          break;
      }

      await food_Authservice.updateOrderType(typeString);

      /// 🔥 Notify parent to refresh cart & summary
      widget.onOrderTypeChanged?.call();
    } catch (e) {
      // handle error
    }
  }

  OrderType? _mapVendorOrderType(String type) {
    switch (type.toUpperCase()) {
      case "DELIVERY":
        return OrderType.delivery;

      case "TAKEAWAY":
        return OrderType.takeaway;

      case "DINE_IN":
        // case "TABLE_DINE_IN": // 🔥 normalize both to dine-in
        return OrderType.dinein;

      default:
        return null;
    }
  }

  Color _getSegmentColor(OrderType type) {
    switch (type) {
      case OrderType.delivery:
        return Colors.blue;
      case OrderType.takeaway:
        return Colors.orange;
      case OrderType.dinein:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (!isSmallScreen) ...[
              Expanded(flex: 2, child: _buildOrderTypeSelector()),
              const SizedBox(width: 16),
            ],
            if (isSmallScreen) ...[
              const SizedBox(width: 12),
              _buildOrderTypeDropdown(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTypeSelector() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Row(
        children: [
          for (int i = 0; i < availableOrderTypes.length; i++) ...[
            _buildOrderTypeSegment(
              label: _getOrderTypeLabel(availableOrderTypes[i]),
              type: availableOrderTypes[i],
              icon: _getOrderTypeIcon(availableOrderTypes[i]),
            ),
            if (i != availableOrderTypes.length - 1) _buildDivider(),
          ],
        ],
      ),
    );
  }

  String _getOrderTypeLabel(OrderType type) {
    switch (type) {
      case OrderType.delivery:
        return "Delivery";
      case OrderType.takeaway:
        return "Takeaway";
      case OrderType.dinein:
        return "Dine-in";
    }
  }

  Widget _buildOrderTypeDropdown() {
    return PopupMenuButton<OrderType>(
      onSelected: (type) async {
        setState(() => selectedType = type);
        await updateOrderTypeOnServer(type);
      },
      itemBuilder: (context) => availableOrderTypes
          .map(
            (type) => _buildPopupMenuItem(
              type,
              _getOrderTypeLabel(type),
              _getOrderTypeIcon(type),
            ),
          )
          .toList(),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: _getSegmentColor(selectedType ?? OrderType.takeaway),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _getOrderTypeIcon(selectedType ?? OrderType.takeaway),
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  PopupMenuItem<OrderType> _buildPopupMenuItem(
    OrderType type,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem<OrderType>(
      value: type,
      child: Row(
        children: [
          Icon(icon, color: _getSegmentColor(type), size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  IconData _getOrderTypeIcon(OrderType type) {
    switch (type) {
      case OrderType.delivery:
        return Icons.delivery_dining_rounded;
      case OrderType.takeaway:
        return Icons.takeout_dining_rounded;
      case OrderType.dinein:
        return Icons.restaurant_rounded;
    }
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 20, color: Colors.grey.shade300);
  }

  Widget _buildOrderTypeSegment({
    required String label,
    required OrderType type,
    required IconData icon,
  }) {
    final isSelected = selectedType == type;
    final color = _getSegmentColor(type);

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() => selectedType = type);
          await updateOrderTypeOnServer(type); // send to server immediately
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
