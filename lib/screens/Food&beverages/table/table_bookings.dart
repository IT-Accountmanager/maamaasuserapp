// import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// import '../../../Services/Auth_service/food_authservice.dart';
// import '../../../Models/food/table_confirmedlist_model.dart';
// import '../../../Models/food/table_waitinglist_model.dart';
// import 'package:flutter/material.dart';
//
// import '../Menu/table_menu.dart';
//
// class TableBookings extends StatefulWidget {
//   const TableBookings({super.key});
//
//   @override
//   State<TableBookings> createState() => _TableBookingsState();
// }
//
// class _TableBookingsState extends State<TableBookings> {
//   bool isArrived = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: DefaultTabController(
//         length: 2,
//         child: Column(
//           children: [
//             // Tab Bar
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     // ignore: deprecated_member_use
//                     color: Colors.grey.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               child: TabBar(
//                 labelColor: Colors.white,
//                 unselectedLabelColor: Colors.grey[600],
//                 indicator: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.purple[600]!, Colors.purple[400]!],
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 tabs: [
//                   Tab(
//                     icon: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.access_time, size: 18),
//                         const SizedBox(width: 6),
//                         const Text("Waiting List"),
//                       ],
//                     ),
//                   ),
//                   Tab(
//                     icon: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.verified, size: 18),
//                         const SizedBox(width: 6),
//                         const Text("Confirmed"),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 8),
//
//             // Tab Views
//             Expanded(
//               child: TabBarView(
//                 children: [_buildWaitingList(), _buildConfirmedList()],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildWaitingList() {
//     return FutureBuilder<List<WaitingItem>>(
//       future: food_Authservice.fetchWaitingList(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _buildLoadingState();
//         } else if (snapshot.hasError) {
//           return _buildErrorState(snapshot.error.toString());
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return _buildEmptyState("No tables in waiting list");
//         }
//
//         final items = snapshot.data!;
//
//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: items.length,
//           reverse: true,
//           itemBuilder: (context, index) {
//             final item = items[index];
//             return _buildWaitingCard(item, index);
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildConfirmedList() {
//     return FutureBuilder<List<ConfirmedList>>(
//       future: food_Authservice.fetchConfirmedList(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _buildLoadingState();
//         } else if (snapshot.hasError) {
//           return _buildErrorState(snapshot.error.toString());
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return _buildEmptyState("No confirmed bookings");
//         }
//
//         final items = snapshot.data!;
//
//         // Sort: non-completed first, completed at bottom
//         items.sort((a, b) {
//           bool aCompleted = a.arrivalStatus.toUpperCase() == "COMPLETED";
//           bool bCompleted = b.arrivalStatus.toUpperCase() == "COMPLETED";
//
//           if (aCompleted == bCompleted) return 0;
//           return aCompleted ? 1 : -1;
//         });
//
//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: items.length,
//           reverse: false, // top → bottom scroll
//           itemBuilder: (context, index) {
//             final item = items[index];
//             return ConfirmedListCard(item: item);
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[600]!),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             "Loading bookings...",
//             style: TextStyle(color: Colors.grey[600], fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildErrorState(String error) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//           const SizedBox(height: 16),
//           Text(
//             "Something went wrong",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[700],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32),
//             child: Text(
//               error,
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton.icon(
//             onPressed: () => setState(() {}),
//             icon: const Icon(Icons.refresh),
//             label: const Text("Try Again"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.purple[600],
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState(String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.table_restaurant_outlined,
//             size: 64,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildWaitingCard(WaitingItem item, int index) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//         border: Border.all(color: Colors.grey[200]!, width: 1),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Status indicator
//             Container(
//               width: 4,
//               height: 80,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.orange[400]!, Colors.orange[600]!],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(width: 12),
//             // Content
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         item.types,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: Colors.deepOrange,
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.orange[50],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.access_time,
//                               size: 14,
//                               color: Colors.orange[700],
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               "Waiting",
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.orange[700],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   _buildDetailRow(Icons.person, "Name", item.guestName),
//                   _buildDetailRow(Icons.phone, "Phone", item.phoneNumber),
//                   _buildDetailRow(
//                     Icons.calendar_today,
//                     "Date",
//                     item.bookingDate,
//                   ),
//                   _buildDetailRow(Icons.schedule, "Time", item.requestTime),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       _buildChip("Capacity: ${item.capacity}", Icons.group),
//                       const SizedBox(width: 8),
//                       _buildChip("${item.durationMinutes} min", Icons.timer),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: Colors.grey[600]),
//           const SizedBox(width: 8),
//           Text(
//             "$label: ",
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[700],
//               fontSize: 13,
//             ),
//           ),
//           Text(value, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildChip(String text, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: Colors.grey[600]),
//           const SizedBox(width: 4),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 11,
//               color: Colors.grey[700],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class ConfirmedListCard extends StatefulWidget {
//   final ConfirmedList item;
//
//   const ConfirmedListCard({Key? key, required this.item}) : super(key: key);
//
//   @override
//   State<ConfirmedListCard> createState() => _ConfirmedListCardState();
// }
//
// class _ConfirmedListCardState extends State<ConfirmedListCard>
//     with SingleTickerProviderStateMixin {
//   bool isArrived = false;
//
//   @override
//   void initState() {
//     super.initState();
//     isArrived = widget.item.arrivalStatus.toUpperCase() == "NOT_ARRIVED";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final item = widget.item;
//     final bool isCompleted = item.arrivalStatus.toUpperCase() == "COMPLETED";
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Opacity(
//         opacity: isCompleted ? 0.6 : 1.0,
//         child: IgnorePointer(
//           ignoring: isCompleted,
//           child: Card(
//             color: Colors.white,
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             // ignore: deprecated_member_use
//             shadowColor: Colors.purple.withOpacity(0.1),
//             child: ClipPath(
//               clipper: ShapeBorderClipper(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border(
//                     left: BorderSide(
//                       color: isCompleted
//                           ? Colors.grey
//                           : (isArrived ? Colors.green : Colors.purple),
//                       width: 4,
//                     ),
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Table number with icon
//                           Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               color: Colors.purple[50],
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.table_restaurant,
//                               color: Colors.purple[600],
//                               size: 24,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           // Content
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       item.types.toUpperCase().replaceAll(
//                                         '_',
//                                         ' ',
//                                       ),
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                         color: Colors.deepPurple,
//                                       ),
//                                     ),
//                                     if (isCompleted)
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 8,
//                                           vertical: 4,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: Colors.grey[200],
//                                           borderRadius: BorderRadius.circular(
//                                             12,
//                                           ),
//                                         ),
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Icon(
//                                               Icons.check_circle,
//                                               size: 14,
//                                               color: Colors.grey[600],
//                                             ),
//                                             const SizedBox(width: 4),
//                                             Text(
//                                               "Completed",
//                                               style: TextStyle(
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.w600,
//                                                 color: Colors.grey[600],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Text(
//                                   "Table ${item.code}",
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.purple[600],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 _buildDetailRow(Icons.person, item.guestName),
//                                 _buildDetailRow(Icons.phone, item.phoneNumber),
//
//                                 // _buildDetailRow(
//                                 //   Icons.table_restaurant,
//                                 //   item.code,
//                                 // ),
//                                 _buildDetailRow(
//                                   Icons.calendar_today,
//                                   item.bookingDate,
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Row(
//                                   children: [
//                                     _buildInfoChip(
//                                       Icons.group,
//                                       "${item.capacity} Guests",
//                                     ),
//                                     const SizedBox(width: 8),
//                                     _buildInfoChip(
//                                       Icons.timer,
//                                       "${item.durationMinutes} min",
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//
//                       // Arrival Button
//                       Row(
//                         children: [
//                           // Arrival Button (flexible width)
//                           if (!isCompleted)
//                             Expanded(flex: 3, child: _buildArrivalButton()),
//
//                           const SizedBox(width: 12), // space between buttons
//                           // Arrival Section (Add Items button)
//                           Expanded(flex: 3, child: _buildArrivalSection()),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(IconData icon, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: Colors.grey[600]),
//           const SizedBox(width: 8),
//           Text(value, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoChip(IconData icon, String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: Colors.grey[600]),
//           const SizedBox(width: 4),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 11,
//               color: Colors.grey[700],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildArrivalButton() {
//     return Container(
//       width: double.infinity,
//       // height: 44,
//       decoration: BoxDecoration(
//         gradient: isArrived
//             ? LinearGradient(colors: [Colors.red[400]!, Colors.red[600]!])
//             : LinearGradient(colors: [Colors.green[400]!, Colors.green[600]!]),
//         borderRadius: BorderRadius.circular(12),
//         // boxShadow: [
//         //   BoxShadow(
//         //     // ignore: deprecated_member_use
//         //     color: (isArrived ? Colors.red : Colors.green).withOpacity(0.3),
//         //     blurRadius: 8,
//         //     offset: const Offset(0, 3),
//         //   ),
//         // ],
//       ),
//       child: ElevatedButton(
//         onPressed: _handleArrivalAction,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Icon(
//             //   isArrived ? Icons.close : Icons.check,
//             //   color: Colors.white,
//             //   size: 20,
//             // ),
//             // const SizedBox(width: 8),
//             Text(
//               isArrived ? "Mark as Not Arrived" : "Mark as Arrived",
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 10, // increased from 10
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _handleArrivalAction() async {
//     // 2️⃣ Send Arrival Status Update
//     bool statusUpdated = await food_Authservice.sendArrivalStatus(
//       widget.item.id,
//     );
//
//     if (!statusUpdated) {
//       // ignore: use_build_context_synchronously
//       AppAlert.error(context, "Failed to update arrival status");
//       return;
//     }
//
//     // 3️⃣ UI change
//     setState(() {
//       isArrived = !isArrived;
//     });
//   }
//
//   Widget _buildArrivalSection() {
//     return AnimatedSize(
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeInOut,
//       child: ClipRect(
//         child: Align(
//           heightFactor: isArrived ? 1.0 : 0.0,
//           child: AnimatedOpacity(
//             duration: const Duration(milliseconds: 400),
//             opacity: isArrived ? 1.0 : 0.0,
//             curve: Curves.easeInOut,
//             child: SizedBox(
//               height: 44, // same height as arrival button
//               child: ElevatedButton.icon(
//                 onPressed: () => _navigateToTableMenu(),
//                 icon: const Icon(Icons.restaurant_menu, size: 16),
//                 label: const Text("Add Items"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.purple[600],
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _navigateToTableMenu() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => tablemneuScreen(
//           vendorId: widget.item.vendorId,
//           seatingId: widget.item.seatingId,
//         ),
//       ),
//     );
//   }
// }

import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:maamaas/widgets/datetimehelper.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import '../../../Models/food/table_confirmedlist_model.dart';
import '../../../Models/food/table_waitinglist_model.dart';
import 'package:flutter/material.dart';
import 'table_menu.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
class tablebcolours {
  static const bg = Color(0xFFF7F8FC);
  static const surface = Colors.white;
  static const border = Color(0xFFEEEFF5);

  static const ink = Color(0xFF111827);
  static const inkSecondary = Color(0xFF6B7280);
  static const inkMuted = Color(0xFF9CA3AF);

  static const accent = Color(0xFF4F46E5); // indigo
  static const accentLight = Color(0xFFEEF2FF);

  static const waiting = Color(0xFFF59E0B); // amber
  static const waitingLight = Color(0xFFFFFBEB);

  static const confirmed = Color(0xFF10B981); // emerald
  static const confirmedLight = Color(0xFFECFDF5);

  static const danger = Color(0xFFEF4444);
  static const dangerLight = Color(0xFFFEF2F2);

  static const completed = Color(0xFF9CA3AF);
  static const completedLight = Color(0xFFF9FAFB);

  static const radius = 14.0;
  static const radiusSm = 8.0;

  // Typography
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

class _TableBookingsState extends State<TableBookings>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final hPad = screenW < 380 ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: tablebcolours.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(hPad),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _WaitingListView(hPad: hPad),
                  _ConfirmedListView(hPad: hPad),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(double hPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: tablebcolours.border,
          borderRadius: BorderRadius.circular(tablebcolours.radius),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: tablebcolours.surface,
            borderRadius: BorderRadius.circular(tablebcolours.radiusSm + 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.all(4),
          labelPadding: EdgeInsets.zero,
          labelStyle: tablebcolours.label.copyWith(color: tablebcolours.ink),
          unselectedLabelStyle: tablebcolours.label.copyWith(
            color: tablebcolours.inkMuted,
          ),
          tabs: [
            _Tab(icon: Icons.access_time_rounded, label: 'Waiting'),
            _Tab(icon: Icons.check_circle_outline_rounded, label: 'Confirmed'),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 15), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}

// ─── Waiting List View ────────────────────────────────────────────────────────
class _WaitingListView extends StatefulWidget {
  final double hPad;
  const _WaitingListView({required this.hPad});

  @override
  State<_WaitingListView> createState() => _WaitingListViewState();
}

class _WaitingListViewState extends State<_WaitingListView> {
  late Future<List<WaitingItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = food_Authservice.fetchWaitingList();
  }

  void _refresh() => setState(() {
    _future = food_Authservice.fetchWaitingList();
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WaitingItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingView();
        }
        if (snapshot.hasError) {
          return _ErrorView(
            error: snapshot.error.toString(),
            onRetry: _refresh,
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const _EmptyView(message: 'No tables in waiting list');
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(widget.hPad, 12, widget.hPad, 24),
          itemCount: items.length,
          reverse: true,
          itemBuilder: (_, i) => _WaitingCard(item: items[i]),
        );
      },
    );
  }
}

// ─── Confirmed List View ──────────────────────────────────────────────────────
class _ConfirmedListView extends StatefulWidget {
  final double hPad;
  const _ConfirmedListView({required this.hPad});

  @override
  State<_ConfirmedListView> createState() => _ConfirmedListViewState();
}

class _ConfirmedListViewState extends State<_ConfirmedListView> {
  late Future<List<ConfirmedList>> _future;

  @override
  void initState() {
    super.initState();
    _future = food_Authservice.fetchConfirmedList();
  }

  void _refresh() => setState(() {
    _future = food_Authservice.fetchConfirmedList();
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConfirmedList>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingView();
        }
        if (snapshot.hasError) {
          return _ErrorView(
            error: snapshot.error.toString(),
            onRetry: _refresh,
          );
        }
        final items = List<ConfirmedList>.from(snapshot.data ?? []);
        if (items.isEmpty) {
          return const _EmptyView(message: 'No confirmed bookings');
        }
        items.sort((a, b) {
          final aD = a.arrivalStatus.toUpperCase() == 'COMPLETED';
          final bD = b.arrivalStatus.toUpperCase() == 'COMPLETED';
          if (aD == bD) return 0;
          return aD ? 1 : -1;
        });
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(widget.hPad, 12, widget.hPad, 24),
          itemCount: items.length,
          itemBuilder: (_, i) => ConfirmedListCard(item: items[i]),
        );
      },
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
              // Left accent bar
              Container(width: 4, color: tablebcolours.waiting),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     _StatusBadge(
                      //       label: 'Waiting',
                      //       color: tablebcolours.waiting,
                      //       bg: tablebcolours.waitingLight,
                      //       icon: Icons.access_time_rounded,
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 10),
                      // Info rows
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
                      // Chips
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
  const ConfirmedListCard({Key? key, required this.item}) : super(key: key);

  @override
  State<ConfirmedListCard> createState() => _ConfirmedListCardState();
}

class _ConfirmedListCardState extends State<ConfirmedListCard> {
  late bool _arrived;

  @override
  void initState() {
    super.initState();
    _arrived = widget.item.arrivalStatus.toUpperCase() == 'ARRIVED';
  }

  bool get _isCompleted =>
      widget.item.arrivalStatus.toUpperCase() == 'COMPLETED';

  Future<void> _toggleArrival() async {
    final ok = await food_Authservice.sendArrivalStatus(widget.item.id);
    if (!ok) {
      if (mounted) AppAlert.error(context, 'Failed to update arrival status');
      return;
    }
    if (mounted) setState(() => _arrived = !_arrived);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _isCompleted ? 0.55 : 1.0,
      child: IgnorePointer(
        ignoring: _isCompleted,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: tablebcolours.surface,
            borderRadius: BorderRadius.circular(tablebcolours.radius),
            border: Border.all(color: tablebcolours.border),
            boxShadow: [
              BoxShadow(
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
                  // Left accent bar
                  Container(
                    width: 4,
                    color: _isCompleted
                        ? tablebcolours.completed
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
                                child: Icon(
                                  Icons.table_restaurant_rounded,
                                  size: 18,
                                  color: tablebcolours.accent,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text(
                                    //   item.types.toUpperCase().replaceAll(
                                    //     '_',
                                    //     ' ',
                                    //   ),
                                    //   style: tablebcolours.titleLg,
                                    //   overflow: TextOverflow.ellipsis,
                                    // ),
                                    Text(
                                      'Table ${item.code}',
                                      style: tablebcolours.bodySm.copyWith(
                                        color: tablebcolours.accent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isCompleted)
                                _StatusBadge(
                                  label: 'Done',
                                  color: tablebcolours.completed,
                                  bg: tablebcolours.completedLight,
                                  icon: Icons.check_circle_outline_rounded,
                                ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          const Divider(height: 1, color: tablebcolours.border),
                          const SizedBox(height: 10),

                          // Info
                          _InfoRow(
                            Icons.person_outline_rounded,
                            item.guestName,
                          ),
                          _InfoRow(Icons.phone_outlined, item.phoneNumber),
                          _InfoRow(
                            Icons.calendar_today_outlined,
                            DateTimeHelper.formatDateString(item.bookingDate),
                          ),

                          const SizedBox(height: 8),

                          // Chips
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

                          // Action buttons
                          if (!_isCompleted) ...[
                            const SizedBox(height: 12),
                            _ActionButtons(
                              arrived: _arrived,
                              onToggle: _toggleArrival,
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
  final VoidCallback onToggle;
  final VoidCallback onAddItems;

  const _ActionButtons({
    required this.arrived,
    required this.onToggle,
    required this.onAddItems,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PillButton(
            label: arrived ? 'Not Arrived' : 'Arrived',
            icon: arrived ? Icons.close_rounded : Icons.check_rounded,
            color: arrived ? tablebcolours.danger : tablebcolours.confirmed,
            bg: arrived
                ? tablebcolours.dangerLight
                : tablebcolours.confirmedLight,
            onTap: onToggle,
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: arrived
              ? Row(
                  children: [
                    const SizedBox(width: 8),
                    _PillButton(
                      label: 'Add Items',
                      icon: Icons.restaurant_menu_rounded,
                      color: tablebcolours.accent,
                      bg: tablebcolours.accentLight,
                      onTap: onAddItems,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
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

  const _PillButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2.5,
            color: tablebcolours.accent,
          ),
          const SizedBox(height: 14),
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
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: tablebcolours.inkMuted,
            ),
            const SizedBox(height: 12),
            Text('Something went wrong', style: tablebcolours.titleSm),
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
                    Icon(
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
          Icon(
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
