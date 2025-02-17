
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDdiumc71f32mGif3Cd7ZBjW_vtF1cblug',
    appId: '1:135075403601:web:57384a987b53d8b53ca570',
    messagingSenderId: '135075403601',
    projectId: 'react-firebase-e5fa4',
    authDomain: 'react-firebase-e5fa4.firebaseapp.com',
    databaseURL: 'https://react-firebase-e5fa4-default-rtdb.firebaseio.com',
    storageBucket: 'react-firebase-e5fa4.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyACJYZJXTVLE1SxuEFiNgwxStlCl4WUu14',
    appId: '1:135075403601:android:e2e6ef3dd121737f3ca570',
    messagingSenderId: '135075403601',
    projectId: 'react-firebase-e5fa4',
    databaseURL: 'https://react-firebase-e5fa4-default-rtdb.firebaseio.com',
    storageBucket: 'react-firebase-e5fa4.appspot.com',
  );

}