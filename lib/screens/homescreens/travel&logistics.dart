// import 'package:flutter/material.dart';
//
// enum ServiceType { passenger, parcel }
//
// enum TravelType { intracity, intercity }
//
// class TravelHomeScreen extends StatefulWidget {
//   const TravelHomeScreen({super.key});
//
//   @override
//   State<TravelHomeScreen> createState() => _TravelHomeScreenState();
// }
//
// class _TravelHomeScreenState extends State<TravelHomeScreen> {
//   ServiceType selectedService = ServiceType.passenger;
//   TravelType selectedTravel = TravelType.intracity;
//
//   final TextEditingController pickupController = TextEditingController();
//   final TextEditingController dropController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Travel"),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           _locationInputs(),
//           _serviceToggle(),
//           _travelToggle(),
//           const SizedBox(height: 10),
//           Expanded(child: _dynamicContent()),
//           _bottomButton(),
//         ],
//       ),
//     );
//   }
//
//   // 📍 Location Inputs
//   Widget _locationInputs() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           _textField("Pickup Location", pickupController),
//           const SizedBox(height: 10),
//           _textField("Drop Location", dropController),
//         ],
//       ),
//     );
//   }
//
//   Widget _textField(String hint, TextEditingController controller) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         hintText: hint,
//         filled: true,
//         fillColor: Colors.white,
//         prefixIcon: const Icon(Icons.location_on),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
//
//   // 🔘 Passenger / Parcel Toggle
//   Widget _serviceToggle() {
//     return _toggleContainer(
//       children: [
//         _toggleButton(
//           label: "Passengers",
//           isSelected: selectedService == ServiceType.passenger,
//           onTap: () {
//             setState(() => selectedService = ServiceType.passenger);
//           },
//         ),
//         _toggleButton(
//           label: "Parcels",
//           isSelected: selectedService == ServiceType.parcel,
//           onTap: () {
//             setState(() => selectedService = ServiceType.parcel);
//           },
//         ),
//       ],
//     );
//   }
//
//   // 🔘 Intracity / Intercity Toggle
//   Widget _travelToggle() {
//     return _toggleContainer(
//       children: [
//         _toggleButton(
//           label: "Within City",
//           isSelected: selectedTravel == TravelType.intracity,
//           onTap: () {
//             setState(() => selectedTravel = TravelType.intracity);
//           },
//         ),
//         _toggleButton(
//           label: "Outstation",
//           isSelected: selectedTravel == TravelType.intercity,
//           onTap: () {
//             setState(() => selectedTravel = TravelType.intercity);
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _toggleContainer({required List<Widget> children}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
//       child: Container(
//         padding: const EdgeInsets.all(5),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: Row(children: children),
//       ),
//     );
//   }
//
//   Widget _toggleButton({
//     required String label,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.orange : Colors.transparent,
//             borderRadius: BorderRadius.circular(25),
//           ),
//           child: Center(
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.black,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // 🔄 Dynamic Content
//   Widget _dynamicContent() {
//     if (selectedService == ServiceType.passenger &&
//         selectedTravel == TravelType.intracity) {
//       return _buildPassengerIntracity();
//     } else if (selectedService == ServiceType.passenger &&
//         selectedTravel == TravelType.intercity) {
//       return _buildPassengerIntercity();
//     } else if (selectedService == ServiceType.parcel &&
//         selectedTravel == TravelType.intracity) {
//       return _buildParcelIntracity();
//     } else {
//       return _buildParcelIntercity();
//     }
//   }
//
//   // 🚶 Passenger + 🏙️ Intracity
//   Widget _buildPassengerIntracity() {
//     return _grid(["Bike", "Mini", "Sedan", "SUV"]);
//   }
//
//   // 🚶 Passenger + 🌍 Intercity
//   Widget _buildPassengerIntercity() {
//     return _grid(["Outstation Cab", "Bus", "Train", "Flight"]);
//   }
//
//   // 📦 Parcel + 🏙️ Intracity
//   Widget _buildParcelIntracity() {
//     return _grid(["Bike Delivery", "Pickup", "Mini Truck"]);
//   }
//
//   // 📦 Parcel + 🌍 Intercity
//   Widget _buildParcelIntercity() {
//     return _grid(["Courier", "Truck", "Door Delivery"]);
//   }
//
//   Widget _grid(List<String> items) {
//     return GridView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: items.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         mainAxisSpacing: 12,
//         crossAxisSpacing: 12,
//         childAspectRatio: 1.2,
//       ),
//       itemBuilder: (_, index) {
//         return Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Center(
//             child: Text(
//               items[index],
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // 🔘 Bottom Button
//   Widget _bottomButton() {
//     String text = "Continue";
//
//     if (selectedService == ServiceType.passenger &&
//         selectedTravel == TravelType.intracity) {
//       text = "Book Ride";
//     } else if (selectedService == ServiceType.passenger &&
//         selectedTravel == TravelType.intercity) {
//       text = "Search Trips";
//     } else if (selectedService == ServiceType.parcel &&
//         selectedTravel == TravelType.intracity) {
//       text = "Send Now";
//     } else {
//       text = "Get Quote";
//     }
//
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: ElevatedButton(
//         onPressed: () {},
//         style: ElevatedButton.styleFrom(
//           minimumSize: const Size(double.infinity, 50),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: Text(text),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

enum ServiceType { passenger, parcel }

enum TravelType { intracity, intercity }

class TravelHomeScreen extends StatefulWidget {
  const TravelHomeScreen({super.key});

  @override
  State<TravelHomeScreen> createState() => _TravelHomeScreenState();
}

class _TravelHomeScreenState extends State<TravelHomeScreen> {
  ServiceType selectedService = ServiceType.passenger;
  TravelType selectedTravel = TravelType.intracity;

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropController = TextEditingController();

  bool isScheduled = false;
  DateTime? scheduledDateTime;

  bool isLoading = false;

  // 📍 Get Current Location
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      pickupController.text = "${position.latitude}, ${position.longitude}";
    });
  }

  // 🗺️ Open Google Maps
  Future<void> _openMap() async {
    final Uri url = Uri.parse("https://www.google.com/maps");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  // 🕒 Pick Schedule
  Future<void> _pickSchedule() async {
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date == null) return;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      scheduledDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Travel")),
      body: Column(
        children: [
          _locationInputs(),
          _serviceToggle(),
          _travelToggle(),

          if (selectedTravel == TravelType.intracity) _scheduleWidget(),

          Expanded(child: _dynamicContent()),
          _bottomButton(),
        ],
      ),
    );
  }

  // 📍 Location Inputs
  Widget _locationInputs() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _textField("Pickup Location", pickupController),
          Row(
            children: [
              TextButton(
                onPressed: _getCurrentLocation,
                child: const Text("Use Current Location"),
              ),
              TextButton(
                onPressed: _openMap,
                child: const Text("Pick from Map"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _textField("Drop Location", dropController),
        ],
      ),
    );
  }

  Widget _textField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        prefixIcon: const Icon(Icons.location_on),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // 🕒 Schedule Widget
  Widget _scheduleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Switch(
            value: isScheduled,
            onChanged: (val) {
              setState(() => isScheduled = val);
            },
          ),
          const Text("Schedule Ride"),
          const Spacer(),
          if (isScheduled)
            TextButton(
              onPressed: _pickSchedule,
              child: Text(
                scheduledDateTime == null
                    ? "Select Time"
                    : DateFormat('dd MMM, hh:mm a').format(scheduledDateTime!),
              ),
            ),
        ],
      ),
    );
  }

  // 🔘 Toggles (same as your code)
  Widget _serviceToggle() => _toggleContainer(
    children: [
      _toggleButton(
        label: "Passengers",
        isSelected: selectedService == ServiceType.passenger,
        onTap: () => setState(() => selectedService = ServiceType.passenger),
      ),
      _toggleButton(
        label: "Parcels",
        isSelected: selectedService == ServiceType.parcel,
        onTap: () => setState(() => selectedService = ServiceType.parcel),
      ),
    ],
  );

  Widget _travelToggle() => _toggleContainer(
    children: [
      _toggleButton(
        label: "Within City",
        isSelected: selectedTravel == TravelType.intracity,
        onTap: () => setState(() => selectedTravel = TravelType.intracity),
      ),
      _toggleButton(
        label: "Outstation",
        isSelected: selectedTravel == TravelType.intercity,
        onTap: () => setState(() => selectedTravel = TravelType.intercity),
      ),
    ],
  );

  Widget _toggleContainer({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: children),
    );
  }

  Widget _toggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          color: isSelected ? Colors.orange : Colors.grey.shade200,
          child: Center(child: Text(label)),
        ),
      ),
    );
  }

  // 🔄 Dynamic Grid
  Widget _dynamicContent() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      children: [
        "Bike",
        "Mini",
        "Sedan",
        "SUV",
      ].map((e) => Card(child: Center(child: Text(e)))).toList(),
    );
  }

  // 🚕 Booking Button
  Widget _bottomButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _handleBooking,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Book Ride"),
      ),
    );
  }

  // 🚀 Booking Logic
  void _handleBooking() async {
    if (pickupController.text.isEmpty || dropController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter all locations")));
      return;
    }

    if (isScheduled && scheduledDateTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select schedule time")));
      return;
    }

    setState(() => isLoading = true);

    // simulate API call
    await Future.delayed(const Duration(seconds: 3));

    setState(() => isLoading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("🚕 Nearby riders found!")));
  }
}
