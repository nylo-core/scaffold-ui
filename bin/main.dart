import 'dart:io';

import 'package:scaffold_ui/models/ny_revenuecat_slate_config.dart';
import 'package:scaffold_ui/scaffold_ui.dart';
import 'package:scaffold_ui/cli_dialog/src/dialog.dart';
import 'package:scaffold_ui/models/ny_laravel_slate_config.dart';
import 'package:scaffold_ui/models/ny_supabase_slate_config.dart';
import 'package:nylo_support/metro/metro_console.dart';
import 'package:nylo_support/metro/metro_service.dart';
import 'package:nylo_support/metro/models/ny_template.dart';

void main(List<String> arguments) async {
  if (arguments.length != 1) {
    MetroConsole.writeInRed("Invalid arguments");
    MetroConsole.writeInRed(
        "Authentication Usage: dart run scaffold_ui:main auth\nIn-app Purchases Usage: dart run scaffold_ui:main iap");
    exit(1);
  }

  String command = arguments[0];
  if (!["iap", "auth"].contains(command)) {
    MetroConsole.writeInRed("Invalid command");
    MetroConsole.writeInRed(
        "Authentication Usage: dart run scaffold_ui:main auth\nIn-app Purchases Usage: dart run scaffold_ui:main iap");
    exit(1);
  }

  switch (command) {
    case 'auth':
      await auth();
      break;
    case 'iap':
      await iap();
      break;
    default:
  }
  exit(0);
}

Future<void> iap() async {
  final dialogQuestions = CliDialog(listQuestions: [
    [
      {
        'question': 'Which service would you like to use?',
        'options': [
          'RevenueCat',
        ]
      },
      'iap'
    ],
  ]).ask();

  String iap = dialogQuestions['iap'];

  switch (iap) {
    case 'RevenueCat':
      MetroConsole.writeInGreen("Installing RevenueCat");
      // install RevenueCat
      await MetroService.addPackage("purchases_flutter");
      await MetroService.addPackage("purchases_ui_flutter");

      // ios
      final dialogRevenueCatAppleKey = CliDialog(questions: [
        [
          "What is your Apple RevenueCat API Key? If you don't know, enter 'n'",
          'apple_revenuecat_api_key'
        ]
      ]);
      String? appleRevenueCatApiKey =
          dialogRevenueCatAppleKey.ask()['apple_revenuecat_api_key'];
      if (appleRevenueCatApiKey == 'n') {
        appleRevenueCatApiKey = "";
      }

      // android
      final dialogRevenueCatAndroidKey = CliDialog(questions: [
        [
          "What is your Android RevenueCat API Key? If you don't know, enter 'n'",
          'android_revenuecat_api_key'
        ]
      ]);
      String? androidRevenueCatApiKey =
          dialogRevenueCatAndroidKey.ask()['android_revenuecat_api_key'];
      if (androidRevenueCatApiKey == 'n') {
        androidRevenueCatApiKey = "";
      }

      // config
      NyRevenueCatSlateConfig nyRevenueCatSlateConfig = NyRevenueCatSlateConfig(
        appleAppId: appleRevenueCatApiKey,
        androidAppId: androidRevenueCatApiKey,
      );

      String iosSetupInfo = "";
      if (appleRevenueCatApiKey != "") {
        iosSetupInfo = "IOS Setup";
        iosSetupInfo += "\n- Open the `ios/Runner.xcworkspace` file in Xcode";
        iosSetupInfo += "\n- Navigate to the `Runner` target";
        iosSetupInfo +=
            "\n- Under the `Signing & Capabilities` tab, add the `In-App Purchase` capability";
        iosSetupInfo += "\n- Run \"cd ios && pod repo update\"";
        iosSetupInfo += "\n\n";
      }

      List<NyTemplate> templates = revenueCatRun(nyRevenueCatSlateConfig);
      await MetroService.createSlate(templates, hasForceFlag: true);
      MetroConsole.writeInGreen(
          "RevenueCat scaffolding complete 🎉\n\nTo view the paywall, use 'routeTo(PaywallPage.path)';\n\n${iosSetupInfo}Learn more: https://revenuecat.com/docs/flutter");
      break;
    default:
      break;
  }
}

