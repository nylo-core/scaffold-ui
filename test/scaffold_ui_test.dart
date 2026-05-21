import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_ui/cli/scaffold_cli.dart';
import 'package:scaffold_ui/models/ny_laravel_slate_config.dart';
import 'package:scaffold_ui/models/ny_revenuecat_slate_config.dart';
import 'package:scaffold_ui/models/ny_superwall_slate_config.dart';
import 'package:scaffold_ui/models/ny_supabase_slate_config.dart';

/// Records every prompt the planner asks and replays canned answers in order.
/// Throws when the planner asks more questions than answers were provided —
/// keeps tests honest about prompt count.
class _PromptRecorder {
  final List<String> _answers;
  int _idx = 0;
  final List<String> asked = [];

  _PromptRecorder(this._answers);

  String call(String question) {
    asked.add(question);
    if (_idx >= _answers.length) {
      throw StateError(
        'Planner asked an unexpected question: "$question". '
        'Already asked ${asked.length}, only ${_answers.length} answers '
        'were primed.',
      );
    }
    return _answers[_idx++];
  }

  bool get drained => _idx == _answers.length;
}

void main() {
  group('parseCommand', () {
    test('returns "auth" when called with a single "auth" argument', () {
      expect(parseCommand(['auth']), 'auth');
    });

    test('returns "iap" when called with a single "iap" argument', () {
      expect(parseCommand(['iap']), 'iap');
    });

    test('returns null for no arguments', () {
      expect(parseCommand([]), isNull);
    });

    test('returns null for more than one argument', () {
      expect(parseCommand(['auth', 'extra']), isNull);
    });

    test('returns null for an unknown command', () {
      expect(parseCommand(['login']), isNull);
    });

    test('is case-sensitive — "Auth" is not the same as "auth"', () {
      expect(parseCommand(['Auth']), isNull);
      expect(parseCommand(['AUTH']), isNull);
    });
  });

  group('supported lists exposed to the user', () {
    test('the auth backends list lines up with the planner branches', () {
      expect(
        supportedAuthBackends,
        containsAll(['Supabase', 'Laravel', 'Firebase', 'Basic']),
      );
      // Pinning the length protects the order the list is shown to the user.
      expect(supportedAuthBackends, hasLength(4));
    });

    test('the iap services list contains exactly the supported services', () {
      expect(supportedIapServices, ['RevenueCat', 'Superwall']);
    });
  });

  group('planAuthSlate — Supabase', () {
    test('asks for url then anonKey, in that exact order', () {
      final prompts = _PromptRecorder(['https://abc.supabase.co', 'eyJanon']);
      planAuthSlate(backend: 'Supabase', prompt: prompts.call);
      expect(prompts.asked, [supabaseUrlPrompt, supabaseAnonKeyPrompt]);
      expect(prompts.drained, isTrue);
    });

    test('schedules a single supabase_flutter package install', () {
      final prompts = _PromptRecorder(['https://abc.supabase.co', 'eyJanon']);
      final plan = planAuthSlate(backend: 'Supabase', prompt: prompts.call);
      expect(plan!.packagesToAdd, ['supabase_flutter']);
    });

    test('threads url and anonKey through to the supabase_provider stub', () {
      final prompts = _PromptRecorder(['https://abc.supabase.co', 'eyJanon']);
      final plan = planAuthSlate(backend: 'Supabase', prompt: prompts.call);
      final providerStub = plan!.templates
          .firstWhere((t) => t.name == 'supabase_provider')
          .stub;
      expect(providerStub, contains("url: 'https://abc.supabase.co'"));
      expect(providerStub, contains("anonKey: 'eyJanon'"));
    });

    test('exposes the slate config so the runtime can template messages', () {
      final prompts = _PromptRecorder(['https://abc.supabase.co', 'eyJanon']);
      final plan = planAuthSlate(backend: 'Supabase', prompt: prompts.call);
      expect(plan!.config, isA<NySupabaseSlateConfig>());
      final cfg = plan.config as NySupabaseSlateConfig;
      expect(cfg.url, 'https://abc.supabase.co');
      expect(cfg.anonKey, 'eyJanon');
    });
  });

  group('planAuthSlate — Laravel', () {
    test('asks only for the Laravel URL', () {
      final prompts = _PromptRecorder(['https://api.example.com']);
      planAuthSlate(backend: 'Laravel', prompt: prompts.call);
      expect(prompts.asked, [laravelUrlPrompt]);
    });

    test('strips a trailing slash before building the api-service stub', () {
      final prompts = _PromptRecorder(['https://api.example.com/']);
      final plan = planAuthSlate(backend: 'Laravel', prompt: prompts.call);
      final apiStub = plan!.templates
          .firstWhere((t) => t.name == 'laravel_api_service')
          .stub;
      expect(apiStub, contains("'https://api.example.com/app/v1'"));
      expect(apiStub.contains('//app/v1'), isFalse);
    });

    test('does not schedule any package installs (Laravel is server-side)', () {
      final prompts = _PromptRecorder(['https://api.example.com']);
      final plan = planAuthSlate(backend: 'Laravel', prompt: prompts.call);
      expect(plan!.packagesToAdd, isEmpty);
    });

    test('exposes a NyLaravelSlateConfig with the trimmed URL', () {
      final prompts = _PromptRecorder(['https://api.example.com/']);
      final plan = planAuthSlate(backend: 'Laravel', prompt: prompts.call);
      expect(plan!.config, isA<NyLaravelSlateConfig>());
      final cfg = plan.config as NyLaravelSlateConfig;
      expect(cfg.url, 'https://api.example.com');
    });
  });

  group('planAuthSlate — Firebase', () {
    test(
      'does not prompt the user (flutterfire configure handles secrets)',
      () {
        final prompts = _PromptRecorder(const []);
        planAuthSlate(backend: 'Firebase', prompt: prompts.call);
        expect(prompts.asked, isEmpty);
      },
    );

    test(
      'schedules firebase_core, firebase_auth and cloud_firestore in order',
      () {
        final prompts = _PromptRecorder(const []);
        final plan = planAuthSlate(backend: 'Firebase', prompt: prompts.call);
        expect(plan!.packagesToAdd, [
          'firebase_core',
          'firebase_auth',
          'cloud_firestore',
        ]);
      },
    );

    test('emits the Firebase user model template', () {
      final prompts = _PromptRecorder(const []);
      final plan = planAuthSlate(backend: 'Firebase', prompt: prompts.call);
      expect(plan!.templates.any((t) => t.name == 'user'), isTrue);
      expect(plan.templates.any((t) => t.name == 'firebase_provider'), isTrue);
    });

    test('exposes no config (Firebase has none to template into messages)', () {
      final prompts = _PromptRecorder(const []);
      final plan = planAuthSlate(backend: 'Firebase', prompt: prompts.call);
      expect(plan!.config, isNull);
    });
  });

  group('planAuthSlate — Basic', () {
    test('does not prompt and schedules no package installs', () {
      final prompts = _PromptRecorder(const []);
      final plan = planAuthSlate(backend: 'Basic', prompt: prompts.call);
      expect(prompts.asked, isEmpty);
      expect(plan!.packagesToAdd, isEmpty);
    });

    test('emits the basic landing/login/register/dashboard templates', () {
      final prompts = _PromptRecorder(const []);
      final plan = planAuthSlate(backend: 'Basic', prompt: prompts.call);
      final names = plan!.templates.map((t) => t.name).toSet();
      expect(
        names,
        containsAll([
          'landing_page',
          'login_page',
          'register_page',
          'forgot_password_page',
          'dashboard_page',
        ]),
      );
    });
  });

  group('planAuthSlate — unknown backend', () {
    test('returns null without consuming any prompt', () {
      final prompts = _PromptRecorder(const []);
      final plan = planAuthSlate(
        backend: 'NotARealBackend',
        prompt: prompts.call,
      );
      expect(plan, isNull);
      expect(prompts.asked, isEmpty);
    });
  });

  group('planIapSlate — RevenueCat', () {
    test('asks for the Apple key first, then the Android key', () {
      final prompts = _PromptRecorder(['apple_xxx', 'android_yyy']);
      planIapSlate(service: 'RevenueCat', prompt: prompts.call);
      expect(prompts.asked, [
        appleRevenueCatKeyPrompt,
        androidRevenueCatKeyPrompt,
      ]);
    });

    test('schedules purchases_flutter then purchases_ui_flutter', () {
      final prompts = _PromptRecorder(['apple_xxx', 'android_yyy']);
      final plan = planIapSlate(service: 'RevenueCat', prompt: prompts.call);
      expect(plan!.packagesToAdd, [
        'purchases_flutter',
        'purchases_ui_flutter',
      ]);
    });

    test('threads both keys into the RevenueCat provider stub', () {
      final prompts = _PromptRecorder(['apple_xxx', 'android_yyy']);
      final plan = planIapSlate(service: 'RevenueCat', prompt: prompts.call);
      final providerStub = plan!.templates
          .firstWhere((t) => t.name == 'revenue_cat_provider')
          .stub;
      expect(providerStub, contains('"apple_xxx"'));
      expect(providerStub, contains('"android_yyy"'));
    });

    test("normalises 'n' on the Apple key to an empty string", () {
      final prompts = _PromptRecorder(['n', 'android_yyy']);
      final plan = planIapSlate(service: 'RevenueCat', prompt: prompts.call);
      final cfg = plan!.config as NyRevenueCatSlateConfig;
      expect(cfg.appleAppId, '');
      expect(cfg.androidAppId, 'android_yyy');
    });

    test("normalises 'n' on the Android key to an empty string", () {
      final prompts = _PromptRecorder(['apple_xxx', 'n']);
      final plan = planIapSlate(service: 'RevenueCat', prompt: prompts.call);
      final cfg = plan!.config as NyRevenueCatSlateConfig;
      expect(cfg.appleAppId, 'apple_xxx');
      expect(cfg.androidAppId, '');
    });

    test(
      "'n' on both keys leaves both empty (everything is just placeholder)",
      () {
        final prompts = _PromptRecorder(['n', 'n']);
        final plan = planIapSlate(service: 'RevenueCat', prompt: prompts.call);
        final cfg = plan!.config as NyRevenueCatSlateConfig;
        expect(cfg.appleAppId, '');
        expect(cfg.androidAppId, '');
        // Provider stub must use the placeholder text on both lines.
        final stub = plan.templates
            .firstWhere((t) => t.name == 'revenue_cat_provider')
            .stub;
        expect(stub, contains('Your RevenueCat IOS API Key'));
        expect(stub, contains('Your RevenueCat Android API Key'));
      },
    );

    test('exposes a NyRevenueCatSlateConfig with the resolved values', () {
      final prompts = _PromptRecorder(['apple_xxx', 'android_yyy']);
      final plan = planIapSlate(service: 'RevenueCat', prompt: prompts.call);
      expect(plan!.config, isA<NyRevenueCatSlateConfig>());
      final cfg = plan.config as NyRevenueCatSlateConfig;
      expect(cfg.appleAppId, 'apple_xxx');
      expect(cfg.androidAppId, 'android_yyy');
    });
  });

  group('planIapSlate — Superwall', () {
    test('asks for the Apple key first, then the Android key', () {
      final prompts = _PromptRecorder(['apple_xxx', 'android_yyy']);
      planIapSlate(service: 'Superwall', prompt: prompts.call);
      expect(prompts.asked, [
        appleSuperwallKeyPrompt,
        androidSuperwallKeyPrompt,
      ]);
    });

    test('schedules superwallkit_flutter as the only package', () {
      final prompts = _PromptRecorder(['apple_xxx', 'android_yyy']);
      final plan = planIapSlate(service: 'Superwall', prompt: prompts.call);
      expect(plan!.packagesToAdd, ['superwallkit_flutter']);
    });

    test('threads both keys into the Superwall provider stub', () {
      final prompts = _PromptRecorder(['apple_xxx', 'android_yyy']);
      final plan = planIapSlate(service: 'Superwall', prompt: prompts.call);
      final providerStub = plan!.templates
          .firstWhere((t) => t.name == 'superwall_provider')
          .stub;
      expect(providerStub, contains('"apple_xxx"'));
      expect(providerStub, contains('"android_yyy"'));
    });

    test("normalises 'n' on the Apple key to an empty string", () {
      final prompts = _PromptRecorder(['n', 'android_yyy']);
      final plan = planIapSlate(service: 'Superwall', prompt: prompts.call);
      final cfg = plan!.config as NySuperwallSlateConfig;
      expect(cfg.appleApiKey, '');
      expect(cfg.androidApiKey, 'android_yyy');
    });

    test("normalises 'n' on the Android key to an empty string", () {
      final prompts = _PromptRecorder(['apple_xxx', 'n']);
      final plan = planIapSlate(service: 'Superwall', prompt: prompts.call);
      final cfg = plan!.config as NySuperwallSlateConfig;
      expect(cfg.appleApiKey, 'apple_xxx');
      expect(cfg.androidApiKey, '');
    });

    test(
      "'n' on both keys leaves both empty (everything is just placeholder)",
      () {
        final prompts = _PromptRecorder(['n', 'n']);
        final plan = planIapSlate(service: 'Superwall', prompt: prompts.call);
        final cfg = plan!.config as NySuperwallSlateConfig;
        expect(cfg.appleApiKey, '');
        expect(cfg.androidApiKey, '');
        // Provider stub must use the placeholder text on both lines.
        final stub = plan.templates
            .firstWhere((t) => t.name == 'superwall_provider')
            .stub;
        expect(stub, contains('Your Superwall IOS API Key'));
        expect(stub, contains('Your Superwall Android API Key'));
      },
    );

    test('exposes a NySuperwallSlateConfig with the resolved values', () {
      final prompts = _PromptRecorder(['apple_xxx', 'android_yyy']);
      final plan = planIapSlate(service: 'Superwall', prompt: prompts.call);
      expect(plan!.config, isA<NySuperwallSlateConfig>());
      final cfg = plan.config as NySuperwallSlateConfig;
      expect(cfg.appleApiKey, 'apple_xxx');
      expect(cfg.androidApiKey, 'android_yyy');
    });
  });

  group('planIapSlate — unknown service', () {
    test('returns null without consuming any prompt', () {
      final prompts = _PromptRecorder(const []);
      final plan = planIapSlate(
        service: 'NotARealService',
        prompt: prompts.call,
      );
      expect(plan, isNull);
      expect(prompts.asked, isEmpty);
    });
  });

  group('iosSetupHintFor', () {
    test('returns the empty string when the Apple key was not provided', () {
      expect(iosSetupHintFor(appleKeyProvided: false), isEmpty);
    });

    test('returns the multi-line iOS hint when the Apple key was provided', () {
      final hint = iosSetupHintFor(appleKeyProvided: true);
      expect(hint, contains('IOS Setup'));
      expect(hint, contains('ios/Runner.xcworkspace'));
      expect(hint, contains('In-App Purchase'));
      expect(hint, contains('cd ios && pod repo update'));
      // Trailing blank line so the runtime can concatenate it before
      // "Learn more: ...".
      expect(hint, endsWith('\n\n'));
    });
  });

  group('superwallIosSetupHintFor', () {
    test('returns the empty string when the Apple key was not provided', () {
      expect(superwallIosSetupHintFor(appleKeyProvided: false), isEmpty);
    });

    test('mentions iOS 14.0 (Superwall\'s minimum deployment target)', () {
      final hint = superwallIosSetupHintFor(appleKeyProvided: true);
      expect(hint, contains('14.0'));
      expect(hint, contains('ios/Podfile'));
    });

    test('still mentions the In-App Purchase capability + pod repo update', () {
      // Superwall defaults to StoreKit for purchases, so the capability is
      // still required.
      final hint = superwallIosSetupHintFor(appleKeyProvided: true);
      expect(hint, contains('In-App Purchase'));
      expect(hint, contains('cd ios && pod repo update'));
    });

    test('ends with a blank line so it composes with "Learn more: ..."', () {
      final hint = superwallIosSetupHintFor(appleKeyProvided: true);
      expect(hint, endsWith('\n\n'));
    });
  });

  group('superwallAndroidSetupHintFor', () {
    test('returns the empty string when no Android key was provided', () {
      expect(superwallAndroidSetupHintFor(androidKeyProvided: false), isEmpty);
    });

    test('mentions minSdkVersion 26 (Superwall\'s requirement)', () {
      final hint = superwallAndroidSetupHintFor(androidKeyProvided: true);
      expect(hint, contains('minSdkVersion 26'));
      expect(hint, contains('android/app/build.gradle'));
    });

    test('ends with a blank line so it composes with "Learn more: ..."', () {
      final hint = superwallAndroidSetupHintFor(androidKeyProvided: true);
      expect(hint, endsWith('\n\n'));
    });
  });

  group('patchAndroidManifestForSuperwall', () {
    const minimalManifest = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="my_app"
        android:name="\${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity android:name=".MainActivity" />
    </application>
</manifest>
''';

    test('inserts the SuperwallPaywallActivity inside <application>', () {
      final patched = patchAndroidManifestForSuperwall(minimalManifest);
      expect(patched.result, AndroidManifestPatchResult.added);
      expect(
        patched.content,
        contains('com.superwall.sdk.paywall.view.SuperwallPaywallActivity'),
      );
      // The new activity must be inside <application> — i.e. before
      // </application>.
      final supIdx = patched.content.indexOf('SuperwallPaywallActivity');
      final closeIdx = patched.content.indexOf('</application>');
      expect(supIdx, greaterThan(0));
      expect(supIdx, lessThan(closeIdx));
    });

    test('uses the docs-recommended Material Components theme', () {
      // The Superwall install docs specify
      // Theme.MaterialComponents.DayNight.NoActionBar. The plugin's bundled
      // manifest uses Theme.AppCompat.NoActionBar; our injection wins via
      // manifest-merger priority so the consumer ends up with Material.
      final patched = patchAndroidManifestForSuperwall(minimalManifest);
      expect(
        patched.content,
        contains('Theme.MaterialComponents.DayNight.NoActionBar'),
      );
    });

    test('preserves existing activities (MainActivity stays put)', () {
      final patched = patchAndroidManifestForSuperwall(minimalManifest);
      expect(patched.content, contains('android:name=".MainActivity"'));
    });

    test('is idempotent — re-running leaves the manifest untouched', () {
      final first = patchAndroidManifestForSuperwall(minimalManifest);
      final second = patchAndroidManifestForSuperwall(first.content);
      expect(second.result, AndroidManifestPatchResult.alreadyRegistered);
      expect(second.content, first.content);
    });

    test('returns malformedManifest when <application> is missing', () {
      const noApp = '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
</manifest>
''';
      final patched = patchAndroidManifestForSuperwall(noApp);
      expect(patched.result, AndroidManifestPatchResult.malformedManifest);
      expect(patched.content, noApp);
    });

    test('the activity XML snippet contains all three required attributes', () {
      expect(
        superwallAndroidActivityXml,
        contains(
          'android:name="com.superwall.sdk.paywall.view.SuperwallPaywallActivity"',
        ),
      );
      expect(
        superwallAndroidActivityXml,
        contains(
          'android:theme="@style/Theme.MaterialComponents.DayNight.NoActionBar"',
        ),
      );
      expect(
        superwallAndroidActivityXml,
        contains(
          'android:configChanges="orientation|screenSize|keyboardHidden"',
        ),
      );
    });
  });
}
