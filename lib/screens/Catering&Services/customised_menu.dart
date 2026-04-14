import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/Auth_service/catering_authservice.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Models/subscrptions/address_model.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '../../Models/caterings/dish.dart';
import '../screens/saved_address.dart';
import 'package:flutter/material.dart';

import 'package:maamaas/Services/App_color_service/app_colours.dart';

class CustomisedMenu extends StatefulWidget {
  const CustomisedMenu({super.key});

  @override
  State<CustomisedMenu> createState() => _CustomisedMenuState();
}

class _CustomisedMenuState extends State<CustomisedMenu> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _specialrequestsController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _peopleController = TextEditingController();
  final _budgetController = TextEditingController();
  final _fulladdressController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _vegController = TextEditingController();
  final _nonvegController = TextEditingController();
  final _mixedController = TextEditingController();
  bool _isVeg = true;
  String? _selectedEventType;
  Map<String, List<Dish>> categoryItems = {};
  List<String> customizedCategories = [];
  List<int> selectedItems = [];
  bool _isSubmitting = false;
  String? selectedAddress;
  int? selectedAddressId;
  String? _expandedCategory;

  List<Map<String, dynamic>> selectedAddOns = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final dishes = await catering_authservice.fetchDishes();

    if (!mounted) return; // 🔑 STOP if widget is gone

    final categories = dishes.where((d) => d.parentId == 0).toList();

    categoryItems.clear();
    customizedCategories.clear();

    for (var category in categories) {
      final items = dishes.where((d) => d.parentId == category.dishId).toList();

      customizedCategories.add(category.dishName);
      categoryItems[category.dishName] = items;
    }

    setState(() {});
  }

  List<Map<String, dynamic>> _buildSelectedAddOns() {
    return _addOns.entries
        .where((entry) => entry.value['selected'] == true)
        .map(
          (entry) => {
            "addOnType": entry.key,
            "quantity": entry.value['quantity'] ?? 0,
            "selected": true, // always true because filtered
          },
        )
        .toList();
  }

  void _showSummarySheet(BuildContext context) {
    final selectedAddOns = _buildSelectedAddOns();
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Enquiry Summary",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal Details Section
                        _buildSectionTitle("Personal Details"),
                        _buildDetailCard(
                          children: [
                            _buildDetailRow("Name", _nameController.text),
                            _buildDetailRow("Email", _emailController.text),
                            _buildDetailRow("Contact", _contactController.text),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Event Details Section
                        _buildSectionTitle("Event Details"),
                        _buildDetailCard(
                          children: [
                            _buildDetailRow(
                              "Event Type",
                              _selectedEventType ?? "-",
                            ),
                            _buildDetailRow("Date", _dateController.text),
                            _buildDetailRow("Time", _timeController.text),
                            _buildDetailRow("People", _peopleController.text),
                            _buildDetailRow("Budget", _budgetController.text),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Address Section
                        _buildSectionTitle("Delivery Address"),
                        _buildDetailCard(
                          children: [
                            _buildDetailRow(
                              "Address",
                              selectedAddress ?? 'Not selected',
                            ),
                            if (_countryController.text.isNotEmpty)
                              _buildDetailRow(
                                "Country",
                                _countryController.text,
                              ),
                            if (_stateController.text.isNotEmpty)
                              _buildDetailRow("State", _stateController.text),
                            if (_cityController.text.isNotEmpty)
                              _buildDetailRow("City", _cityController.text),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Plates Section
                        _buildSectionTitle("Menu Details"),
                        _buildDetailCard(
                          children: [
                            _buildDetailRow("Veg Plates", _vegController.text),
                            _buildDetailRow(
                              "Non-Veg Plates",
                              _nonvegController.text,
                            ),
                            _buildDetailRow(
                              "Mixed Plates",
                              _mixedController.text,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Special Requests
                        if (_specialrequestsController.text.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("Special Requests"),

                              _buildDetailCard(
                                children: [
                                  Text(_specialrequestsController.text),
                                ],
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),

                        // Selected Items
                        if (selectedItems.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("Selected Menu Items"),
                              const SizedBox(height: 8),

                              ...categoryItems.entries.map((entry) {
                                final category = entry.key;

                                final items = entry.value
                                    .where(
                                      (dish) =>
                                          selectedItems.contains(dish.dishId),
                                    )
                                    .toList();

                                if (items.isEmpty) return const SizedBox();

                                return _buildDetailCard(
                                  children: [
                                    Text(
                                      category,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    ...items.map((dish) {
                                      return ListTile(
                                        dense: true,
                                        leading: VegNonVegIcon(
                                          type: dish.dishType,
                                        ),
                                        title: Text(dish.dishName),
                                      );
                                    }),
                                  ],
                                );
                              }),

                              const SizedBox(height: 20),
                            ],
                          ),
                        const SizedBox(height: 20),
                        if (selectedAddOns.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("Selected Add-Ons"),

                              _buildDetailCard(
                                children: selectedAddOns.map((addOn) {
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.deepPurple,
                                    ),
                                    title: Text(addOn["addOnType"]),
                                    trailing: Text(
                                      "Qty: ${addOn["quantity"]}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Submit Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              setState(() => _isSubmitting = true);
                              AppAlert.info(context, "Submitting enquiry...");

                              final success = await catering_authservice
                                  .createEnquiry(
                                    fullName: _nameController.text,
                                    email: _emailController.text,
                                    phoneNumber: _contactController.text,
                                    event: "EVENT",
                                    eventType: _selectedEventType ?? "",
                                    eventDate: _dateController.text,
                                    eventTime: _timeController.text,
                                    people: _peopleController.text,
                                    budget: _budgetController.text,
                                    fullAddress: selectedAddress ?? "",
                                    country: _countryController.text,
                                    state: _stateController.text,
                                    city: _cityController.text,
                                    vegPlates: _vegController.text,
                                    nonVegPlates: _nonvegController.text,
                                    mixedPlates: _mixedController.text,
                                    additionalRequests:
                                        _specialrequestsController.text,
                                    // gstRequirement: _gstController.text,
                                    selectedItems: selectedItems,
                                    addressId: selectedAddressId,
                                    // pincode: pincode,
                                    addOns: _buildSelectedAddOns(),
                                  );

                              setState(() => _isSubmitting = false);

                              if (success) {
                                Navigator.pop(context);
                                // Clear all fields
                                [
                                  _nameController,
                                  _emailController,
                                  _contactController,
                                  _dateController,
                                  _timeController,
                                  _peopleController,
                                  _budgetController,
                                  // _gstController,
                                  _fulladdressController,
                                  _countryController,
                                  _stateController,
                                  _cityController,
                                  // _pincodeController,
                                  _vegController,
                                  _nonvegController,
                                  _mixedController,
                                  _specialrequestsController,
                                  // ignore: avoid_function_literals_in_foreach_calls
                                ].forEach((controller) => controller.clear());

                                // Clear add-ons
                                _addOns.forEach((key, value) {
                                  _addOns[key] = {
                                    ...value,
                                    'selected': false,
                                    'quantity': 0,
                                  };
                                });

                                setState(() {
                                  // _selectedEventCategory = null;
                                  _selectedEventType = null;
                                  selectedItems.clear();
                                  selectedAddressId = null;
                                  selectedAddress = null;
                                });
                                AppAlert.success(
                                  context,
                                  "Enquiry Submitted Successfully!",
                                );
                              } else {
                                AppAlert.error(
                                  context,
                                  "Failed to submit enquiry!",
                                );
                              }
                            },
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Submit Enquiry",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildDetailCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return value.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$label: ",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildForm(),

              const SizedBox(height: 24),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select your Menu",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: FlutterSwitch(
                          width: 85,
                          height: 40,
                          toggleSize: 30,
                          borderRadius: 20,
                          value: _isVeg,
                          showOnOff: true,
                          activeColor: Colors.green,
                          inactiveColor: Colors.red,
                          activeToggleColor: Colors.white,
                          inactiveToggleColor: Colors.white,
                          activeText: "Veg",
                          inactiveText: "Non-Veg",
                          valueFontSize: 10,
                          toggleColor: Colors.white70,
                          onToggle: (val) {
                            setState(() => _isVeg = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCategoryItems(),
                  const SizedBox(height: 20),
                  _buildAddOnsSection(),
                ],
                // ),
              ),
              const SizedBox(height: 20),

              // Special Requests Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Special Requests",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _specialrequestsController,
                      decoration: InputDecoration(
                        hintText: "Any special requirements or requests...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: 4,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  // onPressed: () => _showSummarySheet(context),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {});
                    _showSummarySheet(context);
                  },
                  child: const Text(
                    "Review & Submit",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    DateTime today = DateTime.now();
    DateTime firstAllowedDate = today.add(const Duration(days: 2));
    DateTime lastAllowedDate = today.add(const Duration(days: 365));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8, left: 4),
              child: Text(
                "Event Type",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedEventType,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  dropdownColor: Colors.white,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.deepPurple,
                  ),
                  hint: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text("Select event type"),
                  ),
                  items:
                      [
                        "WEDDING",
                        "BIRTHDAY",
                        "ENGAGEMENT",
                        "ANNIVERSARY",
                        "OTHER",
                      ].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEventType = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Date and Time Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8, left: 4),
                    child: Text(
                      "Date",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      hintText: "Select date",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.deepPurple),
                      ),
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.deepPurple,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: firstAllowedDate,
                        firstDate: firstAllowedDate,
                        lastDate: lastAllowedDate,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.deepPurple,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                              // ignore: deprecated_member_use
                              dialogBackgroundColor: Colors.white,
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        _dateController.text =
                            "${pickedDate.day.toString().padLeft(2, '0')}-"
                            "${pickedDate.month.toString().padLeft(2, '0')}-"
                            "${pickedDate.year}";
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8, left: 4),
                    child: Text(
                      "Time",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  TextField(
                    controller: _timeController,
                    decoration: InputDecoration(
                      hintText: "Select time",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.deepPurple),
                      ),
                      suffixIcon: const Icon(
                        Icons.access_time,
                        color: Colors.deepPurple,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.deepPurple,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: MediaQuery(
                              data: MediaQuery.of(
                                context,
                              ).copyWith(alwaysUse24HourFormat: false),
                              child: child!,
                            ),
                          );
                        },
                      );
                      if (pickedTime != null) {
                        final hours = pickedTime.hour.toString().padLeft(
                          2,
                          '0',
                        );
                        final minutes = pickedTime.minute.toString().padLeft(
                          2,
                          '0',
                        );

                        _timeController.text =
                            "$hours:$minutes"; // ✅ backend-friendly
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: "Email Address",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurple),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            prefixIcon: const Icon(Icons.email, color: Colors.deepPurple),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        _buildDeliveryAddress(),

        const SizedBox(height: 16),

        // People and Budget Row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _budgetController,
                decoration: InputDecoration(
                  labelText: "Estimated Budget",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(
                    Icons.currency_rupee,
                    color: Colors.deepPurple,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _vegController,
                decoration: InputDecoration(
                  labelText: "Veg Plates",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                  filled: true,
                  fillColor: Colors.green.shade50,
                  // prefixIcon: const Icon(Icons.eco, color: Colors.green),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _nonvegController,
                decoration: InputDecoration(
                  labelText: "Non-Veg",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  filled: true,
                  fillColor: Colors.red.shade50,
                  // prefixIcon: const Icon(Icons.whatshot, color: Colors.red),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress() {
    return GestureDetector(
      onTap: () => _showAddressBottomSheet(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.location_on, color: Colors.deepPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedAddress ?? "Select delivery address",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selectedAddress == null
                          ? FontWeight.normal
                          : FontWeight.w500,
                      color: selectedAddress == null
                          ? Colors.grey.shade600
                          : Colors.black87,
                    ),
                  ),
                  if (selectedAddress != null)
                    Text(
                      "Tap to change",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Home':
        return Icons.home_rounded;
      case 'Office':
        return Icons.business_rounded;
      case 'Other':
        return Icons.location_on_rounded;
      default:
        return Icons.place;
    }
  }

  Future<void> _showAddressBottomSheet(BuildContext context) async {
    List<Address> savedAddresses = [];
    bool isLoading = true;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> fetchAddresses() async {
              try {
                final data = await subscription_AuthService
                    .fetchAddresses(); // ✅ working API
                setModalState(() {
                  savedAddresses = data;
                  isLoading = false;
                });
              } catch (e) {
                setModalState(() {
                  isLoading = false;
                  errorMessage = "Error: $e";
                });
              }
            }

            // Trigger initial load once
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (isLoading) fetchAddresses();
            });

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Delivery Address",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (isLoading)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (errorMessage != null)
                      Expanded(child: Center(child: Text(errorMessage!)))
                    else if (savedAddresses.isEmpty)
                      const Expanded(
                        child: Center(child: Text("No saved addresses found")),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: savedAddresses.length,
                          itemBuilder: (context, index) {
                            final address = savedAddresses[index];
                            final displayText = " ${address.address}";

                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context, {
                                  "id": address.id,
                                  "display": displayText,
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    // const Icon(
                                    //   Icons.location_on,
                                    //   color: Color(0xFFB15DC6),
                                    // ),
                                    // const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                getCategoryIcon(
                                                  address.category,
                                                ),
                                                size: 16.sp,
                                                color: Colors.blueAccent,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                // 👈 important
                                                child: Text(
                                                  displayText,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
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
                          },
                        ),
                      ),

                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddressFormScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.add_location_alt,
                          color: AppColors.of(context).primary,
                        ),
                        label: Text(
                          "Add new Address",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.of(context).primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: AppColors.of(context).primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((selected) {
      if (selected != null && selected is Map<String, dynamic>) {
        setState(() {
          selectedAddressId = selected["id"];
          selectedAddress = selected["display"];
        });
        debugPrint("✅ Selected Address ID: $selectedAddressId");
        debugPrint("✅ Selected Address: $selectedAddress");
      }
    });
  }

  Widget _buildCategoryItems() {
    if (customizedCategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Loading menu...", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: customizedCategories.map((category) {
        List<Dish> allItems = (categoryItems[category] ?? []).cast<Dish>();
        List<Dish> items = allItems.where((dish) {
          if (_isVeg) {
            return dish.dishType.toLowerCase() == "veg";
          } else {
            return dish.dishType.toLowerCase() == "non_veg";
          }
        }).toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // ===== HEADER =====
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      if (_expandedCategory == category) {
                        _expandedCategory = null;
                      } else {
                        _expandedCategory = category;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade50,
                          child: Text(
                            category[0],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title + Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${items.length} items available",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Rotating Arrow
                        AnimatedRotation(
                          turns: _expandedCategory == category ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== BODY =====
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _expandedCategory == category
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: items.isNotEmpty
                        ? Column(
                            children: items.map((dish) {
                              bool isSelected = selectedItems.contains(
                                dish.dishId,
                              );

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.deepPurple.shade50
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.deepPurple
                                        : Colors.grey.shade300,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedItems.add(dish.dishId);
                                      } else {
                                        selectedItems.remove(dish.dishId);
                                      }
                                    });
                                  },
                                  title: Row(
                                    children: [
                                      VegNonVegIcon(type: dish.dishType),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          dish.dishName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected
                                                ? Colors.deepPurple
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _isVeg
                                  ? "No vegetarian items in this category"
                                  : "No non-vegetarian items in this category",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                  secondChild: const SizedBox(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddOnsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add-Ons",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Select additional services and items",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ..._addOns.entries.map((entry) {
            final String key = entry.key;
            final Map<String, dynamic> value = entry.value;
            final bool isSelected = value['selected'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.deepPurple.shade50
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  // Add-on header with switch
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.deepPurple
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        value['icon'],
                        color: isSelected ? Colors.white : Colors.grey,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      value['label'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.deepPurple : Colors.black87,
                      ),
                    ),
                    trailing: Switch(
                      value: isSelected,
                      onChanged: (bool newValue) {
                        setState(() {
                          _addOns[key] = {
                            ...value,
                            'selected': newValue,
                            'quantity': newValue ? 1 : 0,
                          };
                        });
                      },
                      activeThumbColor: Colors.deepPurple,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                  ),

                  // Quantity selector (only shown when selected)
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            "Quantity:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (_addOns[key]!['quantity'] > 0) {
                                        _addOns[key] = {
                                          ...value,
                                          'quantity': value['quantity'] - 1,
                                        };
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.remove, size: 18),
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                                Container(
                                  width: 40,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    _addOns[key]!['quantity'].toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _addOns[key] = {
                                        ...value,
                                        'quantity': value['quantity'] + 1,
                                      };
                                    });
                                  },
                                  icon: const Icon(Icons.add, size: 18),
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  final Map<String, Map<String, dynamic>> _addOns = {
    'SERVICE_BOYS': {
      'selected': false,
      'quantity': 0,
      'label': 'Service Boys',
      'icon': Icons.group,
    },
    'PAPER_PLATES': {
      'selected': false,
      'quantity': 0,
      'label': 'Paper Plates',
      'icon': Icons.dinner_dining,
    },
    'WATER_BOTTLES': {
      'selected': false,
      'quantity': 0,
      'label': 'Water Bottles',
      'icon': Icons.water_drop,
    },
    'DISPOSABLE_CUPS': {
      'selected': false,
      'quantity': 0,
      'label': 'Disposable Cups',
      'icon': Icons.coffee,
    },
    'TISSUE_PAPER': {
      'selected': false,
      'quantity': 0,
      'label': 'Tissue Paper',
      'icon': Icons.note_alt,
    },
  };
}

class VegNonVegIcon extends StatelessWidget {
  final String type;
  final double size;

  const VegNonVegIcon({super.key, required this.type, this.size = 20});

  @override
  Widget build(BuildContext context) {
    final bool isVeg = type.toLowerCase() == "veg";
    final color = isVeg ? Colors.green : Colors.red;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(
          isVeg ? Icons.eco : Icons.whatshot,
          color: color,
          size: size * 0.6,
        ),
      ),
    );
  }
}
