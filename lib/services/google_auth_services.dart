import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  // 1. Initialize GoogleSignIn with your WEB CLIENT ID
  // Make sure this is the Web Client ID you generated in the previous step,
  // NOT the Android Client ID.
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // 2. The function to trigger the backdrop and get the token
  static Future<String?> signInAndGetToken() async {
    try {
      await _googleSignIn.initialize(
        serverClientId:
            '536054439823-f54c3aanjfp2ilrfr8nkef4e243lcnrj.apps.googleusercontent.com',
      );

      // This line is what actually opens the Google Account backdrop
      final googleUser = await _googleSignIn.authenticate();

      // 3. Request the authentication details from Google
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 4. Extract the id_token! This is what your FastAPI backend needs.
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        debugPrint('Successfully retrieved id_token!');
        // You can print it to the console temporarily to test it
        // print(idToken);
        return idToken;
      } else {
        debugPrint('Error: id_token is null.');
        return null;
      }
    } catch (error) {
      debugPrint('Google Sign-In Error: $error');
      return null;
    }
  }

  // A helper function to sign out (clears the selected account)
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
