// // import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// // import 'package:maamaas/widgets/datetimehelper.dart';
// // import '../../../Services/Auth_service/food_authservice.dart';
// // import '../../../Models/food/table_confirmedlist_model.dart';
// // import '../../../Models/food/table_waitinglist_model.dart';
// // import 'package:flutter/material.dart';
// // import 'table_menu.dart';
// //
// // // ─── Design Tokens ────────────────────────────────────────────────────────────
// // // ignore: camel_case_types
// // class tablebcolours {
// //   static const bg = Color(0xFFF7F8FC);
// //   static const surface = Colors.white;
// //   static const border = Color(0xFFEEEFF5);
// //
// //   static const ink = Color(0xFF111827);
// //   static const inkSecondary = Color(0xFF6B7280);
// //   static const inkMuted = Color(0xFF9CA3AF);
// //
// //   static const accent = Color(0xFF4F46E5); // indigo
// //   static const accentLight = Color(0xFFEEF2FF);
// //
// //   static const waiting = Color(0xFFF59E0B); // amber
// //   static const waitingLight = Color(0xFFFFFBEB);
// //
// //   static const confirmed = Color(0xFF10B981); // emerald
// //   static const confirmedLight = Color(0xFFECFDF5);
// //
// //   static const danger = Color(0xFFEF4444);
// //   static const dangerLight = Color(0xFFFEF2F2);
// //
// //   static const completed = Color(0xFF9CA3AF);
// //   static const completedLight = Color(0xFFF9FAFB);
// //
// //   static const radius = 14.0;
// //   static const radiusSm = 8.0;
// //
// //   // Typography
// //   static const titleLg = TextStyle(
// //     fontSize: 15,
// //     fontWeight: FontWeight.w700,
// //     color: ink,
// //     letterSpacing: -0.2,
// //   );
// //   static const titleSm = TextStyle(
// //     fontSize: 13,
// //     fontWeight: FontWeight.w600,
// //     color: ink,
// //   );
// //   static const bodyMd = TextStyle(
// //     fontSize: 13,
// //     color: inkSecondary,
// //     height: 1.4,
// //   );
// //   static const bodySm = TextStyle(fontSize: 12, color: inkMuted);
// //   static const label = TextStyle(
// //     fontSize: 11,
// //     fontWeight: FontWeight.w600,
// //     letterSpacing: 0.4,
// //   );
// // }
// //
// // // ─── Screen ───────────────────────────────────────────────────────────────────
// // class TableBookings extends StatefulWidget {
// //   const TableBookings({super.key});
// //
// //   @override
// //   State<TableBookings> createState() => _TableBookingsState();
// // }
// //
// // class _TableBookingsState extends State<TableBookings>
// //     with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 2, vsync: this);
// //   }
// //
// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final mq = MediaQuery.of(context);
// //     final screenW = mq.size.width;
// //     final hPad = screenW < 380 ? 12.0 : 16.0;
// //
// //     return Scaffold(
// //       backgroundColor: tablebcolours.bg,
// //       body: SafeArea(
// //         child: Column(
// //           children: [
// //             _buildTabBar(hPad),
// //             const SizedBox(height: 4),
// //             Expanded(
// //               child: TabBarView(
// //                 controller: _tabController,
// //                 children: [
// //                   _WaitingListView(hPad: hPad),
// //                   _ConfirmedListView(hPad: hPad),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildTabBar(double hPad) {
// //     return Padding(
// //       padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
// //       child: Container(
// //         height: 46,
// //         decoration: BoxDecoration(
// //           color: tablebcolours.border,
// //           borderRadius: BorderRadius.circular(tablebcolours.radius),
// //         ),
// //         child: TabBar(
// //           controller: _tabController,
// //           indicator: BoxDecoration(
// //             color: tablebcolours.surface,
// //             borderRadius: BorderRadius.circular(tablebcolours.radiusSm + 2),
// //             boxShadow: [
// //               BoxShadow(
// //                 // ignore: deprecated_member_use
// //                 color: Colors.black.withOpacity(0.08),
// //                 blurRadius: 6,
// //                 offset: const Offset(0, 2),
// //               ),
// //             ],
// //           ),
// //           indicatorSize: TabBarIndicatorSize.tab,
// //           dividerColor: Colors.transparent,
// //           padding: const EdgeInsets.all(4),
// //           labelPadding: EdgeInsets.zero,
// //           labelStyle: tablebcolours.label.copyWith(color: tablebcolours.ink),
// //           unselectedLabelStyle: tablebcolours.label.copyWith(
// //             color: tablebcolours.inkMuted,
// //           ),
// //           tabs: [
// //             _Tab(icon: Icons.access_time_rounded, label: 'Waiting'),
// //             _Tab(icon: Icons.check_circle_outline_rounded, label: 'Confirmed'),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class _Tab extends StatelessWidget {
// //   final IconData icon;
// //   final String label;
// //   const _Tab({required this.icon, required this.label});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Tab(
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [Icon(icon, size: 15), const SizedBox(width: 6), Text(label)],
// //       ),
// //     );
// //   }
// // }
// //
// // // ─── Waiting List View ────────────────────────────────────────────────────────
// // class _WaitingListView extends StatefulWidget {
// //   final double hPad;
// //   const _WaitingListView({required this.hPad});
// //
// //   @override
// //   State<_WaitingListView> createState() => _WaitingListViewState();
// // }
// //
// // class _WaitingListViewState extends State<_WaitingListView> {
// //   late Future<List<WaitingItem>> _future;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _future = food_Authservice.fetchWaitingList();
// //   }
// //
// //   void _refresh() => setState(() {
// //     _future = food_Authservice.fetchWaitingList();
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return FutureBuilder<List<WaitingItem>>(
// //       future: _future,
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const _LoadingView();
// //         }
// //         if (snapshot.hasError) {
// //           return _ErrorView(
// //             error: snapshot.error.toString(),
// //             onRetry: _refresh,
// //           );
// //         }
// //         final items = snapshot.data ?? [];
// //         if (items.isEmpty) {
// //           return const _EmptyView(message: 'No tables in waiting list');
// //         }
// //         return ListView.builder(
// //           padding: EdgeInsets.fromLTRB(widget.hPad, 12, widget.hPad, 24),
// //           itemCount: items.length,
// //           reverse: true,
// //           itemBuilder: (_, i) => _WaitingCard(item: items[i]),
// //         );
// //       },
// //     );
// //   }
// // }
// //
// // // ─── Confirmed List View ──────────────────────────────────────────────────────
// // class _ConfirmedListView extends StatefulWidget {
// //   final double hPad;
// //   const _ConfirmedListView({required this.hPad});
// //
// //   @override
// //   State<_ConfirmedListView> createState() => _ConfirmedListViewState();
// // }
// //
// // class _ConfirmedListViewState extends State<_ConfirmedListView> {
// //   late Future<List<ConfirmedList>> _future;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _future = food_Authservice.fetchConfirmedList();
// //   }
// //
// //   void _refresh() => setState(() {
// //     _future = food_Authservice.fetchConfirmedList();
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return FutureBuilder<List<ConfirmedList>>(
// //       future: _future,
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const _LoadingView();
// //         }
// //         if (snapshot.hasError) {
// //           return _ErrorView(
// //             error: snapshot.error.toString(),
// //             onRetry: _refresh,
// //           );
// //         }
// //         final items = List<ConfirmedList>.from(snapshot.data ?? []);
// //         if (items.isEmpty) {
// //           return const _EmptyView(message: 'No confirmed bookings');
// //         }
// //         items.sort((a, b) {
// //           final aD = a.arrivalStatus.toUpperCase() == 'COMPLETED';
// //           final bD = b.arrivalStatus.toUpperCase() == 'COMPLETED';
// //           if (aD == bD) return 0;
// //           return aD ? 1 : -1;
// //         });
// //         return ListView.builder(
// //           padding: EdgeInsets.fromLTRB(widget.hPad, 12, widget.hPad, 24),
// //           itemCount: items.length,
// //           itemBuilder: (_, i) => ConfirmedListCard(item: items[i]),
// //         );
// //       },
// //     );
// //   }
// // }
// //
// // // ─── Waiting Card ─────────────────────────────────────────────────────────────
// // class _WaitingCard extends StatelessWidget {
// //   final WaitingItem item;
// //   const _WaitingCard({required this.item});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 10),
// //       decoration: BoxDecoration(
// //         color: tablebcolours.surface,
// //         borderRadius: BorderRadius.circular(tablebcolours.radius),
// //         border: Border.all(color: tablebcolours.border),
// //         boxShadow: [
// //           BoxShadow(
// //             // ignore: deprecated_member_use
// //             color: Colors.black.withOpacity(0.04),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: ClipRRect(
// //         borderRadius: BorderRadius.circular(tablebcolours.radius),
// //         child: IntrinsicHeight(
// //           child: Row(
// //             crossAxisAlignment: CrossAxisAlignment.stretch,
// //             children: [
// //               // Left accent bar
// //               Container(width: 4, color: tablebcolours.waiting),
// //               Expanded(
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(14),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       // Header row
// //                       // Row(
// //                       //   mainAxisAlignment: MainAxisAlignment.end,
// //                       //   children: [
// //                       //     _StatusBadge(
// //                       //       label: 'Waiting',
// //                       //       color: tablebcolours.waiting,
// //                       //       bg: tablebcolours.waitingLight,
// //                       //       icon: Icons.access_time_rounded,
// //                       //     ),
// //                       //   ],
// //                       // ),
// //                       // const SizedBox(height: 10),
// //                       // Info rows
// //                       _InfoRow(Icons.person_outline_rounded, item.guestName),
// //                       _InfoRow(Icons.phone_outlined, item.phoneNumber),
// //                       _InfoRow(
// //                         Icons.calendar_today_outlined,
// //                         DateTimeHelper.formatDateString(item.bookingDate),
// //                       ),
// //                       _InfoRow(
// //                         Icons.schedule_outlined,
// //                         DateTimeHelper.to12Hour(item.requestTime),
// //                       ),
// //                       const SizedBox(height: 8),
// //                       // Chips
// //                       Wrap(
// //                         spacing: 8,
// //                         children: [
// //                           _Chip(
// //                             Icons.group_outlined,
// //                             '${item.capacity} guests',
// //                           ),
// //                           _Chip(
// //                             Icons.timer_outlined,
// //                             '${item.durationMinutes} min',
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ─── Confirmed Card ───────────────────────────────────────────────────────────
// // class ConfirmedListCard extends StatefulWidget {
// //   final ConfirmedList item;
// //   const ConfirmedListCard({super.key, required this.item});
// //
// //   @override
// //   State<ConfirmedListCard> createState() => _ConfirmedListCardState();
// // }
// //
// // class _ConfirmedListCardState extends State<ConfirmedListCard> {
// //   late bool _arrived;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _arrived = widget.item.arrivalStatus.toUpperCase() == 'ARRIVED';
// //   }
// //
// //   bool get _isCompleted =>
// //       widget.item.arrivalStatus.toUpperCase() == 'COMPLETED';
// //
// //   Future<void> _toggleArrival() async {
// //     final ok = await food_Authservice.sendArrivalStatus(widget.item.id);
// //     if (!ok) {
// //       if (mounted) AppAlert.error(context, 'Failed to update arrival status');
// //       return;
// //     }
// //     if (mounted) setState(() => _arrived = !_arrived);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final item = widget.item;
// //
// //     return AnimatedOpacity(
// //       duration: const Duration(milliseconds: 300),
// //       opacity: _isCompleted ? 0.55 : 1.0,
// //       child: IgnorePointer(
// //         ignoring: _isCompleted,
// //         child: Container(
// //           margin: const EdgeInsets.only(bottom: 10),
// //           decoration: BoxDecoration(
// //             color: tablebcolours.surface,
// //             borderRadius: BorderRadius.circular(tablebcolours.radius),
// //             border: Border.all(color: tablebcolours.border),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.black.withOpacity(0.04),
// //                 blurRadius: 8,
// //                 offset: const Offset(0, 2),
// //               ),
// //             ],
// //           ),
// //           child: ClipRRect(
// //             borderRadius: BorderRadius.circular(tablebcolours.radius),
// //             child: IntrinsicHeight(
// //               child: Row(
// //                 crossAxisAlignment: CrossAxisAlignment.stretch,
// //                 children: [
// //                   // Left accent bar
// //                   Container(
// //                     width: 4,
// //                     color: _isCompleted
// //                         ? tablebcolours.completed
// //                         : (_arrived
// //                               ? tablebcolours.confirmed
// //                               : tablebcolours.accent),
// //                   ),
// //                   Expanded(
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(14),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           // Header
// //                           Row(
// //                             children: [
// //                               Container(
// //                                 width: 36,
// //                                 height: 36,
// //                                 decoration: BoxDecoration(
// //                                   color: tablebcolours.accentLight,
// //                                   shape: BoxShape.circle,
// //                                 ),
// //                                 child: Icon(
// //                                   Icons.table_restaurant_rounded,
// //                                   size: 18,
// //                                   color: tablebcolours.accent,
// //                                 ),
// //                               ),
// //                               const SizedBox(width: 10),
// //                               Expanded(
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     // Text(
// //                                     //   item.types.toUpperCase().replaceAll(
// //                                     //     '_',
// //                                     //     ' ',
// //                                     //   ),
// //                                     //   style: tablebcolours.titleLg,
// //                                     //   overflow: TextOverflow.ellipsis,
// //                                     // ),
// //                                     Text(
// //                                       'Table ${item.code}',
// //                                       style: tablebcolours.bodySm.copyWith(
// //                                         color: tablebcolours.accent,
// //                                         fontWeight: FontWeight.w600,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                               if (_isCompleted)
// //                                 _StatusBadge(
// //                                   label: 'Done',
// //                                   color: tablebcolours.completed,
// //                                   bg: tablebcolours.completedLight,
// //                                   icon: Icons.check_circle_outline_rounded,
// //                                 ),
// //                             ],
// //                           ),
// //
// //                           const SizedBox(height: 10),
// //                           const Divider(height: 1, color: tablebcolours.border),
// //                           const SizedBox(height: 10),
// //
// //                           // Info
// //                           _InfoRow(
// //                             Icons.person_outline_rounded,
// //                             item.guestName,
// //                           ),
// //                           _InfoRow(Icons.phone_outlined, item.phoneNumber),
// //                           _InfoRow(
// //                             Icons.calendar_today_outlined,
// //                             DateTimeHelper.formatDateString(item.bookingDate),
// //                           ),
// //
// //                           const SizedBox(height: 8),
// //
// //                           // Chips
// //                           Wrap(
// //                             spacing: 8,
// //                             children: [
// //                               _Chip(
// //                                 Icons.group_outlined,
// //                                 '${item.capacity} guests',
// //                               ),
// //                               _Chip(
// //                                 Icons.timer_outlined,
// //                                 '${item.durationMinutes} min',
// //                               ),
// //                             ],
// //                           ),
// //
// //                           // Action buttons
// //                           if (!_isCompleted) ...[
// //                             const SizedBox(height: 12),
// //                             _ActionButtons(
// //                               arrived: _arrived,
// //                               onToggle: _toggleArrival,
// //                               onAddItems: () => Navigator.push(
// //                                 context,
// //                                 MaterialPageRoute(
// //                                   builder: (_) => tablemneuScreen(
// //                                     vendorId: item.vendorId,
// //                                     seatingId: item.seatingId,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ─── Action Buttons ───────────────────────────────────────────────────────────
// // class _ActionButtons extends StatelessWidget {
// //   final bool arrived;
// //   final VoidCallback onToggle;
// //   final VoidCallback onAddItems;
// //
// //   const _ActionButtons({
// //     required this.arrived,
// //     required this.onToggle,
// //     required this.onAddItems,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: _PillButton(
// //             label: arrived ? 'Not Arrived' : 'Arrived',
// //             icon: arrived ? Icons.close_rounded : Icons.check_rounded,
// //             color: arrived ? tablebcolours.danger : tablebcolours.confirmed,
// //             bg: arrived
// //                 ? tablebcolours.dangerLight
// //                 : tablebcolours.confirmedLight,
// //             onTap: onToggle,
// //           ),
// //         ),
// //         AnimatedSize(
// //           duration: const Duration(milliseconds: 300),
// //           curve: Curves.easeInOut,
// //           child: arrived
// //               ? Row(
// //                   children: [
// //                     const SizedBox(width: 8),
// //                     _PillButton(
// //                       label: 'Add Items',
// //                       icon: Icons.restaurant_menu_rounded,
// //                       color: tablebcolours.accent,
// //                       bg: tablebcolours.accentLight,
// //                       onTap: onAddItems,
// //                     ),
// //                   ],
// //                 )
// //               : const SizedBox.shrink(),
// //         ),
// //       ],
// //     );
// //   }
// // }
// //
// // class _PillButton extends StatelessWidget {
// //   final String label;
// //   final IconData icon;
// //   final Color color;
// //   final Color bg;
// //   final VoidCallback onTap;
// //
// //   const _PillButton({
// //     required this.label,
// //     required this.icon,
// //     required this.color,
// //     required this.bg,
// //     required this.onTap,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         height: 38,
// //         padding: const EdgeInsets.symmetric(horizontal: 12),
// //         decoration: BoxDecoration(
// //           color: bg,
// //           borderRadius: BorderRadius.circular(tablebcolours.radiusSm),
// //           border: Border.all(color: color.withOpacity(0.25)),
// //         ),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Icon(icon, size: 14, color: color),
// //             const SizedBox(width: 5),
// //             Flexible(
// //               child: Text(
// //                 label,
// //                 style: tablebcolours.label.copyWith(color: color),
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ─── Shared Small Widgets ─────────────────────────────────────────────────────
// // class _InfoRow extends StatelessWidget {
// //   final IconData icon;
// //   final String value;
// //   const _InfoRow(this.icon, this.value);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 4),
// //       child: Row(
// //         children: [
// //           Icon(icon, size: 14, color: tablebcolours.inkMuted),
// //           const SizedBox(width: 6),
// //           Expanded(
// //             child: Text(
// //               value,
// //               style: tablebcolours.bodyMd,
// //               overflow: TextOverflow.ellipsis,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class _Chip extends StatelessWidget {
// //   final IconData icon;
// //   final String text;
// //   const _Chip(this.icon, this.text);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //       decoration: BoxDecoration(
// //         color: tablebcolours.bg,
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(color: tablebcolours.border),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(icon, size: 11, color: tablebcolours.inkMuted),
// //           const SizedBox(width: 4),
// //           Text(text, style: tablebcolours.bodySm),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class _StatusBadge extends StatelessWidget {
// //   final String label;
// //   final Color color;
// //   final Color bg;
// //   final IconData icon;
// //   const _StatusBadge({
// //     required this.label,
// //     required this.color,
// //     required this.bg,
// //     required this.icon,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //       decoration: BoxDecoration(
// //         color: bg,
// //         borderRadius: BorderRadius.circular(20),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(icon, size: 12, color: color),
// //           const SizedBox(width: 4),
// //           Text(label, style: tablebcolours.label.copyWith(color: color)),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ─── State Views ──────────────────────────────────────────────────────────────
// // class _LoadingView extends StatelessWidget {
// //   const _LoadingView();
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           const CircularProgressIndicator(
// //             strokeWidth: 2.5,
// //             color: tablebcolours.accent,
// //           ),
// //           const SizedBox(height: 14),
// //           Text('Loading...', style: tablebcolours.bodyMd),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class _ErrorView extends StatelessWidget {
// //   final String error;
// //   final VoidCallback onRetry;
// //   const _ErrorView({required this.error, required this.onRetry});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Padding(
// //         padding: const EdgeInsets.all(32),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Icon(
// //               Icons.wifi_off_rounded,
// //               size: 48,
// //               color: tablebcolours.inkMuted,
// //             ),
// //             const SizedBox(height: 12),
// //             Text('Something went wrong', style: tablebcolours.titleSm),
// //             const SizedBox(height: 6),
// //             Text(
// //               error,
// //               style: tablebcolours.bodyMd,
// //               textAlign: TextAlign.center,
// //             ),
// //             const SizedBox(height: 20),
// //             GestureDetector(
// //               onTap: onRetry,
// //               child: Container(
// //                 padding: const EdgeInsets.symmetric(
// //                   horizontal: 20,
// //                   vertical: 10,
// //                 ),
// //                 decoration: BoxDecoration(
// //                   color: tablebcolours.accentLight,
// //                   borderRadius: BorderRadius.circular(tablebcolours.radiusSm),
// //                 ),
// //                 child: Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     Icon(
// //                       Icons.refresh_rounded,
// //                       size: 16,
// //                       color: tablebcolours.accent,
// //                     ),
// //                     const SizedBox(width: 6),
// //                     Text(
// //                       'Try Again',
// //                       style: tablebcolours.label.copyWith(
// //                         color: tablebcolours.accent,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class _EmptyView extends StatelessWidget {
// //   final String message;
// //   const _EmptyView({required this.message});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(
// //             Icons.table_restaurant_outlined,
// //             size: 48,
// //             color: tablebcolours.inkMuted,
// //           ),
// //           const SizedBox(height: 12),
// //           Text(message, style: tablebcolours.bodyMd),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// import 'package:maamaas/widgets/datetimehelper.dart';
// import '../../../Services/Auth_service/food_authservice.dart';
// import '../../../Models/food/table_confirmedlist_model.dart';
// import '../../../Models/food/table_waitinglist_model.dart';
// import 'package:flutter/material.dart';
// import 'table_menu.dart';
//
// // ─── Design Tokens ────────────────────────────────────────────────────────────
// // ignore: camel_case_types
// class tablebcolours {
//   static const bg = Color(0xFFF7F8FC);
//   static const surface = Colors.white;
//   static const border = Color(0xFFEEEFF5);
//
//   static const ink = Color(0xFF111827);
//   static const inkSecondary = Color(0xFF6B7280);
//   static const inkMuted = Color(0xFF9CA3AF);
//
//   static const accent = Color(0xFF4F46E5);
//   static const accentLight = Color(0xFFEEF2FF);
//
//   static const waiting = Color(0xFFF59E0B);
//   static const waitingLight = Color(0xFFFFFBEB);
//
//   static const confirmed = Color(0xFF10B981);
//   static const confirmedLight = Color(0xFFECFDF5);
//
//   static const danger = Color(0xFFEF4444);
//   static const dangerLight = Color(0xFFFEF2F2);
//
//   static const completed = Color(0xFF9CA3AF);
//   static const completedLight = Color(0xFFF9FAFB);
//
//   static const radius = 14.0;
//   static const radiusSm = 8.0;
//
//   static const titleLg = TextStyle(
//     fontSize: 15,
//     fontWeight: FontWeight.w700,
//     color: ink,
//     letterSpacing: -0.2,
//   );
//   static const titleSm = TextStyle(
//     fontSize: 13,
//     fontWeight: FontWeight.w600,
//     color: ink,
//   );
//   static const bodyMd = TextStyle(
//     fontSize: 13,
//     color: inkSecondary,
//     height: 1.4,
//   );
//   static const bodySm = TextStyle(fontSize: 12, color: inkMuted);
//   static const label = TextStyle(
//     fontSize: 11,
//     fontWeight: FontWeight.w600,
//     letterSpacing: 0.4,
//   );
// }
//
// // ─── Screen ───────────────────────────────────────────────────────────────────
// class TableBookings extends StatefulWidget {
//   const TableBookings({super.key});
//
//   @override
//   State<TableBookings> createState() => _TableBookingsState();
// }
//
// class _TableBookingsState extends State<TableBookings> {
//   late Future<List<WaitingItem>> _waitingFuture;
//   late Future<List<ConfirmedList>> _confirmedFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }
//
//   void _load() {
//     _waitingFuture = food_Authservice.fetchWaitingList();
//     _confirmedFuture = food_Authservice.fetchConfirmedList();
//   }
//
//   void _refresh() => setState(() => _load());
//
//   @override
//   Widget build(BuildContext context) {
//     final mq = MediaQuery.of(context);
//     final screenW = mq.size.width;
//     final hPad = screenW < 380 ? 12.0 : 16.0;
//
//     return Scaffold(
//       backgroundColor: tablebcolours.bg,
//       body: SafeArea(
//         child: FutureBuilder2(
//           waitingFuture: _waitingFuture,
//           confirmedFuture: _confirmedFuture,
//           hPad: hPad,
//           onRefresh: _refresh,
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Combined FutureBuilder ───────────────────────────────────────────────────
// class FutureBuilder2 extends StatelessWidget {
//   final Future<List<WaitingItem>> waitingFuture;
//   final Future<List<ConfirmedList>> confirmedFuture;
//   final double hPad;
//   final VoidCallback onRefresh;
//
//   const FutureBuilder2({
//     super.key,
//     required this.waitingFuture,
//     required this.confirmedFuture,
//     required this.hPad,
//     required this.onRefresh,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<WaitingItem>>(
//       future: waitingFuture,
//       builder: (context, waitingSnap) {
//         return FutureBuilder<List<ConfirmedList>>(
//           future: confirmedFuture,
//           builder: (context, confirmedSnap) {
//             final bothDone =
//                 waitingSnap.connectionState == ConnectionState.done &&
//                 confirmedSnap.connectionState == ConnectionState.done;
//
//             if (!bothDone) return const _LoadingView();
//
//             if (waitingSnap.hasError || confirmedSnap.hasError) {
//               final err = (waitingSnap.error ?? confirmedSnap.error).toString();
//               return _ErrorView(error: err, onRetry: onRefresh);
//             }
//
//             final waitingItems = waitingSnap.data ?? [];
//             final confirmedItems = List<ConfirmedList>.from(
//               confirmedSnap.data ?? [],
//             );
//
//             // Sort confirmed: completed go to bottom
//             confirmedItems.sort((a, b) {
//               final aD = a.arrivalStatus.toUpperCase() == 'COMPLETED';
//               final bD = b.arrivalStatus.toUpperCase() == 'COMPLETED';
//               if (aD == bD) return 0;
//               return aD ? 1 : -1;
//             });
//
//             final hasWaiting = waitingItems.isNotEmpty;
//             final hasConfirmed = confirmedItems.isNotEmpty;
//
//             if (!hasWaiting && !hasConfirmed) {
//               return const _EmptyView(message: 'No bookings yet');
//             }
//
//             return RefreshIndicator(
//               color: tablebcolours.accent,
//               backgroundColor: tablebcolours.surface,
//               onRefresh: () async => onRefresh(),
//               child: CustomScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 slivers: [
//                   // ── Waiting Section ──────────────────────────────────────
//                   if (hasWaiting) ...[
//                     SliverToBoxAdapter(
//                       child: _SectionHeader(
//                         icon: Icons.access_time_rounded,
//                         label: 'Waiting',
//                         count: waitingItems.length,
//                         color: tablebcolours.waiting,
//                         bg: tablebcolours.waitingLight,
//                         hPad: hPad,
//                       ),
//                     ),
//                     SliverPadding(
//                       padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 8),
//                       sliver: SliverList(
//                         delegate: SliverChildBuilderDelegate(
//                           (_, i) => _WaitingCard(
//                             item: waitingItems[waitingItems.length - 1 - i],
//                           ),
//                           childCount: waitingItems.length,
//                         ),
//                       ),
//                     ),
//                   ],
//
//                   // ── Confirmed Section ────────────────────────────────────
//                   if (hasConfirmed) ...[
//                     SliverToBoxAdapter(
//                       child: _SectionHeader(
//                         icon: Icons.check_circle_outline_rounded,
//                         label: 'Confirmed',
//                         count: confirmedItems.length,
//                         color: tablebcolours.confirmed,
//                         bg: tablebcolours.confirmedLight,
//                         hPad: hPad,
//                       ),
//                     ),
//                     SliverPadding(
//                       padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
//                       sliver: SliverList(
//                         delegate: SliverChildBuilderDelegate(
//                           (_, i) => ConfirmedListCard(item: confirmedItems[i]),
//                           childCount: confirmedItems.length,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
//
// // ─── Section Header ───────────────────────────────────────────────────────────
// class _SectionHeader extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final int count;
//   final Color color;
//   final Color bg;
//   final double hPad;
//
//   const _SectionHeader({
//     required this.icon,
//     required this.label,
//     required this.count,
//     required this.color,
//     required this.bg,
//     required this.hPad,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 10),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
//             child: Icon(icon, size: 14, color: color),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             label,
//             style: tablebcolours.titleSm.copyWith(color: tablebcolours.ink),
//           ),
//           const SizedBox(width: 6),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//             decoration: BoxDecoration(
//               color: bg,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               '$count',
//               style: tablebcolours.label.copyWith(color: color),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Waiting Card ─────────────────────────────────────────────────────────────
// class _WaitingCard extends StatelessWidget {
//   final WaitingItem item;
//   const _WaitingCard({required this.item});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: tablebcolours.surface,
//         borderRadius: BorderRadius.circular(tablebcolours.radius),
//         border: Border.all(color: tablebcolours.border),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(tablebcolours.radius),
//         child: IntrinsicHeight(
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Container(width: 4, color: tablebcolours.waiting),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(14),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _InfoRow(Icons.person_outline_rounded, item.guestName),
//                       _InfoRow(Icons.phone_outlined, item.phoneNumber),
//                       _InfoRow(
//                         Icons.calendar_today_outlined,
//                         DateTimeHelper.formatDateString(item.bookingDate),
//                       ),
//                       _InfoRow(
//                         Icons.schedule_outlined,
//                         DateTimeHelper.to12Hour(item.requestTime),
//                       ),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 8,
//                         children: [
//                           _Chip(
//                             Icons.group_outlined,
//                             '${item.capacity} guests',
//                           ),
//                           _Chip(
//                             Icons.timer_outlined,
//                             '${item.durationMinutes} min',
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Confirmed Card ───────────────────────────────────────────────────────────
// class ConfirmedListCard extends StatefulWidget {
//   final ConfirmedList item;
//   const ConfirmedListCard({super.key, required this.item});
//
//   @override
//   State<ConfirmedListCard> createState() => _ConfirmedListCardState();
// }
//
// class _ConfirmedListCardState extends State<ConfirmedListCard> {
//   late bool _arrived;
//
//   @override
//   void initState() {
//     super.initState();
//     _arrived = widget.item.arrivalStatus.toUpperCase() == 'ARRIVED';
//   }
//
//   bool get _isCompleted =>
//       widget.item.arrivalStatus.toUpperCase() == 'COMPLETED';
//
//   Future<void> _toggleArrival() async {
//     final ok = await food_Authservice.sendArrivalStatus(widget.item.id);
//     if (!ok) {
//       if (mounted) AppAlert.error(context, 'Failed to update arrival status');
//       return;
//     }
//     if (mounted) setState(() => _arrived = !_arrived);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final item = widget.item;
//
//     return AnimatedOpacity(
//       duration: const Duration(milliseconds: 300),
//       opacity: _isCompleted ? 0.55 : 1.0,
//       child: IgnorePointer(
//         ignoring: _isCompleted,
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 10),
//           decoration: BoxDecoration(
//             color: tablebcolours.surface,
//             borderRadius: BorderRadius.circular(tablebcolours.radius),
//             border: Border.all(color: tablebcolours.border),
//             boxShadow: [
//               BoxShadow(
//                 // ignore: deprecated_member_use
//                 color: Colors.black.withOpacity(0.04),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(tablebcolours.radius),
//             child: IntrinsicHeight(
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Container(
//                     width: 4,
//                     color: _isCompleted
//                         ? tablebcolours.completed
//                         : (_arrived
//                               ? tablebcolours.confirmed
//                               : tablebcolours.accent),
//                   ),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.all(14),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Header
//                           Row(
//                             children: [
//                               Container(
//                                 width: 36,
//                                 height: 36,
//                                 decoration: BoxDecoration(
//                                   color: tablebcolours.accentLight,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.table_restaurant_rounded,
//                                   size: 18,
//                                   color: tablebcolours.accent,
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Text(
//                                   'Table ${item.code}',
//                                   style: tablebcolours.bodySm.copyWith(
//                                     color: tablebcolours.accent,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                               if (_isCompleted)
//                                 _StatusBadge(
//                                   label: 'Done',
//                                   color: tablebcolours.completed,
//                                   bg: tablebcolours.completedLight,
//                                   icon: Icons.check_circle_outline_rounded,
//                                 ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 10),
//                           const Divider(height: 1, color: tablebcolours.border),
//                           const SizedBox(height: 10),
//
//                           _InfoRow(
//                             Icons.person_outline_rounded,
//                             item.guestName,
//                           ),
//                           _InfoRow(Icons.phone_outlined, item.phoneNumber),
//                           _InfoRow(
//                             Icons.calendar_today_outlined,
//                             DateTimeHelper.formatDateString(item.bookingDate),
//                           ),
//
//                           const SizedBox(height: 8),
//                           Wrap(
//                             spacing: 8,
//                             children: [
//                               _Chip(
//                                 Icons.group_outlined,
//                                 '${item.capacity} guests',
//                               ),
//                               _Chip(
//                                 Icons.timer_outlined,
//                                 '${item.durationMinutes} min',
//                               ),
//                             ],
//                           ),
//
//                           if (!_isCompleted) ...[
//                             const SizedBox(height: 12),
//                             _ActionButtons(
//                               arrived: _arrived,
//                               onToggle: _toggleArrival,
//                               onAddItems: () => Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => tablemneuScreen(
//                                     vendorId: item.vendorId,
//                                     seatingId: item.seatingId,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Action Buttons ───────────────────────────────────────────────────────────
// class _ActionButtons extends StatelessWidget {
//   final bool arrived;
//   final VoidCallback onToggle;
//   final VoidCallback onAddItems;
//
//   const _ActionButtons({
//     required this.arrived,
//     required this.onToggle,
//     required this.onAddItems,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: _PillButton(
//             label: arrived ? 'Not Arrived' : 'Arrived',
//             icon: arrived ? Icons.close_rounded : Icons.check_rounded,
//             color: arrived ? tablebcolours.danger : tablebcolours.confirmed,
//             bg: arrived
//                 ? tablebcolours.dangerLight
//                 : tablebcolours.confirmedLight,
//             onTap: onToggle,
//           ),
//         ),
//         AnimatedSize(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           child: arrived
//               ? Row(
//                   children: [
//                     const SizedBox(width: 8),
//                     _PillButton(
//                       label: 'Add Items',
//                       icon: Icons.restaurant_menu_rounded,
//                       color: tablebcolours.accent,
//                       bg: tablebcolours.accentLight,
//                       onTap: onAddItems,
//                     ),
//                   ],
//                 )
//               : const SizedBox.shrink(),
//         ),
//       ],
//     );
//   }
// }
//
// class _PillButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   final Color bg;
//   final VoidCallback onTap;
//
//   const _PillButton({
//     required this.label,
//     required this.icon,
//     required this.color,
//     required this.bg,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 38,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(tablebcolours.radiusSm),
//           border: Border.all(color: color.withOpacity(0.25)),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 14, color: color),
//             const SizedBox(width: 5),
//             Flexible(
//               child: Text(
//                 label,
//                 style: tablebcolours.label.copyWith(color: color),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Shared Small Widgets ─────────────────────────────────────────────────────
// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String value;
//   const _InfoRow(this.icon, this.value);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         children: [
//           Icon(icon, size: 14, color: tablebcolours.inkMuted),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               value,
//               style: tablebcolours.bodyMd,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _Chip extends StatelessWidget {
//   final IconData icon;
//   final String text;
//   const _Chip(this.icon, this.text);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: tablebcolours.bg,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: tablebcolours.border),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 11, color: tablebcolours.inkMuted),
//           const SizedBox(width: 4),
//           Text(text, style: tablebcolours.bodySm),
//         ],
//       ),
//     );
//   }
// }
//
// class _StatusBadge extends StatelessWidget {
//   final String label;
//   final Color color;
//   final Color bg;
//   final IconData icon;
//   const _StatusBadge({
//     required this.label,
//     required this.color,
//     required this.bg,
//     required this.icon,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: color),
//           const SizedBox(width: 4),
//           Text(label, style: tablebcolours.label.copyWith(color: color)),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── State Views ──────────────────────────────────────────────────────────────
// class _LoadingView extends StatelessWidget {
//   const _LoadingView();
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircularProgressIndicator(
//             strokeWidth: 2.5,
//             color: tablebcolours.accent,
//           ),
//           SizedBox(height: 14),
//           Text('Loading...', style: tablebcolours.bodyMd),
//         ],
//       ),
//     );
//   }
// }
//
// class _ErrorView extends StatelessWidget {
//   final String error;
//   final VoidCallback onRetry;
//   const _ErrorView({required this.error, required this.onRetry});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.wifi_off_rounded,
//               size: 48,
//               color: tablebcolours.inkMuted,
//             ),
//             const SizedBox(height: 12),
//             const Text('Something went wrong', style: tablebcolours.titleSm),
//             const SizedBox(height: 6),
//             Text(
//               error,
//               style: tablebcolours.bodyMd,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             GestureDetector(
//               onTap: onRetry,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 10,
//                 ),
//                 decoration: BoxDecoration(
//                   color: tablebcolours.accentLight,
//                   borderRadius: BorderRadius.circular(tablebcolours.radiusSm),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.refresh_rounded,
//                       size: 16,
//                       color: tablebcolours.accent,
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       'Try Again',
//                       style: tablebcolours.label.copyWith(
//                         color: tablebcolours.accent,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _EmptyView extends StatelessWidget {
//   final String message;
//   const _EmptyView({required this.message});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(
//             Icons.table_restaurant_outlined,
//             size: 48,
//             color: tablebcolours.inkMuted,
//           ),
//           const SizedBox(height: 12),
//           Text(message, style: tablebcolours.bodyMd),
//         ],
//       ),
//     );
//   }
// }

import 'package:intl/intl.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:maamaas/widgets/datetimehelper.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import '../../../Models/food/table_confirmedlist_model.dart';
import '../../../Models/food/table_waitinglist_model.dart';
import 'package:flutter/material.dart';
import 'table_menu.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
// ignore: camel_case_types
class tablebcolours {
  static const bg = Color(0xFFF7F8FC);
  static const surface = Colors.white;
  static const border = Color(0xFFEEEFF5);

  static const ink = Color(0xFF111827);
  static const inkSecondary = Color(0xFF6B7280);
  static const inkMuted = Color(0xFF9CA3AF);

  static const accent = Color(0xFF4F46E5);
  static const accentLight = Color(0xFFEEF2FF);

  static const waiting = Color(0xFFF59E0B);
  static const waitingLight = Color(0xFFFFFBEB);

  static const confirmed = Color(0xFF10B981);
  static const confirmedLight = Color(0xFFECFDF5);

  static const danger = Color(0xFFEF4444);
  static const dangerLight = Color(0xFFFEF2F2);

  static const completed = Color(0xFF9CA3AF);
  static const completedLight = Color(0xFFF9FAFB);

  static const radius = 14.0;
  static const radiusSm = 8.0;

  static const titleLg = TextStyle(
    fontSize: 15,
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
    height: 1.4,
  );
  static const bodySm = TextStyle(fontSize: 12, color: inkMuted);
  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
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
    final screenW = mq.size.width;
    final hPad = screenW < 380 ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: tablebcolours.bg,
      body: SafeArea(
        child: FutureBuilder2(
          waitingFuture: _waitingFuture,
          confirmedFuture: _confirmedFuture,
          hPad: hPad,
          onRefresh: _refresh,
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

            // Sort confirmed: completed go to bottom
            // confirmedItems.sort((a, b) {
            //   final aD = a.arrivalStatus.toUpperCase() == 'COMPLETED';
            //   final bD = b.arrivalStatus.toUpperCase() == 'COMPLETED';
            //   if (aD == bD) return 0;
            //   return aD ? 1 : -1;
            // });
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
              color: tablebcolours.accent,
              backgroundColor: tablebcolours.surface,
              onRefresh: () async => onRefresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── Waiting Section ──────────────────────────────────────
                  if (hasWaiting) ...[
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        icon: Icons.access_time_rounded,
                        label: 'Waiting',
                        count: waitingItems.length,
                        color: tablebcolours.waiting,
                        bg: tablebcolours.waitingLight,
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

                  // ── Confirmed Section ────────────────────────────────────
                  if (hasConfirmed) ...[
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Confirmed',
                        count: confirmedItems.length,
                        color: tablebcolours.confirmed,
                        bg: tablebcolours.confirmedLight,
                        hPad: hPad,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
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
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: tablebcolours.titleSm.copyWith(color: tablebcolours.ink),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: tablebcolours.label.copyWith(color: color),
            ),
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tablebcolours.surface,
        borderRadius: BorderRadius.circular(tablebcolours.radius),
        border: Border.all(color: tablebcolours.border),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tablebcolours.radius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: tablebcolours.waiting),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(Icons.person_outline_rounded, item.guestName),
                      _InfoRow(Icons.phone_outlined, item.phoneNumber),
                      _InfoRow(
                        Icons.calendar_today_outlined,
                        DateTimeHelper.formatDateString(item.bookingDate),
                      ),
                      _InfoRow(
                        Icons.schedule_outlined,
                        DateTimeHelper.to12Hour(item.requestTime),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _Chip(
                            Icons.group_outlined,
                            '${item.capacity} guests',
                          ),
                          _Chip(
                            Icons.timer_outlined,
                            '${item.durationMinutes} min',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    // _arrived = widget.item.arrivalStatus.toUpperCase() == 'ARRIVED';
    _arrivalStatus = widget.item.arrivalStatus.toUpperCase();

    _arrived = _arrivalStatus == 'ARRIVED';
  }

  // bool get _isCompleted {
  //   final status = widget.item.arrivalStatus.toUpperCase();
  //
  //   return status == 'COMPLETED' || status == 'CANCELLED';
  // }
  // bool get _isCompleted {
  //   return widget.item.arrivalStatus.toUpperCase() == 'COMPLETED';
  // }
  //
  // bool get _isCancelled {
  //   return widget.item.arrivalStatus.toUpperCase() == 'CANCELLED';
  // }

  bool get _isCompleted {
    return _arrivalStatus == 'COMPLETED';
  }

  bool get _isCancelled {
    return _arrivalStatus == 'CANCELLED';
  }

  // bool get _isInactive => _isCompleted || _isCancelled;

  bool get _isInactive => _isCompleted || _isCancelled;

  /// Returns true if the booking time is more than 30 mins away (button disabled).
  bool get _isArrivalLocked {
    if (_arrived) return false; // already arrived → never lock
    try {
      // Combine bookingDate + bookingTime to get a DateTime.
      // Adjust parsing to match your actual field formats.
      final dateStr = widget.item.bookingDate; // e.g. "2025-07-20"
      final timeStr = widget.item.startTime; // e.g. "14:30:00" or "14:30"
      final dt = DateTime.parse('${dateStr}T$timeStr');
      final diff = dt.difference(DateTime.now());
      return diff.inMinutes > 30;
    } catch (_) {
      return false; // if parse fails, don't lock
    }
  }

  Future<void> _markArrived() async {
    setState(() => _loading = true);
    final ok = await food_Authservice.sendArrivalStatus(
      widget.item.id,
      "ARRIVED",
    );
    if (!ok) {
      if (mounted) AppAlert.error(context, 'Failed to update arrival status');
      setState(() => _loading = false);
      return;
    }
    if (mounted) {
      // setState(() {
      //   _arrived = true;
      //   _loading = false;
      // });
      setState(() {
        _arrived = true;
        _arrivalStatus = "ARRIVED";
        _loading = false;
      });
    }
  }

  Future<void> _cancelArrival() async {
    setState(() => _loading = true);
    final ok = await food_Authservice.sendArrivalStatus(
      widget.item.id,
      "CANCELLED",
    );
    if (!ok) {
      if (mounted) AppAlert.error(context, 'Failed to cancel arrival');
      setState(() => _loading = false);
      return;
    }
    if (mounted) {
      // setState(() {
      //   _arrived = false;
      //   _loading = false;
      // });
      setState(() {
        _arrived = false;
        _arrivalStatus = "CANCELLED";
        _loading = false;
      });
    }
  }

  String _formatTime(String time) {
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(time);

      return DateFormat("hh:mm a").format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      // opacity: _isCompleted ? 0.55 : 1.0,
      opacity: _isInactive ? 0.55 : 1.0,
      child: IgnorePointer(
        // ignoring: _isCompleted,
        ignoring: _isInactive,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: tablebcolours.surface,
            borderRadius: BorderRadius.circular(tablebcolours.radius),
            border: Border.all(color: tablebcolours.border),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tablebcolours.radius),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    // color: _isCompleted
                    //     ? tablebcolours.completed
                    //     : (_arrived
                    //           ? tablebcolours.confirmed
                    //           : tablebcolours.accent),
                    color: _isCompleted
                        ? tablebcolours.completed
                        : _isCancelled
                        ? Colors.red
                        : (_arrived
                              ? tablebcolours.confirmed
                              : tablebcolours.accent),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: tablebcolours.accentLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.table_restaurant_rounded,
                                  size: 18,
                                  color: tablebcolours.accent,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Table ${item.code}',
                                  style: tablebcolours.bodySm.copyWith(
                                    color: tablebcolours.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (_isCompleted)
                                _StatusBadge(
                                  label: 'Done',
                                  color: tablebcolours.completed,
                                  bg: tablebcolours.completedLight,
                                  icon: Icons.check_circle_outline_rounded,
                                ),
                              if (_arrived && !_isCompleted)
                                _StatusBadge(
                                  label: 'Arrived',
                                  color: tablebcolours.confirmed,
                                  bg: tablebcolours.confirmedLight,
                                  icon: Icons.check_circle_outline_rounded,
                                ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          const Divider(height: 1, color: tablebcolours.border),
                          const SizedBox(height: 10),

                          _InfoRow(
                            Icons.person_outline_rounded,
                            item.guestName.toUpperCase(),
                          ),
                          _InfoRow(Icons.phone_outlined, item.phoneNumber),
                          _InfoRow(
                            Icons.calendar_today_outlined,
                            DateTimeHelper.formatDateString(item.bookingDate),
                          ),
                          // _InfoRow(
                          //   Icons.timer,
                          //   // DateTimeHelper.formatDateString(item.startTime),
                          //   item.startTime,
                          // ),
                          _InfoRow(Icons.timer, _formatTime(item.startTime)),

                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _Chip(
                                Icons.group_outlined,
                                '${item.capacity} guests',
                              ),
                              _Chip(
                                Icons.timer_outlined,
                                '${item.durationMinutes} min',
                              ),
                            ],
                          ),

                          // if (!_isCompleted) ...[
                          if (!_isInactive) ...[
                            const SizedBox(height: 12),
                            _ActionButtons(
                              arrived: _arrived,
                              loading: _loading,
                              locked: _isArrivalLocked,
                              onArrived: _markArrived,
                              onCancel: _cancelArrival,
                              onAddItems: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => tablemneuScreen(
                                    vendorId: item.vendorId,
                                    seatingId: item.seatingId,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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

// ─── Action Buttons ───────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final bool arrived;
  final bool loading;
  final bool locked; // true = booking > 30 min away, disable arrived button
  final VoidCallback onArrived;
  final VoidCallback onCancel;
  final VoidCallback onAddItems;

  const _ActionButtons({
    required this.arrived,
    required this.loading,
    required this.locked,
    required this.onArrived,
    required this.onCancel,
    required this.onAddItems,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 38,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: tablebcolours.accent,
            ),
          ),
        ),
      );
    }

    // ── After arrived is confirmed: show only Add Items ─────────────────────
    if (arrived) {
      return Row(
        children: [
          Expanded(
            child: _PillButton(
              label: 'Add Items',
              icon: Icons.restaurant_menu_rounded,
              color: tablebcolours.accent,
              bg: tablebcolours.accentLight,
              onTap: onAddItems,
            ),
          ),
        ],
      );
    }

    // ── Before arrival: Arrived + Cancel side by side ─────────────────────────
    return Row(
      children: [
        Expanded(
          child: _PillButton(
            label: locked ? 'Arrived (30 min before)' : 'Arrived',
            icon: Icons.check_rounded,
            color: locked ? tablebcolours.inkMuted : tablebcolours.confirmed,
            bg: locked
                ? tablebcolours.completedLight
                : tablebcolours.confirmedLight,
            onTap: onArrived,
            disabled: locked,
          ),
        ),
        const SizedBox(width: 8),
        _PillButton(
          label: 'Cancel',
          icon: Icons.close_rounded,
          color: tablebcolours.danger,
          bg: tablebcolours.dangerLight,
          onTap: onCancel,
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  final bool disabled;

  const _PillButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(tablebcolours.radiusSm),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: tablebcolours.label.copyWith(color: color),
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

// ─── Shared Small Widgets ─────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _InfoRow(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: tablebcolours.inkMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: tablebcolours.bodyMd,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Chip(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tablebcolours.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tablebcolours.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: tablebcolours.inkMuted),
          const SizedBox(width: 4),
          Text(text, style: tablebcolours.bodySm),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.bg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: tablebcolours.label.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ─── State Views ──────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2.5,
            color: tablebcolours.accent,
          ),
          SizedBox(height: 14),
          Text('Loading...', style: tablebcolours.bodyMd),
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
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: tablebcolours.inkMuted,
            ),
            const SizedBox(height: 12),
            const Text('Something went wrong', style: tablebcolours.titleSm),
            const SizedBox(height: 6),
            Text(
              error,
              style: tablebcolours.bodyMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: tablebcolours.accentLight,
                  borderRadius: BorderRadius.circular(tablebcolours.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: tablebcolours.accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Try Again',
                      style: tablebcolours.label.copyWith(
                        color: tablebcolours.accent,
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
          const Icon(
            Icons.table_restaurant_outlined,
            size: 48,
            color: tablebcolours.inkMuted,
          ),
          const SizedBox(height: 12),
          Text(message, style: tablebcolours.bodyMd),
        ],
      ),
    );
  }
}
