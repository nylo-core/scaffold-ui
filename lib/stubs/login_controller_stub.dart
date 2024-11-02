stubLoginController() => '''
import '/app/events/laravel_auth_event.dart';
import '/app/models/laravel_auth_response.dart';
import '/app/networking/laravel_auth_api_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'controller.dart';
import 'package:flutter/widgets.dart';

class LoginController extends Controller {

  construct(BuildContext context) {
    super.construct(context);

  }

  /// Login the user
  login(String email, String password) async {
    LaravelAuthResponse? laravelAuthResponse = await api<LaravelAuthApiService>((request) => request.login(email, password), context: context);
      if (laravelAuthResponse?.status != 200) {
        showToastOops(description: laravelAuthResponse?.message ?? "");
        return;
      }
      event<LaravelAuthEvent>(data: {"user": laravelAuthResponse});
  }
}
''';
