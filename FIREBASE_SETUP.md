# HotPlate Firebase Backend Setup Guide

## ✅ Completed Setup

### 1. Firebase Project Configuration
- Project ID: `hotplate-4b9e6`
- All platforms configured (Android, iOS, Web, macOS, Windows)
- Firebase options updated and consistent

### 2. Firebase Services Added
- **Firebase Core** - Basic Firebase functionality
- **Firebase Auth** - User authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File uploads
- **Firebase Analytics** - App analytics
- **Firebase Crashlytics** - Crash reporting
- **Firebase Messaging** - Push notifications

### 3. Authentication Methods
- Email/Password authentication
- Google Sign-In
- Facebook Login
- Anonymous authentication support

### 4. Backend Services Created
- `AuthService` - Complete authentication management
- `DatabaseService` - Firestore database operations
- `StorageService` - File upload and management

### 5. Security Rules
- Firestore security rules configured
- User-based data access control
- Restaurant and order management rules

## 🚀 How to Use the Backend Services

### Authentication Example
```dart
import 'package:hotplate/services/auth_service.dart';

final AuthService _authService = AuthService();

// Sign in with email
await _authService.signInWithEmailAndPassword(email, password);

// Sign in with Google
await _authService.signInWithGoogle();

// Sign out
await _authService.signOut();
```

### Database Example
```dart
import 'package:hotplate/services/database_service.dart';

final DatabaseService _dbService = DatabaseService();

// Create user profile
await _dbService.createUserProfile({
  'name': 'John Doe',
  'email': 'john@example.com',
  'phone': '+1234567890',
});

// Create restaurant
await _dbService.createRestaurant({
  'name': 'My Restaurant',
  'address': '123 Main St',
  'cuisine': 'Filipino',
});

// Create order
await _dbService.createOrder({
  'restaurantId': 'restaurant_id',
  'items': [
    {'name': 'Adobo', 'price': 150, 'quantity': 2}
  ],
  'total': 300,
});
```

### Storage Example
```dart
import 'package:hotplate/services/storage_service.dart';
import 'dart:io';

final StorageService _storageService = StorageService();

// Upload profile image
File imageFile = File('path/to/image.jpg');
String? imageUrl = await _storageService.uploadProfileImage(imageFile);

// Upload restaurant image
String? restaurantImageUrl = await _storageService.uploadRestaurantImage(
  imageFile, 
  'restaurant_id'
);
```

## 📱 Next Steps

### 1. Enable Authentication Methods in Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `hotplate-4b9e6`
3. Go to Authentication > Sign-in method
4. Enable:
   - Email/Password
   - Google
   - Facebook
   - Anonymous (for testing)

### 2. Configure Google Sign-In
1. Download `google-services.json` for Android
2. Download `GoogleService-Info.plist` for iOS
3. Add SHA-1 fingerprint for Android

### 3. Configure Facebook Login
1. Create Facebook App
2. Add Facebook App ID to Firebase
3. Configure OAuth redirect URLs

### 4. Set up Push Notifications
1. Configure FCM in Firebase Console
2. Add notification handling in app
3. Test push notifications

### 5. Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### 6. Test Your Setup
```bash
# Run the app
flutter run

# Run tests
flutter test

# Check for issues
flutter analyze
```

## 🔧 Firebase Emulator Setup (for Development)
```bash
# Start emulators
firebase emulators:start

# Available emulators:
# - Firestore: http://localhost:8080
# - Auth: http://localhost:9099
# - Storage: http://localhost:9199
```

## 📊 Analytics and Monitoring
- **Firebase Analytics** - Automatically tracks user engagement
- **Firebase Crashlytics** - Automatically reports crashes
- **Performance Monitoring** - Can be added later if needed

## 🛡️ Security Best Practices
1. Never expose API keys in client code
2. Use Firestore security rules for data protection
3. Validate user input on both client and server
4. Implement proper error handling
5. Use Firebase App Check for additional security

Your Firebase backend is now fully configured and ready for development! 🎉