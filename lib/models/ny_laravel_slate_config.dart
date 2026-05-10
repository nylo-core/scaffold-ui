/// Laravel Slate configuration model
class NyLaravelSlateConfig {
  final String _url;

  NyLaravelSlateConfig({
    required String url,
  }) : _url = url;

  /// Get the base URL
  String get url {
    // Strip every trailing slash so a user pasting "https://api.example.com//"
    // doesn't end up with "//app/v1" in the generated stub.
    return _url.replaceAll(RegExp(r'/+$'), '');
  }
}
