import 'package:cloud_functions/cloud_functions.dart';

class AntiProcrastinationService {
  final FirebaseFunctions _functions;

  // Constructor with optional custom instance (useful for testing or region configuration)
  AntiProcrastinationService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  /// Securely notifies the guarantor by invoking the Cloud Function.
  ///
  /// [userId] - The ID of the current user.
  /// [delayMinutes] - The delay duration (must be > 30 mins).
  Future<bool> activateLazyStateAlert({
    required String userId,
    required int delayMinutes,
  }) async {
    try {
      // 1. Get reference to the HttpsCallable function
      final HttpsCallable callable = _functions.httpsCallable(
        'notifyGuarantorLazyState',
      );

      // 2. Execute call with payload mapping
      final HttpsCallableResult result = await callable.call(<String, dynamic>{
        'userId': userId,
        'delayMinutes': delayMinutes,
      });

      // 3. Process return value
      if (result.data != null && result.data['success'] == true) {
        print(
          '[AntiProcrastinationService] Successfully activated lazy state alert. Message ID: ${result.data['messageId']}',
        );
        return true;
      }

      print(
        '[AntiProcrastinationService] Failed to activate alert: ${result.data}',
      );
      return false;
    } on FirebaseFunctionsException catch (e) {
      _handleFunctionsException(e);
      return false;
    } catch (e) {
      print(
        '[AntiProcrastinationService] Unexpected error calling notifyGuarantorLazyState: $e',
      );
      return false;
    }
  }

  /// Helper to catch, log, and parse Firebase Functions errors
  void _handleFunctionsException(FirebaseFunctionsException e) {
    print(
      '[AntiProcrastinationService] Firebase Functions Error [${e.code}]: ${e.message}',
    );
    // You can parse e.details to extract custom error payloads sent by the function
  }
}
