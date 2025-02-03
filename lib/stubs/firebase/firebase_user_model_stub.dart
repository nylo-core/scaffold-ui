/// User Model.
String stubFirebaseUserModel() => '''
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nylo_framework/nylo_framework.dart';

class User extends Model {
  String? name;
  String? email;

  static StorageKey key = 'user';

  User() : super(key: key);

  User.fromJson(dynamic data) {
    name = data['name'];
    email = data['email'];
  }

  User.fromFirebaseUserCredential(UserCredential userCredential) {
    email = userCredential.user?.email;
  }

  @override
  toJson() => {"name": name, "email": email};
}
''';
