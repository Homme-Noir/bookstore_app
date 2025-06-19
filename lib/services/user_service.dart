import '../mock_data.dart';
import '../models/user_data.dart';
import '../models/address.dart';

class UserService {
  List<UserData> getUsers() {
    return MockData.users;
  }

  UserData? getUserById(String id) {
    for (final user in MockData.users) {
      if (user.id == id) return user;
    }
    return null;
  }

  Stream<List<ShippingAddress>> getShippingAddresses(String userId) async* {
    // Return empty or mock addresses for now
    yield [];
  }

  Future<void> updateUserProfile(
      {String? userId,
      String? name,
      String? email,
      String? photoUrl,
      String? address}) async {
    // No-op for mock
  }

  // Add more mock methods as needed.
}
