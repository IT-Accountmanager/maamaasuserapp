class vendorteam {
  final int teamId;
  final String name;
  final String designation;
  final String description;
  final String image;

  vendorteam({
    required this.teamId,
    required this.name,
    required this.description,
    required this.image,
    required this.designation,
  });
  factory vendorteam.fromJson(Map<String, dynamic> json) {
    return vendorteam(
      teamId: json['teamId'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      designation: json['designation'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
