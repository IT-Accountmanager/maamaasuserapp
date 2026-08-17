// import 'package:flutter/material.dart';
// import '../../../Models/food/seatingdetails.dart';
// import '../../../Services/Auth_service/food_authservice.dart';
// import '../../Mainscreen.dart';
//
// // ─────────────────────────────────────────────
// //  DESIGN TOKENS
// // ─────────────────────────────────────────────
// class _Clr {
//   static const bg = Color(0xFFF7F5F2);
//   static const surface = Colors.white;
//   static const ink = Color(0xFF1A1A1A);
//   static const inkSub = Color(0xFF7A7875);
//   static const accent = Color(0xFFD4622A); // warm terra-cotta
//
//   static const available = Color(0xFF2A9D5C);
//   static const occupied = Color(0xFFD94F3D);
//   static const reserved = Color(0xFFE07B39);
//   static const vacant = Color(0xFF3A86C8);
//   static const cleaning = Color(0xFF9B59B6);
//   static const maintenance = Color(0xFF7F8C8D);
// }
//
// class TableUiModel {
//   final Seating table;
//   final SeatingDetails? booking;
//   final String status;
//
//   TableUiModel({
//     required this.table,
//     required this.booking,
//     required this.status,
//   });
// }
//
// // ─────────────────────────────────────────────
// //  MAIN SCREEN
// // ─────────────────────────────────────────────
// class SeatingScreen extends StatefulWidget {
//   final int vendorId;
//   final String guestName;
//   final String phoneNumber;
//   final String bookingDate;
//   final String startTime;
//   final int capacity;
//
//   const SeatingScreen({
//     super.key,
//     required this.vendorId,
//     required this.guestName,
//     required this.phoneNumber,
//     required this.bookingDate,
//     required this.startTime,
//     required this.capacity,
//   });
//
//   @override
//   State<SeatingScreen> createState() => _SeatingScreenState();
// }
//
// class _SeatingScreenState extends State<SeatingScreen> {
//   bool isLoading = true;
//
//   List<Seating> allTables = [];
//   List<SeatingDetails> allBookings = [];
//   Seating? selectedTable;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }
//
//   String getTableStatus({
//     required Seating table,
//     required List<SeatingDetails> bookings,
//   }) {
//     try {
//       final selectedTime = DateTime.parse(
//         "${widget.bookingDate} ${widget.startTime}",
//       );
//
//       /// CHECK EVERY BOOKING OF THIS TABLE
//       for (final booking in bookings) {
//         final bookingStart = DateTime.parse(
//           "${booking.bookingDate} ${booking.startTime}",
//         );
//
//         final bookingEnd = bookingStart.add(
//           Duration(minutes: booking.durationMinutes),
//         );
//
//         /// OCCUPIED
//         if ((selectedTime.isAtSameMomentAs(bookingStart) ||
//                 selectedTime.isAfter(bookingStart)) &&
//             selectedTime.isBefore(bookingEnd)) {
//           return "Occupied";
//         }
//
//         /// RESERVED
//         if (selectedTime.isBefore(bookingStart)) {
//           return "Reserved";
//         }
//       }
//
//       /// NO ACTIVE BOOKINGS
//       return "Available";
//     } catch (e) {
//       debugPrint("STATUS ERROR: $e");
//       return table.seatingStatus;
//     }
//   }
//
//   List<TableUiModel> get finalTables {
//     return allTables.map((table) {
//       final bookings = allBookings
//           .where((b) => b.seatingId == table.id)
//           .toList();
//
//       final status = getTableStatus(table: table, bookings: bookings);
//
//       return TableUiModel(
//         table: table,
//         booking: bookings.isNotEmpty ? bookings.first : null,
//         status: status,
//       );
//     }).toList();
//   }
//
//   Future<void> fetchData() async {
//     try {
//       setState(() => isLoading = true);
//
//       final tables = await food_Authservice.fetchAllTables(
//         vendorId: widget.vendorId,
//       );
//
//       final bookings = await food_Authservice.fetchVendorBookings(
//         vendorId: widget.vendorId,
//         date: widget.bookingDate,
//       );
//
//       debugPrint("TABLES COUNT: ${tables.length}");
//       debugPrint("BOOKINGS COUNT: ${bookings.length}");
//
//       setState(() {
//         allTables = tables;
//         allBookings = bookings;
//         isLoading = false;
//       });
//     } catch (e) {
//       debugPrint("ERROR: $e");
//
//       setState(() => isLoading = false);
//     }
//   }
//
//   Map<int, List<TableUiModel>> get groupedByCapacity {
//     final Map<int, List<TableUiModel>> grouped = {};
//
//     for (final table in finalTables) {
//       final cap = table.table.capacity;
//
//       grouped.putIfAbsent(cap, () => []);
//
//       grouped[cap]!.add(table);
//     }
//
//     return Map.fromEntries(
//       grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
//     );
//   }
//
//   // Summary counts for the legend bar
//   Map<String, int> get statusCounts {
//     final Map<String, int> counts = {};
//
//     for (final table in finalTables) {
//       final s = table.status.toLowerCase();
//
//       counts[s] = (counts[s] ?? 0) + 1;
//     }
//
//     return counts;
//   }
//
//   static Color statusColor(String status) {
//     switch (status.toLowerCase()) {
//       case "available":
//         return _Clr.available;
//       case "occupied":
//         return _Clr.occupied;
//       case "reserved":
//         return _Clr.reserved;
//       case "vacant":
//         return _Clr.vacant;
//       case "cleaning":
//         return _Clr.cleaning;
//       case "maintenance":
//         return _Clr.maintenance;
//       default:
//         return _Clr.inkSub;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: selectedTable == null
//           ? null
//           : Container(
//               padding: const EdgeInsets.all(16),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
//               ),
//               child: SafeArea(
//                 child: SizedBox(
//                   height: 56,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//
//                     onPressed: () async {
//                       try {
//                         final response = await food_Authservice.submitBooking(
//                           vendorId: widget.vendorId,
//                           guestName: widget.guestName,
//                           phoneNumber: widget.phoneNumber,
//                           bookingDate: widget.bookingDate,
//                           startTime: widget.startTime,
//                           capacity: widget.capacity,
//                           seatingId: selectedTable!.id,
//                         );
//
//                         if (response != null && response['statusCode'] == 200) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text("Table booked successfully"),
//                             ),
//                           );
//
//                           /// CLEAR SELECTION
//                           setState(() {
//                             selectedTable = null;
//                           });
//
//                           /// OPTIONAL REFRESH
//                           await fetchData();
//
//                           /// REDIRECT TO FOOD MAIN SCREEN
//                           Navigator.pushAndRemoveUntil(
//                             context,
//                             MaterialPageRoute(builder: (_) => MainScreenfood()),
//                             (route) => false,
//                           );
//                         }
//                       } catch (e) {
//                         ScaffoldMessenger.of(
//                           context,
//                         ).showSnackBar(SnackBar(content: Text("Error: $e")));
//                       }
//                     },
//
//                     child: Text(
//                       "Book ${selectedTable!.code}",
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//       backgroundColor: _Clr.bg,
//       appBar: AppBar(title: const Text("Restaurant Tables"), elevation: 0),
//       body: SafeArea(
//         child: isLoading
//             ? const _LoadingView()
//             : groupedByCapacity.isEmpty
//             ? const _EmptyView()
//             : RefreshIndicator(
//                 color: _Clr.accent,
//                 backgroundColor: _Clr.surface,
//                 onRefresh: fetchData,
//                 child: CustomScrollView(
//                   slivers: [
//                     // ── CAPACITY SECTIONS ────────────────────
//                     ...groupedByCapacity.entries.map((entry) {
//                       return SliverToBoxAdapter(
//                         child: _CapacitySection(
//                           capacity: entry.key,
//                           tables: entry.value,
//                           statusColor: statusColor,
//                           vendorId: widget.vendorId,
//                           guestName: widget.guestName,
//                           phoneNumber: widget.phoneNumber,
//                           bookingDate: widget.bookingDate,
//                           startTime: widget.startTime,
//                           selectedTable: selectedTable,
//
//                           onTableSelected: (table) {
//                             setState(() {
//                               selectedTable = table;
//                             });
//                           },
//                         ),
//                       );
//                     }),
//
//                     const SliverToBoxAdapter(child: SizedBox(height: 32)),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// //  CAPACITY SECTION
// // ─────────────────────────────────────────────
// class _CapacitySection extends StatelessWidget {
//   final int capacity;
//   final List<TableUiModel> tables;
//   final Color Function(String) statusColor;
//   final int vendorId;
//   final String guestName;
//   final String phoneNumber;
//   final String bookingDate;
//   final String startTime;
//   final Seating? selectedTable;
//   final Function(Seating table) onTableSelected;
//
//   const _CapacitySection({
//     required this.capacity,
//     required this.tables,
//     required this.statusColor,
//
//     required this.vendorId,
//     required this.startTime,
//     required this.phoneNumber,
//     required this.guestName,
//     required this.bookingDate,
//     required this.selectedTable,
//     required this.onTableSelected,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section header
//           Row(
//             children: [
//               Container(
//                 width: 4,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   color: _Clr.accent,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 "$capacity-Seat Tables",
//                 style: const TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.w700,
//                   color: _Clr.ink,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: _Clr.accent.withOpacity(0.10),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   "${tables.length}",
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     color: _Clr.accent,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: tables.length,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               mainAxisSpacing: 10,
//               crossAxisSpacing: 10,
//               childAspectRatio: 1.0,
//             ),
//             itemBuilder: (context, index) {
//               final tableUi = tables[index];
//
//               return _TableCard(
//                 tableUi: tableUi,
//                 color: statusColor(tableUi.status),
//                 vendorId: vendorId,
//                 guestName: guestName,
//                 phoneNumber: phoneNumber,
//                 bookingDate: bookingDate,
//                 startTime: startTime,
//                 capacity: capacity,
//                 selectedTable: selectedTable,
//                 onTableSelected: onTableSelected,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// //  TABLE CARD
// // ─────────────────────────────────────────────
// class _TableCard extends StatefulWidget {
//   final TableUiModel tableUi;
//   final Color color;
//   final int vendorId;
//   final String guestName;
//   final String phoneNumber;
//   final String bookingDate;
//   final String startTime;
//   final int capacity;
//   final Seating? selectedTable;
//   final Function(Seating table) onTableSelected;
//
//   const _TableCard({
//     required this.tableUi,
//     required this.color,
//     required this.vendorId,
//     required this.guestName,
//     required this.phoneNumber,
//     required this.bookingDate,
//     required this.startTime,
//     required this.capacity,
//     required this.selectedTable,
//     required this.onTableSelected,
//   });
//
//   @override
//   State<_TableCard> createState() => _TableCardState();
// }
//
// class _TableCardState extends State<_TableCard> {
//   bool isBooking = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final isSelected = widget.selectedTable?.id == widget.tableUi.table.id;
//     return GestureDetector(
//       onTap: () {
//         if (widget.tableUi.status.toLowerCase() != "available") {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("This table is not available")),
//           );
//           return;
//         }
//
//         widget.onTableSelected(widget.tableUi.table);
//       },
//
//       child: Opacity(
//         opacity: widget.tableUi.status.toLowerCase() == "available" ? 1 : 0.65,
//
//         child: Container(
//           decoration: BoxDecoration(
//             color: _Clr.surface,
//             borderRadius: BorderRadius.circular(20),
//
//             border: isSelected
//                 ? Border.all(color: Colors.green, width: 3)
//                 : null,
//           ),
//
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//
//             child: Stack(
//               children: [
//                 /// TOP STRIP
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   child: Container(height: 4, color: widget.color),
//                 ),
//
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
//
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 5,
//                             ),
//
//                             decoration: BoxDecoration(
//                               color: widget.color.withOpacity(0.12),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//
//                             child: Text(
//                               _label(widget.tableUi.status),
//                               style: TextStyle(
//                                 color: widget.color,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//
//                           const Spacer(),
//
//                           if (isBooking)
//                             const SizedBox(
//                               width: 18,
//                               height: 18,
//                               child: CircularProgressIndicator(strokeWidth: 2),
//                             ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 14),
//
//                       /// TABLE CODE
//                       Text(
//                         widget.tableUi.table.code,
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.w800,
//                           color: _Clr.ink,
//                         ),
//                       ),
//
//                       const SizedBox(height: 4),
//
//                       /// TABLE NAME
//                       Text(
//                         widget.tableUi.table.name,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: _Clr.inkSub,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   static String _label(String s) {
//     return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
//   }
// }
//
// class _LoadingView extends StatelessWidget {
//   const _LoadingView();
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircularProgressIndicator(color: _Clr.accent, strokeWidth: 2.5),
//           SizedBox(height: 16),
//           Text(
//             "Loading tables…",
//             style: TextStyle(color: _Clr.inkSub, fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _EmptyView extends StatelessWidget {
//   const _EmptyView();
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: _Clr.accent.withOpacity(0.08),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.chair_alt_rounded,
//               size: 48,
//               color: _Clr.accent,
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             "No Tables Found",
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               color: _Clr.ink,
//             ),
//           ),
//           const SizedBox(height: 6),
//           const Text(
//             "Pull down to refresh",
//             style: TextStyle(fontSize: 14, color: _Clr.inkSub),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:maamaas/screens/Food&beverages/foodmainscreen.dart';
import '../../../Models/food/seatingdetails.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import '../../../Mainscreen.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _Clr {
  static const bg = Color(0xFFF4F2EF);
  static const surface = Colors.white;
  static const ink = Color(0xFF1A1A1A);
  static const inkSub = Color(0xFF8A8784);
  static const accent = Color(0xFFD4622A);

  static const available = Color(0xFF2A9D5C);
  static const occupied = Color(0xFFD94F3D);
  static const reserved = Color(0xFFE07B39);
  static const vacant = Color(0xFF3A86C8);
  static const cleaning = Color(0xFF9B59B6);
  static const maintenance = Color(0xFF7F8C8D);
}

