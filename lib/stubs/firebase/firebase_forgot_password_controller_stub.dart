stubFirebaseForgotPasswordController() => '''
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'controller.dart';
import 'package:flutter/widgets.dart';

class ForgotPasswordController extends Controller {

  TextEditingController textEmailForgotPassword = TextEditingController();

  /// Send password reset email
  forgotPassword() async {
    String email = textEmailForgotPassword.text;
    validate(rules: {
      "email": [email, "email"]
    }, onSuccess: () async {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        showToastSuccess(description: "Password reset email sent to \$email");
      } on FirebaseAuthException catch (firebaseAuthException) {

        if (firebaseAuthException.code == 'auth/invalid-email') {
          showToastSorry(description: 'The email provided is invalid.');
          return;
        }
        
        if (firebaseAuthException.code == 'auth/missing-android-pkg-name') {
          showToastSorry(description: "Something went wrong, please try again later.");
          printError('An Android package name must be provided if the Android app is required to be installed.');
          return;
        }
        
        if (firebaseAuthException.code == 'auth/missing-continue-uri') {
          showToastSorry(description: "Something went wrong, please try again later.");
          printError('A continue URL must be provided in the request.');
          return;
        }
        
        if (firebaseAuthException.code == 'auth/missing-ios-bundle-id') {
          showToastSorry(description: "Something went wrong, please try again later.");
          printError('An iOS Bundle ID must be provided if an App Store ID is provided.');
          return;
        }
        
        if (firebaseAuthException.code == 'auth/invalid-continue-uri') {
          showToastSorry(description: "Something went wrong, please try again later.");
          printError('The continue URL provided in the request is invalid.');
          return;
        }
        
        if (firebaseAuthException.code == 'auth/unauthorized-continue-uri') {
          showToastSorry(description: "Something went wrong, please try again later.");
          printError('The domain of the continue URL is not whitelisted. Whitelist the domain in the Firebase console.');
          return;
        }
        
        if (firebaseAuthException.code == 'auth/user-not-found') {
          showToastSorry(description: "We couldn't find an account with that email.");
          return;
        }
      } on Exception catch (e) {
        printError(e.toString());
      }
    });
  }
}
''';
