import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload user profile image
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      String uid = _auth.currentUser!.uid;
      String fileName = 'profile_images/$uid.jpg';
      
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  // Upload restaurant image
  Future<String?> uploadRestaurantImage(File imageFile, String restaurantId) async {
    try {
      String fileName = 'restaurant_images/$restaurantId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading restaurant image: $e');
      return null;
    }
  }

  // Upload menu item image
  Future<String?> uploadMenuItemImage(File imageFile, String restaurantId, String menuItemId) async {
    try {
      String fileName = 'menu_images/$restaurantId/$menuItemId.jpg';
      
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading menu item image: $e');
      return null;
    }
  }

  // Upload multiple images
  Future<List<String>> uploadMultipleImages(List<File> imageFiles, String folderPath) async {
    List<String> downloadUrls = [];
    
    try {
      for (int i = 0; i < imageFiles.length; i++) {
        String fileName = '$folderPath/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        
        Reference ref = _storage.ref().child(fileName);
        UploadTask uploadTask = ref.putFile(imageFiles[i]);
        
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        
        downloadUrls.add(downloadUrl);
      }
    } catch (e) {
      debugPrint('Error uploading multiple images: $e');
    }
    
    return downloadUrls;
  }

  // Delete image
  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }

  // Get download URL
  Future<String?> getDownloadURL(String filePath) async {
    try {
      Reference ref = _storage.ref().child(filePath);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error getting download URL: $e');
      return null;
    }
  }

  // Upload with progress tracking
  Future<String?> uploadImageWithProgress(
    File imageFile, 
    String filePath,
    Function(double)? onProgress,
  ) async {
    try {
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(imageFile);
      
      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        if (onProgress != null) {
          onProgress(progress);
        }
      });
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image with progress: $e');
      return null;
    }
  }
}