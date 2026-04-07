import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Models/delivery/fooddelivery.dart';
import '../../../Models/food/orders_model.dart';
import 'catering_orders/catering_orders.dart';
import 'food orders/food_orders.dart';

enum OrderVertical {
  food,
  catering,
  // groceries,
  // table,
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  List<Order> orders = [];
  bool isDrawerOpen = false;

  DeliveryOrderModel? deliveryorder;
  OrderVertical _selectedVertical = OrderVertical.food;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //
      //   // 👇 this actually increases usable height
      //   toolbarHeight: 100,
      //
      //   automaticallyImplyLeading: true,
      //
      //   flexibleSpace: SafeArea(child: Center(child: _buildVerticalChips())),
      // ),
      appBar: _buildAppBar(),

      body: SafeArea(child: _buildOrdersByVertical()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Orders',
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
        ), // iOS-style back arrow
        color: Color(0xFF1A1D2E),
        onPressed: () => Navigator.of(context).pop(),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildVerticalChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: OrderVertical.values.map((vertical) {
          final isSelected = _selectedVertical == vertical;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: GestureDetector(
              onTap: () => setState(() => _selectedVertical = vertical),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _verticalIcon(vertical),
                      size: 22,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _shortLabel(vertical),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _shortLabel(OrderVertical v) {
    switch (v) {
      case OrderVertical.food:
        return "Food";
      // case OrderVertical.table:
      //   return "Table";
      case OrderVertical.catering:
        return "Catering";
      // case OrderVertical.groceries:
      //   return "Grocery";
    }
  }

  IconData _verticalIcon(OrderVertical v) {
    switch (v) {
      case OrderVertical.food:
        return Icons.fastfood;
      // case OrderVertical.table:
      //   return Icons.event_seat;
      case OrderVertical.catering:
        return Icons.restaurant;
      // case OrderVertical.groceries:
      //   return Icons.local_grocery_store;
    }
  }

  Widget _buildOrdersByVertical() {
    switch (_selectedVertical) {
      case OrderVertical.food:
        return food_orders();
      // case OrderVertical.table:
      //   return TableBookings();
      case OrderVertical.catering:
        return CateringOrdersScreen();
      //   case OrderVertical.groceries:
      //     return _buildGroceryOrderList();
    }
  }
}
