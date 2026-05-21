String stubFirebaseProvider() => '''
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/firebase_options.dart';

class FirebaseProvider implements NyProvider {
  @override
  setup(Nylo nylo) async {

    // firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        routeToInitial();
      }
    });

    return null;
  }

  @override
  boot(Nylo nylo) async {
    
  }
}
''';
