import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Profile Operations
  Future<void> createUserProfile(Map<String, dynamic> userData) async {
    try {
      String uid = _auth.currentUser!.uid;
      await _db.collection('users').doc(uid).set({
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating user profile: $e');
    }
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      String uid = _auth.currentUser!.uid;
      await _db.collection('users').doc(uid).update({
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user profile: $e');
    }
  }

  // Restaurant Operations
  Future<void> createRestaurant(Map<String, dynamic> restaurantData) async {
    try {
      await _db.collection('restaurants').add({
        ...restaurantData,
        'ownerId': _auth.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating restaurant: $e');
    }
  }

  Stream<QuerySnapshot> getRestaurants() {
    return _db.collection('restaurants').snapshots();
  }

  Future<DocumentSnapshot> getRestaurant(String restaurantId) async {
    return await _db.collection('restaurants').doc(restaurantId).get();
  }

  // Menu Operations
  Future<void> addMenuItem(String restaurantId, Map<String, dynamic> menuItem) async {
    try {
      await _db.collection('restaurants').doc(restaurantId).collection('menu').add({
        ...menuItem,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding menu item: $e');
    }
  }

  Stream<QuerySnapshot> getMenuItems(String restaurantId) {
    return _db.collection('restaurants').doc(restaurantId).collection('menu').snapshots();
  }

  Future<void> updateMenuItem(String restaurantId, String menuItemId, Map<String, dynamic> updates) async {
    try {
      await _db.collection('restaurants').doc(restaurantId).collection('menu').doc(menuItemId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating menu item: $e');
    }
  }

  // Order Operations
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      await _db.collection('orders').add({
        ...orderData,
        'userId': _auth.currentUser!.uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating order: $e');
    }
  }

  Stream<QuerySnapshot> getUserOrders() {
    return _db.collection('orders')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }

  // Search Operations
  Future<QuerySnapshot> searchRestaurants(String query) async {
    return await _db.collection('restaurants')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
  }

  // Favorites Operations
  Future<void> addToFavorites(String restaurantId) async {
    try {
      String uid = _auth.currentUser!.uid;
      await _db.collection('users').doc(uid).collection('favorites').doc(restaurantId).set({
        'restaurantId': restaurantId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String restaurantId) async {
    try {
      String uid = _auth.currentUser!.uid;
      await _db.collection('users').doc(uid).collection('favorites').doc(restaurantId).delete();
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
    }
  }

  Stream<QuerySnapshot> getUserFavorites() {
    return _db.collection('users').doc(_auth.currentUser!.uid).collection('favorites').snapshots();
  }
}