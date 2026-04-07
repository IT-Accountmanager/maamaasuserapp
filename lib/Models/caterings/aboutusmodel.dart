class AboutUsModel {
  final String aboutUs;
  final String image;
  final String image1;
  final String image2;
  final String image3;
  final String image4;
  final String mission;
  final String vision;

  AboutUsModel({
    required this.aboutUs,
    required this.image,
    required this.image1,
    required this.image2,
    required this.image3,
    required this.image4,
    required this.mission,
    required this.vision,
  });

  factory AboutUsModel.fromJson(Map<String, dynamic> json) {
    return AboutUsModel(
      aboutUs: json['aboutUs'] ?? '',
      image: json['image'] ?? '',
      image1: json['image1'] ?? '',
      image2: json['image2'] ?? '',
      image3: json['image3'] ?? '',
      image4: json['image4'] ?? '',
      mission: json['mission']?? '',
      vision: json['vision']?? '',
    );
  }
  List<String> get allImages => [
    // image,
    image1,
    image2,
    image3,
    image4,
  ].where((img) => img.isNotEmpty).toList();
}
