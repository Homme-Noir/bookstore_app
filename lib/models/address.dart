class ShippingAddress {
  final String name;
  final String phoneNumber;
  final String flatNumber;
  final String area;
  final String landmark;
  final String city;
  final String state;
  final String pincode;

  const ShippingAddress({
    required this.name,
    required this.phoneNumber,
    required this.flatNumber,
    required this.area,
    required this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      flatNumber: map['flatNumber'] as String,
      area: map['area'] as String,
      landmark: map['landmark'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
      pincode: map['pincode'] as String,
    );
  }

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      flatNumber: json['flatNumber'] as String,
      area: json['area'] as String,
      landmark: json['landmark'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'flatNumber': flatNumber,
      'area': area,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  ShippingAddress copyWith({
    String? name,
    String? phoneNumber,
    String? flatNumber,
    String? area,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
  }) {
    return ShippingAddress(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      flatNumber: flatNumber ?? this.flatNumber,
      area: area ?? this.area,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShippingAddress &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          phoneNumber == other.phoneNumber &&
          flatNumber == other.flatNumber &&
          area == other.area &&
          landmark == other.landmark &&
          city == other.city &&
          state == other.state &&
          pincode == other.pincode;

  @override
  int get hashCode =>
      name.hashCode ^
      phoneNumber.hashCode ^
      flatNumber.hashCode ^
      area.hashCode ^
      landmark.hashCode ^
      city.hashCode ^
      state.hashCode ^
      pincode.hashCode;

  @override
  String toString() {
    return '''$name
$flatNumber, $area, $landmark
$city, $state, $pincode
Phone: $phoneNumber''';
  }
}
