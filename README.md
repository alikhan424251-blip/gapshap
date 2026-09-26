# GapShap App — Setup Guide

## Kya bana hai
Flutter chat app ka poora code tayyar hai:
- **Login:** Phone number + OTP (Firebase Auth)
- **Chat list:** Saari conversations
- **1-to-1 chat:** Real-time messages + photo sharing
- **Groups:** Backend code ready (chat_service.dart mein)

## Chalane ke liye (developer ke liye)

### 1. Zaroori cheezein install karein
- Flutter SDK: https://docs.flutter.dev/get-started/install
- Android Studio (Android ke liye)

### 2. Firebase project banayein (5 min)
1. https://console.firebase.google.com → Create project → **GapShap**
2. Authentication → Sign-in method → **Phone** → Enable
3. Firestore Database → Create → **test mode**
4. Storage → Get started → **test mode**

### 3. App ko Firebase se jorein
```bash
cd gapshap-app
dart pub global activate flutterfire_cli
flutterfire configure --project=gapshap-app
```
Ye command `lib/firebase_options.dart` ko khud update kar degi.

### 4. Packages install + run
```bash
flutter pub get
flutter run
```

## File structure
```
lib/
  main.dart                  - App start
  firebase_options.dart      - Firebase config (auto-generated)
  services/
    auth_service.dart        - OTP login/logout
    chat_service.dart        - Messages, groups, media upload
  screens/
    splash_screen.dart       - Logo screen
    phone_auth_screen.dart   - Phone number input
    otp_screen.dart          - OTP verify
    home_screen.dart         - Chat list
    chat_screen.dart         - 1-to-1 chat
```

## Agle steps
- Group chat ki UI screens banana
- Push notifications (FCM) lagana
- Profile photo + status
- Play Store pe publish
