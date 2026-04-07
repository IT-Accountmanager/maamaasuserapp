import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Enquiry_helpers {
  static String paymentTypeToEnum(String type) {
    switch (type.toLowerCase()) {
      case 'full':
        return 'FULL_PAYMENT';
      case 'partial':
        return 'PARTIAL_PAYMENT';
      case 'final':
        return 'FINAL_PAYMENT';
      default:
        return 'FULL_PAYMENT'; // fallback
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'selected':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'paid':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'selected':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'paid':
        return Icons.payment;
      default:
        return Icons.help;
    }
  }

  static String formatAddOnType(String type) {
    return type
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
  }

  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return dateString; // fallback if parse fails
    }
  }

  static String formatTime(String timeString) {
    try {
      final dateTime = DateTime.parse(timeString);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return timeString; // fallback if parse fails
    }
  }
}
