/// Configuration de l'application injectée via `--dart-define`.
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.useMocks,
  });

  factory AppConfig.fromEnvironment() {
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    const useMocks = bool.fromEnvironment('USE_MOCKS');
    return const AppConfig(
      apiBaseUrl: apiBaseUrl,
      useMocks: useMocks,
    );
  }

  final String apiBaseUrl;
  final bool useMocks;

  void validate() {
    if (!useMocks && apiBaseUrl.trim().isEmpty) {
      throw StateError(
        'API_BASE_URL est requis lorsque USE_MOCKS=false. '
        'Passez --dart-define=API_BASE_URL=https://... ou --dart-define=USE_MOCKS=true.',
      );
    }
  }
}
