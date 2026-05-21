import 'dart:io';

import 'package:nylo_support/metro/ny_metro.dart';
import 'package:scaffold_ui/cli/scaffold_cli.dart';
import 'package:scaffold_ui/cli_dialog/src/dialog.dart';
import 'package:scaffold_ui/models/ny_revenuecat_slate_config.dart';
import 'package:scaffold_ui/models/ny_superwall_slate_config.dart';

const String _usageHint =
    'Authentication Usage: dart run scaffold_ui:main auth\n'
    'In-app Purchases Usage: dart run scaffold_ui:main iap';

void main(List<String> arguments) async {
  final command = parseCommand(arguments);
  if (command == null) {
    MetroConsole.writeInRed('Invalid arguments');
    MetroConsole.writeInRed(_usageHint);
    exit(1);
  }

  switch (command) {
    case 'auth':
      await auth();
      break;
    case 'iap':
      await iap();
      break;
  }
  exit(0);
}

Future<void> auth() async {
  final selection = CliDialog(
    listQuestions: [
      [
        {
          'question': 'Which backend would you like to use?',
          'options': List<String>.from(supportedAuthBackends),
        },
        'backend',
      ],
    ],
  ).ask();

  final backend = selection['backend'] as String;
  final plan = planAuthSlate(backend: backend, prompt: _ask);
  if (plan == null) return;

  if (plan.packagesToAdd.isNotEmpty) {
    MetroConsole.writeInGreen('Installing $backend');
    for (final package in plan.packagesToAdd) {
      await _addPackage(package);
    }
  }

  if (backend == 'Laravel') {
    const laravelSetup =
        'Setup Laravel (server-side)'
        '\n'
        '\nPrerequisites:'
        '\n  - Your User model uses the `HasApiTokens` trait'
        '\n'
        '\nIn your Laravel project, run:'
        '\n  1. composer require nylo/laravel-nylo-auth'
        '\n  2. php artisan install:api'
        '\n  3. php artisan vendor:publish \\'
        '\n        --provider="Nylo\\LaravelNyloAuth\\LaravelNyloAuthServiceProvider"'
        '\n';
    MetroConsole.writeInYellow(laravelSetup);
  }

  await MetroService.createSlate(plan.templates, hasForceFlag: true);

  switch (backend) {
    case 'Supabase':
      MetroConsole.writeInGreen(
        'Supabase scaffolding is ready 🎉\nLearn more: https://supabase.io/docs/guides/with-flutter',
      );
      break;
    case 'Laravel':
      MetroConsole.writeInGreen(
        'Laravel scaffolding is ready 🎉\nLearn more: https://laravel.com',
      );
      break;
    case 'Firebase':
      const firebaseInfo =
          'Setup Firebase'
          '\n- Create a Firebase project: https://console.firebase.google.com'
          '\n- Download flutterfire: https://firebase.google.com/docs/flutter/setup'
          '\n- Run `flutterfire configure`'
          '\n- Enable Email/Password sign-in method in Firebase Console';
      MetroConsole.writeInGreen(
        'Firebase Auth scaffolding has been setup 🎉\n\n$firebaseInfo\n\nLearn more: https://firebase.google.com/docs/auth/flutter/start',
      );
      break;
    case 'Basic':
      MetroConsole.writeInGreen(
        'Basic Auth scaffolding has been setup 🎉\nLearn more: https://nylo.dev',
      );
      break;
  }
}

