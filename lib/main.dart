import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/app/bloc/app_bloc.dart';
import 'src/app/view/app_router.dart';
import 'src/core/config/app_config.dart';
import 'src/core/network/api_client.dart';
import 'src/core/notifications/notification_service.dart';
import 'src/core/storage/token_storage.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/auth/bloc/auth_bloc.dart';
import 'src/features/auth/data/firebase_auth_service.dart';
import 'src/features/auth/repository/auth_repository.dart';
import 'src/features/home/cubit/user_mode_cubit.dart';
import 'src/features/offer_requests/cubit/offer_requests_cubit.dart';
import 'src/features/onboarding/bloc/onboarding_bloc.dart';
import 'src/features/onboarding/repository/onboarding_repository.dart';
import 'src/features/airports/repository/airport_repository.dart';
import 'src/features/countries/repository/country_repository.dart';
import 'src/features/flights/repository/flight_repository.dart';
import 'src/features/items/repository/item_repository.dart';
import 'src/features/offer_requests/repository/offer_request_repository.dart';
import 'src/features/offers/repository/offer_repository.dart';
import 'src/features/settings/cubit/locale_cubit.dart';
import 'src/features/settings/cubit/theme_cubit.dart';
import 'src/features/settings/repository/settings_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Shared services
  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();
  await NotificationService.initialize();

  // Set environment — switch to AppEnvironment.prod for release
  AppConfig.environment = AppEnvironment.dev;

  runApp(AirpickApp(prefs: prefs, secureStorage: secureStorage));
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
        RepositoryProvider<TokenStorage>(
          create: (_) => tokenStorage,
        ),
        RepositoryProvider<ApiClient>(
          create: (_) => apiClient,
        ),
        RepositoryProvider<IAuthRepository>(
          create: (_) => AuthRepository(
            firebaseService: FirebaseAuthService(),
            apiClient: apiClient,
            tokenStorage: tokenStorage,
          ),
        ),
        RepositoryProvider<SettingsRepository>(
          create: (_) => settingsRepo,
        ),
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (context) =>
                ThemeCubit(context.read<SettingsRepository>()),
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
            create: (context) => OnboardingBloc(
              context.read<IOnboardingRepository>(),
            ),
          ),
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              context.read<IAuthRepository>(),
            ),
          ),
          // App-wide so sender/carrier mode is consistent everywhere
          BlocProvider<UserModeCubit>(
            create: (_) => UserModeCubit(),
          ),
          BlocProvider<OfferRequestsCubit>(
            create: (context) =>
                OfferRequestsCubit(context.read<OfferRequestRepository>()),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp(
                  title: 'Airpick',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: themeMode,
                  locale: locale,
                  supportedLocales: LocaleCubit.supportedLocales,
                  localizationsDelegates: const [
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
