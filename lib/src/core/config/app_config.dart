enum AppEnvironment { dev, prod }

class AppConfig {
  AppConfig._();

  static AppEnvironment environment = AppEnvironment.dev;

  static String get baseUrl => switch (environment) {
    AppEnvironment.dev => 'https://airdash-155736728726.us-east4.run.app',
        // 'https://994b-209-127-211-232.ngrok-free.app',
    AppEnvironment.prod => 'https://api.airpick.app', // replace when live
  };

  static String get apiBaseUrl => '$baseUrl/api/v1';

  // TODO: placeholder — replace with the real support inbox before release.
  // Shown to users whose verification is locked or whose account is blocked.
  static const supportEmail = 'support@guzomy.app';
}
