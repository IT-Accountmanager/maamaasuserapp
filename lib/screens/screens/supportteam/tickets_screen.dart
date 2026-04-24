import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../Models/subscrptions/ticket_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../../Services/Auth_service/promotion_services_Authservice.dart';
import '../../../providers/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';

// ── Design tokens — White theme ───────────────────────────────────────────────
class tktcolour {
  // Backgrounds
  static const bg = Color(0xFFF5F6FA); // soft off-white page
  static const surface = Color(0xFFFFFFFF); // white surfaces
  static const card = Color(0xFFFFFFFF); // white cards
  static const cardBorder = Color(0xFFE8ECF4); // cool-grey border

  // Accent — violet (matches app's existing 0xFF6C63FF brand)
  static const amber = Color(0xFF6C63FF); // primary CTA

  // Text
  static const textPrimary = Color(0xFF1A1D2E); // near-black
  static const textSecondary = Color(0xFF64748B); // medium grey
  static const textMuted = Color(0xFFB0B8CC); // muted grey

  // Status colours — kept vivid so they pop on white
  static const open = Color(0xFF10B981);
  static const progress = Color(0xFFF59E0B);
  static const resolved = Color(0xFF3B82F6);
  static const resolvedDim = Color(0x153B82F6);
  static const rejected = Color(0xFFEF4444);
}

// ═══════════════════════════════════════════════════════════════════════════════
// TicketListScreen
// ═══════════════════════════════════════════════════════════════════════════════
class TicketListScreen extends StatefulWidget {
  final int userId;
  const TicketListScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _TicketListScreenState createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  late Future<List<Ticket>> _futureTickets;

  @override
  void initState() {
    super.initState();
    _futureTickets = promotion_Authservice.fetchTicketsByUser();
  }

  Future<void> _refreshTickets() async {
    setState(() {
      _futureTickets = promotion_Authservice.fetchTicketsByUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tktcolour.bg,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderStats(),
            Expanded(
              child: FutureBuilder<List<Ticket>>(
                future: _futureTickets,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  } else if (snapshot.hasError) {
                    return _buildErrorState();
                  }

                  final tickets = (snapshot.data ?? []).reversed.toList();

                  if (tickets.isEmpty) return _buildEmptyState();

                  return RefreshIndicator(
                    onRefresh: _refreshTickets,
                    backgroundColor: tktcolour.surface,
                    color: tktcolour.amber,
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                      itemCount: tickets.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) =>
                          _buildTicketCard(context, tickets[index]),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: tktcolour.bg,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'My Tickets',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: tktcolour.textPrimary,
          letterSpacing: 0.3,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: tktcolour.cardBorder),
      ),
    );
  }

  // ── Stats header ─────────────────────────────────────────────────────────
  Widget _buildHeaderStats() {
    return FutureBuilder<List<Ticket>>(
      future: _futureTickets,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        final tickets = snapshot.data ?? [];
        final open = tickets.where((t) => t.status == 'OPEN').length;
        final inProg = tickets.where((t) => t.status == 'IN_PROGRESS').length;
        final resolved = tickets.where((t) => t.status == 'RESOLVED').length;

        return Container(
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6C63FF), Color(0xFF4A43C9)],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.28),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(
                tickets.length,
                'Total',
                Icons.confirmation_number_rounded,
                tktcolour.amber,
              ),
              _divider(),
              _statItem(open, 'Open', Icons.lock_open_rounded, tktcolour.open),
              _divider(),
              _statItem(
                inProg,
                'Progress',
                Icons.autorenew_rounded,
                tktcolour.progress,
              ),
              _divider(),
              _statItem(
                resolved,
                'Closed',
                Icons.check_circle_rounded,
                tktcolour.resolved,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 36.h, color: Colors.white.withOpacity(0.2));

  Widget _statItem(int count, String label, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }

