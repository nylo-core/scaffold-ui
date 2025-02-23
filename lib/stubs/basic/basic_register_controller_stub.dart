String stubBasicRegisterController() => '''
import 'package:nylo_framework/nylo_framework.dart';
import 'controller.dart';

class RegisterController extends Controller {

  /// Register the user
  register(String name, String email, String password) async {
    await Auth.authenticate(data: {
      "email": email,
    });
    
    routeToAuthenticatedRoute();
  }
}
''';
