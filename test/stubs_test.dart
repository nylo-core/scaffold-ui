import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_ui/models/ny_laravel_slate_config.dart';
import 'package:scaffold_ui/models/ny_revenuecat_slate_config.dart';
import 'package:scaffold_ui/models/ny_supabase_slate_config.dart';
import 'package:scaffold_ui/stubs/iap/revenuecat/revenue_cat_provider_stub.dart';
import 'package:scaffold_ui/stubs/laravel/laravel_api_service_stub.dart';
import 'package:scaffold_ui/stubs/laravel/laravel_auth_api_service_stub.dart';
import 'package:scaffold_ui/stubs/supabase/supabase_provider_stub.dart';

void main() {
  group('stubSupabaseProvider', () {
    test('embeds the configured url and anonKey verbatim', () {
      final stub = stubSupabaseProvider(
        NySupabaseSlateConfig(
          url: 'https://demo.supabase.co',
          anonKey: 'eyJanon-key-here',
        ),
      );
      expect(stub, contains("url: 'https://demo.supabase.co'"));
      expect(stub, contains("anonKey: 'eyJanon-key-here'"));
    });

    test('produces compilable boilerplate (imports + class declaration)', () {
      final stub = stubSupabaseProvider(
        NySupabaseSlateConfig(url: 'u', anonKey: 'k'),
      );
      expect(stub,
          contains("import 'package:nylo_framework/nylo_framework.dart';"));
      expect(stub, contains('class SupabaseProvider implements NyProvider'));
    });

    test('subscribes to onAuthStateChange (auth wiring stays put)', () {
      final stub = stubSupabaseProvider(
        NySupabaseSlateConfig(url: 'u', anonKey: 'k'),
      );
      expect(stub, contains('supabase.auth.onAuthStateChange.listen'));
      expect(stub, contains('AuthChangeEvent.signedIn'));
    });
  });

  group('stubLaravelApiService', () {
    test('uses the trimmed URL on the base URL line', () {
      final stub = stubLaravelApiService(
        NyLaravelSlateConfig(url: 'https://api.example.com/'),
      );
      expect(stub, contains("'https://api.example.com/app/v1'"));
      // Any trailing-slash leak would produce '//' before app/v1.
      expect(stub.contains('//app/v1'), isFalse);
    });

    test('extends NyApiService and exposes a bearerToken getter', () {
      final stub = stubLaravelApiService(
        NyLaravelSlateConfig(url: 'http://localhost:8000'),
      );
      expect(stub, contains('class LaravelApiService extends NyApiService'));
      expect(stub, contains('String get bearerToken'));
    });
  });

  group('stubLaravelAuthApiService', () {
    test('uses the trimmed URL on the base URL line', () {
      final stub = stubLaravelAuthApiService(
        NyLaravelSlateConfig(url: 'https://api.example.com/'),
      );
      expect(stub, contains("'https://api.example.com/app/v1'"));
      expect(stub.contains('//app/v1'), isFalse);
    });
  });

  group('stubRevenueCatProvider', () {
    test('embeds the apple + android app IDs when both are present', () {
      final stub = stubRevenueCatProvider(
        NyRevenueCatSlateConfig(
          appleAppId: 'apple_real_key',
          androidAppId: 'android_real_key',
        ),
      );
      expect(stub, contains('"apple_real_key"'));
      expect(stub, contains('"android_real_key"'));
    });

    test('comments out the iOS configure line when appleAppId is empty', () {
      final stub = stubRevenueCatProvider(
        NyRevenueCatSlateConfig(appleAppId: '', androidAppId: 'a'),
      );
      // The conditional is "// " + the configuration line, leaving the
      // placeholder text intact for the user to fill in later.
      expect(
        stub,
        contains(
            '// configuration = PurchasesConfiguration("Your RevenueCat IOS API Key")'),
      );
    });

    test('comments out the Android configure line when androidAppId is empty',
        () {
      final stub = stubRevenueCatProvider(
        NyRevenueCatSlateConfig(appleAppId: 'a', androidAppId: ''),
      );
      expect(
        stub,
        contains(
            '// configuration = PurchasesConfiguration("Your RevenueCat Android API Key")'),
      );
    });

    test(
        'comments out and uses placeholder text on both lines when both IDs '
        'are null', () {
      final stub = stubRevenueCatProvider(
        NyRevenueCatSlateConfig(appleAppId: null, androidAppId: null),
      );
      // Both lines should be commented AND should use the placeholder text,
      // not the literal string "null" — regression for the bug where
      // `appleAppId == ""` was the only condition that triggered the
      // placeholder branch.
      expect(
        stub,
        contains(
            '// configuration = PurchasesConfiguration("Your RevenueCat IOS API Key")'),
      );
      expect(
        stub,
        contains(
            '// configuration = PurchasesConfiguration("Your RevenueCat Android API Key")'),
      );
      expect(stub.contains('"null"'), isFalse,
          reason: 'null appleAppId/androidAppId must not leak as the literal '
              'string "null" into the generated provider');
    });

    test('does NOT comment out the configure line when an ID is provided', () {
      final stub = stubRevenueCatProvider(
        NyRevenueCatSlateConfig(
          appleAppId: 'apple_real_key',
          androidAppId: 'android_real_key',
        ),
      );
      // Active line — no leading "// " — should appear for both platforms.
      expect(stub,
          contains('configuration = PurchasesConfiguration("apple_real_key")'));
      expect(
          stub,
          contains(
              'configuration = PurchasesConfiguration("android_real_key")'));
    });
  });
}
