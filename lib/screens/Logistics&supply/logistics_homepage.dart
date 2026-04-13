import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'finding_driver_screen.dart';
import 'loaction.dart';

class LogisticsScreen extends StatefulWidget {
  @override
  _LogisticsScreenState createState() => _LogisticsScreenState();
}

class _LogisticsScreenState extends State<LogisticsScreen>
    with SingleTickerProviderStateMixin {
  String selectedService = "Passenger";
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, Set<String>> tempFilters = {};
  String? selectedVertical;
  String? selectedSubCategory;
  String? selectedSubCat;
  Map<String, Set<String>> appliedFilters = {};

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      print("📸 Image picked: ${image.path}");
    }
  }

  Future<void> _startRecording() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      print("🎤 Start recording audio...");
    } else {
      print("❌ Microphone permission denied");
    }
  }

  final Map<String, Map<String, List<String>>> filterOptionsMap = {
    'Food & Beverages': {
      'Location': ['current Location', 'Add location', 'Home','office','others'],
      // 'Bengaluru': ['Koramangala', 'Whitefield', 'Indiranagar'],
      // 'Chennai': ['T Nagar', 'Velachery', 'Anna Nagar'],
      // 'Mumbai': ['Andheri', 'Bandra', 'Juhu'],
      'Outlet Type': [
        'Restaurants',
        'Cafés & Coffee Shops',
        'Hotels (with Dining)',
        'Cloud Kitchens',
        'Street Food / Fast Food',
        'Bakeries & Desserts',
        'Juice & Shake Bars',
      ],

      'Service Type': [
        'Dine-In',
        'Quick Dine',
        'Takeaway',
        'Delivery',
      ],
      'Cuisine': [
        'Indian',
        'Chinese',
        'Italian',
        'Continental',
        'American / Fast Food',
        'Japanese',
        'Mexican',
        'Middle Eastern',
        'Vegan / Vegetarian',
        'Healthy / Organic',
      ],
      'Special Features': [
        'Pure Veg',
        'Vegan Friendly',
        'Halal / Jain Food',
        'Alcohol Served',
        'Outdoor Seating',
        'Family Friendly',
        'Pet Friendly',
        'Live Music / Entertainment',
        'WiFi Available',
      ],
      'Delivery Options': [
        'Free Delivery',
        'Express (≤30 mins)',
        'Minimum Order Requirement',
      ],
    },

    'Catering & Services': {
      'Service Type': [
        'Event Catering (Weddings, Corporate, Parties)',
        'Home Catering / Private Chef',
        'Tiffin / Meal Subscription',
        'Outdoor Catering',
        'Food Truck Catering',
      ],
      'Cuisine Options': [
        'Multi-Cuisine',
        'Regional / Traditional',
        'International (Italian, Chinese, Continental, etc.)',
        'Vegan / Healthy / Organic',
      ],
      'Capacity & Scale': [
        'Small Events (≤50 guests)',
        'Medium Events (50–200 guests)',
        'Large Events (200–1000 guests)',
        'Mega Events (1000+ guests)',
      ],
      'Pricing Models': [
        'Per Plate Pricing',
        'Buffet Packages',
        'Custom Menu Pricing',
        'Inclusive Packages (Food + Staff + Setup)',
      ],
      'Add-On Services': [
        'Decoration & Setup',
        'Live Counters (BBQ, Chaat, Pasta, etc.)',
        'Bartending / Beverage Service',
        'Service Staff & Waiters',
        'Music / Entertainment Add-Ons',
      ],
      'Availability': [
        'Instant Booking',
        'Advance Booking Required',
        'Festival / Seasonal Availability',
      ],
    },

    'Logistics & Supply': {
      'Service Type': [
        'Freight & Cargo',
        'Courier & Express Delivery',
        'Warehousing & Storage',
        'Cold Chain Logistics',
        'Last-Mile Delivery',
        'E-Commerce Fulfillment',
        'Bulk Material Transport',
        'International Shipping (Air, Sea, Rail)',
      ],
      'Goods Category': [
        'Food & Beverages (Perishable)',
        'Fresh Produce / Grocery',
        'Industrial & Machinery',
        'Pharmaceuticals / Medical',
        'Consumer Electronics',
        'Fashion & Apparel',
        'Documents & Small Parcels',
        'Furniture & Heavy Goods',
      ],
      'Vehicle Type': [
        'Bike / Scooter (Last Mile)',
        'Small Van / Pickup',
        'Tempo / Mini-Truck',
        'Light / Medium / Heavy Trucks',
        'Container Trucks',
        'Refrigerated Vehicles',
        'Tankers (Liquids, Fuel, Chemicals)',
      ],
      'Delivery Timelines': [
        'Express (≤2 hrs)',
        'Same Day',
        'Next Day',
        'Scheduled Delivery',
        'Standard (2–5 days)',
        'International (7–15 days)',
      ],
      'Compliance & Security': [
        'Verified Provider',
        'Insurance Included',
        'GPS Tracking',
        'Temperature-Controlled Vehicles',
        'Safety Certified',
      ],
    },

    'Fresh & Groceries': {
      'Store Type': [
        'Supermarkets',
        'Hypermarkets',
        'Local Kirana Stores',
        'Organic Stores',
        'Dairy & Milk Shops',
        'Butcher Shops',
        'Online-Only Grocery',
      ],
      'Product Categories': [
        'Fruits & Vegetables',
        'Dairy & Eggs',
        'Meat, Fish & Poultry',
        'Grains, Rice & Pulses',
        'Oils, Spices & Condiments',
        'Packaged Foods & Snacks',
        'Beverages (Juice, Tea, Coffee, Soft Drinks)',
        'Bakery & Fresh Breads',
        'Organic / Health Food',
      ],
      'Delivery Slots': [
        'Express (≤2 hrs)',
        'Same Day',
        'Next Day',
        'Scheduled Delivery',
      ],
      'Special Filters': [
        'Organic Certified',
        'Pesticide-Free',
        'Locally Sourced',
        'Seasonal Picks',
        'Imported Products',
      ],
      'Delivery Options': ['Free Delivery', 'Minimum Order Requirement'],
    },
  };

  void _openFilterBottomSheet() {
    tempFilters = {
      for (var entry in appliedFilters.entries)
        entry.key: Set.from(entry.value),
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  Expanded(
                    child: selectedVertical == null
                        ? Row(
                      children: [
                        // LEFT: Title
                        Container(
                          width: 150,
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Text(
                            "Select Vertical",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // RIGHT: List of Verticals
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(8),
                            children: filterOptionsMap.keys.map((
                                vertical,
                                ) {
                              final isSelected =
                                  vertical == selectedVertical;
                              return ListTile(
                                title: Text(vertical),
                                selected: isSelected,
                                onTap: () {
                                  setModalState(() {
                                    selectedVertical = vertical;
                                    selectedSubCat = null; // reset subCat
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    )
                        : Row(
                      children: [
                        // LEFT: Subcategories
                        Container(
                          width: 150,
                          color: Colors.grey[200],
                          child: ListView(
                            children: filterOptionsMap[selectedVertical]!
                                .keys
                                .map((subCat) {
                              final isSelected =
                                  subCat == selectedSubCat;
                              return ListTile(
                                title: Text(
                                  subCat,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.black,
                                  ),
                                ),
                                tileColor: isSelected
                                    ? Colors.white
                                    : Colors.grey[200],
                                onTap: () {
                                  setModalState(() {
                                    selectedSubCat =
                                        subCat; // now persists
                                  });
                                },
                              );
                            })
                                .toList(),
                          ),
                        ),

                        // RIGHT: Options of selected subcategory
                        Expanded(
                          child: selectedSubCat == null
                              ? const Center(
                            child: Text("Select a subcategory"),
                          )
                              : ListView(
                            padding: const EdgeInsets.all(8),
                            children: filterOptionsMap[selectedVertical]![selectedSubCat]!
                                .map((opt) {
                              final isChecked =
                                  tempFilters[selectedSubCat]
                                      ?.contains(opt) ??
                                      false;
                              return CheckboxListTile(
                                title: Text(opt),
                                value: isChecked,
                                onChanged: (checked) {
                                  setModalState(() {
                                    tempFilters.putIfAbsent(
                                      selectedSubCat!,
                                          () => <String>{},
                                    );
                                    if (checked == true) {
                                      tempFilters[selectedSubCat]!
                                          .add(opt);
                                    } else {
                                      tempFilters[selectedSubCat]!
                                          .remove(opt);
                                    }
                                  });
                                },
                              );
                            })
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempFilters.clear();
                                selectedVertical = null;
                                selectedSubCat = null;
                              });
                            },
                            child: const Text("Reset"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                appliedFilters = {
                                  for (var entry in tempFilters.entries)
                                    entry.key: Set.from(entry.value),
                                };
                              });
                              Navigator.pop(context);
                            },
                            child: const Text("Apply"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      // appBar: customappBar(
      //   searchController: _searchController,
      //   onCameraTap: _openCamera,
      //   onMicTap: _startRecording,
      //   onProfileTap: () => ProfileDrawer.open(context), // ✅ reusable
      // ),
      body: SafeArea(
        child: Column(
          children: [
            // VideoPreviewContainer(),
            Container(
              height: 100,
              padding: EdgeInsets.symmetric(vertical: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  serviceCard("Travel", Icons.directions_car, 0),
                  SizedBox(width: 12),
                  serviceCard("Parcel", Icons.local_shipping, 1),
                  SizedBox(width: 12),
                  serviceCard("Driver", Icons.person, 2),
                  SizedBox(width: 12),
                  serviceCard("Goods", Icons.handyman, 3),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: getServiceForm(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // bottomNavigationBar: home_footer(
      //   onFilterTap: () => _openFilterBottomSheet(),
      // ),
    );
  }

  Widget serviceCard(String title, IconData icon, int index) {
    final isSelected = selectedService == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedService = title;
          _animationController.reset();
          _animationController.forward();
        });
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 90,
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFB15DC6) : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Color(0xFFB15DC6).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Color(0xFFB15DC6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? Color(0xFFB15DC6) : Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getServiceForm() {
    switch (selectedService) {
      case "Travel":
        return PassengerForm(key: ValueKey("Travel"));
      case "Parcel":
        return ParcelForm(key: ValueKey("Parcel"));
      case "Driver":
        return DriverHireForm(key: ValueKey("Driver"));
      case "Goods":
        return PorterForm(key: ValueKey("Goods"));
      default:
        return Center(child: Text("Select a service"));
    }
  }
}



class PassengerForm extends StatefulWidget {
  PassengerForm({Key? key}) : super(key: key);

  @override
  _PassengerFormState createState() => _PassengerFormState();
}

class _PassengerFormState extends State<PassengerForm> {
  final pickupController = TextEditingController();
  final dropController = TextEditingController();
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _dropFocusNode = FocusNode();
  String? selectedCategory;
  String? selectedVehicle;
  final TextEditingController noofpeopleController = TextEditingController();
  int noOfPeople = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pickupFocusNode.dispose();
    _dropFocusNode.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildForm(
          context,
          icon: Icons.directions_car,
          children: [
            peopleInput(setState),
            SizedBox(height: 16),
            LocationField(
              label: "Pickup Location",
              controller: pickupController,
              icon: Icons.my_location,
              recentLocationsProvider: () => ["Home", "Office", "Airport"],
              onLocationSelected: (loc) {
                print("Pickup: $loc");
              },
            ),
            SizedBox(height: 10),
            LocationField(
              label: "Drop Location",
              controller: dropController,
              icon: Icons.location_on,
              recentLocationsProvider: () => ["Mall", "Railway Station"],
              onLocationSelected: (loc) {
                print("Drop: $loc");
              },
            ),

            SizedBox(height: 16),

            Text(
              "If you want to schedule your Travel?",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            DateTimePickerField(),
            SizedBox(height: 16),
            vehicleTypeSelector(),
          ],
        ),
      ],
    );
  }

  Widget peopleInput(void Function(void Function()) refresh) {
    return TextField(
      controller: noofpeopleController,
      decoration: InputDecoration(
        labelText: "Enter no of People",
        hintText: "Type here...",
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        noOfPeople = int.tryParse(value) ?? 0;
        refresh(() {}); // refresh UI when user types
      },
    );
  }

  Widget vehicleTypeSelector() {
    final List<Map<String, dynamic>> vehicleCategories = [
      {"category": "Two Wheeler", "symbol": "🏍️", "Price": "100"},
      {"category": "Three Wheeler", "symbol": "🛺", "Price": "200"},
      {"category": "Four Wheeler", "symbol": "🚗", "Price": "250"},
    ];

    return StatefulBuilder(
      builder: (context, setState) {
        // 🔹 Filter logic
        List<Map<String, dynamic>> filteredCategories = vehicleCategories;

        if (noOfPeople == 1) {
          filteredCategories = vehicleCategories; // all vehicles
        } else if (noOfPeople == 2 || noOfPeople == 3) {
          filteredCategories = vehicleCategories
              .where(
                (c) =>
                    c["category"] == "Three Wheeler" ||
                    c["category"] == "Four Wheeler",
              )
              .toList();
        } else if (noOfPeople >= 4) {
          filteredCategories = vehicleCategories
              .where((c) => c["category"] == "Four Wheeler")
              .toList();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Vehicle Type",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Column(
              children: filteredCategories.map((category) {
                final isSelected = selectedCategory == category["category"];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category["category"] as String;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFB15DC6)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFB15DC6)
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isSelected
                              ? Colors.white
                              : Colors.grey[200],
                          child: Text(
                            category["symbol"] as String,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          category["category"] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          category["Price"] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class LocationEntryScreen extends StatefulWidget {
  final String type;
  final List<String> recentLocations;
  final Function(String) onLocationSelected;

  const LocationEntryScreen({
    required this.type,
    required this.recentLocations,
    required this.onLocationSelected,
  });

  @override
  _LocationEntryScreenState createState() => _LocationEntryScreenState();
}

class _LocationEntryScreenState extends State<LocationEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];
  bool _showRecentLocations = true;

  @override
  void initState() {
    super.initState();
    _suggestions = widget.recentLocations;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> _generateSuggestions(String query) {
    if (query.isEmpty) {
      _showRecentLocations = true;
      return widget.recentLocations;
    }

    _showRecentLocations = false;
    final recentMatches = widget.recentLocations
        .where(
          (location) => location.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    final mockApiSuggestions = [
      '$query, City Center',
      '$query, Downtown',
      '$query, Commercial Area',
    ];

    return [...recentMatches, ...mockApiSuggestions];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select ${widget.type} Location",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 24),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Search Field
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search for area, street, landmark...",
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                suffixIcon: IconButton(
                  icon: Icon(Icons.my_location, color: const Color(0xFFB15DC6)),
                  onPressed: () {
                    widget.onLocationSelected("Current Location");
                    Navigator.pop(context);
                  },
                  tooltip: "Pick from map",
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _suggestions = _generateSuggestions(value);
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Map Selection Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFB15DC6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFB15DC6).withOpacity(0.3),
              ),
            ),
            child: TextButton.icon(
              onPressed: () async {
                final selectedLocation = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapLocationSelector(
                      onLocationSelected: (String location) {
                        Navigator.pop(context, location);
                      },
                    ),
                  ),
                );

                if (selectedLocation != null) {
                  // You can setState here to show the selected location
                  print("Selected location: $selectedLocation");
                }
              },
              icon: Icon(Icons.map_outlined, color: const Color(0xFFB15DC6)),
              label: Text(
                "Select from Map",
                style: TextStyle(
                  color: const Color(0xFFB15DC6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Section Title
          Text(
            _showRecentLocations ? "Recent Locations" : "Search Results",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Suggestions List
          Expanded(
            child: _suggestions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No locations found",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Try searching with different keywords",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _suggestions.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final location = _suggestions[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB15DC6).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _showRecentLocations
                                ? Icons.history
                                : Icons.location_on,
                            color: const Color(0xFFB15DC6),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          location,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: _showRecentLocations
                            ? null
                            : Text(
                                "Tap to select this location",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                        onTap: () {
                          widget.onLocationSelected(location);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ParcelForm extends StatefulWidget {
  ParcelForm({Key? key}) : super(key: key);

  @override
  _ParcelFormState createState() => _ParcelFormState();
}

class _ParcelFormState extends State<ParcelForm> {
  final pickupController = TextEditingController();
  final dropController = TextEditingController();
  String? selectedParcelType;
  double _weightValue = 2.0;
  String? selectedCategory;
  String? selectedVehicle;
  double? selectedWeight;

  @override
  Widget build(BuildContext context) {
    bool allDetailsFilled =
        selectedParcelType != null &&
        selectedWeight != null &&
        pickupController.text.isNotEmpty &&
        dropController.text.isNotEmpty;
    return buildForm(
      context,
      icon: Icons.local_shipping,
      children: [
        parcelTypeSelector(),
        SizedBox(height: 16),
        weightSelector(),
        LocationField(
          label: "Pickup Location",
          controller: pickupController,
          icon: Icons.my_location,
          recentLocationsProvider: () => ["Home", "Office", "Airport"],
          onLocationSelected: (loc) {
            print("Pickup: $loc");
          },
        ),
        SizedBox(height: 10),
        LocationField(
          label: "Drop Location",
          controller: dropController,
          icon: Icons.location_on,
          recentLocationsProvider: () => ["Mall", "Railway Station"],
          onLocationSelected: (loc) {
            print("Drop: $loc");
          },
        ),
        SizedBox(height: 8),
        Text(
          "If you want to schedule your Ride?",
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        SizedBox(height: 8),
        DateTimePickerField(),
        SizedBox(height: 10),
        if (allDetailsFilled) vehicleTypeSelector(),
      ],
    );
  }

  Widget parcelTypeSelector() {
    final parcelTypes = [
      {"type": "Documents", "icon": Icons.description},
      {"type": "Small Box", "icon": Icons.inventory_2},
      {"type": "Large", "icon": Icons.local_shipping},
      {"type": "Fragile", "icon": Icons.warning_amber},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Parcel Type",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedParcelType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          hint: const Text("Select parcel type"),
          items: parcelTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type["type"] as String,
              child: Row(
                children: [
                  Icon(
                    type["icon"] as IconData,
                    size: 20,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 10),
                  Text(type["type"] as String),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedParcelType = value;
            });
          },
        ),
      ],
    );
  }

  Widget weightSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Weight (kg)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFFB15DC6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFB15DC6).withOpacity(0.3)),
              ),
              child: Text(
                "${_weightValue.toStringAsFixed(1)} kg",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB15DC6),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Color(0xFFB15DC6),
            inactiveTrackColor: Colors.grey[300],
            trackHeight: 6,
            thumbColor: Colors.white,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 12,
              disabledThumbRadius: 12,
              elevation: 4,
            ),
            overlayColor: Color(0xFFB15DC6).withOpacity(0.2),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
            valueIndicatorColor: Color(0xFFB15DC6),
            valueIndicatorTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            showValueIndicator: ShowValueIndicator.always,
          ),
          child: Slider(
            value: _weightValue,
            min: 0.5,
            max: 30,
            divisions:
                59, // 0.5 increments from 0.5 → 30 (30/0.5 = 60 steps -1)
            label: "${_weightValue.toStringAsFixed(1)} kg",
            onChanged: (value) {
              setState(() {
                _weightValue = value;
              });
            },
            onChangeEnd: (value) {
              setState(() {
                selectedWeight = value; // ✅ store finalized weight
              });
              print("✅ Final weight selected: $value kg");
            },
          ),
        ),
      ],
    );
  }

  Widget vehicleTypeSelector() {
    final List<Map<String, dynamic>> vehicleCategories = [
      {"category": "walk", "symbol": "🚶", "Price": "50"},
      {"category": "bicycle", "symbol": "🚲", "Price": "70"},
      {"category": "Two Wheeler", "symbol": "🏍️", "Price": "100"},
      {"category": "Three Wheeler", "symbol": "🛺", "Price": "200"},
      {"category": "Four Wheeler", "symbol": "🚗", "Price": "250"},
    ];

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Vehicle Type",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Column(
              children: vehicleCategories.map((category) {
                final isSelected = selectedCategory == category["category"];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category["category"] as String;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFB15DC6)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFB15DC6)
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isSelected
                              ? Colors.white
                              : Colors.grey[200],
                          child: Text(
                            category["symbol"] as String,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          category["category"] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        Text(
                          category["Price"] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class DriverHireForm extends StatefulWidget {
  DriverHireForm({Key? key}) : super(key: key);

  @override
  _DriverHireFormState createState() => _DriverHireFormState();
}

class _DriverHireFormState extends State<DriverHireForm> {
  String? selectedDuration;
  String? selectedVehicleType;

  @override
  Widget build(BuildContext context) {
    return buildForm(
      context,
      // title: "Hire a Driver",
      icon: Icons.person,
      children: [
        durationSelector(),
        SizedBox(height: 16),
        DateTimePickerField(),
        SizedBox(height: 16),
        VehicleAndExperienceSelector(
          onSelectionChanged: (vehicle, experience) {
            print("Selected Vehicle: $vehicle, Experience: $experience");
          },
        ),
      ],
    );
  }

  Widget durationSelector() {
    final durationOptions = [
      {"label": "Hourly", /*"price": "₹200/hr",*/ "value": "Hourly"},
      {"label": "Daily", /* "price": "₹1500/day",*/ "value": "Daily"},
      {"label": "Weekly", /*"price": "₹10000/week",*/ "value": "Weekly"},
      {"label": "Monthly", /*"price": "₹30000/month",*/ "value": "Monthly"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Duration",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 12),

        // Responsive ToggleButtons
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isSmallScreen = screenWidth < 400;

            return ToggleButtons(
              isSelected: durationOptions
                  .map((option) => selectedDuration == option["value"])
                  .toList(),
              onPressed: (index) {
                setState(() {
                  selectedDuration = durationOptions[index]["value"] as String;
                });
              },
              borderRadius: BorderRadius.circular(12),
              borderColor: Colors.grey[300],
              selectedBorderColor: Color(0xFFB15DC6),
              color: Colors.black87,
              selectedColor: Color(0xFFB15DC6),
              fillColor: Color(0xFFB15DC6).withOpacity(0.1),
              constraints: BoxConstraints(
                minHeight: 50,
                minWidth: isSmallScreen ? 80 : 100,
              ),
              children: durationOptions.map((option) {
                return Container(
                  width: isSmallScreen ? 80 : 100,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 10 : 12,
                    horizontal: 4,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        option["label"] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),

        // Selected duration indicator
        if (selectedDuration != null) ...[
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFB15DC6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFB15DC6).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Text(
                  "Selected: $selectedDuration",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB15DC6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class VehicleAndExperienceSelector extends StatefulWidget {
  final Function(String vehicle, String experience)? onSelectionChanged;

  const VehicleAndExperienceSelector({Key? key, this.onSelectionChanged})
    : super(key: key);

  @override
  State<VehicleAndExperienceSelector> createState() =>
      _VehicleAndExperienceSelectorState();
}

class _VehicleAndExperienceSelectorState
    extends State<VehicleAndExperienceSelector> {
  String? selectedVehicle;
  String? selectedExperience;

  final List<String> vehicleTypes = ["Car", "Bike", "Auto", "Van", "Truck"];
  final List<String> experiences = [
    "0–1 years",
    "2–5 years",
    "5–10 years",
    "10+ years",
  ];

  void _notifyChange() {
    if (widget.onSelectionChanged != null &&
        selectedVehicle != null &&
        selectedExperience != null) {
      widget.onSelectionChanged!(selectedVehicle!, selectedExperience!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vehicle Type Dropdown
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Select Vehicle Type",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          value: selectedVehicle,
          items: vehicleTypes
              .map(
                (vehicle) =>
                    DropdownMenuItem(value: vehicle, child: Text(vehicle)),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedVehicle = value;
            });
            _notifyChange();
          },
        ),
        const SizedBox(height: 16),

        // Driving Experience Dropdown
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Driving Experience",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          value: selectedExperience,
          items: experiences
              .map((exp) => DropdownMenuItem(value: exp, child: Text(exp)))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedExperience = value;
            });
            _notifyChange();
          },
        ),
      ],
    );
  }
}

class PorterForm extends StatefulWidget {
  PorterForm({Key? key}) : super(key: key);

  @override
  _PorterFormState createState() => _PorterFormState();
}

class _PorterFormState extends State<PorterForm> {
  final pickupController = TextEditingController();
  final dropController = TextEditingController();
  int selectedPorters = 1;
  String? selectedGoodsType;
  String? selectedVehicleType;

  @override
  Widget build(BuildContext context) {
    return buildForm(
      context,
      // title: "Book Goods Service",
      icon: Icons.handyman,
      children: [
        goodsTypeSelector(),
        SizedBox(height: 16),
        LocationField(
          label: "Pickup Location",
          controller: pickupController,
          icon: Icons.my_location,
          recentLocationsProvider: () => ["Home", "Office", "Airport"],
          onLocationSelected: (loc) {
            print("Pickup: $loc");
          },
        ),
        SizedBox(height: 10),
        LocationField(
          label: "Drop Location",
          controller: dropController,
          icon: Icons.location_on,
          recentLocationsProvider: () => ["Mall", "Railway Station"],
          onLocationSelected: (loc) {
            print("Drop: $loc");
          },
        ),
        SizedBox(height: 16),
        DateTimePickerField(),
        SizedBox(height: 16),
        vehicleTypeSelector(), // Added vehicle selection
      ],
    );
  }

  Widget porterCounter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Number of Porters",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Porters: $selectedPorters", style: TextStyle(fontSize: 16)),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle, color: Color(0xFFB15DC6)),
                  onPressed: () {
                    if (selectedPorters > 1) {
                      setState(() {
                        selectedPorters--;
                      });
                    }
                  },
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Color(0xFFB15DC6)),
                  onPressed: () {
                    if (selectedPorters < 5) {
                      setState(() {
                        selectedPorters++;
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: selectedPorters / 5,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB15DC6)),
        ),
        SizedBox(height: 4),
        Text(
          "₹${selectedPorters * 300}/hour",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget goodsTypeSelector() {
    final goodsTypes = ["Household", "Office", "Furniture", "Other"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Type of Goods",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          value: selectedGoodsType,
          items: goodsTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedGoodsType = value;
            });
          },
          isExpanded: true,
          hint: Text("Select goods type"),
        ),
      ],
    );
  }

  // New vehicle type selector for mover vehicles
  Widget vehicleTypeSelector() {
    final vehicleTypes = [
      {
        "type": "Pickup Truck",
        "icon": Icons.local_shipping,
        "capacity": "Upto 1500 kg",
        "price": "₹800",
      },
      {
        "type": "Mini Truck",
        "icon": Icons.fire_truck,
        "capacity": "1500-2500 kg",
        "price": "₹1200",
      },
      {
        "type": "Medium Truck",
        "icon": Icons.local_shipping,
        "capacity": "2500-5000 kg",
        "price": "₹2000",
      },
      {
        "type": "Large Truck",
        "icon": Icons.fire_truck,
        "capacity": "5000-10000 kg",
        "price": "₹3500",
      },
      {
        "type": "Tempo",
        "icon": Icons.directions_bus,
        "capacity": "Upto 1000 kg",
        "price": "₹600",
      },
      {
        "type": "Container Truck",
        "icon": Icons.local_shipping,
        "capacity": "10000+ kg",
        "price": "₹5000",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Choose Vehicle Type",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          "Select appropriate vehicle based on your goods",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemCount: vehicleTypes.length,
          itemBuilder: (context, index) {
            final vehicle = vehicleTypes[index];
            final isSelected = selectedVehicleType == vehicle["type"];

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedVehicleType = vehicle["type"] as String;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(0xFFB15DC6).withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Color(0xFFB15DC6) : Colors.grey[300]!,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFFB15DC6)
                                : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            vehicle["icon"] as IconData,
                            size: 18,
                            color: isSelected
                                ? Colors.white
                                : Color(0xFFB15DC6),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vehicle["type"] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isSelected
                                  ? Color(0xFFB15DC6)
                                  : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      vehicle["capacity"] as String,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      vehicle["price"] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

Widget buildForm(
  BuildContext context, {
  // required String title,
  required IconData icon,
  required List<Widget> children,
}) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        //   children: [
        //     Icon(icon, color: Color(0xFFB15DC6), size: 28),
        //     SizedBox(width: 8),
        //     Text(
        //       title,
        //       style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        //     ),
        //   ],
        // ),
        // SizedBox(height: 20),
        ...children,
        SizedBox(height: 30),
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FindingDriverScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFB15DC6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                "Book",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget locationField(
  String label,
  TextEditingController controller,
  IconData icon,
) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: Icon(icon, color: Color(0xFFB15DC6)),
      filled: true,
      fillColor: Colors.grey[50],
    ),
  );
}

class DateTimePickerField extends StatefulWidget {
  const DateTimePickerField({super.key});

  @override
  State<DateTimePickerField> createState() => _DateTimePickerFieldState();
}

class _DateTimePickerFieldState extends State<DateTimePickerField> {
  DateTime? selectedDateTime;

  /// Pick custom date & time
  Future<void> _pickCustomDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    setState(() {
      selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  /// Pick only time but fix the base date (today/tomorrow)
  Future<void> _pickTimeForBaseDate(DateTime baseDate) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    setState(() {
      selectedDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Date & Time",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // 📅 Date + ⏰ Time stacked on left
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Row
                  GestureDetector(
                    onTap: _pickCustomDateTime,
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          selectedDateTime == null
                              ? "" // show nothing if no date is selected
                              : DateFormat(
                                  "dd-MM-yyyy",
                                ).format(selectedDateTime!),
                          style: TextStyle(
                            fontSize: 15,
                            color: selectedDateTime == null
                                ? Colors.grey[500]
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Time Row (only if selected)
                  if (selectedDateTime != null)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('hh:mm a').format(selectedDateTime!),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const Spacer(),

              // TODAY button
              TextButton(
                onPressed: () => _pickTimeForBaseDate(today),
                child: const Text("TODAY"),
              ),

              // TOMORROW button
              TextButton(
                onPressed: () => _pickTimeForBaseDate(tomorrow),
                child: const Text("TOMORROW"),
              ),
            ],
          ),
        ),

        // Show selected Time separately below
      ],
    );
  }
}

class LocationField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Function(String location)? onLocationSelected;
  final List<String> Function()? recentLocationsProvider;

  const LocationField({
    Key? key,
    required this.label,
    required this.controller,
    required this.icon,
    this.onLocationSelected,
    this.recentLocationsProvider,
  }) : super(key: key);

  @override
  State<LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<LocationField> {
  Color _getIconColor() {
    if (widget.label.toLowerCase().contains('pickup')) {
      return const Color(0xFF4CAF50); // Green for pickup
    } else {
      return const Color(0xFFB15DC6); // Purple for drop
    }
  }

  String _getHintText() {
    if (widget.label.toLowerCase().contains('pickup')) {
      return "Where should we pick up from?";
    } else {
      return "Where would you like to go?";
    }
  }

  String _getFieldType() {
    return widget.label.toLowerCase().contains('pickup') ? 'pickup' : 'drop';
  }

  void _openLocationPicker(String type) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return LocationEntryScreen(
          type: type,
          recentLocations: widget.recentLocationsProvider?.call() ?? [],
          onLocationSelected: (location) {
            setState(() {
              widget.controller.text = location;
            });

            if (widget.onLocationSelected != null) {
              widget.onLocationSelected!(location);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          hintText: _getHintText(),
          prefixIcon: Container(
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Icon(widget.icon, color: _getIconColor()),
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    setState(() {
                      widget.controller.clear();
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.search, size: 18),
                  onPressed: () => _openLocationPicker(_getFieldType()),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: const TextStyle(fontSize: 15),
        onTap: () => _openLocationPicker(_getFieldType()),
        readOnly: true,
      ),
    );
  }
}

class ImageBanner extends StatefulWidget {
  const ImageBanner({super.key});

  @override
  State<ImageBanner> createState() => _ImageBannerState();
}

class _ImageBannerState extends State<ImageBanner> {
  final List<String> bannerImages = [
    "assets/gallery-img-3.jpg",
    "assets/gallery-img-5.jpg",
    "assets/gallery-img-6.jpg",
  ];

  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: bannerImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(
                bannerImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerImages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: _currentPage == index ? 12 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.blue
                    : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
