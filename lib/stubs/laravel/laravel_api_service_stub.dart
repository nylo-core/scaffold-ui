import 'package:scaffold_ui/models/ny_laravel_slate_config.dart';

String stubLaravelApiService(NyLaravelSlateConfig nyLaravelSlateConfig) =>
    '''
import 'package:nylo_framework/nylo_framework.dart';
import '/bootstrap/decoders.dart';
import '/app/models/user.dart';

/* LaravelApiService
| -------------------------------------------------------------------------
| API Service for your authenticated users
| Learn more https://nylo.dev/docs/7.x/networking
|-------------------------------------------------------------------------- */

class LaravelApiService extends NyApiService {
  LaravelApiService()
      : super(
          decoders: modelDecoders,
        );

  @override
  String get baseUrl => '${nyLaravelSlateConfig.url}/app/v1';

  /// Fetch the authenticated user's information
  Future<User?> user() async {
    return await network<User>(
      request: (request) => request.get("/user"),
    );
  }

  /* Authentication Headers
  |--------------------------------------------------------------------------
  | Attach the bearer token (stored via Auth.authenticate) to every request.
  |-------------------------------------------------------------------------- */

  @override
  Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
    final String? token = Auth.data(field: 'token');
    if (token != null) {
      headers.addBearerToken(token);
    }
    return headers;
  }
}
''';
