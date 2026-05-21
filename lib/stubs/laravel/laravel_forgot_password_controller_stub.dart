String stubLaravelForgotPasswordController() => '''
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/laravel_auth_api_service.dart';
import 'controller.dart';

class ForgotPasswordController extends Controller {

  TextEditingController textEmailForgotPassword = TextEditingController();

  /// Send password reset email
  forgotPassword() async {
    String email = textEmailForgotPassword.text;
    validate(rules: {
      "email": [email, "email"]
    }, onSuccess: () async {
      bool hasSentEmail = await api<LaravelAuthApiService>((request) => request.forgotPassword(email));
      if (hasSentEmail == false) {
        showToastSorry(description: "Unable to reset password. Please try again later.");
        return;
      }
      showToastSuccess(description: "Password reset email sent.");
    }, lockRelease: "forgot_password");
  }
}
''';
