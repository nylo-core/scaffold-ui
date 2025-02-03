String stubFirebaseRegisterController() => '''
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_app/app/models/user.dart';
import 'controller.dart';
import 'package:nylo_framework/nylo_framework.dart';

class RegisterController extends Controller {

  /// Register the user
  register(String name, String email, String password) async {

    try {
      fb.UserCredential userCredential = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      
      User user = User.fromFirebaseUserCredential(userCredential);
      
      await Auth.authenticate(data: user.toJson());
      routeToAuthenticatedRoute();

    } on fb.FirebaseAuthException catch (firebaseAuthException) {
      if (firebaseAuthException.code == 'weak-password') {
        showToastSorry(description: 'The password provided is too weak.');
        return;
      } 
      if (firebaseAuthException.code == 'invalid-email') {
        showToastSorry(description: 'The email provided is invalid.');
        return;
      }
      if (firebaseAuthException.code == 'email-already-in-use') {
        showToastSorry(description: 'The account already exists for that email.');
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
    } on Exception catch (e) {
      printError(e.toString());
    }
  }
}
''';
