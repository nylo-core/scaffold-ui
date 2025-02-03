stubFirebaseLoginController() => '''
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/user.dart';
import 'controller.dart';

class LoginController extends Controller {

  /// Login the user
  login(String email, String password) async {

    try {
      fb.UserCredential userCredential = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = User.fromFirebaseUserCredential(userCredential);
      await Auth.authenticate(data: user.toJson());
      routeToAuthenticatedRoute();
      
    } on fb.FirebaseAuthException catch (firebaseAuthException) {
      if (firebaseAuthException.code == 'invalid-email') {
        showToastSorry(description: 'The email provided is invalid.');
        return;
      }
      if (firebaseAuthException.code == 'operation-not-allowed') {
        showToastSorry(description: 'Something went wrong, please try again later.');
        printError('The email/password accounts are not enabled.');
        return;
      }
      if (firebaseAuthException.code == 'too-many-requests') {
        showToastSorry(description: 'Too many requests, please try again later.');
        return;
      }
      if (firebaseAuthException.code == 'user-token-expired') {
        showToastSorry(description: 'Please try again.');
        printError('The user is no longer authenticated since his refresh token has been expired.');
        return;
      }
      if (firebaseAuthException.code == 'network-request-failed') {
        showToastSorry(description: 'Please check your internet connection.');
        return;
      }
      if (firebaseAuthException.code == 'user-disabled') {
        showToastSorry(description: 'Something went wrong, please try again later.');
        printError('The user corresponding to the given email has been disabled.');
        return;
      }
      if (firebaseAuthException.code == 'user-not-found') {
        showToastSorry(description: 'The user corresponding to the given email was not found.');
        return;
      }
      if (firebaseAuthException.code == 'wrong-password') {
        showToastSorry(description: 'The password is invalid for the given email.');
        return;
      }
      if (firebaseAuthException.code == 'invalid-credential') {
        showToastSorry(description: 'The account corresponding to the email does not have a password set.');
        return;
      }
    } on Exception catch (e) {
      printError(e.toString());
    }
  }
}
''';
