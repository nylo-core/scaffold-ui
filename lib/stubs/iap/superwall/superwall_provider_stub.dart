import 'package:scaffold_ui/models/ny_superwall_slate_config.dart';

String stubSuperwallProvider(NySuperwallSlateConfig nySuperwallSlate) =>
    '''
import 'package:nylo_framework/nylo_framework.dart';
import 'dart:io' show Platform;

import 'package:superwallkit_flutter/superwallkit_flutter.dart';

class SuperwallProvider implements NyProvider {
  @override
  setup(Nylo nylo) async {
    final logging = Logging();
    if (getEnv('APP_DEBUG', defaultValue: false)) {
      logging.level = LogLevel.debug;
      logging.scopes = {LogScope.all};
    }
    final options = SuperwallOptions();
    options.logging = logging;

    String? apiKey;
    if (Platform.isIOS) {
      ${(nySuperwallSlate.appleApiKey?.isEmpty ?? true) ? "// " : ""}apiKey = "${(nySuperwallSlate.appleApiKey?.isEmpty ?? true) ? "Your Superwall IOS API Key" : nySuperwallSlate.appleApiKey}";
    }
    if (Platform.isAndroid) {
      ${(nySuperwallSlate.androidApiKey?.isEmpty ?? true) ? "// " : ""}apiKey = "${(nySuperwallSlate.androidApiKey?.isEmpty ?? true) ? "Your Superwall Android API Key" : nySuperwallSlate.androidApiKey}";
    }

    if (apiKey == null) {
      printInfo('[Superwall Provider] Platform not supported');
      return nylo;
    }

    Superwall.configure(apiKey, options: options);

    return nylo;
  }

  @override
  boot(Nylo nylo) async {

  }

  // ---------------------------------------------------------------------------
  // User identification — wire these into your auth flow so Superwall can
  // attribute paywall events to the same user across sessions and devices.
  //
  // On login (after you have your own user id):
  //   Superwall.shared.identify('<your-user-id>');
  //
  // On logout:
  //   Superwall.shared.reset();
  //
  // Guidance: use a non-guessable, non-email id (a UUID is ideal). Do NOT use
  // device identifiers or email addresses.
  // ---------------------------------------------------------------------------
}
''';
