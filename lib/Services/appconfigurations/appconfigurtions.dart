// class AppConfigManager {
//   static final AppConfigManager _instance =
//   AppConfigManager._internal();
//
//   factory AppConfigManager() => _instance;
//
//   AppConfigManager._internal();
//
//   final Map<String, AppConfigurationDto> _configs = {};
//
//   Future<void> initialize() async {
//     final response = await ApiService.get('/app-configs');
//
//     final configs = (response.data as List)
//         .map((e) => AppConfigurationDto.fromJson(e))
//         .toList();
//
//     _configs.clear();
//
//     for (final config in configs) {
//       _configs[config.configKey] = config;
//     }
//   }
//
//   AppConfigurationDto? get(String key) {
//     return _configs[key];
//   }
//
//   bool isEnabled(String key) {
//     return _configs[key]?.enable ?? false;
//   }
//
//   String getValue(String key, {String defaultValue = ''}) {
//     return _configs[key]?.configValue ?? defaultValue;
//   }
// }