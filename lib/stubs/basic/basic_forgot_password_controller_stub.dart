stubBasicForgotPasswordController() => '''
import '/app/networking/laravel_auth_api_service.dart';
import 'controller.dart';
import 'package:flutter/widgets.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ForgotPasswordController extends Controller {

  TextEditingController textEmailForgotPassword = TextEditingController();

  construct(BuildContext context) {
    super.construct(context);

  }

  /// Send password reset email
  forgotPassword() async {
    String email = textEmailForgotPassword.text;
    validate(rules: {
      "email": "email"
    }, data: {
      "email": email
    }, onSuccess: () async {
      // handle success
      
      showToastSuccess(description: "Password reset email sent.");
    }, lockRelease: "forgot_password");
  }
}
''';
