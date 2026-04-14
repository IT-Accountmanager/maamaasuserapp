import 'package:flutter/material.dart';

class RestaurentsHelper {
  static const orderTabs = [
    {'label': 'Dine-In', 'icon': Icons.restaurant_rounded, 'type': 'dinein'},
    {
      'label': 'Takeaway',
      'icon': Icons.takeout_dining_rounded,
      'type': 'takeaway',
    },
    {
      'label': 'Delivery',
      'icon': Icons.delivery_dining_outlined,
      'type': 'delivery',
    },
    {'label': 'Dine-out', 'icon': Icons.table_restaurant, 'type': 'dineout'},
    {'label': 'Catering', 'icon': Icons.restaurant, 'type': 'catering'},
  ];

  static final Map<String, String> typeMapping = {
    'dinein': 'DINE_IN',
    'takeaway': 'TAKEAWAY',
    'delivery': 'DELIVERY',
    'dineout': 'TABLE_DINE_IN', // ✅ FIXED
    'catering': 'CATERING', // ✅ FIXED (removed space)
  };

  static const filters = [
    {'icon': Icons.tune_rounded, 'label': 'Filters'},
    {'icon': Icons.star_rounded, 'label': 'Rating 4.0+'},
    {'icon': Icons.flash_on_rounded, 'label': 'Near & Fast'},
    {'icon': Icons.eco_rounded, 'label': 'Pure Veg'},
    {'icon': Icons.local_offer_rounded, 'label': 'Offers'},
    {'icon': Icons.whatshot_rounded, 'label': 'Trending'},
  ];

  static final offers = [
    {
      'title': '10% OFF',
      'sub': 'UP TO ₹100',
      'c1': 0xFFFF6B35,
      'c2': 0xFFF7931E,
    },
    {
      'title': '20% OFF',
      'sub': 'UP TO ₹150',
      'c1': 0xFF6C63FF,
      'c2': 0xFF8B85FF,
    },
    {
      'title': 'FLAT ₹100',
      'sub': 'NO MIN ORDER',
      'c1': 0xFF00B894,
      'c2': 0xFF55EFC4,
    },
    {
      'title': 'FREE DEL',
      'sub': 'TODAY ONLY',
      'c1': 0xFF0984E3,
      'c2': 0xFF74B9FF,
    },
  ];

  static final menu = ['Time', 'Rating', 'Offers', 'Dish Price', 'Trust'];
}

String formatCategory(String? category) {
  if (category == null || category.isEmpty) return "Others";

  switch (category.toLowerCase()) {
    case "home":
      return "Home";
    case "office":
      return "Office";
    default:
      return "Others";
  }
}
