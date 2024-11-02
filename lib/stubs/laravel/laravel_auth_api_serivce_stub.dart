import '/models/ny_laravel_slate_config.dart';

String stubLaravelAuthApiService(NyLaravelSlateConfig nyLaravelSlateConfig) =>
    '''
import 'package:flutter/material.dart';
import '/config/decoders.dart';
import '/app/models/laravel_auth_response.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* LaravelAuthApiService
| -------------------------------------------------------------------------
| API Service for Laravel Auth - Login, Register, Forgot Password
| Learn more https://nylo.dev/docs/6.x/networking
|-------------------------------------------------------------------------- */

class LaravelAuthApiService extends NyApiService {
  LaravelAuthApiService({BuildContext? buildContext}) : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl => '${nyLaravelSlateConfig.url}/app/v1';

  /// Login
  Future<LaravelAuthResponse?> login(String email, String password) async => await network<LaravelAuthResponse>(
    request: (request) => request.post("/login", data: {
      "email": email,
      "password": password
    }),
  );

  /// Register
  Future<LaravelAuthResponse?> register({required String name, required String email, required String password}) async => await network<LaravelAuthResponse>(
    request: (request) => request.post("/register", data: {
      "name": name,
      "email": email,
      "password": password
    }),
  );

  /// Forgot Password
  Future<bool> forgotPassword(String email) async => await network(
        request: (request) => request.post("/forgot-password", data: {
          "email": email
        }),
        handleSuccess: (response) {
          if (response.statusCode != 200) return false;
          return response.data['status'] == 200;
        }
    ) ?? false;

  @override
  displayError(DioException exception, BuildContext context) {
    Map<String, dynamic> data = exception.response?.data;
    if (!data.containsKey('message')) return;
    showToastNotification(context, title: "Error", description: data['message'], style: ToastNotificationStyleType.danger);
  }
}
''';
