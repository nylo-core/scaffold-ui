String stubBasicRegisterController() => '''
import '/app/events/laravel_auth_event.dart';
import '/app/models/laravel_auth_response.dart';
import '/app/networking/laravel_auth_api_service.dart';
import 'controller.dart';
import 'package:flutter/widgets.dart';
import 'package:nylo_framework/nylo_framework.dart';

class RegisterController extends Controller {

  construct(BuildContext context) {
    super.construct(context);

  }

  /// Register the user
  register(String name, String email, String password) async {
    await authAuthenticate(data: {
      "name": name,
      "email": email,
    });
    
    routeToAuthenticatedRoute();
  }
}
''';