  // ── States ───────────────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40.r,
            height: 40.r,
            child: CircularProgressIndicator(
              color: tktcolour.amber,
              strokeWidth: 2.5,
              backgroundColor: tktcolour.cardBorder,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading tickets...',
            style: TextStyle(fontSize: 13.sp, color: tktcolour.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 56.sp, color: tktcolour.textMuted),
            SizedBox(height: 16.h),
            Text(
              'Failed to load tickets',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: tktcolour.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Check your connection and try again',
              style: TextStyle(fontSize: 13.sp, color: tktcolour.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            _primaryButton('Retry', _refreshTickets),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96.r,
              height: 96.r,
              decoration: BoxDecoration(
                color: tktcolour.surface,
                shape: BoxShape.circle,
                border: Border.all(color: tktcolour.cardBorder, width: 2),
              ),
              child: Icon(
                Icons.confirmation_number_outlined,
                size: 40.sp,
                color: tktcolour.textMuted,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No tickets yet',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: tktcolour.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Create a ticket to get support\nfrom our team.',
              style: TextStyle(fontSize: 13.sp, color: tktcolour.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            _primaryButton('Create Ticket', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateTicketScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Ticket card ──────────────────────────────────────────────────────────
  Widget _buildTicketCard(BuildContext context, Ticket ticket) {
    final statusColor = _statusColor(ticket.status);
    final statusIcon = _statusIcon(ticket.status);
    final date = DateFormat('MMM dd, yyyy').format(ticket.createdAt.toLocal());
    final time = DateFormat('hh:mm a').format(ticket.createdAt.toLocal());

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: ticket)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: tktcolour.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: tktcolour.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top accent bar matching status colour
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Issue type + status badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatType(ticket.issueType),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: tktcolour.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _statusBadge(statusColor, statusIcon, ticket.status),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Meta row
                  // Column(
                  //   children: [
                  _metaChip(Icons.tag_rounded, ticket.ticketNumber),
                  SizedBox(width: 8.w),
                  _metaChip(Icons.calendar_today_rounded, date),
                  SizedBox(width: 8.w),
                  _metaChip(Icons.schedule_rounded, time),

                  //   ],
                  // ),
                  if (ticket.orderId != null) ...[
                    SizedBox(height: 8.h),
                    _metaChip(
                      Icons.receipt_long_rounded,
                      'Order #${ticket.orderId}',
                    ),
                  ],

                  SizedBox(height: 14.h),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'View details',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: tktcolour.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14.sp,
                        color: tktcolour.amber,
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

  Widget _statusBadge(Color color, IconData icon, String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            status.replaceAll('_', ' '),
            style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11.sp, color: tktcolour.textMuted),
        SizedBox(width: 3.w),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: tktcolour.textSecondary),
        ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  Widget _primaryButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: tktcolour.amber,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: tktcolour.amber.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: tktcolour.bg,
          ),
        ),
      ),
    );
  }

