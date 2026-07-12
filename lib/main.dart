import 'package:airpick/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'src/app/bloc/app_bloc.dart';
import 'src/app/view/app_router.dart';
import 'src/core/l10n/l10n.dart';
import 'src/core/config/app_config.dart';
import 'src/core/network/api_client.dart';
import 'src/core/media/upload_repository.dart';
import 'src/core/navigation/app_navigator.dart';
import 'src/core/notifications/notification_service.dart';
import 'src/core/notifications/device_registration_service.dart';
import 'src/features/chat/navigation/chat_deep_link.dart';
import 'src/features/chat/repository/chat_repository.dart';
import 'src/core/storage/token_storage.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/auth/bloc/auth_bloc.dart';
import 'src/features/auth/data/firebase_auth_service.dart';
import 'src/features/auth/repository/auth_repository.dart';
import 'src/features/home/cubit/user_mode_cubit.dart';
import 'src/features/matches/repository/match_repository.dart';
import 'src/features/offer_requests/cubit/offer_requests_cubit.dart';
import 'src/features/onboarding/bloc/onboarding_bloc.dart';
import 'src/features/onboarding/repository/onboarding_repository.dart';
import 'src/features/airports/repository/airport_repository.dart';
import 'src/features/countries/repository/country_repository.dart';
import 'src/features/flights/repository/flight_repository.dart';
import 'src/features/items/repository/item_repository.dart';
import 'src/features/offer_requests/repository/offer_request_repository.dart';
import 'src/features/offers/cubit/offers_cubit.dart';
import 'src/features/offers/repository/offer_repository.dart';
import 'src/features/profile/cubit/current_user_cubit.dart';
import 'src/features/profile/repository/user_repository.dart';
import 'src/features/settings/cubit/locale_cubit.dart';
import 'src/features/settings/cubit/theme_cubit.dart';
import 'src/features/settings/repository/settings_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await _initializeFirebase();

  // Present FCM messages that arrive while the app is backgrounded/terminated.
  // Must be registered before runApp and reference a top-level handler.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Shared services
  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();
  await NotificationService.initialize();
  // Ask for notification permission up-front (required on iOS and Android 13+;
  // without this notifications are silently dropped).
  await NotificationService.requestPermissions();
  // Route MATCH notifications to the chat screen (step 6).
  NotificationService.onDeepLink = handleChatDeepLink;

  // Set environment — switch to AppEnvironment.prod for release
  AppConfig.environment = AppEnvironment.dev;

  runApp(AirpickApp(prefs: prefs, secureStorage: secureStorage));
}

Future<void> _initializeFirebase() async {
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return;
  }

  await Firebase.initializeApp();
}

class AirpickApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FlutterSecureStorage secureStorage;

  const AirpickApp({
    super.key,
    required this.prefs,
    required this.secureStorage,
  });

  @override
  Widget build(BuildContext context) {
    final settingsRepo = SettingsRepository(prefs);
    final tokenStorage = TokenStorage(secureStorage);
    final apiClient = ApiClient(tokenStorage);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IOnboardingRepository>(
          create: (_) => const OnboardingRepository(),
        ),
        RepositoryProvider<TokenStorage>(create: (_) => tokenStorage),
        RepositoryProvider<ApiClient>(create: (_) => apiClient),
        RepositoryProvider<DeviceRegistrationService>(
          lazy: false,
          create: (_) => DeviceRegistrationService(apiClient, tokenStorage)
            ..start(),
        ),
        RepositoryProvider<IAuthRepository>(
          create: (_) => AuthRepository(
            firebaseService: FirebaseAuthService(),
            apiClient: apiClient,
            tokenStorage: tokenStorage,
            settings: settingsRepo,
          ),
        ),
        RepositoryProvider<SettingsRepository>(create: (_) => settingsRepo),
        RepositoryProvider<AirportRepository>(
          create: (_) => AirportRepository(apiClient),
        ),
        RepositoryProvider<FlightRepository>(
          create: (_) => FlightRepository(apiClient),
        ),
        RepositoryProvider<OfferRepository>(
          create: (_) => OfferRepository(apiClient),
        ),
        RepositoryProvider<ItemRepository>(
          create: (_) => ItemRepository(apiClient),
        ),
        RepositoryProvider<OfferRequestRepository>(
          create: (_) => OfferRequestRepository(apiClient),
        ),
        RepositoryProvider<CountryRepository>(
          create: (_) => CountryRepository(apiClient),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => UserRepository(apiClient),
        ),
        RepositoryProvider<UploadRepository>(
          create: (_) => UploadRepository(apiClient),
        ),
        RepositoryProvider<MatchRepository>(
          create: (_) => MatchRepository(apiClient),
        ),
        RepositoryProvider<ChatRepository>(
          create: (_) => ChatRepository(apiClient),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(context.read<SettingsRepository>()),
          ),
          BlocProvider<LocaleCubit>(
            create: (context) =>
                LocaleCubit(context.read<SettingsRepository>()),
          ),
          BlocProvider<AppBloc>(
            create: (context) => AppBloc(
              context.read<IOnboardingRepository>(),
              context.read<TokenStorage>(),
            )..add(const AppStarted()),
          ),
          BlocProvider<OnboardingBloc>(
            create: (context) =>
                OnboardingBloc(context.read<IOnboardingRepository>()),
          ),
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(context.read<IAuthRepository>()),
          ),
          BlocProvider<CurrentUserCubit>(
            create: (context) =>
                CurrentUserCubit(context.read<SettingsRepository>()),
          ),
          // App-wide so sender/carrier mode is consistent everywhere
          BlocProvider<UserModeCubit>(
            create: (context) => UserModeCubit(
              context.read<SettingsRepository>(),
              context.read<UserRepository>(),
            ),
          ),
          BlocProvider<OfferRequestsCubit>(
            create: (context) =>
                OfferRequestsCubit(context.read<OfferRequestRepository>()),
          ),
          BlocProvider<OffersCubit>(
            create: (context) => OffersCubit(context.read<OfferRepository>()),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp(
                  title: 'Airpick',
                  debugShowCheckedModeBanner: false,
                  navigatorKey: appNavigatorKey,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: themeMode,
                  locale: resolveAppLocale(locale),
                  supportedLocales: LocaleCubit.supportedLocales,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  home: const AppRouter(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
