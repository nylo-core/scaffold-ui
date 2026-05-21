import '/models/ny_laravel_slate_config.dart';

String stubLaravelAuthApiService(NyLaravelSlateConfig nyLaravelSlateConfig) =>
    '''
import 'package:nylo_framework/nylo_framework.dart';
import '/bootstrap/decoders.dart';
import '/app/models/laravel_auth_response.dart';

/* LaravelAuthApiService
| -------------------------------------------------------------------------
| API Service for Laravel Auth - Login, Register, Forgot Password
| Learn more https://nylo.dev/docs/7.x/networking
|-------------------------------------------------------------------------- */

class LaravelAuthApiService extends NyApiService {
  LaravelAuthApiService()
      : super(
          decoders: modelDecoders,
        );

  @override
  String get baseUrl => '${nyLaravelSlateConfig.url}/app/v1';

  /// Login
  Future<LaravelAuthResponse?> login(String email, String password) async =>
      await network<LaravelAuthResponse>(
        request: (request) => request.post("/login", data: {
          "email": email,
          "password": password,
        }),
      );

  /// Register
  Future<LaravelAuthResponse?> register({
    required String name,
    required String email,
    required String password,
  }) async =>
      await network<LaravelAuthResponse>(
        request: (request) => request.post("/register", data: {
          "name": name,
          "email": email,
          "password": password,
        }),
      );

  /// Forgot Password
  Future<bool> forgotPassword(String email) async =>
      await network<bool>(
        request: (request) => request.post("/forgot-password", data: {
          "email": email,
        }),
        handleSuccess: (response) {
          if (!response.isSuccessful) return false;
          final data = response.rawData;
          if (data is Map) {
            return data['status'] == 200;
          }
          return true;
        },
      ) ??
      false;
}
''';
