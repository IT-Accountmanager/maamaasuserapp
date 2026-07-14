import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:maamaas/Services/Auth_service/Apiclient.dart';
import 'configuration _model.dart';

class AppConfigService {
  static final AppConfigService instance = AppConfigService._();

  AppConfigService._();

  final Map<String, AppConfiguration> _configs = {};

  Future<void> loadConfigs() async {
    final response = await ApiClient.get(
      "api/app-config/all",
      service: "subscription",
    );

    debugPrint("CONFIG RESPONSE = ${response.body}");

    final List<dynamic> data = jsonDecode(response.body);

    _configs.clear();

    for (final item in data) {
      final config = AppConfiguration.fromJson(item);
      _configs[config.configKey] = config;
    }
  }

  AppConfiguration? getConfig(String key) {
    return _configs[key];
  }

  List<AppConfiguration> get allConfigs => _configs.values.toList();

  bool isEnabled(String key) {
    final config = _configs[key];

    debugPrint("Config Check => $key : ${config?.enable}");

    return config?.enable ?? false;
  }

  String getValue(String key) {
    return _configs[key]?.configValue ?? '';
  }

  int getIntValue(String key) {
    return int.tryParse(_configs[key]?.configValue ?? '') ?? 0;
  }

  double getDoubleValue(String key) {
    return double.tryParse(_configs[key]?.configValue ?? '') ?? 0;
  }
}
