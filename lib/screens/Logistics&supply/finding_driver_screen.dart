import 'package:flutter/material.dart';

class FindingDriverScreen extends StatefulWidget {
  const FindingDriverScreen({Key? key}) : super(key: key);

  @override
  State<FindingDriverScreen> createState() => _FindingDriverScreenState();
}

class _FindingDriverScreenState extends State<FindingDriverScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Driver assigned successfully! 🚗")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated searching effect
            const CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation(Color(0xFFB15DC6)),
            ),
            const SizedBox(height: 30),
            const Text(
              "Finding a Captain nearby...",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Please wait while we assign your ride",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 50),

            // Cancel button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  "Cancel Ride",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
