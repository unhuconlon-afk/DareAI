const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

// Initialize Firebase Admin if not already initialized
if (admin.apps.length === 0) {
  admin.initializeApp();
}

/**
 * Callable function to notify a guarantor when a user is in a lazy state.
 * Expected data payload:
 * {
 *   userId: string,
 *   delayMinutes: number
 * }
 */
exports.notifyGuarantorLazyState = onCall(async (request) => {
  const data = request.data;
  const userId = data.userId;
  const delayMinutes = data.delayMinutes;

  if (!userId || delayMinutes === undefined) {
    throw new HttpsError(
      "invalid-argument",
      "The function must be called with a 'userId' and 'delayMinutes'."
    );
  }

  console.log(`notifyGuarantorLazyState: Request payload validated: userId=${userId}, delayMinutes=${delayMinutes}`);

  try {
    // 1. Query the users collection for the guarantor token
    const userDocRef = admin.firestore().collection("users").doc(userId);
    const userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      throw new HttpsError("not-found", "User not found.");
    }

    const userData = userDoc.data();
    const guarantorToken = userData.guarantor_token;

    if (!guarantorToken) {
      throw new HttpsError("failed-precondition", "Guarantor token is not available for this user.");
    }

    console.log("notifyGuarantorLazyState: Successfully queried user document. guarantor_token found.");

    // 2. Prepare the FCM payload
    const message = {
      token: guarantorToken,
      data: {
        type: "SOS_LAZY_STATE",
        targetUserId: String(userId),
        delayTime: String(delayMinutes)
      }
    };

    console.log(`notifyGuarantorLazyState: FCM payload compiled:`, message);

    // 3. Send the FCM message
    // Check if running locally inside the Firebase Emulator
    if (process.env.FUNCTIONS_EMULATOR === 'true') {
      console.log("🚀 [EMULATOR INTERCEPT] FCM Messaging bypassed safely!");
      const token = guarantorToken;
      console.log("Target Token:", message.token || token);
      console.log("Payload compiled:", JSON.stringify(message || data));
      
      // Return a mock success response back to the Flutter client immediately
      return { success: true, message: "FCM delivery simulated successfully in local emulator." };
    } else {
      // Real production flow
      const response = await admin.messaging().send(message);
      
      console.log(`notifyGuarantorLazyState: FCM message dispatched. Message ID: ${response}`);

      return {
        success: true,
        messageId: response
      };
    }

  } catch (error) {
    console.error("notifyGuarantorLazyState: Error executing function", error);
    
    // Pass the specific HttpsError back to the client if it's one we created
    if (error instanceof HttpsError) {
      throw error;
    }
    
    // Otherwise wrap it in a generic internal error
    throw new HttpsError("internal", "An internal error occurred while processing the request.");
  }
});
