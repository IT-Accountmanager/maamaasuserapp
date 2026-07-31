import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:maamaas/widgets/safearea.dart';
import '../../../Models/food/Restaurentscdhule.dart';
import '../../../Services/App_color_service/app_colours.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TableTabContent extends StatefulWidget {
  final int vendorId;
  const TableTabContent({super.key, required this.vendorId});

  @override
  State<TableTabContent> createState() => _TableTabContentState();
}

class _TableTabContentState extends State<TableTabContent> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController noofpeople = TextEditingController();
  TimeOfDay? selectedTime;
  bool _isLoading = false;

  List<int> capacities = [];
  int? selectedCapacity;
  bool isCapacityLoading = false;

  List<RestaurantSchedule> schedules = [];
  RestaurantSchedule? selectedDaySchedule;

  bool isScheduleLoading = false;
  bool isCheckingSchedule = false;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
    nameController.addListener(() => setState(() {}));
    phoneController.addListener(() => setState(() {}));
    dateController.addListener(() => setState(() {}));
    timeController.addListener(() => setState(() {}));
    noofpeople.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    // print("🚀 _loadSchedules CALLED");

    setState(() {
      isScheduleLoading = true;
    });

    try {
      final data = await food_Authservice.fetchRestaurantSchedules(
        widget.vendorId,
      );

      // print("📦 DATA RECEIVED IN UI => ${data.length}");

      for (var item in data) {
        // print("📅 ${item.day}");
      }

      setState(() {
        schedules = data;
      });

      // print("✅ schedules state updated");
    } catch (e) {
      // print("❌ ERROR LOADING SCHEDULES => $e");
    } finally {
      setState(() {
        isScheduleLoading = false;
      });
    }
  }

  bool get isFormValid {
    return nameController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty &&
        dateController.text.trim().isNotEmpty &&
        timeController.text.trim().isNotEmpty &&
        // selectedCapacity != null &&
        selectedTime != null &&
        !_isLoading;
  }

  String _formatApiTime(String time) {
    try {
      final parsed = DateFormat("HH:mm:ss").parse(time);

      return DateFormat("hh:mm a").format(parsed);
    } catch (e) {
      return time;
    }
  }

  void _showScheduleOrderDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, bottomSheetSetState) {
            return PlatformSafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom:
                      MediaQuery.of(bottomSheetContext).viewInsets.bottom + 16,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: SingleChildScrollView(
                  child: (isScheduleLoading)
                      ? const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                "Schedule Your Table",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.of(context).primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              nameController,
                              "Name",
                              Icons.person,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              phoneController,
                              "Phone Number",
                              Icons.phone,
                              TextInputType.phone,
                            ),
                            const SizedBox(height: 12),

                            // _buildDateField(bottomSheetContext),
                            _buildDateField(
                              bottomSheetContext,
                              bottomSheetSetState,
                            ),
                            const SizedBox(height: 12),
                            if (isCheckingSchedule) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Checking restaurant timings...",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else if (selectedDaySchedule != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.orange,
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Restaurant Available Timings",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.orange.shade900,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_today,
                                                size: 14,
                                                color: Colors.black54,
                                              ),
                                              const SizedBox(width: 6),

                                              Text(
                                                selectedDaySchedule?.day ?? '',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 6),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "${_formatApiTime(selectedDaySchedule?.startTime ?? '')}  →  ${_formatApiTime(selectedDaySchedule?.lastTime ?? '')}",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.of(
                                                  context,
                                                ).primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),
                            ],

                            _buildTimeField(
                              bottomSheetContext,
                              bottomSheetSetState,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              noofpeople,
                              "Number of People",
                              Icons.people,
                              TextInputType.number,
                            ),

                            const SizedBox(height: 20),
                            _buildSubmitButton(bottomSheetContext),
                            const SizedBox(height: 16),
                          ],
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType? keyboardType,
  ]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.of(context).primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.of(context).primary),
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    StateSetter bottomSheetSetState,
  ) {
    return TextField(
      controller: dateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Select Date",
        prefixIcon: Icon(
          Icons.calendar_today,
          color: AppColors.of(context).primary,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.of(context).primary),
        ),
      ),

      onTap: () async {
        if (isScheduleLoading) {
          _showErrorDialog("Please wait, restaurant timings are loading");
          return;
        }

        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );

        if (pickedDate != null) {
          bottomSheetSetState(() {
            isCheckingSchedule = true;
          });

          await Future.delayed(const Duration(milliseconds: 500));

          final selectedDay = DateFormat('EEEE').format(pickedDate);

          // print("📅 PICKED DATE: $pickedDate");
          // print("📅 SELECTED DAY: $selectedDay");

          RestaurantSchedule? schedule;

          try {
            schedule = schedules.firstWhere(
              (e) =>
                  e.day.trim().toLowerCase() ==
                  selectedDay.trim().toLowerCase(),
            );

            // print("✅ MATCHED SCHEDULE => ${schedule.day}");
          } catch (e) {
            // print("❌ NO SCHEDULE FOUND");
            schedule = null;
          }

          bottomSheetSetState(() {
            dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);

            selectedDaySchedule = schedule;

            timeController.clear();
            selectedTime = null;

            isCheckingSchedule = false;
          });

          if (schedule == null) {
            _showErrorDialog("Restaurant is closed on $selectedDay");
          }
        }
      },
    );
  }

  // Widget _buildTimeField(BuildContext context) {
  Widget _buildTimeField(
    BuildContext context,
    StateSetter bottomSheetSetState,
  ) {
    return TextField(
      controller: timeController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Select Time",
        prefixIcon: Icon(
          Icons.access_time,
          color: AppColors.of(context).primary,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.of(context).primary),
        ),
      ),

      onTap: () async {
        if (selectedDaySchedule == null) {
          _showErrorDialog("Please select a valid booking date");
          return;
        }

        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (picked != null) {
          final pickedMinutes = picked.hour * 60 + picked.minute;

          final open = DateFormat(
            "HH:mm:ss",
          ).parse(selectedDaySchedule?.startTime ?? '--');

          final close = DateFormat(
            "HH:mm:ss",
          ).parse(selectedDaySchedule?.lastTime ?? '--');

          final openMinutes = open.hour * 60 + open.minute;
          final closeMinutes = close.hour * 60 + close.minute;

          // Check range
          if (pickedMinutes < openMinutes || pickedMinutes > closeMinutes) {
            _showErrorDialog(
              "Please select time between "
              "${_formatApiTime(selectedDaySchedule?.startTime ?? '--')} and "
              "${_formatApiTime(selectedDaySchedule?.lastTime ?? '--')}",
            );

            return;
          }

          bottomSheetSetState(() {
            selectedTime = picked;

            timeController.text =
                "${picked.hour}:${picked.minute.toString().padLeft(2, '0')}";
          });
        }
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
                setState(() => _isLoading = true);
                await _submitBooking(context);
                setState(() => _isLoading = false);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.of(context).primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Schedule Booking",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  bool _areFieldsValid() {
    return nameController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty &&
        dateController.text.trim().isNotEmpty &&
        timeController.text.trim().isNotEmpty &&
        noofpeople.text.trim().isNotEmpty &&
        selectedTime != null;
  }

  Future<void> _submitBooking(BuildContext context) async {
    final vendorId = widget.vendorId;

    if (!_areFieldsValid()) {
      _showErrorDialog('Please fill all fields');
      return;
    }

    final response = await food_Authservice.submitBooking(
      vendorId: vendorId,
      guestName: nameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      bookingDate: dateController.text.trim(),
      startTime:
          "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00",
      capacity: int.tryParse(noofpeople.text.trim()) ?? 0,
    );

    if (response != null && response['statusCode'] == 200) {
      Navigator.pop(context);

      AppAlert.success(context, "Booking scheduled successfully");
    } else {
      AppAlert.error(context, "Failed to schedule booking");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(Icons.error, color: Colors.red, size: 60),
            SizedBox(height: 8),
            Text(
              "Oops!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text("Try Again"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  "Schedule Table",
                  // Icons.calendar_today,
                  _showScheduleOrderDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.of(context).primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
