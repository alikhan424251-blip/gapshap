// Firebase configuration — GapShap project (gapshap-bfdf9)
// Android app registered in Firebase console as com.gapshap.app (2026-09-26)

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web abhi support nahi hai');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Ye platform support nahi hai');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAfGGZr8mSvYOI25DlpG-ML5Cd0XT0YRoQ',
    appId: '1:447354255822:android:58dc3f169407b61ff2d39f',
    messagingSenderId: '447354255822',
    projectId: 'gapshap-bfdf9',
    storageBucket: 'gapshap-bfdf9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAfGGZr8mSvYOI25DlpG-ML5Cd0XT0YRoQ',
    appId: 'APNA_IOS_APP_ID_YAHAN',
    messagingSenderId: '447354255822',
    projectId: 'gapshap-bfdf9',
    storageBucket: 'gapshap-bfdf9.firebasestorage.app',
    iosBundleId: 'com.gapshap.app',
  );
}
