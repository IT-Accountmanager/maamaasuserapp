class AppConfiguration {
  final int id;
  final String configKey;
  final String configValue;
  final bool enable;
  final String title;
  final String description;

  AppConfiguration({
    required this.id,
    required this.configKey,
    required this.configValue,
    required this.enable,
    required this.title,
    required this.description,
  });

  factory AppConfiguration.fromJson(Map<String, dynamic> json) {
    return AppConfiguration(
      id: json['id'],
      configKey: json['configKey'],
      configValue: json['configValue'] ?? '',
      enable: json['enable'] ?? false,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
