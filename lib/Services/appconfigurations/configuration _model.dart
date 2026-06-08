class AppConfiguration {
  final int id;
  final String configKey;
  final String configValue;
  final bool enable;
  final String description;
  final String title;

  AppConfiguration({
    required this.id,
    required this.configKey,
    required this.configValue,
    required this.enable,
    required this.description,
    required this.title,
  });

  factory AppConfiguration.fromJson(Map<String, dynamic> json) {
    return AppConfiguration(
      id: json['id'],
      configKey: json['configKey'],
      configValue: json['configValue'],
      enable: json['enable'],
      description: json['description'],
      title: json['title'],
    );
  }
}