// ─────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────
class TableUiModel {
  final Seating table;
  final SeatingDetails? booking;
  final String status;

  TableUiModel({
    required this.table,
    required this.booking,
    required this.status,
  });
}

// ─────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────
class SeatingScreen extends StatefulWidget {
  final int vendorId;
  final String guestName;
  final String phoneNumber;
  final String bookingDate;
  final String startTime;
  final int capacity;

  const SeatingScreen({
    super.key,
    required this.vendorId,
    required this.guestName,
    required this.phoneNumber,
    required this.bookingDate,
    required this.startTime,
    required this.capacity,
  });

  @override
  State<SeatingScreen> createState() => _SeatingScreenState();
}

class _SeatingScreenState extends State<SeatingScreen> {
  bool isLoading = true;
  List<Seating> allTables = [];
  List<SeatingDetails> allBookings = [];
  Seating? selectedTable;
  bool _detailsExpanded = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // ── STATUS LOGIC ────────────────────────────
  String getTableStatus({
    required Seating table,
    required List<SeatingDetails> bookings,
  }) {
    try {
      final selectedTime = DateTime.parse(
        "${widget.bookingDate} ${widget.startTime}",
      );

      for (final booking in bookings) {
        final bookingStart = DateTime.parse(
          "${booking.bookingDate} ${booking.startTime}",
        );
        final bookingEnd = bookingStart.add(
          Duration(minutes: booking.durationMinutes),
        );

        if ((selectedTime.isAtSameMomentAs(bookingStart) ||
                selectedTime.isAfter(bookingStart)) &&
            selectedTime.isBefore(bookingEnd)) {
          return "Occupied";
        }
        if (selectedTime.isBefore(bookingStart)) return "Reserved";
      }
      return "Available";
    } catch (e) {
      //       debugPrint("STATUS ERROR: $e");
      return table.seatingStatus;
    }
  }