Future<void> auth() async {
  final dialogQuestions = CliDialog(listQuestions: [
    [
      {
        'question': 'Which backend would you like to use?',
        'options': [
          'Supabase',
          'Laravel',
          'Firebase',
          'Basic',
        ]
      },
      'backend'
    ],
  ]).ask();

  String backend = dialogQuestions['backend'];

  switch (backend) {
    case 'Supabase':
      MetroConsole.writeInGreen("Installing Supabase");
      // install supabase
      await MetroService.addPackage("supabase_flutter");

      final dialogSupabaseUrl = CliDialog(questions: [
        ['What is your Supabase Url?', 'supabase_url']
      ]);
      final String supabaseUrl = dialogSupabaseUrl.ask()['supabase_url'];

      final dialogSupabaseAnonKey = CliDialog(questions: [
        ['What is your Supabase Anon Key?', 'supabase_anon_key']
      ]);
      final String supabaseAnonKey =
          dialogSupabaseAnonKey.ask()['supabase_anon_key'];

      NySupabaseSlateConfig nySupabaseSlateConfig =
          NySupabaseSlateConfig(url: supabaseUrl, anonKey: supabaseAnonKey);

      List<NyTemplate> templates = supabaseRun(nySupabaseSlateConfig);
      await MetroService.createSlate(templates, hasForceFlag: true);
      MetroConsole.writeInGreen(
          "Supabase scaffolding is ready 🎉\nLearn more: https://supabase.io/docs/guides/with-flutter");
      break;
    case 'Laravel':
      final dialogSupabaseUrl = CliDialog(questions: [
        ['What is your Laravel Url?', 'laravel_url']
      ]);
      String laravelUrl = dialogSupabaseUrl.ask()['laravel_url'];

      // remove trailing slash if exists
      if (laravelUrl.endsWith('/')) {
        laravelUrl = laravelUrl.substring(0, laravelUrl.length - 1);
      }

      NyLaravelSlateConfig nyLaravelSlateConfig = NyLaravelSlateConfig(
        url: laravelUrl,
      );

      MetroConsole.writeInGreen(
          'Go to your Laravel project\n\nRun: composer require nylo/laravel-nylo-auth\n\nThen publish the package: php artisan vendor:publish --provider="Nylo\\LaravelNyloAuth\\LaravelNyloAuthServiceProvider"');
      MetroConsole.writeInGreen(
          'Make sure you have Laravel Sanctum installed\n Run: php artisan install:api\nYour User model must use the HasApiTokens trait');
      List<NyTemplate> templates = laravelRun(nyLaravelSlateConfig);
      await MetroService.createSlate(templates, hasForceFlag: true);

      MetroConsole.writeInGreen(
          "Laravel scaffolding is ready 🎉\nLearn more: https://laravel.com");
      break;
    case 'Firebase':
      MetroConsole.writeInGreen("Installing Firebase");
      // install firebase
      await MetroService.addPackage("firebase_core");
      await MetroService.addPackage("firebase_auth");
      await MetroService.addPackage("cloud_firestore");

      List<NyTemplate> templates = firebaseRun();
      await MetroService.createSlate(templates, hasForceFlag: true);

      String firebaseInfo = "Setup Firebase";
      firebaseInfo +=
          "\n- Create a Firebase project: https://console.firebase.google.com";
      firebaseInfo +=
          "\n- Download flutterfire: https://firebase.google.com/docs/flutter/setup";
      firebaseInfo += "\n- Run `flutterfire configure`";
      firebaseInfo +=
          "\n- Enable Email/Password sign-in method in Firebase Console";

      MetroConsole.writeInGreen(
          "Firebase Auth scaffolding has been setup 🎉\n\n$firebaseInfo\n\nLearn more: https://firebase.google.com/docs/auth/flutter/start");
      break;
    case 'Basic':
      List<NyTemplate> templates = basicRun();
      await MetroService.createSlate(templates, hasForceFlag: true);
      MetroConsole.writeInGreen(
          "Basic Auth scaffolding has been setup 🎉\nLearn more: https://nylo.dev");
      break;
    default:
  }
}
