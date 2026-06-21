import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'services/anti_procrastination_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/app_config.dart';

/// Configures Firebase services to use local Emulator Suite when running in Debug mode.
void configureEmulators() {
  if (kDebugMode) {
    // 10.0.2.2 is the special IP that redirects to localhost of the host machine from the Android Emulator.
    final String host = (!kIsWeb && Platform.isAndroid)
        ? '10.0.2.2'
        : 'localhost';

    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);

    developer.log(
      'Firebase Emulators configured to point to $host (Firestore: 8080, Functions: 5001)',
      name: 'FCMInitialization',
    );
  }
}

/// Top-level background message handler.
///
/// Annotated with `@pragma('vm:entry-point')` to instruct the Flutter compiler/tree-shaker
/// that this method is invoked from native code (Java/Kotlin/Obj-C/Swift) and must not be removed,
/// as background messages run in a completely separate Dart isolate.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized inside the background isolate
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyFakeKeyForLocalTestingPurposes123",
      appId: "1:1234567890:android:1234567890",
      messagingSenderId: "1234567890",
      projectId: "demo-anti-procrastination",
    ),
  );

  developer.log(
    'Received message in background: ${message.messageId}',
    name: 'FCMBackgroundHandler',
  );

  // Parse and check if the payload matches our anti-procrastination SOS message
  final data = message.data;
  if (data['type'] == 'SOS_LAZY_STATE') {
    final String? targetUserId = data['targetUserId'];
    final String? delayTime = data['delayTime'];

    developer.log(
      'SOS ALERT RECEIVED! Target User: $targetUserId has been inactive for $delayTime minutes.',
      name: 'FCMBackgroundHandler',
      error: {
        'type': 'SOS_LAZY_STATE',
        'targetUserId': targetUserId,
        'delayTime': delayTime,
      },
    );
  }
}

void main() async {
  // 1. Ensure Flutter bindings are initialized before calling async operations
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase Core
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyFakeKeyForLocalTestingPurposes123",
      appId: "1:1234567890:android:1234567890",
      messagingSenderId: "1234567890",
      projectId: "demo-anti-procrastination",
    ),
  );

  // Configure Local Emulators if in Debug Mode
  configureEmulators();

  // 3. Register the background messaging handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 4. Request permissions (for Android 13+ POST_NOTIFICATIONS runtime permission & iOS APNS/FCM alerts)
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  try {
    final NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false, // Set to false to ask user explicitly
    );

    developer.log(
      'Notification permission status: ${settings.authorizationStatus}',
      name: 'FCMInitialization',
    );
  } catch (e) {
    developer.log(
      'Failed to request permission (possibly already in progress during hot-restart): $e',
      name: 'FCMInitialization',
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Antigravity App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF67E8F9),
          brightness: Brightness.dark,
        ),
      ),
      home: AppConfig.hasCompletedOnboarding
          ? DashboardScreen(
              weightKg: AppConfig.weightKg,
              durationMinutes: AppConfig.durationMinutes,
            )
          : const OnboardingScreen(),
    );
  }
}

class TestSOSTriggerWidget extends StatefulWidget {
  const TestSOSTriggerWidget({super.key});

  @override
  State<TestSOSTriggerWidget> createState() => _TestSOSTriggerWidgetState();
}

class _TestSOSTriggerWidgetState extends State<TestSOSTriggerWidget> {
  final AntiProcrastinationService _procrastinationService =
      AntiProcrastinationService();
  bool _isLoading = false;
  String _statusMessage = 'Idle';

  Future<void> _triggerSOSEvent() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Calling function...';
    });

    try {
      // Insert dummy data directly into local Firestore Emulator so the Cloud Function finds it
      await FirebaseFirestore.instance
          .collection('users')
          .doc('test_user_123')
          .set({
            'guarantor_token': 'mock_guarantor_token_for_testing',
            'name': 'Test User',
          });
    } catch (e) {
      print('Failed to seed mock data: $e');
    }

    final success = await _procrastinationService.activateLazyStateAlert(
      userId: 'test_user_123',
      delayMinutes: 45, // Simulating a 45-minute delay
    );

    setState(() {
      _isLoading = false;
      _statusMessage = success
          ? 'SOS alert fired successfully!'
          : 'Failed to fire SOS alert.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Status: $_statusMessage',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const CircularProgressIndicator(color: Colors.orange)
          else
            ElevatedButton.icon(
              onPressed: _triggerSOSEvent,
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('Trigger SOS Alert (>30m)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
