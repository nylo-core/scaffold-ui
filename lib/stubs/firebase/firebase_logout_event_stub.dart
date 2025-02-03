String stubFirebaseLogoutEvent() => '''
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LogoutEvent implements NyEvent {
  @override
  final listeners = {
    FirebaseListener: FirebaseListener(),
  };
}

class FirebaseListener extends NyListener {
  @override
  handle(dynamic event) async {
    // logout from firebase
    await FirebaseAuth.instance.signOut();
  }
}
''';
