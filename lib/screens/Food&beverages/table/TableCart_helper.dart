
import 'package:flutter/material.dart';

class tabecartcolour {
  static const bg = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);

  static const brand = Color(0xFFFF6B35);
  static const brandLight = Color(0xFFFFF0EB);
  static const brandDark = Color(0xFFE55A27);

  static const textPrimary = Color(0xFF1C1C1E);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFFB0B8C8);

  static const green = Color(0xFF22C55E);
  static const greenLight = Color(0xFFDCFCE7);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEE2E2);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const blue = Color(0xFF3B82F6);
  static const blueLight = Color(0xFFEFF6FF);
  static const purple = Color(0xFF8B5CF6);
  static const purpleLight = Color(0xFFF5F3FF);
  static const teal = Color(0xFF14B8A6);
  static const tealLight = Color(0xFFCCFBF1);

  static const border = Color(0xFFEEF0F5);
  static const shadow = Color(0x0A000000);
}

// ─── Status config ────────────────────────────────────────────────────────────
class StatusConfig {
  final Color bg, fg;
  final IconData icon;
  final String label;
  const StatusConfig({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.label,
  });
}

StatusConfig _statusConfig(String? rawStatus) {
  final s = (rawStatus ?? '').toUpperCase().trim();
  switch (s) {
    case 'DELIVERED':
    case 'COMPLETED':
      return StatusConfig(
        bg: tabecartcolour.greenLight,
        fg: tabecartcolour.green,
        icon: Icons.check_circle_rounded,
        label: 'Delivered',
      );
    case 'CANCELLED':
      return StatusConfig(
        bg: tabecartcolour.redLight,
        fg: tabecartcolour.red,
        icon: Icons.cancel_rounded,
        label: 'Cancelled',
      );
    case 'PENDING':
      return StatusConfig(
        bg: tabecartcolour.amberLight,
        fg: tabecartcolour.amber,
        icon: Icons.hourglass_top_rounded,
        label: 'Pending',
      );
    case 'CONFIRMED':
      return StatusConfig(
        bg: tabecartcolour.blueLight,
        fg: tabecartcolour.blue,
        icon: Icons.thumb_up_alt_rounded,
        label: 'Confirmed',
      );
    case 'BEING_PREPARED':
    case 'PREPARING':
    case 'PROCESSING':
      return StatusConfig(
        bg: tabecartcolour.amberLight,
        fg: tabecartcolour.amber,
        icon: Icons.outdoor_grill_rounded,
        label: 'Preparing',
      );
    case 'ORDER_IS_READY':
    case 'READY':
      return StatusConfig(
        bg: tabecartcolour.greenLight,
        fg: tabecartcolour.green,
        icon: Icons.done_all_rounded,
        label: 'Ready',
      );
    case 'WAITING_FOR_PICKUP':
      return StatusConfig(
        bg: tabecartcolour.blueLight,
        fg: tabecartcolour.blue,
        icon: Icons.pan_tool_rounded,
        label: 'Pickup',
      );
    case 'ON_THE_WAY':
    case 'ONTHEWAY':
      return StatusConfig(
        bg: tabecartcolour.tealLight,
        fg: tabecartcolour.teal,
        icon: Icons.delivery_dining_rounded,
        label: 'On the Way',
      );
    case 'HOLD':
      return StatusConfig(
        bg: tabecartcolour.purpleLight,
        fg: tabecartcolour.purple,
        icon: Icons.pause_circle_rounded,
        label: 'On Hold',
      );
    default:
      return StatusConfig(
        bg: tabecartcolour.border,
        fg: tabecartcolour.textMuted,
        icon: Icons.info_rounded,
        label: s.isEmpty
            ? 'Unknown'
            : s
                  .replaceAll('_', ' ')
                  .toLowerCase()
                  .split(' ')
                  .map(
                    (w) => w.isEmpty
                        ? ''
                        : '${w[0].toUpperCase()}${w.substring(1)}',
                  )
                  .join(' '),
      );
  }
}

class StatusBadge extends StatelessWidget {
  final String? status;
  const StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final cfg = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: 11, color: cfg.fg),
          const SizedBox(width: 4),
          Text(
            cfg.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cfg.fg,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Enums ────────────────────────────────────────────────────────────────────
enum PaymentOverlayState {
  none,
  placingOrder,
  openingGateway,
  processing,
  success,
}
