import 'package:intl/intl.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:maamaas/widgets/datetimehelper.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import '../../../Models/food/table_confirmedlist_model.dart';
import '../../../Models/food/table_waitinglist_model.dart';
import 'package:flutter/material.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
class _T {
  // Backgrounds
  static const bg = Color(0xFFF5F4F0);
  static const surface = Colors.white;
  static const border = Color(0xFFEDE9E3);

  // Text
  static const ink = Color(0xFF1C1917);
  static const inkSecondary = Color(0xFF78716C);
  static const inkMuted = Color(0xFFA8A29E);

  // Brand – warm amber
  static const brand = Color(0xFFD97706);
  static const brandDeep = Color(0xFFB45309);
  static const brandLight = Color(0xFFFEF3C7);
  static const brandSurface = Color(0xFFFFFBEB);

  // Status
  static const waiting = Color(0xFFEA580C);
  static const waitingLight = Color(0xFFFFF7ED);
  static const confirmed = Color(0xFF16A34A);
  static const confirmedLight = Color(0xFFF0FDF4);
  static const danger = Color(0xFFDC2626);
  static const dangerLight = Color(0xFFFEF2F2);
  static const completed = Color(0xFF78716C);
  static const completedLight = Color(0xFFF5F4F0);

  static const double arrivalRadiusMeters = 200;

  // Radii
  static const r = 16.0;
  static const rSm = 10.0;
  static const rXs = 6.0;

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF1C1917).withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF1C1917).withOpacity(0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  // Text styles
  static const titleLg = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: ink,
    letterSpacing: -0.3,
    height: 1.2,
  );
  static const titleMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: ink,
    letterSpacing: -0.2,
  );
  static const titleSm = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: ink,
  );
  static const bodyMd = TextStyle(
    fontSize: 13,
    color: inkSecondary,
    height: 1.45,
  );
  static const bodySm = TextStyle(fontSize: 12, color: inkMuted, height: 1.4);
  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: inkSecondary,
  );
  static const labelBold = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class TableBookings extends StatefulWidget {
  const TableBookings({super.key});

  @override
  State<TableBookings> createState() => _TableBookingsState();
}

