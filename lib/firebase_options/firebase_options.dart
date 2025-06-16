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
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDZsgA8c7ner-sZnxFnN22boad_Xcf-5K4',
    appId: '1:754175928853:android:d5b28d0170837b3edf3c1c',
    messagingSenderId: '754175928853',
    projectId: 'bookstore-app-28217',
    storageBucket: 'bookstore-app-28217.firebasestorage.app',
  );
}
