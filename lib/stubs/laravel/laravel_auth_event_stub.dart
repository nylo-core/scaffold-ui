String stubLaravelAuthEvent() => '''
import '/app/models/laravel_auth_response.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LaravelAuthEvent implements NyEvent {

  @override
  final listeners = {
    DefaultListener: DefaultListener(),
  };
}

class DefaultListener extends NyListener {

  @override
  handle(dynamic event) async {
   // Handle the event
    LaravelAuthResponse? laravelAuthResponse = event['user'];
    if (laravelAuthResponse == null) {
      return;
    }
    await Auth.authenticate(data: laravelAuthResponse);
    await routeToAuthenticatedRoute();
  }
}
''';
