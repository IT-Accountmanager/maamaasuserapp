import 'package:flutter/material.dart';

class restaurentsnewcolour {
  static const primary = Color(0xFFE23744);
  static const primaryLight = Color(0xFFFFECED);
  static const green = Color(0xFF1BA672);
  static const surface = Colors.white;
  static const bg = Color(0xFFF3F3F8);
  static const text = Color(0xFF1C1C1C);
  static const textMuted = Color(0xFF7C7C7C);
  static const textLight = Color(0xFFB0B0B0);
  static const border = Color(0xFFECECEC);
  static const cardRadius = 16.0;
}

class RestaurentsHelper {
  // static const orderTabs = [
  //   {'label': 'Dine-In', 'icon': Icons.restaurant_rounded, 'type': 'dinein'},
  //   {
  //     'label': 'Takeaway',
  //     'icon': Icons.takeout_dining_rounded,
  //     'type': 'takeaway',
  //   },
  //   {
  //     'label': 'Delivery',
  //     'icon': Icons.delivery_dining_outlined,
  //     'type': 'delivery',
  //   },
  //   {'label': 'Dine-out', 'icon': Icons.table_restaurant, 'type': 'dineout'},
  //   // {'label': 'Catering', 'icon': Icons.restaurant, 'type': 'catering'},
  // ];
  static const orderTabs = [
    {
      'label': 'Delivery',
      'icon': Icons.delivery_dining_outlined,
      'type': 'delivery',
      'configKey': 'DELIVERY',
    },
    {
      'label': 'Dine-In',
      'icon': Icons.restaurant_rounded,
      'type': 'dinein',
      'configKey': 'DINE_IN',
    },
    {
      'label': 'Takeaway',
      'icon': Icons.takeout_dining_rounded,
      'type': 'takeaway',
      'configKey': 'TAKEAWAY',
    },

    {
      'label': 'Dine-out',
      'icon': Icons.table_restaurant,
      'type': 'dineout',
      'configKey': 'TABLE_DINE_IN',
    },
    {
      'label': 'catering',
      'icon': Icons.table_restaurant,
      'type': 'catering',
      'configKey': 'catering',
    },
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
    {'icon': Icons.bolt_rounded, 'label': 'Near & Fast'},
    {'icon': Icons.local_offer_rounded, 'label': 'Offers'},
  ];

  static const menu = ['Rating', 'Dish price', 'Offers'];

  //

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
