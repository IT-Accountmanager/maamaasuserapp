class Package {
  final int id;
  final int vendorId;
  final String packageName;
  final String packageType;
  final String companyLogo;
  final String companyName;
  final String image;
  final double totalPrice;
  final List<PackageItem> items;

  Package({
    required this.id,
    required this.vendorId,
    required this.packageName,
    required this.packageType,
    required this.companyLogo,
    required this.companyName,
    required this.image,
    required this.totalPrice,
    required this.items,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      packageName: json['packageName'] ?? '',
      packageType: json['packageType'] ?? '',
      companyLogo: json['companyLogo'] ?? '',
      companyName: json['companyName'] ?? '',
      image: json['image'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => PackageItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'packageName': packageName,
      'packageType': packageType,
      'companyLogo': companyLogo,
      'companyName': companyName,
      'image': image,
      'totalPrice': totalPrice,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class PackageItem {
  final int id;
  final String itemName;
  final double price;

  PackageItem({
    required this.id,
    required this.itemName,
    required this.price,
  });

  factory PackageItem.fromJson(Map<String, dynamic> json) {
    return PackageItem(
      id: json['id'] ?? 0,
      itemName: json['itemName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'price': price,
    };
  }
}
