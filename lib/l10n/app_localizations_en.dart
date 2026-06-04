// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Airpick';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboardingTitle1 => 'A trusted community';

  @override
  String get onboardingSubtitle1 =>
      'Join a verified network of travelers and senders with confidence.';

  @override
  String get onboardingTitle2 => 'Fast & reliable delivery';

  @override
  String get onboardingSubtitle2 =>
      'Match with travelers headed your way and get items delivered on time.';

  @override
  String get onboardingTitle3 => 'Simple & secure';

  @override
  String get onboardingSubtitle3 =>
      'Track progress, and complete delivery with peace of mind.';

  @override
  String get authTitle => 'Sign in or\ncreate account';

  @override
  String get authSubtitle => 'Continue with a social account to get started.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get peerToPeerDelivery => 'Peer-to-peer delivery';

  @override
  String get termsPrefix => 'By continuing you agree to our ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String signInCancelledTitle(String provider) {
    return '$provider sign-in cancelled';
  }

  @override
  String get signInCancelledBody =>
      'You closed the sign-in window before finishing. No changes were made.';

  @override
  String tryAgain(String provider) {
    return 'Try $provider again';
  }

  @override
  String get maybeLater => 'Maybe later';
}
