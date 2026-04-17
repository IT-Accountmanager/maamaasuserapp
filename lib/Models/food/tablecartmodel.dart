class TableCartModel {
  int cartId;
  int userId;
  int vendorId;
  String orderType;
  int seatingId;
  String tableCode;
  final List<CartItem> cartItems;
  double subtotal;
  double gstTotal;
  double platformCharges;
  double grandTotal;
  double packingTotal;
  double serviceCharges;
  double? deliveryCharges; // ✅ nullable
  double cgst;
  double sgst;
  String? couponCode;
  double? discountAmount;
  final int couponId;
  List<int> itemId;

  TableCartModel({
    required this.cartId,
    required this.userId,
    required this.vendorId,
    required this.orderType,
    required this.seatingId,
    required this.tableCode,
    required this.cartItems,
    required this.subtotal,
    required this.gstTotal,
    required this.platformCharges,
    required this.grandTotal,
    required this.packingTotal,
    required this.serviceCharges,
    this.deliveryCharges,
    required this.cgst,
    required this.sgst,
    this.couponCode,
    this.discountAmount,
    required this.itemId,
    required this.couponId,
  });

  factory TableCartModel.fromJson(Map<String, dynamic> json) {
    return TableCartModel(
      cartId: json['cartId'] ?? 0,
      userId: json['userId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      orderType: json['orderType'] ?? '', // ✅ FIX
      seatingId: json['seatingId'] ?? 0,
      tableCode: json['tableCode'] ?? '', // ✅ FIX
      cartItems: (json['cartItems'] as List? ?? [])
          .map((item) => CartItem.fromJson(item))
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      gstTotal: (json['gstTotal'] ?? 0).toDouble(),
      platformCharges: (json['platformCharges'] ?? 0).toDouble(),
      grandTotal: (json['grandTotal'] ?? 0).toDouble(),
      packingTotal: (json['packingTotal'] ?? 0).toDouble(),
      serviceCharges: (json['serviceCharges'] ?? 0).toDouble(),
      deliveryCharges: json['deliveryCharges']?.toDouble(),
      cgst: (json['cgst'] ?? 0).toDouble(),
      sgst: (json['sgst'] ?? 0).toDouble(),
      couponCode: json['couponCode'],
      discountAmount: json['discountAmount']?.toDouble(),
      itemId: [],
      couponId: json['couponId'] ?? 0,
    );
  }
}

class CartItem {
  int itemId;
  double price;
  String dishName;
  int dishId;
  double gst;
  double packingCharges;
  int quantity;
  String chefType;
  double totalPrice;
  String? note;
  String? orderStatus;
  String? dishImage; // ✅ nullable
  String? orderType; // ✅ nullable

  CartItem.empty()
    : itemId = 0,
      price = 0.0,
      dishName = '',
      dishId = 0,
      gst = 0.0,
      packingCharges = 0.0,
      quantity = 0,
      chefType = '',
      totalPrice = 0.0,
      note = '',
      orderStatus = '',
      dishImage = '',
      orderType = ''; // <-- ✅ initialize here

  CartItem({
    required this.itemId,
    required this.price,
    required this.dishName,
    required this.dishId,
    required this.gst,
    required this.packingCharges,
    required this.quantity,
    required this.chefType,
    required this.totalPrice,
    this.note,
    this.orderStatus,
    this.dishImage,
    this.orderType,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: json['itemId'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      dishName: json['dishName'] ?? '', // ✅ FIX
      dishId: json['dishId'] ?? 0,
      gst: (json['gst'] ?? 0).toDouble(),
      packingCharges: (json['packingCharges'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      chefType: json['chefType'] ?? '', // ✅ FIX
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      note: json['note'],
      orderStatus: json['orderStatus'],
      dishImage: json['dishImage'],
      orderType: json['orderType'], // nullable → OK
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'price': price,
      'dishName': dishName,
      'dishId': dishId,
      'gst': gst,
      'packingCharges': packingCharges,
      'quantity': quantity,
      'chefType': chefType,
      'totalPrice': totalPrice,
      'note': note,
      'orderStatus': orderStatus,
      'dishImage': dishImage,
      'orderType': orderType,
    };
  }
}
