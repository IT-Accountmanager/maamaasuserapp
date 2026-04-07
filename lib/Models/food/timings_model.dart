class Timing {
  final String day;
  final String startTime;
  final String lastTime;

  Timing({
    required this.day,
    required this.startTime,
    required this.lastTime,
  });

  factory Timing.fromJson(Map<String, dynamic> json) {
    return Timing(
      day: json['day'],
      startTime: json['startTime'],
      lastTime: json['lastTime'],
    );
  }
}