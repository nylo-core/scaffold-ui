stubSupabaseLoginController() => '''
import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controller.dart';
import 'package:flutter/widgets.dart';

class LoginController extends Controller {

  construct(BuildContext context) {
    super.construct(context);

  }

  /// Login the user
  login(String email, String password) async {

    final SupabaseClient supabase = backpackRead('supabase');

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      showToastOops(description: e.message);
    }
  }
}
''';
