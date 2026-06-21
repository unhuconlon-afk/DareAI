# Anti-Procrastination Feature: End-to-End Testing Guide

This guide walks you through setting up a testing loop to verify the anti-procrastination SOS alert flow across the Firebase Cloud Function, Firestore database, and Flutter client messaging receiver.

---

## 1. Local Testing via Firebase Emulator Suite

To test without incurring Firebase costs or requiring deployment, run both Firestore and Cloud Functions locally.

### A. Initialize Firebase Emulators
Ensure you have the Firebase CLI installed (`npm install -g firebase-tools`). Run this in the `functions/` directory or project root:
```bash
firebase init emulators
```
*Select **Functions** and **Firestore** to configure.*

### B. Start the Emulators
Launch the emulator suite:
```bash
firebase emulators:start
```
Take note of the ports:
*   **Firestore Emulator**: Default `8080` (UI at `4000`)
*   **Functions Emulator**: Default `5001`

### C. Connect the Flutter App to local Emulators
In your `lib/main.dart` (or app configuration), direct Firebase to use local emulators in debug mode:

```dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

void configureEmulators() {
  if (kDebugMode) {
    // Point Firestore to local emulator
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    
    // Point Cloud Functions to local emulator
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  }
}
```
*Call `configureEmulators()` immediately after `Firebase.initializeApp()` in `main()`.*

---

## 2. Mocking/Inserting a Dummy Firestore Document

The Cloud Function expects a `users` collection with documents containing a `guarantor_token`.

### Option A: Via Firebase Emulator UI (Recommended)
1. Open the Emulator UI in your browser (usually `http://localhost:4000`).
2. Go to the **Firestore** tab.
3. Click **Start collection** and name it `users`.
4. Add a document with:
   *   **Document ID**: `test_user_123`
   *   **Fields**:
       *   `guarantor_token` (string): Put your supervisor device's actual FCM Token here (or a dummy token like `mock_guarantor_token_abc` for offline logs).
       *   `name` (string): `Test User`

### Option B: Programmatically via Flutter Code
Add this temp snippet to write the mock data directly from Flutter:
```dart
await FirebaseFirestore.instance.collection('users').doc('test_user_123').set({
  'guarantor_token': 'YOUR_RECEIVING_DEVICE_FCM_TOKEN_HERE',
  'name': 'Test User',
});
```

---

## 3. Temporary Test Trigger in Flutter

Replace your `MyHomePageState` UI in `lib/main.dart` (or add a separate screen) with a test button to invoke the service.

### Implement the Test Trigger Button:
```dart
import 'package:flutter/material.dart';
import 'services/anti_procrastination_service.dart';

class TestSOSTriggerWidget extends StatefulWidget {
  const TestSOSTriggerWidget({super.key});

  @override
  State<TestSOSTriggerWidget> createState() => _TestSOSTriggerWidgetState();
}

class _TestSOSTriggerWidgetState extends State<TestSOSTriggerWidget> {
  final AntiProcrastinationService _procrastinationService = AntiProcrastinationService();
  bool _isLoading = false;
  String _statusMessage = 'Idle';

  Future<void> _triggerSOSEvent() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Calling function...';
    });

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
    return Scaffold(
      appBar: AppBar(title: const Text('SOS Alert Test Panel')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Status: $_statusMessage', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _triggerSOSEvent,
                    icon: const Icon(Icons.warning_amber_rounded),
                    label: const Text('Trigger SOS Alert (>30m)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
```
*Simply swap the `MyHomePage` in `MaterialApp(home: ...)` to `const TestSOSTriggerWidget()` to test.*

---

## 4. Verification and Console Logs

Here is what to look for on both ends when you click the button.

### A. Sender Client (Flutter Debug Console)
When the button is pressed, the service invokes the callable function. You should see logs from the `AntiProcrastinationService` tag:

```text
[AntiProcrastinationService] Successfully activated lazy state alert. Message ID: projects/YOUR_PROJECT/messages/MESSAGE_ID
```
*   If Firestore setup failed: `FirebaseFunctionsException [failed-precondition]: Guarantor token is not available for this user.`
*   If User ID doesn't exist: `FirebaseFunctionsException [not-found]: User not found.`

### B. Cloud Functions Server (Emulator/Firebase Console logs)
The function prints log sequences. Check the terminal running `firebase emulators:start` or your Google Cloud Log Explorer:

```text
>  notifyGuarantorLazyState: Request payload validated: userId=test_user_123, delayMinutes=45
>  notifyGuarantorLazyState: Successfully queried user document. guarantor_token found.
>  notifyGuarantorLazyState: FCM payload compiled: { token: '...', data: { type: 'SOS_LAZY_STATE', targetUserId: 'test_user_123', delayTime: '45' } }
>  notifyGuarantorLazyState: FCM message dispatched. Message ID: ...
```

### C. Receiving Client (Background Logs)
This step must be tested on a separate physical device or emulator representing the **guarantor/supervisor**.
1. Retrieve the FCM Token for the supervisor's device using `FirebaseMessaging.instance.getToken()` and save it in Firestore.
2. Put the supervisor app in the **Background** (press the home button) or **terminate** the app.
3. Click the trigger button on the sender device.
4. On the supervisor's device debugger console (running in a background isolate), look for:

```text
[FCMBackgroundHandler] Received message in background: MESSAGE_ID
[FCMBackgroundHandler] SOS ALERT RECEIVED! Target User: test_user_123 has been inactive for 45 minutes.
```
