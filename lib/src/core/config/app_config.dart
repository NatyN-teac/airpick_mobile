enum AppEnvironment { dev, prod }

class AppConfig {
  AppConfig._();

  static AppEnvironment environment = AppEnvironment.dev;

  static String get baseUrl => switch (environment) {
        AppEnvironment.dev =>
          'https://48aa-209-127-211-232.ngrok-free.app',
        AppEnvironment.prod =>
          'https://api.airpick.app', // replace when live
      };

  static String get apiBaseUrl => '$baseUrl/api/v1';
}
