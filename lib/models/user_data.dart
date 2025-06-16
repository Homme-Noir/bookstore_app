class UserData {
  final String id;
  final String email;
  final String name;

  UserData({required this.id, required this.email, required this.name});

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(id: map['id'], email: map['email'], name: map['name']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email, 'name': name};
  }
}
