# GapShap — Developer Build Guide

Flutter chat app (Pakistan ki apni chat app). Backend 100% ready, code complete.
Sirf APK build karna baqi hai.

## 1. Firebase — pehle se tayyar (kuch nahi karna)

- **Project:** GapShap — ID `gapshap-bfdf9`
  Console: https://console.firebase.google.com/project/gapshap-bfdf9/overview
- **Authentication → Phone provider:** enabled (OTP login)
- **Firestore Database:** live, test mode, location `asia-south1` (Mumbai)
- **Android app registered:** package `com.gapshap.app`, nickname "GapShap Android"
- **Config values** already wired into `lib/firebase_options.dart` (apiKey, appId,
  messagingSenderId, projectId, storageBucket) — Dart-only init, `google-services.json`
  ki zaroorat nahi.
- **Cloud Storage:** NOT enabled — Blaze billing plan chahiye (owner ke paas card nahi).
  `firebase_storage` dependency maujood hai lekin media upload runtime par fail hoga
  jab tak Storage enable na ho. Text chat fully functional hai.

## 2. Build karne ka tareeqa (kisi bhi normal PC par)

```bash
cd gapshap-app
flutter pub get
flutter build apk --debug        # testing ke liye
# ya
flutter build apk --release      # production ke liye (signing key chahiye)
```

APK milega: `build/app/outputs/flutter-apk/app-debug.apk`

Requirements: Flutter stable SDK + Android SDK (platform-tools, build-tools,
Android platform, licenses accepted).

## 3. Zaroori notes

- **SHA-1:** Firebase app registration ke waqt SHA-1 skip hui thi. Production se
  pehle apne release keystore ki SHA-1 Firebase console → Project settings →
  Android app mein add karein. Debug builds mein phone auth reCAPTCHA fallback
  par chal jayega.
- **Firestore rules:** abhi test mode mein hain (open). Production se pehle
  proper security rules likhein.
- **Package name:** `com.gapshap.app` (android/app/build.gradle mein set hai —
  Firebase mein registered app se match karta hai, change na karein).

## 4. App structure

```
lib/
  main.dart                  # entry point, Firebase.initializeApp
  firebase_options.dart      # Firebase config (wired)
  services/
    auth_service.dart        # phone OTP login
    chat_service.dart        # Firestore chat logic
  screens/
    splash_screen.dart
    phone_auth_screen.dart
    otp_screen.dart
    home_screen.dart         # chat list
    chat_screen.dart         # 1-to-1 chat
```

## 5. Features (v1)

Phone OTP login, 1-to-1 chat, group chat, online/last seen + ticks, notifications.
Photo/video sharing: code maujood hai, Storage enable hote hi chalega.