Future<void> iap() async {
  final selection = CliDialog(
    listQuestions: [
      [
        {
          'question': 'Which service would you like to use?',
          'options': List<String>.from(supportedIapServices),
        },
        'iap',
      ],
    ],
  ).ask();

  final service = selection['iap'] as String;
  final plan = planIapSlate(service: service, prompt: _ask);
  if (plan == null) return;

  if (plan.packagesToAdd.isNotEmpty) {
    MetroConsole.writeInGreen('Installing $service');
    for (final package in plan.packagesToAdd) {
      await _addPackage(package);
    }
  }

  await MetroService.createSlate(plan.templates, hasForceFlag: true);

  if (service == 'RevenueCat') {
    final config = plan.config as NyRevenueCatSlateConfig;
    final iosHint = iosSetupHintFor(
      appleKeyProvided: (config.appleAppId ?? '').isNotEmpty,
    );
    MetroConsole.writeInGreen(
      "RevenueCat scaffolding complete 🎉\n\nTo view the paywall, use 'routeTo(PaywallPage.path)';\n\n${iosHint}Learn more: https://revenuecat.com/docs/flutter",
    );
  }

  if (service == 'Superwall') {
    final config = plan.config as NySuperwallSlateConfig;
    final androidKeyProvided = (config.androidApiKey ?? '').isNotEmpty;
    if (androidKeyProvided) {
      _patchAndroidManifestForSuperwall();
    }

    final iosHint = superwallIosSetupHintFor(
      appleKeyProvided: (config.appleApiKey ?? '').isNotEmpty,
    );
    final androidHint = superwallAndroidSetupHintFor(
      androidKeyProvided: androidKeyProvided,
    );
    MetroConsole.writeInGreen(
      "Superwall scaffolding complete 🎉\n\nTo trigger the paywall, use 'routeTo(PaywallPage.path)';\nCustomise the placement name 'campaign_trigger' in lib/resources/pages/paywall_page.dart.\n\n$iosHint${androidHint}Learn more: https://superwall.com/docs/flutter",
    );
  }
}

// Attempts to register Superwall's `<activity>` inside the consumer project's
// `AndroidManifest.xml`, matching Superwall's official install docs. Falls
// back to printing a manual snippet on every failure path (file missing,
// malformed manifest) so the developer never silently ends up without it.
// Idempotent — re-running the scaffolder won't duplicate the registration.
//
// Why this is safe even though the plugin's bundled manifest also declares
// the activity: Gradle's manifest merger uses priority-based resolution and
// the main app manifest outranks library manifests, so our injection wins on
// any attribute conflict (theme) — no build error.
void _patchAndroidManifestForSuperwall() {
  final manifestFile = File('android/app/src/main/AndroidManifest.xml');
  if (!manifestFile.existsSync()) {
    MetroConsole.writeInYellow(
      'android/app/src/main/AndroidManifest.xml not found.\nAdd the following inside <application> when ready:\n$superwallAndroidActivityXml',
    );
    return;
  }

  final original = manifestFile.readAsStringSync();
  final patched = patchAndroidManifestForSuperwall(original);
  switch (patched.result) {
    case AndroidManifestPatchResult.added:
      manifestFile.writeAsStringSync(patched.content);
      MetroConsole.writeInGreen(
        'Registered SuperwallPaywallActivity in android/app/src/main/AndroidManifest.xml',
      );
      break;
    case AndroidManifestPatchResult.alreadyRegistered:
      // No-op — the activity is already there.
      break;
    case AndroidManifestPatchResult.malformedManifest:
      MetroConsole.writeInYellow(
        'Could not locate <application> in android/app/src/main/AndroidManifest.xml.\nAdd the following inside <application> manually:\n$superwallAndroidActivityXml',
      );
      break;
  }
}

// `CliDialog.ask()` returns answers keyed by the per-question key. `_ask`
// always asks exactly one question per dialog, so the key is incidental — we
// use a single named constant for clarity.
const String _answerKey = 'answer';

String _ask(String question) {
  return CliDialog(
    questions: [
      [question, _answerKey],
    ],
  ).ask()[_answerKey];
}

// Avoids `MetroService.addPackage`: that helper pipes the parent's stdin into
// the child via `stdin.pipe(process.stdin)`, which leaves stdin consumed and
// causes the next `readLineSync` in this CLI to return null.
Future<int> _addPackage(String package) async {
  final process = await Process.start(
    'dart',
    ['pub', 'add', package],
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    MetroConsole.writeInRed('Error adding package $package: $exitCode');
  }
  return exitCode;
}
