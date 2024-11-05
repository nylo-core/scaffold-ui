stubBasicForgotPasswordController() => '''
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
      // handle success
      
      showToastSuccess(description: "Password reset email sent.");
    }, lockRelease: "forgot_password");
  }
}
''';