  String _formatType(String v) => v
      .toLowerCase()
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
      .join(' ');

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'OPEN':
        return tktcolour.open;
      case 'IN_PROGRESS':
        return tktcolour.progress;
      case 'RESOLVED':
        return tktcolour.resolved;
      case 'REJECTED':
        return tktcolour.rejected;
      default:
        return tktcolour.textMuted;
    }
  }

  IconData _statusIcon(String s) {
    switch (s.toUpperCase()) {
      case 'OPEN':
        return Icons.lock_open_rounded;
      case 'IN_PROGRESS':
        return Icons.autorenew_rounded;
      case 'RESOLVED':
        return Icons.check_circle_rounded;
      case 'REJECTED':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TicketDetailScreen
// ═══════════════════════════════════════════════════════════════════════════════
class TicketDetailScreen extends StatelessWidget {
  final Ticket ticket;
  const TicketDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final statusColor = _statusColor(ticket.status);
    final statusIcon = _statusIcon(ticket.status);

    return Scaffold(
      backgroundColor: tktcolour.bg,
      appBar: AppBar(
        backgroundColor: tktcolour.bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: tktcolour.textSecondary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ticket Details',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: tktcolour.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: tktcolour.cardBorder),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Hero header ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(16.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: tktcolour.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: tktcolour.cardBorder),
                  // Coloured top accent
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: statusColor.withOpacity(0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12.sp, color: statusColor),
                              SizedBox(width: 4.w),
                              Text(
                                ticket.status.replaceAll('_', ' '),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '#${ticket.id}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: tktcolour.textMuted,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      _formatType(ticket.issueType),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: tktcolour.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Detail grid ───────────────────────────────────────────
            if (ticket.orderId != null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _buildDetailsGrid(ticket, dateFormat),
                ),
              ),
            ],

            SliverToBoxAdapter(child: SizedBox(height: 16.h)),

            // ── Description ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: _sectionCard(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                title: 'Description',
                icon: Icons.notes_rounded,
                iconColor: tktcolour.amber,
                child: Text(
                  ticket.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.7,
                    color: tktcolour.textSecondary,
                  ),
                ),
              ),
            ),

            // ── Attachment ────────────────────────────────────────────
            if (ticket.attachmentUrl != null &&
                ticket.attachmentUrl!.isNotEmpty) ...[
              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
              SliverToBoxAdapter(
                child: _sectionCard(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  title: 'Attachment',
                  icon: Icons.attach_file_rounded,
                  iconColor: tktcolour.resolved,
                  child: _buildAttachmentWidget(ticket.attachmentUrl!),
                ),
              ),
            ],

            // ── Admin response ────────────────────────────────────────
            if (ticket.adminResponse != null) ...[
              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
              SliverToBoxAdapter(
                child: _sectionCard(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  title: 'Admin Response',
                  icon: Icons.support_agent_rounded,
                  iconColor: tktcolour.resolved,
                  accentColor: tktcolour.resolvedDim,
                  child: Text(
                    (ticket.adminResponse ?? '').replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.7,
                      color: tktcolour.resolved,
                    ),
                  ),
                ),
              ),
            ],

            SliverToBoxAdapter(child: SizedBox(height: 32.h)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(Ticket ticket, DateFormat fmt) {
    final items = <_DetailItem>[
      _DetailItem(
        icon: Icons.calendar_month_rounded,
        label: 'Created',
        value: fmt.format(ticket.createdAt.toLocal()),
        color: tktcolour.amber,
      ),
      if (ticket.orderId != 0)
        _DetailItem(
          icon: Icons.receipt_long_rounded,
          label: 'Order ID',
          value: ticket.orderId.toString(),
          color: tktcolour.open,
        ),
      if (ticket.status == 'RESOLVED' || ticket.status == 'REJECTED')
        _DetailItem(
          icon: Icons.check_circle_rounded,
          label: 'Resolved',
          value: fmt.format(ticket.resolvedAt!.toLocal()),
          color: tktcolour.resolved,
        ),
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _detailRow(item),
            ),
          )
          .toList(),
    );
  }

  Widget _detailRow(_DetailItem item) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: tktcolour.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: tktcolour.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(item.icon, size: 16.sp, color: item.color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(fontSize: 11.sp, color: tktcolour.textMuted),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: tktcolour.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required EdgeInsets margin,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    Color? accentColor,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: accentColor ?? tktcolour.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: tktcolour.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
            child: Row(
              children: [
                Icon(icon, size: 16.sp, color: iconColor),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: tktcolour.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(16.w), child: child),
        ],
      ),
    );
  }

  Widget _buildAttachmentWidget(String url) {
    const double size = 120;

    Widget image;
    if (url.startsWith('data:image')) {
      try {
        final bytes = base64Decode(url.split(',').last.trim());
        image = Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        image = _errorPlaceholder();
      }
    } else {
      image = Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, loading) => loading == null
            ? child
            : Center(
                child: CircularProgressIndicator(
                  color: tktcolour.amber,
                  strokeWidth: 2,
                ),
              ),
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: tktcolour.cardBorder, width: 1.5),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(11.r), child: image),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      color: tktcolour.card,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_rounded, color: tktcolour.textMuted, size: 28.sp),
          SizedBox(height: 6.h),
          Text(
            'Unable to load',
            style: TextStyle(color: tktcolour.textMuted, fontSize: 10.sp),
          ),
        ],
      ),
    );
  }

  String _formatType(String v) => v
      .toLowerCase()
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
      .join(' ');

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'OPEN':
        return tktcolour.open;
      case 'IN_PROGRESS':
        return tktcolour.progress;
      case 'RESOLVED':
        return tktcolour.resolved;
      case 'REJECTED':
        return tktcolour.rejected;
      default:
        return tktcolour.textMuted;
    }
  }

  IconData _statusIcon(String s) {
    switch (s.toUpperCase()) {
      case 'OPEN':
        return Icons.lock_open_rounded;
      case 'IN_PROGRESS':
        return Icons.autorenew_rounded;
      case 'RESOLVED':
        return Icons.check_circle_rounded;
      case 'REJECTED':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// CreateTicketScreen
// ═══════════════════════════════════════════════════════════════════════════════
class CreateTicketScreen extends ConsumerStatefulWidget {
  final int? orderId;
  final String? serviceType;
  const CreateTicketScreen({super.key, this.orderId, this.serviceType});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  String? _selectedCategory;
  bool _loading = false;
  XFile? _pickedImage;
  final _picker = ImagePicker();

  final Map<String, String> _categoryMap = {
    'Delivery Issue': 'DELIVERY',
    'Payment Problem': 'PAYMENT',
    'Wrong Order': 'ORDER',
    'Service Quality': 'GENERAL',
    'Other': 'GENERAL',
  };

  @override
  void initState() {
    super.initState();
    if (widget.orderId != null) {
      _selectedCategory = 'Delivery Issue';
    }
  }

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _pickedImage = img);
  }

  Future<void> _submit(String userId) async {
    setState(() => _loading = true);

    final res = await promotion_Authservice.createTicket(
      orderId: widget.orderId,
      description: _messageController.text,
      serviceType: widget.serviceType,
      issueType: _categoryMap[_selectedCategory] ?? 'GENERAL',
      attachmentFile: _pickedImage != null ? File(_pickedImage!.path) : null,
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      Navigator.pop(context, true);
      AppAlert.success(context, '✅ Ticket created successfully');
    } else {
      AppAlert.error(context, '❌ Failed to create ticket');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider);

    return Scaffold(
      backgroundColor: tktcolour.bg,
      appBar: AppBar(
        backgroundColor: tktcolour.bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: tktcolour.textSecondary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Raise a Ticket',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: tktcolour.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: tktcolour.cardBorder),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Category ────────────────────────────────
                      _fieldLabel('Category', Icons.category_rounded),
                      SizedBox(height: 8.h),
                      _dropdownField(),

                      SizedBox(height: 20.h),

                      // ── Description ─────────────────────────────
                      _fieldLabel('Description', Icons.notes_rounded),
                      SizedBox(height: 8.h),
                      _textareaField(),

                      SizedBox(height: 24.h),

                      // ── Attachment ──────────────────────────────
                      _fieldLabel(
                        'Attachment (optional)',
                        Icons.attach_file_rounded,
                      ),
                      SizedBox(height: 12.h),
                      _attachmentRow(),

                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),

              // ── Submit ─────────────────────────────────────────
              _submitBar(userId.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: tktcolour.amber),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: tktcolour.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _dropdownField() {
    return Container(
      decoration: BoxDecoration(
        color: tktcolour.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: tktcolour.cardBorder),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        dropdownColor: tktcolour.surface,
        style: TextStyle(fontSize: 14.sp, color: tktcolour.textPrimary),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: tktcolour.textMuted),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
        hint: Text(
          'Select a category',
          style: TextStyle(color: tktcolour.textMuted, fontSize: 14.sp),
        ),
        items: _categoryMap.keys
            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
            .toList(),
        onChanged: (v) => setState(() => _selectedCategory = v),
        validator: (v) => v == null ? 'Please select a category' : null,
      ),
    );
  }

  Widget _textareaField() {
    return Container(
      decoration: BoxDecoration(
        color: tktcolour.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: tktcolour.cardBorder),
      ),
      child: TextFormField(
        controller: _messageController,
        maxLines: 5,
        style: TextStyle(fontSize: 14.sp, color: tktcolour.textPrimary, height: 1.6),
        cursorColor: tktcolour.amber,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.w),
          hintText: 'Describe your issue in detail...',
          hintStyle: TextStyle(color: tktcolour.textMuted, fontSize: 14.sp),
        ),
        validator: (v) =>
            (v == null || v.isEmpty) ? 'Please enter a description' : null,
      ),
    );
  }

  Widget _attachmentRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Pick button
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: tktcolour.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: tktcolour.amber.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 18.sp,
                  color: tktcolour.amber,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Add Photo',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: tktcolour.amber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Image preview
        if (_pickedImage != null) ...[
          SizedBox(width: 14.w),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: tktcolour.cardBorder, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11.r),
                  child: Image.file(
                    File(_pickedImage!.path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.error, color: tktcolour.rejected, size: 24.sp),
                  ),
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () => setState(() => _pickedImage = null),
                  child: Container(
                    width: 20.r,
                    height: 20.r,
                    decoration: BoxDecoration(
                      color: tktcolour.rejected,
                      shape: BoxShape.circle,
                      border: Border.all(color: tktcolour.bg, width: 1.5),
                    ),
                    child: Icon(Icons.close, size: 11.sp, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _submitBar(String userId) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: tktcolour.bg,
        border: Border(top: BorderSide(color: tktcolour.cardBorder)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: GestureDetector(
          onTap: _loading
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    _submit(userId);
                  }
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: _loading ? tktcolour.amber.withOpacity(0.5) : tktcolour.amber,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: _loading
                  ? []
                  : [
                      BoxShadow(
                        color: tktcolour.amber.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Center(
              child: _loading
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: tktcolour.bg,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send_rounded, size: 16.sp, color: tktcolour.bg),
                        SizedBox(width: 8.w),
                        Text(
                          'Submit Ticket',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: tktcolour.bg,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
