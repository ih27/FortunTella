// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  static late String androidApiKey;
  static late String iosApiKey;

  static Future<void> loadEnv() async {
    await dotenv.load(fileName: ".env");
    androidApiKey = dotenv.env['FIREBASE_ANDROID_API_KEY']!;
    iosApiKey = dotenv.env['FIREBASE_IOS_API_KEY']!;
  }

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: androidApiKey,
    appId: '1:40432187550:android:5f901e6c801dbb8666638f',
    messagingSenderId: '40432187550',
    projectId: 'fort-un-tella',
    storageBucket: 'fort-un-tella.appspot.com',
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: iosApiKey,
    appId: '1:40432187550:ios:77ffd0ff003e653966638f',
    messagingSenderId: '40432187550',
    projectId: 'fort-un-tella',
    storageBucket: 'fort-un-tella.appspot.com',
    iosBundleId: 'com.pp.fortuntella',
  );
}
