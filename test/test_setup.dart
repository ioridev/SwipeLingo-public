import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Callback = void Function(MethodCall call);

Future<void> setupFirebaseCoreMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock Firebase Core
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_core'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'Firebase#initializeCore') {
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'fake-api-key',
              'appId': 'fake-app-id',
              'messagingSenderId': 'fake-sender-id',
              'projectId': 'fake-project-id',
            },
            'pluginConstants': {},
          }
        ];
      }
      if (methodCall.method == 'Firebase#initializeApp') {
        return {
          'name': methodCall.arguments['appName'],
          'options': methodCall.arguments['options'],
          'pluginConstants': {},
        };
      }
      return null;
    },
  );

  // Mock Firebase Auth
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_auth'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'Auth#registerIdTokenListener') {
        return <String, dynamic>{};
      }
      if (methodCall.method == 'Auth#registerAuthStateListener') {
        return <String, dynamic>{};
      }
      if (methodCall.method == 'Auth#currentUser') {
        return <String, dynamic>{
          'uid': 'test-uid',
          'email': 'test@example.com',
          'isAnonymous': true,
        };
      }
      return null;
    },
  );

  // Mock Cloud Firestore
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/cloud_firestore'),
    (MethodCall methodCall) async {
      return <String, dynamic>{};
    },
  );

  // Initialize Firebase
  await Firebase.initializeApp();
}

Future<void> initializeMockFirebase() async {
  await setupFirebaseCoreMocks();
}