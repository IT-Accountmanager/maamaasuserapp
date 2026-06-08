import 'dart:convert';

import 'package:maamaas/Services/Auth_service/Apiclient.dart';

import 'configuration _model.dart';

class AppConfigService {
  static final Map<String, AppConfiguration> _configs = {};

  static Future<void> loadConfigs() async {

    final endpoint = "app-config/all";
    final response = await ApiClient.get(endpoint ,service: "subscription");

    print(response);
    print(response.runtimeType);

    final configs = (jsonDecode(response.body) as List)
        .map((e) => AppConfiguration.fromJson(e))
        .toList();

    _configs.clear();

    for (final config in configs) {
      _configs[config.configKey] = config;
    }
  }

  static List<AppConfiguration> get allConfigs =>
      _configs.values.toList();

  static AppConfiguration? get(String key) =>
      _configs[key];
}