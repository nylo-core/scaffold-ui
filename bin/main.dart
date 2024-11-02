import 'dart:io';

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
    MetroConsole.writeInRed("Usage: dart run scaffold_ui:main auth");
    exit(1);
  }

  String command = arguments[0];
  if (command != 'auth') {
    MetroConsole.writeInRed("Invalid command");
    MetroConsole.writeInRed("Usage: dart run scaffold_ui:main auth");
    exit(1);
  }

  final dialogQuestions = CliDialog(listQuestions: [
    [
      {
        'question': 'Which backend would you like to use?',
        'options': [
          'Supabase',
          'Laravel',
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
    case 'Basic':
      List<NyTemplate> templates = basicRun();
      await MetroService.createSlate(templates, hasForceFlag: true);
      MetroConsole.writeInGreen(
          "Basic Auth scaffolding has been setup 🎉\nLearn more: https://nylo.dev");
      break;
    default:
  }

  exit(0);
}
