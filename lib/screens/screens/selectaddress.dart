class SelectedAddress {
  final String city;
  final String state;
  final String pincode;
  final String landmark;
  final String subLocality;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final int addressId;
  final String category;

  const SelectedAddress({
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.landmark = '',
    this.subLocality = '',
    this.fullAddress = '',
    this.latitude = 0,
    this.longitude = 0,
    this.addressId = 0,
    this.category = '',
  });
}
