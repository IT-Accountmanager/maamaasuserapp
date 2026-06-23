import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maamaas/screens/Food&beverages/table/table_menu.dart';
import '../../../Models/food/tablebooking.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import '../../../Services/scaffoldmessenger/messenger.dart';
import '../../../widgets/datetimehelper.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
class _T {
  // Surfaces
  static const bg = Color(0xFFF7F7F5);
  static const surface = Colors.white;
  static const surfaceSecondary = Color(0xFFF2F1EF);
  static const border = Color(0xFFEBEAE7);

  // Text
  static const ink = Color(0xFF1A1917);
  static const inkSecondary = Color(0xFF6B6760);
  static const inkMuted = Color(0xFF9C9890);

  // Amber brand
  static const brand = Color(0xFFEF9F27);

  // Status
  static const booked = Color(0xFF185FA5); // seating == null → Booked
  static const bookedBg = Color(0xFFE6F1FB);
  static const allotted = Color(0xFF3B6D11); // seating != null → Allotted
  static const allottedBg = Color(0xFFEAF3DE);
  static const cancelled = Color(0xFFA32D2D);
  static const cancelledBg = Color(0xFFFCEBEB);
  static const completed = Color(0xFF5F5E5A);
  static const completedBg = Color(0xFFF1EFE8);
  // Shape
  static const radius = 14.0;
  static const radiusSm = 9.0;
  static const radiusXs = 7.0;
  static const radiusPill = 20.0;

