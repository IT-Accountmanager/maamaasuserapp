class CateringProvider {
  final String name;
  final String imageUrl;
  final double rating;
  final int reviews;
  final List<String> cuisines;
  final String priceRange;
  final String location;
  final String description;

  CateringProvider({
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.cuisines,
    required this.priceRange,
    required this.location,
    required this.description,
  });
}
