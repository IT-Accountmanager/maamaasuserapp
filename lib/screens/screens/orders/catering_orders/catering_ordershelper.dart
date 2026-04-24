import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../Models/caterings/orders_model.dart';

// ignore: camel_case_types
class cateringorders_helper {
  static IconData getChipIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'enquiry':
        return Icons.mark_email_read_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  static Color getChipColor(String type) {
    switch (type) {
      case 'order':
        return Colors.green;
      case 'enquiry':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  static String getLoadingText(String selectedFilter) {
    switch (selectedFilter) {
      case 'order':
        return 'orders';
      case 'enquiry':
        return 'enquiries';
      default:
        return 'orders';
    }
  }

  static IconData getEmptyStateIcon(selectedFilter) {
    switch (selectedFilter) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'enquiry':
        return Icons.help_outline_rounded;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  static String getEmptyStateTitle(selectedFilter) {
    switch (selectedFilter) {
      case 'order':
        return 'No orders found';
      case 'enquiry':
        return 'No enquiries found';
      default:
        return 'No orders found';
    }
  }

  static String getEmptyStateSubtitle(selectedFilter) {
    switch (selectedFilter) {
      case 'order':
        return 'Your orders will appear here';
      case 'enquiry':
        return 'Your enquiries will appear here';
      default:
        return 'Your orders will appear here';
    }
  }

  static String getNoResultsTitle(selectedFilter) {
    switch (selectedFilter) {
      case 'order':
        return 'No orders';
      case 'enquiry':
        return 'No enquiries';
      case 'enquiry_order':
        return 'No enquiry orders';
      default:
        return 'No orders';
    }
  }

  static String getNoResultsSubtitle(selectedFilter) {
    switch (selectedFilter) {
      case 'order':
        return 'You don\'t have any orders yet';
      case 'enquiry':
        return 'You don\'t have any enquiries yet';
      case 'enquiry_order':
        return 'You don\'t have any enquiry orders yet';
      default:
        return 'You don\'t have any orders yet';
    }
  }

  // static String formatDate(DateTime dateTime) {
  //   return DateFormat('dd MMM yyyy').format(dateTime);
  // }
  //
  // static String formatTime(DateTime dateTime) {
  //   return DateFormat('hh:mm a').format(dateTime);
  // }

  static Color getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.orange;
      case OrderStatus.ready:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
