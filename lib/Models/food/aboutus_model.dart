class AboutUsModel {
  final String aboutUs;
  final String image;
  final List<String> images;
  final String mission;
  final String vision;
  final String missionImage;
  final String visionImage;

  AboutUsModel({
    required this.aboutUs,
    required this.image,
    required this.images,
    required this.mission,
    required this.vision,
    required this.missionImage,
    required this.visionImage,
  });

  factory AboutUsModel.fromJson(Map<String, dynamic> json) {
    return AboutUsModel(
      aboutUs: json['aboutUs'] ?? '',
      image: json['image'] ?? '',

      // ✅ FIX HERE
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) {
                if (e is String) return e;
                if (e is Map && e['mediaUrl'] != null) {
                  return e["mediaUrl"] as String;
                }
                return '';
              })
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],

      mission: json['mission'] ?? '',
      vision: json['vision'] ?? '',
      missionImage: json['missionImage'] ?? '',
      visionImage: json['visionImage'] ?? '',
    );
  }

  List<String> get allImages {
    return [...images];
  }
}
