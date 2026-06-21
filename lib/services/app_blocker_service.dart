import 'package:flutter/services.dart';

class AppBlockerService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.first/app_blocker',
  );

  // Callback to execute in Flutter when native overlay completes exercise and unlocks
  VoidCallback? onUnlockedCallback;

  AppBlockerService() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onUnlocked') {
        if (onUnlockedCallback != null) {
          onUnlockedCallback!();
        }
      }
      return null;
    });
  }

  /// Returns a map of permission status: `{'overlay': bool, 'usage': bool}`
  Future<Map<String, bool>> checkPermissions() async {
    try {
      final Map<dynamic, dynamic>? result = await _channel.invokeMethod(
        'checkPermissions',
      );
      if (result != null) {
        return {
          'overlay': result['overlay'] as bool? ?? false,
          'usage': result['usage'] as bool? ?? false,
        };
      }
    } catch (e) {
      print('[AppBlockerService] Error checking permissions: $e');
    }
    return {'overlay': false, 'usage': false};
  }

  Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      print('[AppBlockerService] Error requesting overlay permission: $e');
    }
  }

  Future<void> requestUsagePermission() async {
    try {
      await _channel.invokeMethod('requestUsagePermission');
    } catch (e) {
      print('[AppBlockerService] Error requesting usage permission: $e');
    }
  }

  Future<void> updateRestrictedApps(List<String> packages) async {
    try {
      await _channel.invokeMethod('updateRestrictedApps', {
        'packages': packages,
      });
    } catch (e) {
      print('[AppBlockerService] Error updating restricted apps: $e');
    }
  }

  Future<void> setLocked(bool locked) async {
    try {
      await _channel.invokeMethod('setLocked', {'locked': locked});
    } catch (e) {
      print('[AppBlockerService] Error setting locked state: $e');
    }
  }

  Future<void> startService() async {
    try {
      await _channel.invokeMethod('startService');
    } catch (e) {
      print('[AppBlockerService] Error starting background service: $e');
    }
  }

  Future<void> stopService() async {
    try {
      await _channel.invokeMethod('stopService');
    } catch (e) {
      print('[AppBlockerService] Error stopping background service: $e');
    }
  }
}
