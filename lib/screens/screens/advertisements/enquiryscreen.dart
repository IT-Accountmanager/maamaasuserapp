
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Models/promotions_model/promotions_model.dart';
import '../../../Services/Auth_service/promotion_services_Authservice.dart';
import '../../Catering&Services/customised_menu.dart';
import 'package:flutter/material.dart';
import 'package:maamaas/Services/App_color_service/app_colours.dart';

class EnquiryFormScreen extends StatefulWidget {
  final int? vendorId;
  const EnquiryFormScreen({super.key,required this.vendorId,});

  @override
  State<EnquiryFormScreen> createState() => _EnquiryFormScreenState();
}

class _EnquiryFormScreenState extends State<EnquiryFormScreen> {
  @override
  @override
  void initState() {
    super.initState();
    debugPrint("📦 EnquiryFormScreen VendorId → ${widget.vendorId}");
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enquiry Form", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.of(context).primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CustomisedMenu(vendorId:widget.vendorId),
    );
  }
}

class EnquiryScreen extends StatefulWidget {
  final int campaignId;
  final CallToAction callToAction;

  const EnquiryScreen({
    Key? key,
    required this.campaignId,
    required this.callToAction,
  }) : super(key: key);

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _submitEnquiry() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId') ?? '';

    final success = await promotion_Authservice.submitEnquiry(
      campaignId: widget.campaignId,
      customerId: customerId,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      callToAction: widget.callToAction.name,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Enquiry Submitted Successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to submit enquiry")),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enquiry Form"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Phone Number"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter phone number";
                  } else if (value.length < 10) {
                    return "Enter valid phone number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration("Email"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter email";
                  } else if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return "Enter valid email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitEnquiry,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
