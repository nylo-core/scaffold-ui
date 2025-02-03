String stubRevenueCatPaywall() => '''
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class PaywallPage extends NyStatefulWidget {
  static RouteView path = ("/paywall", (_) => PaywallPage());

  PaywallPage({super.key}) : super(child: () => _PaywallPageState());
}

class _PaywallPageState extends NyPage<PaywallPage> {
  
  @override
  get init => () async {
        await RevenueCatUI.presentPaywall(displayCloseButton: true)
            .then((val) {
              pop();
            });
      };

  @override
  LoadingStyle get loadingStyle => LoadingStyle.none();

  @override
  Widget view(BuildContext context) {
    return SizedBox.shrink();
  }
}
''';
