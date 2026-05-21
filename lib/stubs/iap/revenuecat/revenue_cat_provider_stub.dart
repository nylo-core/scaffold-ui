import 'package:scaffold_ui/models/ny_revenuecat_slate_config.dart';

String stubRevenueCatProvider(NyRevenueCatSlateConfig nyRevenueCatSlate) =>
    '''
import 'package:nylo_framework/nylo_framework.dart';
import 'dart:io' show Platform;

import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatProvider implements NyProvider {
  @override
  setup(Nylo nylo) async {
    if (getEnv('APP_DEBUG', defaultValue: false)) {
      await Purchases.setLogLevel(LogLevel.verbose);
    }

    PurchasesConfiguration? configuration;
    if (Platform.isIOS) {
      ${(nyRevenueCatSlate.appleAppId?.isEmpty ?? true) ? "// " : ""}configuration = PurchasesConfiguration("${(nyRevenueCatSlate.appleAppId?.isEmpty ?? true) ? "Your RevenueCat IOS API Key" : nyRevenueCatSlate.appleAppId}");
    }
    if (Platform.isAndroid) {
      ${(nyRevenueCatSlate.androidAppId?.isEmpty ?? true) ? "// " : ""}configuration = PurchasesConfiguration("${(nyRevenueCatSlate.androidAppId?.isEmpty ?? true) ? "Your RevenueCat Android API Key" : nyRevenueCatSlate.androidAppId}");
    }
    
    if (configuration == null) {
      printInfo('[RevenueCat Provider] Platform not supported');
      return nylo;
    }
    
    await Purchases.configure(configuration);

    return nylo;
  }

  @override
  boot(Nylo nylo) async {

  }
}
''';
