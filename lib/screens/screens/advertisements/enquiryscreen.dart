import '../../Catering&Services/customised_menu.dart';
import 'package:flutter/material.dart';

import 'package:maamaas/Services/App_color_service/app_colours.dart';
class EnquiryFormScreen extends StatefulWidget {
  const EnquiryFormScreen({super.key});

  @override
  State<EnquiryFormScreen> createState() => _EnquiryFormScreenState();
}

class _EnquiryFormScreenState extends State<EnquiryFormScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Enquiry Form",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.of(context).primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CustomisedMenu(),
    );
  }
}

