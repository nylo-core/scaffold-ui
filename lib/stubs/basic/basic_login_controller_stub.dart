stubBasicLoginController() => '''
import 'package:nylo_framework/nylo_framework.dart';
import 'controller.dart';

class LoginController extends Controller {

  /// Login the user
  login(String email, String password) async {
    await authAuthenticate(data: {
      "email": email,
    });

    routeToAuthenticatedRoute();
  }
}
''';
