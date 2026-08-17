import 'package:flutter/material.dart';

import '../App_color_service/app_colours.dart';

class AppAlert {
  static void error(BuildContext context, String message, {Duration? duration}) {
    _show(context, message, AppColors.error, Icons.error_outline ,duration,);
  }

  static void success(BuildContext context, String message, {Duration? duration}) {
    _show(context, message, AppColors.success, Icons.check_circle_outline, duration,);
  }

  static void info(BuildContext context, String message , {Duration? duration}) {
    _show(context, message, AppColors.info, Icons.info_outline, duration,);
  }

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
      Duration? duration,
  ) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
