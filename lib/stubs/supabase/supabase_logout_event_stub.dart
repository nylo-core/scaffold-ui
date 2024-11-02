String stubSupabaseLogoutEvent() => '''
import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class LogoutEvent implements NyEvent {
  @override
  final listeners = {
    SupabaseListener: SupabaseListener(),
    DefaultListener: DefaultListener(),
  };
}

class SupabaseListener extends NyListener {
  @override
  handle(dynamic event) async {
    final sb.SupabaseClient supabase = backpackRead('supabase');
    await supabase.auth.signOut();
  }
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic event) async {
    await Auth.logout();

    routeToInitial();
  }
}
''';
