String stubLaravelRegisterController() => '''
import 'package:nylo_framework/nylo_framework.dart';
import '/app/events/laravel_auth_event.dart';
import '/app/models/laravel_auth_response.dart';
import '/app/networking/laravel_auth_api_service.dart';
import 'controller.dart';

class RegisterController extends Controller {

  /// Register the user
  register(String name, String email, String password) async {
    LaravelAuthResponse? laravelAuthResponse = await api<LaravelAuthApiService>(
        (request) =>
            request.register(name: name, email: email, password: password),
        context: context, onSuccess: (Response response, dynamic data) {
      data as LaravelAuthResponse;
      if (data.status != 200) {
        showToastOops(description: data.message ?? "");
        return null;
      }
      return data;
    });

    if (laravelAuthResponse == null) {
      return;
    }
     
    await event<LaravelAuthEvent>(data: {"user": laravelAuthResponse});
  }
}
''';
