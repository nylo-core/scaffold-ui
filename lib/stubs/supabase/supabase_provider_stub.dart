import '/models/ny_supabase_slate_config.dart';

String stubSupabaseProvider(NySupabaseSlateConfig nysuperbaseSlateConfig) => '''
import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class SupabaseProvider implements NyProvider {
  @override
  boot(Nylo nylo) async {
 
    return null;
  }

  @override
  afterBoot(Nylo nylo) async {
    await sb.Supabase.initialize(
      url: '${nysuperbaseSlateConfig.url}',
      anonKey: '${nysuperbaseSlateConfig.anonKey}',
        debug: getEnv('APP_DEBUG')
    );

    // add supabase to backpack
    final sb.SupabaseClient supabase = sb.Supabase.instance.client;

    supabase.auth.onAuthStateChange.listen((data) async {
      final sb.AuthChangeEvent event = data.event;
      final sb.Session? session = data.session;

      if (event == sb.AuthChangeEvent.signedIn) {
        await Auth.authenticate(data: {
          "session": session?.accessToken
        });
        routeToAuthenticatedRoute();
        return;
      }
    });

    backpackSave('supabase', supabase);
  }
}
''';
