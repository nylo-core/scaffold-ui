String stubSupabaseRegisterController() => '''
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'controller.dart';
import 'package:flutter/widgets.dart';
import 'package:nylo_framework/nylo_framework.dart';

class RegisterController extends Controller {

  /// Register the user
  register(String name, String email, String password) async {
    final sb.SupabaseClient supabase = backpackRead('supabase');

    try {
      await supabase.auth.signUp(
          email: email,
          password: password,
          data: {
            'name': name,
          }
      );
    } on sb.AuthException catch (e) {
      showToastOops(description: e.message);
    }
  }
}
''';
