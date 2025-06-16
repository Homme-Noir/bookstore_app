import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data.dart';
import '../models/address.dart';

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phoneNumber;
  final List<String> addresses;
  final List<String> paymentMethods;
  final bool isAdmin;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phoneNumber,
    this.addresses = const [],
    this.paymentMethods = const [],
    this.isAdmin = false,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      addresses: List<String>.from(data['addresses'] ?? []),
      paymentMethods: List<String>.from(data['paymentMethods'] ?? []),
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'addresses': addresses,
      'paymentMethods': paymentMethods,
      'isAdmin': isAdmin,
    };
  }
}

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'users';

  // Get current user profile
  Stream<UserProfile?> getCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection(_collection)
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  // Create or update user profile
  Future<void> updateUserProfile(UserProfile profile) {
    return _firestore.collection(_collection).doc(profile.id).set(
          profile.toMap(),
          SetOptions(merge: true),
        );
  }
  
  // Remove shipping address
  Future<void> removeShippingAddress(String userId, String address) {
    return _firestore.collection(_collection).doc(userId).update({
      'addresses': FieldValue.arrayRemove([address]),
    });
  }

  // Add payment method
  Future<void> addPaymentMethod(String userId, String paymentMethod) {
    return _firestore.collection(_collection).doc(userId).update({
      'paymentMethods': FieldValue.arrayUnion([paymentMethod]),
    });
  }

  // Remove payment method
  Future<void> removePaymentMethod(String userId, String paymentMethod) {
    return _firestore.collection(_collection).doc(userId).update({
      'paymentMethods': FieldValue.arrayRemove([paymentMethod]),
    });
  }

  // Update profile photo
  Future<void> updateProfilePhoto(String userId, String photoUrl) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .update({'photoUrl': photoUrl});
  }

  // Check if user is admin
  Future<bool> isAdmin(String userId) async {
    final doc = await _firestore.collection(_collection).doc(userId).get();
    return doc.exists ? (doc.data()?['isAdmin'] ?? false) : false;
  }

  Future<UserData?> getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserData.fromMap(doc.data()!);
  }

  Future<void> createUserData(UserData userData) async {
    await _firestore
        .collection('users')
        .doc(userData.id)
        .set(userData.toMap());
  }

  Future<void> updateUserData(UserData userData) async {
    await _firestore
        .collection('users')
        .doc(userData.id)
        .update(userData.toMap());
  }

  Future<void> addShippingAddress(
      String userId, ShippingAddress address) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .add(address.toMap());
  }

  Future<void> updateShippingAddress(
      String userId, String addressId, ShippingAddress address) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(addressId)
        .update(address.toMap());
  }

  Future<void> deleteShippingAddress(String userId, String addressId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  Stream<List<ShippingAddress>> getShippingAddresses(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShippingAddress.fromMap(doc.data()))
            .toList());
  }
} 