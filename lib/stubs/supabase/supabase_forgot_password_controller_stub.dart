stubSupabaseForgotPasswordController() => '''
import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      final Supabase supabase = backpackRead('supabase');
      
      await supabase.client.auth.resetPasswordForEmail(email);
      showToastSuccess(description: "Password reset email sent to \$email");
    });
  }
}
''';
