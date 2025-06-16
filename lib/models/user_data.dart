class UserData {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final List<String> addresses;
  final List<String> paymentMethods;
  final bool isAdmin;

  const UserData({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.addresses = const [],
    this.paymentMethods = const [],
    this.isAdmin = false,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      photoUrl: map['photoUrl'] as String?,
      addresses: List<String>.from(map['addresses'] ?? []),
      paymentMethods: List<String>.from(map['paymentMethods'] ?? []),
      isAdmin: map['isAdmin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'addresses': addresses,
      'paymentMethods': paymentMethods,
      'isAdmin': isAdmin,
    };
  }

  UserData copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    List<String>? addresses,
    List<String>? paymentMethods,
    bool? isAdmin,
  }) {
    return UserData(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
