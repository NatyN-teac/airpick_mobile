enum AppEnvironment { dev, prod }

class AppConfig {
  AppConfig._();

  static AppEnvironment environment = AppEnvironment.dev;

  static String get baseUrl => switch (environment) {
    AppEnvironment.dev => 'https://airdash-155736728726.us-east4.run.app',
    AppEnvironment.prod => 'https://api.airpick.app', // replace when live
  };

  static String get apiBaseUrl => '$baseUrl/api/v1';
}
