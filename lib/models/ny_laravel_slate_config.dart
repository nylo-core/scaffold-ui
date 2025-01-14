/// Laravel Slate configuration model
class NyLaravelSlateConfig {
  final String _url;

  NyLaravelSlateConfig({
    required String url,
  }) : _url = url;

  /// Get the base URL
  String get url {
    // remove trailing slash
    return _url.replaceAll(RegExp(r'/$'), '');
  }
}
