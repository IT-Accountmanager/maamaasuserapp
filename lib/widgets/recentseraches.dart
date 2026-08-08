import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecentLocationService {
  static const String key = "recent_locations";

  static Future<void> saveLocation(String address) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> locations = prefs.getStringList(key) ?? [];

    // Remove duplicate
    locations.remove(address);

    // Add latest at top
    locations.insert(0, address);

    // Keep only last 10
    if (locations.length > 10) {
      locations = locations.take(10).toList();
    }

    await prefs.setStringList(key, locations);
  }

  static Future<List<String>> getRecentLocations() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }
}