class _TableBookingsState extends State<TableBookings> {
  late Future<List<WaitingItem>> _waitingFuture;
  late Future<List<ConfirmedList>> _confirmedFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _waitingFuture = food_Authservice.fetchWaitingList();
    _confirmedFuture = food_Authservice.fetchConfirmedList();
  }

  void _refresh() => setState(() => _load());

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final hPad = mq.size.width < 380 ? 14.0 : 18.0;

    return Scaffold(
      // backgroundColor: _T.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _AppHeader(onRefresh: _refresh),
            Expanded(
              child: FutureBuilder2(
                waitingFuture: _waitingFuture,
                confirmedFuture: _confirmedFuture,
                hPad: hPad,
                onRefresh: _refresh,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Combined FutureBuilder ───────────────────────────────────────────────────
class FutureBuilder2 extends StatelessWidget {
  final Future<List<WaitingItem>> waitingFuture;
  final Future<List<ConfirmedList>> confirmedFuture;
  final double hPad;
  final VoidCallback onRefresh;

  const FutureBuilder2({
    super.key,
    required this.waitingFuture,
    required this.confirmedFuture,
    required this.hPad,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WaitingItem>>(
      future: waitingFuture,
      builder: (context, waitingSnap) {
        return FutureBuilder<List<ConfirmedList>>(
          future: confirmedFuture,
          builder: (context, confirmedSnap) {
            final bothDone =
                waitingSnap.connectionState == ConnectionState.done &&
                confirmedSnap.connectionState == ConnectionState.done;

            if (!bothDone) return const _LoadingView();

            if (waitingSnap.hasError || confirmedSnap.hasError) {
              final err = (waitingSnap.error ?? confirmedSnap.error).toString();
              return _ErrorView(error: err, onRetry: onRefresh);
            }

            final waitingItems = waitingSnap.data ?? [];
            final confirmedItems = List<ConfirmedList>.from(
              confirmedSnap.data ?? [],
            );

            confirmedItems.sort((a, b) {
              final aDone =
                  a.arrivalStatus.toUpperCase() == 'COMPLETED' ||
                  a.arrivalStatus.toUpperCase() == 'CANCELLED';
              final bDone =
                  b.arrivalStatus.toUpperCase() == 'COMPLETED' ||
                  b.arrivalStatus.toUpperCase() == 'CANCELLED';
              if (aDone == bDone) return 0;
              return aDone ? 1 : -1;
            });

            final hasWaiting = waitingItems.isNotEmpty;
            final hasConfirmed = confirmedItems.isNotEmpty;

            if (!hasWaiting && !hasConfirmed) {
              return const _EmptyView(message: 'No bookings yet');
            }

            return RefreshIndicator(
              color: _T.brand,
              backgroundColor: _T.surface,
              onRefresh: () async => onRefresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (hasWaiting) ...[
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        icon: Icons.hourglass_top_rounded,
                        label: 'Waiting for Confirmation',
                        count: waitingItems.length,
                        color: _T.waiting,
                        bg: _T.waitingLight,
                        hPad: hPad,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _WaitingCard(
                            item: waitingItems[waitingItems.length - 1 - i],
                          ),
                          childCount: waitingItems.length,
                        ),
                      ),
                    ),
                  ],
                  if (hasConfirmed) ...[
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        icon: Icons.event_available_rounded,
                        label: 'Confirmed Bookings',
                        count: confirmedItems.length,
                        color: _T.confirmed,
                        bg: _T.confirmedLight,
                        hPad: hPad,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => ConfirmedListCard(item: confirmedItems[i]),
                          childCount: confirmedItems.length,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final Color bg;
  final double hPad;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
    required this.hPad,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: _T.titleSm)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Text('$count', style: _T.labelBold.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}

// ─── Waiting Card ─────────────────────────────────────────────────────────────
class _WaitingCard extends StatelessWidget {
  final WaitingItem item;
  const _WaitingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(_T.r),
        border: Border.all(color: _T.border),
        boxShadow: _T.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_T.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_T.waiting, Color(0xFFFBBF24)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Avatar(name: item.guestName),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.guestName,
                              style: _T.titleMd,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(item.phoneNumber, style: _T.bodySm),
                          ],
                        ),
                      ),
                      const _StatusPill(
                        label: 'Waiting',
                        color: _T.waiting,
                        bg: _T.waitingLight,
                        icon: Icons.hourglass_empty_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: _T.border),
                  const SizedBox(height: 12),
                  _InfoGrid(
                    children: [
                      _InfoCell(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: DateTimeHelper.formatDateString(
                          item.bookingDate,
                        ),
                      ),
                      _InfoCell(
                        icon: Icons.schedule_rounded,
                        label: 'Time',
                        value: DateTimeHelper.to12Hour(item.requestTime),
                      ),
                      _InfoCell(
                        icon: Icons.group_rounded,
                        label: 'Guests',
                        value: '${item.capacity} people',
                      ),
                      _InfoCell(
                        icon: Icons.timer_rounded,
                        label: 'Duration',
                        value: '${item.durationMinutes} min',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Confirmed Card ───────────────────────────────────────────────────────────
class ConfirmedListCard extends StatefulWidget {
  final ConfirmedList item;
  const ConfirmedListCard({super.key, required this.item});

  @override
  State<ConfirmedListCard> createState() => _ConfirmedListCardState();
}

class _ConfirmedListCardState extends State<ConfirmedListCard> {
  late bool _arrived;
  bool _loading = false;
  late String _arrivalStatus;

  @override
  void initState() {
    super.initState();
    _arrivalStatus = widget.item.arrivalStatus.toUpperCase();
    _arrived = _arrivalStatus == 'ARRIVED';
  }

  bool get _isCompleted => _arrivalStatus == 'COMPLETED';
  bool get _isCancelled => _arrivalStatus == 'CANCELLED';
  bool get _isInactive => _isCompleted || _isCancelled;

  bool get _isArrivalLocked {
    if (_arrived) return false;
    try {
      final dt = DateTime.parse(
        '${widget.item.bookingDate}T${widget.item.startTime}',
      );
      final diff = dt.difference(DateTime.now());
      return diff.inMinutes > 30;
    } catch (_) {
      return false;
    }
  }

  Future<void> _markArrived() async {
    setState(() => _loading = true);
    final ok = await food_Authservice.sendArrivalStatus(
      widget.item.id,
      'ARRIVED',
    );
    if (!ok) {
      if (mounted) AppAlert.error(context, 'Failed to update arrival status');
      setState(() => _loading = false);
      return;
    }
    if (mounted) {
      setState(() {
        _arrived = true;
        _arrivalStatus = 'ARRIVED';
        _loading = false;
      });
    }
  }

  Future<void> _cancelArrival() async {
    setState(() => _loading = true);
    final ok = await food_Authservice.sendArrivalStatus(
      widget.item.id,
      'CANCELLED',
    );
    if (!ok) {
      if (mounted) AppAlert.error(context, 'Failed to cancel arrival');
      setState(() => _loading = false);
      return;
    }
    if (mounted) {
      setState(() {
        _arrived = false;
        _arrivalStatus = 'CANCELLED';
        _loading = false;
      });
    }
  }

  String _formatTime(String t) {
    try {
      return DateFormat('hh:mm a').format(DateFormat('HH:mm:ss').parse(t));
    } catch (_) {
      return t;
    }
  }

  Color get _accentColor {
    if (_isCompleted) return _T.completed;
    if (_isCancelled) return _T.danger;
    if (_arrived) return _T.confirmed;
    return _T.brand;
  }

  Widget get _statusBadge {
    if (_isCompleted) {
      return const _StatusPill(
        label: 'Completed',
        color: _T.completed,
        bg: _T.completedLight,
        icon: Icons.check_circle_rounded,
      );
    }
    if (_isCancelled) {
      return const _StatusPill(
        label: 'Cancelled',
        color: _T.danger,
        bg: _T.dangerLight,
        icon: Icons.cancel_rounded,
      );
    }
    if (_arrived) {
      return const _StatusPill(
        label: 'Arrived',
        color: _T.confirmed,
        bg: _T.confirmedLight,
        icon: Icons.where_to_vote_rounded,
      );
    }
    return const _StatusPill(
      label: 'Confirmed',
      color: _T.brand,
      bg: _T.brandLight,
      icon: Icons.event_available_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _isInactive ? 0.5 : 1.0,
      child: IgnorePointer(
        ignoring: _isInactive,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(_T.r),
            border: Border.all(color: _T.border),
            boxShadow: _T.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_T.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top accent stripe
                Container(height: 3, color: _accentColor),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _T.brandSurface,
                              borderRadius: BorderRadius.circular(_T.rSm),
                              border: Border.all(color: _T.brandLight),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.table_restaurant_rounded,
                                  size: 16,
                                  color: _T.brand,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  item.code,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _T.brandDeep,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.guestName.toUpperCase(),
                                  style: _T.titleMd,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(item.phoneNumber, style: _T.bodySm),
                              ],
                            ),
                          ),
                          _statusBadge,
                        ],
                      ),

                      const SizedBox(height: 14),
                      const Divider(height: 1, color: _T.border),
                      const SizedBox(height: 12),

                      _InfoGrid(
                        children: [
                          _InfoCell(
                            icon: Icons.calendar_today_rounded,
                            label: 'Date',
                            value: DateTimeHelper.formatDateString(
                              item.bookingDate,
                            ),
                          ),
                          _InfoCell(
                            icon: Icons.schedule_rounded,
                            label: 'Start Time',
                            value: _formatTime(item.startTime),
                          ),
                          _InfoCell(
                            icon: Icons.group_rounded,
                            label: 'Guests',
                            value: '${item.capacity} people',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Info Grid ────────────────────────────────────────────────────────────────
class _InfoGrid extends StatelessWidget {
  final List<Widget> children;
  const _InfoGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3.2,
      mainAxisSpacing: 6,
      crossAxisSpacing: 8,
      children: children,
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
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _T.bg,
            borderRadius: BorderRadius.circular(_T.rXs),
          ),
          child: Icon(icon, size: 13, color: _T.inkMuted),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: _T.label),
              Text(
                value,
                style: _T.titleSm.copyWith(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_T.brand, _T.brandDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_T.rSm),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─── Status Pill ──────────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;
  const _StatusPill({
    required this.label,
    required this.color,
    required this.bg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: _T.labelBold.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final bool arrived;
  final bool loading;
  final bool locked;
  final VoidCallback onArrived;
  final VoidCallback onBeforeArrivalCancel;
  final VoidCallback onAfterArrivalCancel;
  final VoidCallback onAddItems;
  final VoidCallback onDirections;

  const _ActionButtons({
    required this.arrived,
    required this.loading,
    required this.locked,
    required this.onArrived,
    required this.onBeforeArrivalCancel,
    required this.onAfterArrivalCancel,
    required this.onAddItems,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        height: 44,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: _T.brand),
        ),
      );
    }

    if (arrived) {
      return Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Add Items to Order',
              icon: Icons.restaurant_menu_rounded,
              color: Colors.white,
              bg: _T.brand,
              onTap: onAddItems,
            ),
          ),

          const SizedBox(width: 8),

          _ActionButton(
            label: 'Cancel Table',
            icon: Icons.logout_rounded,
            color: Colors.white,
            bg: Colors.orange,
            onTap: onAfterArrivalCancel,
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: locked ? 'Arrived (30 min before)' : "I've Arrived",
                icon: locked
                    ? Icons.lock_clock_rounded
                    : Icons.where_to_vote_rounded,
                color: locked ? _T.inkMuted : Colors.white,
                bg: locked ? _T.completedLight : _T.confirmed,
                disabled: locked,
                onTap: onArrived,
              ),
            ),

            const SizedBox(width: 8),

            _ActionButton(
              label: 'Cancel',
              icon: Icons.close_rounded,
              color: Colors.white,
              bg: _T.danger,
              onTap: onBeforeArrivalCancel,
            ),
          ],
        ),

        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          child: _ActionButton(
            label: 'Get Directions',
            icon: Icons.directions_rounded,
            color: Colors.white,
            bg: Colors.blue,
            onTap: onDirections,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  final bool disabled;
  final bool fullWidth;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
    this.disabled = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.45 : 1.0,
        child: Container(
          height: 44,
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(_T.rSm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDistance(double meters) {
  if (meters < 1000) {
    return '${meters.toStringAsFixed(0)} m';
  }

  final km = meters / 1000;

  return '${km.toStringAsFixed(1)} km';
}

class _ArrivalDialog extends StatelessWidget {
  final double distance;

  const _ArrivalDialog({required this.distance});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: _T.dangerLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_rounded,
                color: _T.danger,
                size: 24,
              ),
            ),

            const SizedBox(height: 16),

            const Text('Too Far Away', style: _T.titleLg),

            const SizedBox(height: 12),

            Text(
              'You are ${_formatDistance(distance)} meters away from the restaurant.\n\n'
              'Please come within  ${_T.arrivalRadiusMeters.toInt()}  meters to mark yourself as arrived.',
              textAlign: TextAlign.center,
              style: _T.bodyMd,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _T.danger,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_T.rSm),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelDialog extends StatelessWidget {
  const _CancelDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: _T.dangerLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cancel_rounded,
                    color: _T.danger,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Cancel Booking', style: _T.titleLg),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to cancel this booking? This action cannot be undone.',
              style: _T.bodyMd,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_T.rSm),
                        side: const BorderSide(color: _T.border),
                      ),
                    ),
                    child: Text(
                      'Keep Booking',
                      style: TextStyle(
                        color: _T.inkSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _T.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_T.rSm),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Yes, Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── State Views ──────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _T.brandLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _T.brand,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Loading bookings…', style: _T.bodyMd),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _T.dangerLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 28,
                color: _T.danger,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Something went wrong', style: _T.titleMd),
            const SizedBox(height: 6),
            Text(error, style: _T.bodyMd, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _T.brand,
                  borderRadius: BorderRadius.circular(_T.rSm),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _T.brandLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.table_restaurant_outlined,
              size: 32,
              color: _T.brand,
            ),
          ),
          const SizedBox(height: 16),
          const Text('No Bookings Yet', style: _T.titleMd),
          const SizedBox(height: 6),
          Text(message, style: _T.bodyMd),
        ],
      ),
    );
  }
}

class _LeaveTableDialog extends StatelessWidget {
  const _LeaveTableDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout_rounded, size: 40, color: Colors.orange),

            const SizedBox(height: 16),

            const Text(
              'Leave Table?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),

            const Text(
              'You can leave table only when all ordered items are inactive.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('No'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Yes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
