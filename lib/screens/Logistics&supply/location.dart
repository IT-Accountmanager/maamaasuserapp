import 'package:flutter/material.dart';

class MapLocationSelector extends StatefulWidget {
  final Function(String) onLocationSelected;

  const MapLocationSelector({Key? key, required this.onLocationSelected}) : super(key: key);

  @override
  _MapLocationSelectorState createState() => _MapLocationSelectorState();
}

class _MapLocationSelectorState extends State<MapLocationSelector> {
  List<String> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Location selector"),),
      body: Column(
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),

                  // Search header
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Select Location from Map",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        // Simulated map
                        Container(
                          margin: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map, size: 50, color: Colors.blue[300]),
                                SizedBox(height: 8),
                                Text("Interactive Map View",
                                    style: TextStyle(color: Colors.blue[700])),
                                SizedBox(height: 16),
                                Text("Drag to move, pinch to zoom",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                        ),

                        // Map pin
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.85 / 2 - 30,
                          left: MediaQuery.of(context).size.width / 2 - 15,
                          child: Icon(Icons.location_pin, size: 30, color: Colors.red),
                        ),

                        // Current location button
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: FloatingActionButton(
                            mini: true,
                            backgroundColor: Colors.white,
                            onPressed: () {},
                            child: Icon(Icons.my_location, color: Color(0xFF6A1B9A)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search results
                  if (_searchResults.isNotEmpty)
                    Container(
                      height: 150,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.location_on, color: Colors.grey),
                            title: Text(_searchResults[index]),
                            onTap: () {
                              widget.onLocationSelected(_searchResults[index]);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),

                  // Confirm selection button
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onLocationSelected("Selected Map Location");
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6A1B9A),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Confirm Location",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ],
              ),
            )
          )
        ],
      ),
    );

  }

  List<String> _generateMapSearchResults(String query) {
    final locations = [
      "${query} Main Road",
      "${query} Circle",
      "${query} Cross",
      "${query} Nagar",
      "${query} Layout",
      "${query} Extension",
      "${query} Colony",
    ];
    return locations;
  }
}