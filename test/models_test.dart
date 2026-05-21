import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_ui/models/ny_laravel_slate_config.dart';
import 'package:scaffold_ui/models/ny_revenuecat_slate_config.dart';
import 'package:scaffold_ui/models/ny_supabase_slate_config.dart';

void main() {
  group('NyLaravelSlateConfig.url', () {
    test('returns the URL untouched when there is no trailing slash', () {
      final config = NyLaravelSlateConfig(url: 'https://api.example.com');
      expect(config.url, 'https://api.example.com');
    });

    test('strips a single trailing slash', () {
      final config = NyLaravelSlateConfig(url: 'https://api.example.com/');
      expect(config.url, 'https://api.example.com');
    });

    test('strips every trailing slash (regex anchor is /+\$)', () {
      final config = NyLaravelSlateConfig(url: 'https://api.example.com///');
      expect(config.url, 'https://api.example.com');
    });

    test('keeps internal slashes', () {
      final config = NyLaravelSlateConfig(url: 'https://api.example.com/v1/');
      expect(config.url, 'https://api.example.com/v1');
    });

    test('handles localhost-style URLs', () {
      final config = NyLaravelSlateConfig(url: 'http://localhost:8000/');
      expect(config.url, 'http://localhost:8000');
    });

    test('handles an empty string', () {
      final config = NyLaravelSlateConfig(url: '');
      expect(config.url, '');
    });
  });

  group('NySupabaseSlateConfig', () {
    test('stores url and anonKey', () {
      final config = NySupabaseSlateConfig(
        url: 'https://abc.supabase.co',
        anonKey: 'public-anon-key',
      );
      expect(config.url, 'https://abc.supabase.co');
      expect(config.anonKey, 'public-anon-key');
    });

    test('fields are mutable (used by the Metro CLI prompt flow)', () {
      final config = NySupabaseSlateConfig(url: 'a', anonKey: 'b');
      config.url = 'a2';
      config.anonKey = 'b2';
      expect(config.url, 'a2');
      expect(config.anonKey, 'b2');
    });
  });

  group('NyRevenueCatSlateConfig', () {
    test('stores both app IDs', () {
      final config = NyRevenueCatSlateConfig(
        appleAppId: 'apple_xxx',
        androidAppId: 'android_yyy',
      );
      expect(config.appleAppId, 'apple_xxx');
      expect(config.androidAppId, 'android_yyy');
    });

    test('accepts null app IDs (the CLI uses null when the user skips)', () {
      final config = NyRevenueCatSlateConfig(
        appleAppId: null,
        androidAppId: null,
      );
      expect(config.appleAppId, isNull);
      expect(config.androidAppId, isNull);
    });

    test(
      'accepts empty strings (the CLI normalises "n" -> "" before saving)',
      () {
        final config = NyRevenueCatSlateConfig(
          appleAppId: '',
          androidAppId: '',
        );
        expect(config.appleAppId, '');
        expect(config.androidAppId, '');
      },
    );
  });
}
