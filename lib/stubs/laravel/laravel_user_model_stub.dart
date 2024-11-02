/// User Model.
String stubLaravelUserModel() => '''
import 'package:nylo_framework/nylo_framework.dart';

class User extends Model {
  int? id;
  String? name;
  String? email;
  String? createdAt;
  String? updatedAt;

  static StorageKey key = 'user';

  User({this.id, this.email, this.createdAt, this.updatedAt}) : super(key: key);

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json.containsKey('name')) {
      name = json['name'];
    }
    email = json['email'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
''';