  List<TableUiModel> get finalTables {
    return allTables.map((table) {
      final bookings = allBookings
          .where((b) => b.seatingId == table.id)
          .toList();
      return TableUiModel(
        table: table,
        booking: bookings.isNotEmpty ? bookings.first : null,
        status: getTableStatus(table: table, bookings: bookings),
      );
    }).toList();
  }

  Future<void> fetchData() async {
    try {
      setState(() => isLoading = true);
      final tables = await food_Authservice.fetchAllTables(
        vendorId: widget.vendorId,
      );
      final bookings = await food_Authservice.fetchVendorBookings(
        vendorId: widget.vendorId,
        date: widget.bookingDate,
      );
      setState(() {
        allTables = tables;
        allBookings = bookings;
        isLoading = false;
      });
    } catch (e) {
      //       debugPrint("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  Map<int, List<TableUiModel>> get groupedByCapacity {
    final Map<int, List<TableUiModel>> grouped = {};
    for (final t in finalTables) {
      grouped.putIfAbsent(t.table.capacity, () => []).add(t);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case "available":
        return _Clr.available;
      case "occupied":
        return _Clr.occupied;
      case "reserved":
        return _Clr.reserved;
      case "vacant":
        return _Clr.vacant;
      case "cleaning":
        return _Clr.cleaning;
      case "maintenance":
        return _Clr.maintenance;
      default:
        return _Clr.inkSub;
    }
  }

  static IconData statusIcon(String status) {
    switch (status.toLowerCase()) {
      case "available":
        return Icons.check_circle_outline_rounded;
      case "occupied":
        return Icons.cancel_outlined;
      case "reserved":
        return Icons.schedule_rounded;
      case "vacant":
        return Icons.remove_circle_outline_rounded;
      case "cleaning":
        return Icons.cleaning_services_outlined;
      case "maintenance":
        return Icons.build_circle_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  // ── LEGEND ──────────────────────────────────
  Widget _buildLegend() {
    final items = {
      "Available": _Clr.available,
      "Occupied": _Clr.occupied,
      "Reserved": _Clr.reserved,
      // "Vacant": _Clr.vacant,
      // "Cleaning": _Clr.cleaning,
    };
    return Container(
      color: _Clr.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.entries.map((e) {
            final count = finalTables
                .where((t) => t.status.toLowerCase() == e.key.toLowerCase())
                .length;
            return Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: e.value,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "${e.key} $count",
                    style: const TextStyle(fontSize: 11, color: _Clr.inkSub),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoChips() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: _Clr.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                _detailsExpanded = !_detailsExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _Clr.accent.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: _Clr.accent,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Entered Details",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _Clr.ink,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          "${widget.guestName} ",
                          style: const TextStyle(
                            fontSize: 12,
                            color: _Clr.inkSub,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  AnimatedRotation(
                    turns: _detailsExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _Clr.inkSub,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  const Divider(height: 1),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _DetailTile(
                          icon: Icons.person_outline_rounded,
                          title: "Guest Name",
                          value: widget.guestName,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _DetailTile(
                          icon: Icons.phone_outlined,
                          title: "Phone",
                          value: widget.phoneNumber,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _DetailTile(
                          icon: Icons.event_rounded,
                          title: "Booking Date",
                          value: widget.bookingDate,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _DetailTile(
                          icon: Icons.access_time_rounded,
                          title: "Start Time",
                          value: widget.startTime,
                        ),
                      ),
                    ],
                  ),

                  // const SizedBox(height: 10),
                  //
                  // _DetailTile(
                  //   icon: Icons.group_rounded,
                  //   title: "Guests",
                  //   value: "${widget.capacity} People",
                  //   fullWidth: true,
                  // ),
                ],
              ),
            ),
            crossFadeState: _detailsExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  // ── BUILD ────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    // Responsive: 2 columns on narrow, 3 on wide tablets
    final crossAxisCount = screenW >= 600 ? 3 : 2;
    // Responsive card ratio — tighter on wider screens
    final cardRatio = screenW >= 600 ? 1.15 : 1.05;

    return Scaffold(
      backgroundColor: _Clr.bg,
      appBar: AppBar(
        backgroundColor: _Clr.surface,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Restaurant Tables",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: _Clr.ink,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: Colors.black12),
        ),
      ),
      bottomNavigationBar: selectedTable == null
          ? null
          : _BookingBar(tableCode: selectedTable!.code, onBook: _submitBooking),
      body: SafeArea(
        child: isLoading
            ? const _LoadingView()
            : groupedByCapacity.isEmpty
            ? const _EmptyView()
            : RefreshIndicator(
                color: _Clr.accent,
                backgroundColor: _Clr.surface,
                onRefresh: fetchData,
                child: CustomScrollView(
                  slivers: [
                    // Info chips
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildInfoChips(),
                          Container(height: 0.5, color: Colors.black12),
                          _buildLegend(),
                          Container(height: 0.5, color: Colors.black12),
                        ],
                      ),
                    ),

                    // Capacity sections
                    ...groupedByCapacity.entries.map((entry) {
                      return SliverToBoxAdapter(
                        child: _CapacitySection(
                          capacity: entry.key,
                          tables: entry.value,
                          statusColor: statusColor,
                          statusIcon: statusIcon,
                          selectedTable: selectedTable,
                          crossAxisCount: crossAxisCount,
                          cardAspectRatio: cardRatio,
                          onTableSelected: (t) =>
                              setState(() => selectedTable = t),
                        ),
                      );
                    }),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _submitBooking() async {
    if (selectedTable == null) return;
    try {
      final response = await food_Authservice.submitBooking(
        vendorId: widget.vendorId,
        guestName: widget.guestName,
        phoneNumber: widget.phoneNumber,
        bookingDate: widget.bookingDate,
        startTime: widget.startTime,
        capacity: widget.capacity,
        // seatingId: selectedTable!.id,
      );
      if (response != null && response['statusCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Table booked successfully")),
        );
        setState(() => selectedTable = null);
        await fetchData();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => foodMainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}

// ─────────────────────────────────────────────
//  INFO CHIP
// ─────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDE9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _Clr.inkSub),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 11, color: _Clr.inkSub)),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool fullWidth;

  const _DetailTile({
    required this.icon,
    required this.title,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _Clr.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: _Clr.accent),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: _Clr.inkSub),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _Clr.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CAPACITY SECTION
// ─────────────────────────────────────────────
class _CapacitySection extends StatelessWidget {
  final int capacity;
  final List<TableUiModel> tables;
  final Color Function(String) statusColor;
  final IconData Function(String) statusIcon;
  final Seating? selectedTable;
  final int crossAxisCount;
  final double cardAspectRatio;
  final void Function(Seating) onTableSelected;

  const _CapacitySection({
    required this.capacity,
    required this.tables,
    required this.statusColor,
    required this.statusIcon,
    required this.selectedTable,
    required this.crossAxisCount,
    required this.cardAspectRatio,
    required this.onTableSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: _Clr.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                "$capacity-seat tables",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _Clr.ink,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _Clr.accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${tables.length}",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _Clr.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tables.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: cardAspectRatio,
            ),
            itemBuilder: (context, index) {
              final t = tables[index];
              return _TableCard(
                tableUi: t,
                color: statusColor(t.status),
                icon: statusIcon(t.status),
                isSelected: selectedTable?.id == t.table.id,
                onTap: () {
                  if (t.status.toLowerCase() != "available") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("This table is not available"),
                      ),
                    );
                    return;
                  }
                  onTableSelected(t.table);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TABLE CARD
// ─────────────────────────────────────────────
class _TableCard extends StatelessWidget {
  final TableUiModel tableUi;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TableCard({
    required this.tableUi,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = tableUi.status.toLowerCase() == "available";

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.55,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _Clr.surface,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(color: _Clr.available, width: 2)
                : Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                // Top color strip
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(height: 3, color: color),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(11, 16, 11, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 10, color: color),
                            const SizedBox(width: 4),
                            Text(
                              _label(tableUi.status),
                              style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Table code
                      Text(
                        tableUi.table.code,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _Clr.ink,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Table name
                      Text(
                        tableUi.table.name,
                        style: const TextStyle(
                          fontSize: 10,
                          color: _Clr.inkSub,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Seat count chip
                      Row(
                        children: [
                          Icon(
                            Icons.chair_alt_rounded,
                            size: 11,
                            color: _Clr.inkSub,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "${tableUi.table.capacity} seats",
                            style: const TextStyle(
                              fontSize: 10,
                              color: _Clr.inkSub,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Selected checkmark
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: _Clr.available,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _label(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

// ─────────────────────────────────────────────
//  BOOKING BAR
// ─────────────────────────────────────────────
class _BookingBar extends StatelessWidget {
  final String tableCode;
  final VoidCallback onBook;

  const _BookingBar({required this.tableCode, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _Clr.available,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: onBook,
            icon: const Icon(Icons.event_available_rounded, size: 18),
            label: Text(
              "Book $tableCode",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  LOADING + EMPTY STATES
// ─────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _Clr.accent, strokeWidth: 2),
          SizedBox(height: 14),
          Text(
            "Loading tables…",
            style: TextStyle(color: _Clr.inkSub, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _Clr.accent.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chair_alt_rounded,
              size: 44,
              color: _Clr.accent,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "No tables found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _Clr.ink,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Pull down to refresh",
            style: TextStyle(fontSize: 13, color: _Clr.inkSub),
          ),
        ],
      ),
    );
  }
}
