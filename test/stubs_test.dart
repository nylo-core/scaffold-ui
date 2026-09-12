import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_ui/models/ny_laravel_slate_config.dart';
import 'package:scaffold_ui/models/ny_revenuecat_slate_config.dart';
import 'package:scaffold_ui/models/ny_superwall_slate_config.dart';
import 'package:scaffold_ui/models/ny_supabase_slate_config.dart';
import 'package:scaffold_ui/stubs/iap/revenuecat/revenue_cat_provider_stub.dart';
import 'package:scaffold_ui/stubs/iap/superwall/superwall_provider_stub.dart';
import 'package:scaffold_ui/stubs/laravel/laravel_api_service_stub.dart';
import 'package:scaffold_ui/stubs/laravel/laravel_auth_api_service_stub.dart';
import 'package:scaffold_ui/stubs/supabase/supabase_dashboard_stub.dart';
import 'package:scaffold_ui/stubs/supabase/supabase_provider_stub.dart';

void main() {
  group('stubSupabaseProvider', () {
    test('embeds the configured url and anonKey verbatim', () {
      final String stub = stubSupabaseProvider(
        NySupabaseSlateConfig(
          url: 'https://demo.supabase.co',
          anonKey: 'eyJanon-key-here',
        ),
      );
      expect(stub, contains("url: 'https://demo.supabase.co'"));
      expect(stub, contains("anonKey: 'eyJanon-key-here'"));
    });

    test('produces compilable boilerplate (imports + class declaration)', () {
      final String stub = stubSupabaseProvider(
        NySupabaseSlateConfig(url: 'u', anonKey: 'k'),
      );
      expect(
        stub,
        contains("import 'package:nylo_framework/nylo_framework.dart';"),
      );
      expect(stub, contains('class SupabaseProvider implements NyProvider'));
    });

    test('subscribes to onAuthStateChange (auth wiring stays put)', () {
      final String stub = stubSupabaseProvider(
        NySupabaseSlateConfig(url: 'u', anonKey: 'k'),
      );
      expect(stub, contains('supabase.auth.onAuthStateChange.listen'));
      expect(stub, contains('AuthChangeEvent.signedIn'));
    });
  });

  group('stubSupabaseDashboard', () {
    test('does not import the app User model', () {
      final String stub = stubSupabaseDashboard();
      // Importing '/app/models/user.dart' alongside supabase_flutter pulls
      // two `User` declarations into scope and makes the generated page
      // fail to compile with an ambiguous-import error. The dashboard never
      // uses the app model — `_user` returns the Supabase auth user.
      expect(
        stub.contains("import '/app/models/user.dart';"),
        isFalse,
        reason:
            'the app User model collides with the User type re-exported '
            'by supabase_flutter',
      );
    });

    test('resolves the User type through supabase_flutter', () {
      final String stub = stubSupabaseDashboard();
      expect(
        stub,
        contains("import 'package:supabase_flutter/supabase_flutter.dart';"),
      );
      expect(stub, contains('User? get _user'));
    });
  });

  group('stubLaravelApiService', () {
    test('uses the trimmed URL on the base URL line', () {
      final String stub = stubLaravelApiService(
        NyLaravelSlateConfig(url: 'https://api.example.com/'),
      );
      expect(stub, contains("'https://api.example.com/app/v1'"));
      // Any trailing-slash leak would produce '//' before app/v1.
      expect(stub.contains('//app/v1'), isFalse);
    });

    test('extends NyApiService and injects the bearer token via '
        'setAuthHeaders', () {
      final String stub = stubLaravelApiService(
        NyLaravelSlateConfig(url: 'http://localhost:8000'),
      );
      expect(stub, contains('class LaravelApiService extends NyApiService'));
      expect(stub, contains('setAuthHeaders(RequestHeaders headers)'));
      expect(stub, contains('headers.addBearerToken(token)'));
    });
  });

  group('stubLaravelAuthApiService', () {
    test('uses the trimmed URL on the base URL line', () {
      final String stub = stubLaravelAuthApiService(
        NyLaravelSlateConfig(url: 'https://api.example.com/'),
      );
      expect(stub, contains("'https://api.example.com/app/v1'"));
      expect(stub.contains('//app/v1'), isFalse);
    });
  });

  group('stubRevenueCatProvider', () {
    test('embeds the apple + android app IDs when both are present', () {
      final String stub = stubRevenueCatProvider(
        NyRevenueCatSlateConfig(
          appleAppId: 'apple_real_key',
          androidAppId: 'android_real_key',
        ),
      );
      expect(stub, contains('"apple_real_key"'));
      expect(stub, contains('"android_real_key"'));
    });

    test('comments out the iOS configure line when appleAppId is empty', () {
      final String stub = stubRevenueCatProvider(
        NyRevenueCatSlateConfig(appleAppId: '', androidAppId: 'a'),
      );
      // The conditional is "// " + the configuration line, leaving the
      // placeholder text intact for the user to fill in later.
      expect(
        stub,
        contains(
          '// configuration = PurchasesConfiguration("Your RevenueCat IOS API Key")',
        ),
      );
    });

    test(
      'comments out the Android configure line when androidAppId is empty',
      () {
        final String stub = stubRevenueCatProvider(
          NyRevenueCatSlateConfig(appleAppId: 'a', androidAppId: ''),
        );
        expect(
          stub,
          contains(
            '// configuration = PurchasesConfiguration("Your RevenueCat Android API Key")',
          ),
        );
      },
    );

    test('comments out and uses placeholder text on both lines when both IDs '
        'are null', () {
      final String stub = stubRevenueCatProvider(
        NyRevenueCatSlateConfig(appleAppId: null, androidAppId: null),
      );
      // Both lines should be commented AND should use the placeholder text,
      // not the literal string "null" — regression for the bug where
      // `appleAppId == ""` was the only condition that triggered the
      // placeholder branch.
      expect(
        stub,
        contains(
          '// configuration = PurchasesConfiguration("Your RevenueCat IOS API Key")',
        ),
      );
      expect(
        stub,
        contains(
          '// configuration = PurchasesConfiguration("Your RevenueCat Android API Key")',
        ),
      );
      expect(
        stub.contains('"null"'),
        isFalse,
        reason:
            'null appleAppId/androidAppId must not leak as the literal '
            'string "null" into the generated provider',
      );
    });

    test('does NOT comment out the configure line when an ID is provided', () {
      final String stub = stubRevenueCatProvider(
        NyRevenueCatSlateConfig(
          appleAppId: 'apple_real_key',
          androidAppId: 'android_real_key',
        ),
      );
      // Active line — no leading "// " — should appear for both platforms.
      expect(
        stub,
        contains('configuration = PurchasesConfiguration("apple_real_key")'),
      );
      expect(
        stub,
        contains('configuration = PurchasesConfiguration("android_real_key")'),
      );
    });
  });

  group('stubSuperwallProvider', () {
    test('embeds the apple + android api keys when both are present', () {
      final String stub = stubSuperwallProvider(
        NySuperwallSlateConfig(
          appleApiKey: 'apple_real_key',
          androidApiKey: 'android_real_key',
        ),
      );
      expect(stub, contains('"apple_real_key"'));
      expect(stub, contains('"android_real_key"'));
    });

    test('comments out the iOS apiKey line when appleApiKey is empty', () {
      final String stub = stubSuperwallProvider(
        NySuperwallSlateConfig(appleApiKey: '', androidApiKey: 'a'),
      );
      // The conditional is "// " + the assignment line, leaving the
      // placeholder text intact for the user to fill in later.
      expect(stub, contains('// apiKey = "Your Superwall IOS API Key"'));
    });

    test(
      'comments out the Android apiKey line when androidApiKey is empty',
      () {
        final String stub = stubSuperwallProvider(
          NySuperwallSlateConfig(appleApiKey: 'a', androidApiKey: ''),
        );
        expect(stub, contains('// apiKey = "Your Superwall Android API Key"'));
      },
    );

    test('comments out and uses placeholder text on both lines when both keys '
        'are null', () {
      final String stub = stubSuperwallProvider(
        NySuperwallSlateConfig(appleApiKey: null, androidApiKey: null),
      );
      expect(stub, contains('// apiKey = "Your Superwall IOS API Key"'));
      expect(stub, contains('// apiKey = "Your Superwall Android API Key"'));
      expect(
        stub.contains('"null"'),
        isFalse,
        reason:
            'null appleApiKey/androidApiKey must not leak as the literal '
            'string "null" into the generated provider',
      );
    });

    test('does NOT comment out the apiKey line when a key is provided', () {
      final String stub = stubSuperwallProvider(
        NySuperwallSlateConfig(
          appleApiKey: 'apple_real_key',
          androidApiKey: 'android_real_key',
        ),
      );
      // Active line — no leading "// " — should appear for both platforms.
      expect(stub, contains('apiKey = "apple_real_key"'));
      expect(stub, contains('apiKey = "android_real_key"'));
    });

    test('produces compilable boilerplate (imports + class declaration)', () {
      final String stub = stubSuperwallProvider(
        NySuperwallSlateConfig(appleApiKey: 'a', androidApiKey: 'b'),
      );
      expect(
        stub,
        contains("import 'package:nylo_framework/nylo_framework.dart';"),
      );
      expect(
        stub,
        contains(
          "import 'package:superwallkit_flutter/superwallkit_flutter.dart';",
        ),
      );
      expect(stub, contains('class SuperwallProvider implements NyProvider'));
      expect(stub, contains('Superwall.configure(apiKey, options: options)'));
    });

    test('includes a user-management usage block (identify + reset)', () {
      // Discoverability hint inside the generated provider — developers
      // shouldn't have to read external docs to find these two calls.
      final String stub = stubSuperwallProvider(
        NySuperwallSlateConfig(appleApiKey: 'a', androidApiKey: 'b'),
      );
      expect(stub, contains('Superwall.shared.identify'));
      expect(stub, contains('Superwall.shared.reset()'));
    });
  });
}
