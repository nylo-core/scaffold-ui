import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/metro/ny_metro.dart';
import 'package:scaffold_ui/models/ny_laravel_slate_config.dart';
import 'package:scaffold_ui/models/ny_revenuecat_slate_config.dart';
import 'package:scaffold_ui/models/ny_superwall_slate_config.dart';
import 'package:scaffold_ui/models/ny_supabase_slate_config.dart';
import 'package:scaffold_ui/scaffold_ui.dart';

NyTemplate _byName(List<NyTemplate> templates, String name) =>
    templates.firstWhere(
      (t) => t.name == name,
      orElse: () => throw StateError('No template named $name'),
    );

bool _hasName(List<NyTemplate> templates, String name) =>
    templates.any((t) => t.name == name);

void main() {
  group('basicRun', () {
    final List<NyTemplate> templates = basicRun();

    test('produces every page, controller and form expected by Basic auth', () {
      const expected = {
        'landing_page',
        'login_page',
        'register_page',
        'forgot_password_page',
        'dashboard_page',
        'login_controller',
        'register_controller',
        'forgot_password_controller',
        'register_form',
        'login_form',
      };
      final Set<String> actual = templates.map((t) => t.name).toSet();
      expect(actual, containsAll(expected));
    });

    test('routes pages and controllers to the right Nylo folders', () {
      expect(_byName(templates, 'landing_page').saveTo, pagesFolder);
      expect(_byName(templates, 'login_controller').saveTo, controllersFolder);
      expect(_byName(templates, 'login_form').saveTo, formsFolder);
    });

    test('marks dashboard_page as the post-login destination', () {
      expect(
        _byName(templates, 'dashboard_page').options['is_auth_page'],
        isTrue,
      );
    });

    test('forms do not require nylo_framework (they are pure widgets)', () {
      expect(_byName(templates, 'login_form').pluginsRequired, isEmpty);
      expect(_byName(templates, 'register_form').pluginsRequired, isEmpty);
    });

    test('does not generate a backend-specific provider', () {
      expect(_hasName(templates, 'supabase_provider'), isFalse);
      expect(_hasName(templates, 'firebase_provider'), isFalse);
      expect(_hasName(templates, 'laravel_api_service'), isFalse);
    });
  });

  group('laravelRun', () {
    final List<NyTemplate> templates = laravelRun(
      NyLaravelSlateConfig(url: 'https://api.example.com/'),
    );

    test('contains the user + auth response models', () {
      expect(_byName(templates, 'user').saveTo, modelsFolder);
      expect(_byName(templates, 'laravel_auth_response').saveTo, modelsFolder);
    });

    test('saves api services under networking/', () {
      expect(
        _byName(templates, 'laravel_api_service').saveTo,
        networkingFolder,
      );
      expect(
        _byName(templates, 'laravel_auth_api_service').saveTo,
        networkingFolder,
      );
    });

    test('emits a laravel_auth_event under events/', () {
      expect(_byName(templates, 'laravel_auth_event').saveTo, eventsFolder);
    });

    test('marks dashboard_page as the post-login destination', () {
      expect(
        _byName(templates, 'dashboard_page').options['is_auth_page'],
        isTrue,
      );
    });

    test('strips trailing slash from URL before interpolating into the api '
        'service stub', () {
      // The Laravel slate runner is fed the trimmed URL via NyLaravelSlateConfig,
      // so the api service base URL must NOT end with '//app/v1'.
      final String apiStub = _byName(templates, 'laravel_api_service').stub;
      expect(apiStub, contains("'https://api.example.com/app/v1'"));
      expect(apiStub.contains("'https://api.example.com//app/v1'"), isFalse);
    });

    test('auth api service stub references the configured base URL', () {
      final String stub = _byName(templates, 'laravel_auth_api_service').stub;
      expect(stub, contains('https://api.example.com'));
    });
  });

  group('supabaseRun', () {
    final List<NyTemplate> templates = supabaseRun(
      NySupabaseSlateConfig(
        url: 'https://abc.supabase.co',
        anonKey: 'eyJabc.public.anon',
      ),
    );

    test('emits the supabase_provider in the providers folder', () {
      final NyTemplate t = _byName(templates, 'supabase_provider');
      expect(t.saveTo, providerFolder);
    });

    test('emits a logout_event under events/', () {
      expect(_byName(templates, 'logout_event').saveTo, eventsFolder);
    });

    test('interpolates URL and anonKey into supabase_provider stub', () {
      final String stub = _byName(templates, 'supabase_provider').stub;
      expect(stub, contains("url: 'https://abc.supabase.co'"));
      expect(stub, contains("anonKey: 'eyJabc.public.anon'"));
    });

    test('marks dashboard_page as the post-login destination', () {
      expect(
        _byName(templates, 'dashboard_page').options['is_auth_page'],
        isTrue,
      );
    });

    test('does not generate a Laravel api service or Firebase provider', () {
      expect(_hasName(templates, 'laravel_api_service'), isFalse);
      expect(_hasName(templates, 'firebase_provider'), isFalse);
    });
  });

  group('firebaseRun', () {
    final List<NyTemplate> templates = firebaseRun();

    test('emits the firebase_provider in the providers folder', () {
      expect(_byName(templates, 'firebase_provider').saveTo, providerFolder);
    });

    test('emits the firebase user model', () {
      expect(_byName(templates, 'user').saveTo, modelsFolder);
    });

    test('emits a logout_event under events/', () {
      expect(_byName(templates, 'logout_event').saveTo, eventsFolder);
    });

    test('marks dashboard_page as the post-login destination', () {
      expect(
        _byName(templates, 'dashboard_page').options['is_auth_page'],
        isTrue,
      );
    });

    test('does not embed any backend URL (Firebase is bootstrapped via '
        'flutterfire configure)', () {
      final String stub = _byName(templates, 'firebase_provider').stub;
      expect(stub.contains('http://'), isFalse);
      expect(stub.contains('https://'), isFalse);
    });
  });

  group('revenueCatRun', () {
    test('produces a paywall_page and a revenue_cat_provider', () {
      final List<NyTemplate> templates = revenueCatRun(
        NyRevenueCatSlateConfig(
          appleAppId: 'apple_revenuecat_key',
          androidAppId: 'android_revenuecat_key',
        ),
      );
      expect(_byName(templates, 'paywall_page').saveTo, pagesFolder);
      expect(_byName(templates, 'revenue_cat_provider').saveTo, providerFolder);
    });

    test('paywall_page requires purchases_ui_flutter', () {
      final List<NyTemplate> templates = revenueCatRun(
        NyRevenueCatSlateConfig(appleAppId: 'a', androidAppId: 'b'),
      );
      expect(
        _byName(templates, 'paywall_page').pluginsRequired,
        contains('purchases_ui_flutter'),
      );
    });

    test('interpolates configured app IDs into the provider stub', () {
      final List<NyTemplate> templates = revenueCatRun(
        NyRevenueCatSlateConfig(
          appleAppId: 'apple_xxx',
          androidAppId: 'android_yyy',
        ),
      );
      final String stub = _byName(templates, 'revenue_cat_provider').stub;
      expect(stub, contains('"apple_xxx"'));
      expect(stub, contains('"android_yyy"'));
    });

    test('falls back to placeholder text when an app ID is empty', () {
      final List<NyTemplate> templates = revenueCatRun(
        NyRevenueCatSlateConfig(appleAppId: '', androidAppId: ''),
      );
      final String stub = _byName(templates, 'revenue_cat_provider').stub;
      expect(stub, contains('Your RevenueCat IOS API Key'));
      expect(stub, contains('Your RevenueCat Android API Key'));
    });
  });

  group('superwallRun', () {
    test('produces a paywall_page and a superwall_provider', () {
      final List<NyTemplate> templates = superwallRun(
        NySuperwallSlateConfig(
          appleApiKey: 'apple_superwall_key',
          androidApiKey: 'android_superwall_key',
        ),
      );
      expect(_byName(templates, 'paywall_page').saveTo, pagesFolder);
      expect(_byName(templates, 'superwall_provider').saveTo, providerFolder);
    });

    test('paywall_page requires superwallkit_flutter', () {
      final List<NyTemplate> templates = superwallRun(
        NySuperwallSlateConfig(appleApiKey: 'a', androidApiKey: 'b'),
      );
      expect(
        _byName(templates, 'paywall_page').pluginsRequired,
        contains('superwallkit_flutter'),
      );
    });

    test('interpolates configured api keys into the provider stub', () {
      final List<NyTemplate> templates = superwallRun(
        NySuperwallSlateConfig(
          appleApiKey: 'apple_xxx',
          androidApiKey: 'android_yyy',
        ),
      );
      final String stub = _byName(templates, 'superwall_provider').stub;
      expect(stub, contains('"apple_xxx"'));
      expect(stub, contains('"android_yyy"'));
    });

    test('falls back to placeholder text when an api key is empty', () {
      final List<NyTemplate> templates = superwallRun(
        NySuperwallSlateConfig(appleApiKey: '', androidApiKey: ''),
      );
      final String stub = _byName(templates, 'superwall_provider').stub;
      expect(stub, contains('Your Superwall IOS API Key'));
      expect(stub, contains('Your Superwall Android API Key'));
    });
  });
}
