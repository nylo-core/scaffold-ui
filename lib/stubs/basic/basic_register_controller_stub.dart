String stubBasicRegisterController() => '''
import 'controller.dart';
import 'package:nylo_framework/nylo_framework.dart';

class RegisterController extends Controller {

  /// Register the user
  register(String name, String email, String password) async {
    await authAuthenticate(data: {
      "email": email,
    });
    
    routeToAuthenticatedRoute();
  }
}
''';
