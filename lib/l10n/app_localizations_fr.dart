// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

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

  @override
  String get createOffer => 'Create Offer';

  @override
  String get createAsCarrier => 'Create as Carrier';

  @override
  String get createAsSender => 'Create as Sender';

  @override
  String get stepFlightDetails => 'Flight Details';

  @override
  String get stepOfferDetails => 'Offer Details';

  @override
  String get step1of2 => 'Step 1 of 2';

  @override
  String get step2of2 => 'Step 2 of 2';

  @override
  String get flightType => 'Flight Type';

  @override
  String get oneWay => 'One Way';

  @override
  String get roundTrip => 'Round Trip';

  @override
  String get fromAirport => 'From';

  @override
  String get toAirport => 'To';

  @override
  String get searchAirport => 'Search airport or city…';

  @override
  String get departureDate => 'Departure Date';

  @override
  String get departureTime => 'Departure Time';

  @override
  String get arrivalDate => 'Arrival Date';

  @override
  String get arrivalTime => 'Arrival Time';

  @override
  String get returnLeg => 'Return Flight';

  @override
  String get continueToOffer => 'Continue';

  @override
  String get pickupArea => 'Pickup Area';

  @override
  String get deliveryArea => 'Delivery Area';

  @override
  String get urgencyLevel => 'Urgency';

  @override
  String get urgencyNormal => 'Normal';

  @override
  String get urgencyExpress => 'Express';

  @override
  String get discount => 'Discount (%)';

  @override
  String get specialNote => 'Special Note';

  @override
  String get meetupPlaces => 'Meetup Places';

  @override
  String get addMeetupPlace => 'Add meetup place';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get offerItems => 'Items';

  @override
  String get addItem => 'Add Item';

  @override
  String get pricePerItem => 'Price per item';

  @override
  String get quantity => 'Quantity';

  @override
  String get createOfferButton => 'Create Offer';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectTime => 'Select time';

  @override
  String get optional => 'Optional';

  @override
  String get remove => 'Remove';

  @override
  String get retry => 'Retry';

  @override
  String get errorLoadingAirports => 'Failed to load airports';

  @override
  String get errorCreatingFlight => 'Failed to create flight';

  @override
  String get errorCreatingOffer => 'Failed to create offer';

  @override
  String get offerCreatedSuccess => 'Offer created successfully!';
}