  static List<BoxShadow> get shadow => [
    BoxShadow(
      color: const Color(0xFF1A1917).withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
    BoxShadow(
      color: const Color(0xFF1A1917).withOpacity(0.02),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  // Typography
  static const TextStyle titleMd = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: ink,
    letterSpacing: -0.2,
  );
  static const TextStyle bodyMd = TextStyle(
    fontSize: 13,
    color: inkSecondary,
    height: 1.4,
  );
  static const TextStyle labelSm = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: inkMuted,
  );
  static const TextStyle valueSm = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: ink,
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class TableBookings extends StatefulWidget {
  const TableBookings({super.key});

  @override
  State<TableBookings> createState() => _TableBookingsState();
}

class _TableBookingsState extends State<TableBookings> {
  bool _loading = true;
  late Future<List<BookingModel>> _confirmedFuture;

  @override
  void initState() {
    super.initState();
    _confirmedFuture = food_Authservice.getTableBookings();
    _load();
  }

  Future<void> _load() async {
    try {
      await food_Authservice.getTableBookings();
    } catch (e) {
      //       debugPrint(e.toString());
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _markArrivedAndOpenMenu(
    BuildContext context,
    BookingModel booking,
  ) async {
    final ok = await food_Authservice.sendArrivalStatus(booking.id, 'ARRIVED');

    if (!ok) {
      AppAlert.error(context, 'Failed to update arrival status');
      return;
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => tablemneuScreen(
          vendorId: booking.vendorId!,
          seatingId: booking.seating!.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _T.brand, strokeWidth: 2.5),
      );
    }

    return Scaffold(
      backgroundColor: _T.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<List<BookingModel>>(
                future: _confirmedFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  final bookings = snapshot.data ?? [];
                  final displayBookings = bookings.reversed.toList();

                  if (bookings.isEmpty) {
                    return _buildEmpty();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _confirmedFuture = food_Authservice.getTableBookings();
                      });

                      await _confirmedFuture;
                    },
                    child: ListView.builder(
                      itemCount: displayBookings.length,
                      itemBuilder: (context, i) {
                        return _BookingCard(
                          booking: displayBookings[i],
                          onAddItems: () => _markArrivedAndOpenMenu(
                            context,
                            displayBookings[i],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _T.surfaceSecondary,
              borderRadius: BorderRadius.circular(_T.radius),
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 26,
              color: _T.inkMuted,
            ),
          ),
          const SizedBox(height: 14),
          const Text('No reservations yet', style: _T.titleMd),
          const SizedBox(height: 4),
          const Text('Bookings will appear here', style: _T.bodyMd),
        ],
      ),
    );
  }
}

// ─── Booking Card ─────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final BookingModel booking;

  final Future<void> Function()? onAddItems;

  const _BookingCard({required this.booking, this.onAddItems});

  String get _status {
    switch (booking.arrivalStatus.toUpperCase()) {
      case 'ARRIVED':
        return 'ARRIVED';
      case 'CANCELLED':
        return 'CANCELLED';
      case 'COMPLETED':
        return 'COMPLETED';
      default:
        return booking.seating != null ? 'ALLOTTED' : 'BOOKED';
    }
  }

  bool get _isCancelled => _status == 'CANCELLED';
  bool get _isCompleted => _status == 'COMPLETED';

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: (_isCancelled || _isCompleted) ? 0.65 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(_T.radius),
          border: Border.all(color: _T.border, width: 0.5),
          boxShadow: _T.shadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopRow(),
              const SizedBox(height: 14),
              _buildInfoGrid(),
              if (booking.seating != null) ...[
                const SizedBox(height: 12),
                _buildTableSection(),
              ],
              if (booking.seating != null &&
                  !_isCancelled &&
                  !_isCompleted) ...[
                const SizedBox(height: 14),
                _buildActions(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      children: [
        _Avatar(name: booking.guestName),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(booking.guestName, style: _T.titleMd),
              const SizedBox(height: 2),
              Text(booking.phoneNumber, style: _T.bodyMd),
            ],
          ),
        ),
        _StatusBadge(status: _status),
      ],
    );
  }

  Widget _buildInfoGrid() {
    final date = DateTimeHelper.formatDateString(booking.bookingDate);
    final time = _fmtTime(booking.startTime);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3.0,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _InfoCell(
          icon: Icons.calendar_today_rounded,
          label: 'Date',
          value: date,
        ),
        _InfoCell(icon: Icons.schedule_rounded, label: 'Time', value: time),
      ],
    );
  }

  Widget _buildTableSection() {
    final s = booking.seating!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _T.surfaceSecondary,
        borderRadius: BorderRadius.circular(_T.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Assigned table', style: _T.labelSm),
          const SizedBox(height: 8),
          Row(
            children: [
              if (s.code.isNotEmpty)
                _TableTag(icon: Icons.chair_outlined, label: s.code),
              const SizedBox(width: 6),
              if (s.name.isNotEmpty)
                _TableTag(icon: Icons.grid_view_rounded, label: s.name),
              const SizedBox(width: 6),
              if (s.capacity != null)
                _TableTag(
                  icon: Icons.people_outline_rounded,
                  label: '${s.capacity} seats',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: "Add Items",
            icon: Icons.restaurant_menu,
            foreground: Colors.white,
            background: _T.brand,
            onTap: () async {
              if (onAddItems != null) {
                await onAddItems!();
              }
            },
          ),
        ),
      ],
    );
  }

  String _fmtTime(String t) {
    try {
      return DateFormat('hh:mm a').format(DateFormat('HH:mm:ss').parse(t));
    } catch (_) {
      return t;
    }
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  static const _palettes = [
    [Color(0xFFFAEEDA), Color(0xFF633806)],
    [Color(0xFFE1F5EE), Color(0xFF085041)],
    [Color(0xFFEEEDFE), Color(0xFF26215C)],
    [Color(0xFFE6F1FB), Color(0xFF042C53)],
    [Color(0xFFEAF3DE), Color(0xFF173404)],
  ];

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    final palette = _palettes[name.codeUnitAt(0) % _palettes.length];

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: palette[0],
        borderRadius: BorderRadius.circular(_T.radiusSm),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: palette[1],
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  ({Color fg, Color bg, IconData icon, String label}) get _config {
    switch (status) {
      case 'BOOKED':
        return (
          fg: _T.booked,
          bg: _T.bookedBg,
          icon: Icons.bookmark_outline_rounded,
          label: 'Booked',
        );
      case 'ALLOTTED':
        return (
          fg: _T.allotted,
          bg: _T.allottedBg,
          icon: Icons.where_to_vote_rounded,
          label: 'Allotted',
        );
      case 'ARRIVED':
        return (
          fg: Colors.green,
          bg: const Color(0xFFE8F5E9),
          icon: Icons.check_circle_outline,
          label: 'Arrived',
        );
      case 'CANCELLED':
        return (
          fg: _T.cancelled,
          bg: _T.cancelledBg,
          icon: Icons.cancel_outlined,
          label: 'Cancelled',
        );
      case 'COMPLETED':
        return (
          fg: _T.completed,
          bg: _T.completedBg,
          icon: Icons.done_all_rounded,
          label: 'Completed',
        );
      default:
        return (
          fg: _T.booked,
          bg: _T.bookedBg,
          icon: Icons.bookmark_outline_rounded,
          label: 'Booked',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _config;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(_T.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(c.icon, size: 11, color: c.fg),
          const SizedBox(width: 4),
          Text(
            c.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c.fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _T.surfaceSecondary,
            borderRadius: BorderRadius.circular(_T.radiusXs),
          ),
          child: Icon(icon, size: 14, color: _T.inkSecondary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: _T.labelSm),
              const SizedBox(height: 1),
              Text(value, style: _T.valueSm, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TableTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(_T.radiusXs),
        border: Border.all(color: _T.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _T.inkSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _T.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(_T.radiusSm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: foreground),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: foreground,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _IconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _T.surfaceSecondary,
            borderRadius: BorderRadius.circular(_T.radiusSm),
            border: Border.all(color: _T.border, width: 0.5),
          ),
          child: Icon(icon, size: 17, color: _T.inkSecondary),
        ),
      ),
    );
  }
}
