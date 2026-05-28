// File generated for Firebase project civicroadprod (CivicRoad).
// Values extracted from google-services.json and GoogleService-Info.plist.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for CivicRoad.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVF6boSkzjgz00Hm7mFZse9MEBWCJ1syM',
    appId: '1:345147549098:android:70333827066a815b85b7d3',
    messagingSenderId: '345147549098',
    projectId: 'civicroadprod',
    storageBucket: 'civicroadprod.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCbxJakZP-86QlpBDCg6jBCvX6-Ao9hnx8',
    appId: '1:345147549098:ios:bf97d586259a701085b7d3',
    messagingSenderId: '345147549098',
    projectId: 'civicroadprod',
    storageBucket: 'civicroadprod.firebasestorage.app',
    iosClientId: '345147549098-6m6ptn9um3tm3ah1j5a196cimtgp1g2e.apps.googleusercontent.com',
    iosBundleId: 'com.example.niddepoule',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCbxJakZP-86QlpBDCg6jBCvX6-Ao9hnx8',
    appId: '1:345147549098:ios:bf97d586259a701085b7d3',
    messagingSenderId: '345147549098',
    projectId: 'civicroadprod',
    storageBucket: 'civicroadprod.firebasestorage.app',
    iosClientId: '345147549098-6m6ptn9um3tm3ah1j5a196cimtgp1g2e.apps.googleusercontent.com',
    iosBundleId: 'com.example.niddepoule',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAXVFtrkeVU7oQE-A35SGHfzZaomns0iRU',
    appId: '1:345147549098:web:01d607f65b60394685b7d3',
    messagingSenderId: '345147549098',
    projectId: 'civicroadprod',
    authDomain: 'civicroadprod.firebaseapp.com',
    storageBucket: 'civicroadprod.firebasestorage.app',
    measurementId: 'G-1P02MYPBY3',
  );

  /// Web — relancez `flutterfire configure --platforms=web` si besoin d'un appId web dedie.

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAXVFtrkeVU7oQE-A35SGHfzZaomns0iRU',
    appId: '1:345147549098:web:8f971e36bdac34f885b7d3',
    messagingSenderId: '345147549098',
    projectId: 'civicroadprod',
    authDomain: 'civicroadprod.firebaseapp.com',
    storageBucket: 'civicroadprod.firebasestorage.app',
    measurementId: 'G-ZS5BB1CN2F',
  );

}