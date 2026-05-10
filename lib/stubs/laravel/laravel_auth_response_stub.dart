String stubLaravelAuthResponseModel() => '''
import 'package:nylo_framework/nylo_framework.dart';

class LaravelAuthResponse extends Model {
  LaravelAuthResponse();

  String? token, message;
  int? status;

  LaravelAuthResponse.fromJson(data) {
    status = data['status'];
    message = data['message'];
    if (data['token'] != null) {
      token = data['token'];
    }
  }

  toJson() => {
    "status": status,
    "message": message,
    "token": token
  };
}
''';
