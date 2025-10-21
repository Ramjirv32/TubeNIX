import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for different platforms
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCmzuNczFYHBlNxD7XjZT1aemxuPAwoob8',
    appId: '1:123456789:web:abcdef',
    messagingSenderId: '123456789',
    projectId: 'tubenix-project',
    authDomain: 'tubenix-project.firebaseapp.com',
    storageBucket: 'tubenix-project.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCmzuNczFYHBlNxD7XjZT1aemxuPAwoob8',
    appId: '1:123456789:android:abcdef',
    messagingSenderId: '123456789',
    projectId: 'tubenix-project',
    storageBucket: 'tubenix-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCmzuNczFYHBlNxD7XjZT1aemxuPAwoob8',
    appId: '1:123456789:ios:abcdef',
    messagingSenderId: '123456789',
    projectId: 'tubenix-project',
    storageBucket: 'tubenix-project.appspot.com',
    iosClientId: '123456789-abcdef.apps.googleusercontent.com',
    iosBundleId: 'com.tubenix.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCmzuNczFYHBlNxD7XjZT1aemxuPAwoob8',
    appId: '1:123456789:ios:abcdef',
    messagingSenderId: '123456789',
    projectId: 'tubenix-project',
    storageBucket: 'tubenix-project.appspot.com',
    iosClientId: '123456789-abcdef.apps.googleusercontent.com',
    iosBundleId: 'com.tubenix.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyCmzuNczFYHBlNxD7XjZT1aemxuPAwoob8',
    appId: '1:123456789:linux:abcdef',
    messagingSenderId: '123456789',
    projectId: 'tubenix-project',
    storageBucket: 'tubenix-project.appspot.com',
  );
}
