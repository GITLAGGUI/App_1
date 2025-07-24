# 🔐 Firebase Security Setup Guide

## ⚠️ IMPORTANT: Secure Configuration Required

This repository contains a Flutter app with Firebase integration. For security reasons, sensitive Firebase configuration files are **NOT** included in this public repository.

## 🚀 Setup Instructions

### 1. Firebase Project Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing project
3. Enable the following services:
   - Authentication (Email/Password, Google, Apple, Facebook)
   - Firestore Database
   - Storage

### 2. Download Configuration Files

#### For Android:
1. In Firebase Console → Project Settings → General
2. Add Android app with package name: `com.example.hotplate`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

#### For iOS:
1. In Firebase Console → Project Settings → General
2. Add iOS app with bundle ID: `com.example.hotplate`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

### 3. Configure Firebase Security Rules

#### Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Recipes can be read by authenticated users
    match /recipes/{recipeId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == resource.data.authorId;
    }
  }
}
```

#### Storage Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. API Key Security (Recommended)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to APIs & Services → Credentials
3. Find your API keys and click edit
4. Add restrictions:
   - **Application restrictions**: Set to Android/iOS apps
   - **API restrictions**: Limit to required APIs only

### 5. Environment Variables (Optional - Advanced)

For additional security, you can use environment variables:

Create `.env` file (already in .gitignore):
```
FIREBASE_API_KEY=your_api_key_here
FIREBASE_PROJECT_ID=your_project_id_here
FIREBASE_STORAGE_BUCKET=your_storage_bucket_here
```

## 🛡️ Security Checklist

- [ ] Firebase configuration files are in .gitignore
- [ ] Firestore security rules are configured
- [ ] Storage security rules are configured
- [ ] API keys are restricted in Google Cloud Console
- [ ] Authentication is properly implemented
- [ ] No sensitive data in source code

## 📱 Template Files

Template configuration files are provided:
- `android/app/google-services.json.template`
- `ios/Runner/GoogleService-Info.plist.template`

Replace placeholder values with your actual Firebase configuration.

## 🔧 Development Setup

1. Clone this repository
2. Follow Firebase setup instructions above
3. Run `flutter pub get`
4. Run `flutter run`

## 📞 Support

If you encounter any issues with Firebase setup, refer to:
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

---

**⚠️ Never commit actual Firebase configuration files to version control!**