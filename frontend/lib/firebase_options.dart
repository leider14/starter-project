import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAdSP6Mq0C42SzRhStHDhCF3keBQeUjxkw',
    appId: '1:210413327992:android:97db684a90b598b9ef7f8d',
    messagingSenderId: '210413327992',
    projectId: 'hwyyiikjknaytutuyd',
    storageBucket: 'hwyyiikjknaytutuyd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDIHKxsvaGyukflFVO8sErLqkXJhMq-_TI',
    appId: '1:210413327992:ios:43586b61a336d161ef7f8d',
    messagingSenderId: '210413327992',
    projectId: 'hwyyiikjknaytutuyd',
    storageBucket: 'hwyyiikjknaytutuyd.firebasestorage.app',
    iosBundleId: 'com.noticias.yodev',
  );
}
