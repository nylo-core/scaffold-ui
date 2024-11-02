import 'package:scaffold_ui/models/ny_laravel_slate_config.dart';

String stubLaravelApiService(NyLaravelSlateConfig nyLaravelSlateConfig) => '''
import 'package:flutter/material.dart';
import '/config/decoders.dart';
import '/app/models/laravel_auth_response.dart';
import '/app/models/user.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* LaravelApiService
| -------------------------------------------------------------------------
| API Service for your authenticated users
| Learn more https://nylo.dev/docs/6.x/networking
|-------------------------------------------------------------------------- */

class LaravelApiService extends NyApiService {
  LaravelApiService({BuildContext? buildContext}) : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl => 'http://laravelauthtest.test/app/v1';

  String get bearerToken {
    Map<String, dynamic> data = authData();
    if (!data.containsKey('token')) {
      throw Exception("Bearer token not set");
    }
    return data['token'];
  }

  /// Fetch auth users information
  Future<User?> user() async {
    return await network<User>(
        request: (request) => request.get("/user"),
        bearerToken: bearerToken
    );
  }
}
''';
