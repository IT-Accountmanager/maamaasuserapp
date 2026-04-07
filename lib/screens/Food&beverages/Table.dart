import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/Auth_service/food_authservice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:maamaas/Services/App_color_service/app_colours.dart';
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

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dateController.dispose();
    timeController.dispose();
    noofpeople.dispose();
    super.dispose();
  }

  void _showScheduleOrderDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
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
                _buildTextField(nameController, "Name", Icons.person),
                const SizedBox(height: 12),
                _buildTextField(
                  phoneController,
                  "Phone Number",
                  Icons.phone,
                  TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildDateField(bottomSheetContext),
                const SizedBox(height: 12),
                _buildTimeField(bottomSheetContext),
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

  Widget _buildDateField(BuildContext context) {
    return TextField(
      controller: dateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Select Date",
        prefixIcon: Icon(Icons.calendar_today, color: AppColors.of(context).primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.of(context).primary),
        ),
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (pickedDate != null) {
          setState(() {
            dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return TextField(
      controller: timeController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Select Time",
        prefixIcon: Icon(Icons.access_time, color: AppColors.of(context).primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.of(context).primary),
        ),
      ),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          setState(() {
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

  Future<void> _submitBooking(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final vendorId = widget.vendorId;

    if (userId == null) {
      _showErrorDialog('User not logged in');
      return;
    }

    if (!_areFieldsValid()) {
      _showErrorDialog('Please fill all fields');
      return;
    }

    final status = await food_Authservice.submitBooking(
      vendorId: vendorId,
      guestName: nameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      bookingDate: dateController.text.trim(),
      startTime:
          "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00",
      capacity: int.tryParse(noofpeople.text.trim()) ?? 0,
    );

    if (status == 200) {
      Navigator.pop(context);

      _showSuccessDialog(
        "Booking Confirmed",
        "Your table has been booked successfully!\n\n"
            "📅 Date: ${dateController.text}\n"
            "⏰ Time: ${timeController.text}",
      );
    } else if (status == 202) {
      Navigator.pop(context);

      _showSuccessDialog(
        "Added to Waiting List",
        "All tables are currently full.\n\n"
            "You have been added to the waiting list.\n"
            "The restaurant may contact you if a table becomes available.",
      );
    } else {
      _showErrorDialog("Failed to schedule booking");
    }
  }

  bool _areFieldsValid() {
    return nameController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty &&
        dateController.text.trim().isNotEmpty &&
        timeController.text.trim().isNotEmpty &&
        noofpeople.text.trim().isNotEmpty &&
        selectedTime != null;
  }


  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        titlePadding: EdgeInsets.zero,

        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
          ],
        ),

        actionsAlignment: MainAxisAlignment.center,
        actions: [
          // ✨ Button 1 → Close Dialog
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Close"),
          ),
        ],
      ),
    );
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

          // const SizedBox(height: 24),
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
          // Icon(icon, size: 24),
          // const SizedBox(height: 8),
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
