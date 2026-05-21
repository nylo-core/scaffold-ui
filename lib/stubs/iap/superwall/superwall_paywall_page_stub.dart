String stubSuperwallPaywall() => '''
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

class PaywallPage extends NyStatefulWidget {
  static RouteView path = ("/paywall", (_) => PaywallPage());

  PaywallPage({super.key}) : super(child: () => _PaywallPageState());
}

class _PaywallPageState extends NyPage<PaywallPage> {

  @override
  get init => () async {
        await Superwall.shared.registerPlacement('campaign_trigger',
            feature: () {
          // Gated feature — runs if the user subscribes or the placement is non-gated.
        });
        pop();
      };

  @override
  LoadingStyle get loadingStyle => LoadingStyle.none();

  @override
  Widget view(BuildContext context) {
    return SizedBox.shrink();
  }
}
''';
