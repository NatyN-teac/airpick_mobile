import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Airpick'**
  String get appName;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'A trusted community'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Join a verified network of travelers and senders with confidence.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Fast & reliable delivery'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Match with travelers headed your way and get items delivered on time.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Simple & secure'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Track progress, and complete delivery with peace of mind.'**
  String get onboardingSubtitle3;

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in or\ncreate account'**
  String get authTitle;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continue with a social account to get started.'**
  String get authSubtitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @peerToPeerDelivery.
  ///
  /// In en, this message translates to:
  /// **'Peer-to-peer delivery'**
  String get peerToPeerDelivery;

  /// No description provided for @termsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our '**
  String get termsPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @signInCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'{provider} sign-in cancelled'**
  String signInCancelledTitle(String provider);

  /// No description provided for @signInCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'You closed the sign-in window before finishing. No changes were made.'**
  String get signInCancelledBody;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try {provider} again'**
  String tryAgain(String provider);

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// No description provided for @createOffer.
  ///
  /// In en, this message translates to:
  /// **'Create Offer'**
  String get createOffer;

  /// No description provided for @createAsCarrier.
  ///
  /// In en, this message translates to:
  /// **'Create as Carrier'**
  String get createAsCarrier;

  /// No description provided for @createAsSender.
  ///
  /// In en, this message translates to:
  /// **'Create as Sender'**
  String get createAsSender;

  /// No description provided for @stepFlightDetails.
  ///
  /// In en, this message translates to:
  /// **'Flight Details'**
  String get stepFlightDetails;

  /// No description provided for @stepOfferDetails.
  ///
  /// In en, this message translates to:
  /// **'Offer Details'**
  String get stepOfferDetails;

  /// No description provided for @step1of2.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2'**
  String get step1of2;

  /// No description provided for @step2of2.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2'**
  String get step2of2;

  /// No description provided for @flightType.
  ///
  /// In en, this message translates to:
  /// **'Flight Type'**
  String get flightType;

  /// No description provided for @oneWay.
  ///
  /// In en, this message translates to:
  /// **'One Way'**
  String get oneWay;

  /// No description provided for @roundTrip.
  ///
  /// In en, this message translates to:
  /// **'Round Trip'**
  String get roundTrip;

  /// No description provided for @fromAirport.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromAirport;

  /// No description provided for @toAirport.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toAirport;

  /// No description provided for @searchAirport.
  ///
  /// In en, this message translates to:
  /// **'Search airport or city…'**
  String get searchAirport;

  /// No description provided for @departureDate.
  ///
  /// In en, this message translates to:
  /// **'Departure Date'**
  String get departureDate;

  /// No description provided for @departureTime.
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get departureTime;

  /// No description provided for @arrivalDate.
  ///
  /// In en, this message translates to:
  /// **'Arrival Date'**
  String get arrivalDate;

  /// No description provided for @arrivalTime.
  ///
  /// In en, this message translates to:
  /// **'Arrival Time'**
  String get arrivalTime;

  /// No description provided for @returnLeg.
  ///
  /// In en, this message translates to:
  /// **'Return Flight'**
  String get returnLeg;

  /// No description provided for @continueToOffer.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueToOffer;

  /// No description provided for @pickupArea.
  ///
  /// In en, this message translates to:
  /// **'Pickup Area'**
  String get pickupArea;

  /// No description provided for @deliveryArea.
  ///
  /// In en, this message translates to:
  /// **'Delivery Area'**
  String get deliveryArea;

  /// No description provided for @urgencyLevel.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get urgencyLevel;

  /// No description provided for @urgencyNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get urgencyNormal;

  /// No description provided for @urgencyExpress.
  ///
  /// In en, this message translates to:
  /// **'Express'**
  String get urgencyExpress;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount (%)'**
  String get discount;

  /// No description provided for @specialNote.
  ///
  /// In en, this message translates to:
  /// **'Special Note'**
  String get specialNote;

  /// No description provided for @meetupPlaces.
  ///
  /// In en, this message translates to:
  /// **'Meetup Places'**
  String get meetupPlaces;

  /// No description provided for @addMeetupPlace.
  ///
  /// In en, this message translates to:
  /// **'Add meetup place'**
  String get addMeetupPlace;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @offerItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get offerItems;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @pricePerItem.
  ///
  /// In en, this message translates to:
  /// **'Price per item'**
  String get pricePerItem;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @createOfferButton.
  ///
  /// In en, this message translates to:
  /// **'Create Offer'**
  String get createOfferButton;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorLoadingAirports.
  ///
  /// In en, this message translates to:
  /// **'Failed to load airports'**
  String get errorLoadingAirports;

  /// No description provided for @errorCreatingFlight.
  ///
  /// In en, this message translates to:
  /// **'Failed to create flight'**
  String get errorCreatingFlight;

  /// No description provided for @errorCreatingOffer.
  ///
  /// In en, this message translates to:
  /// **'Failed to create offer'**
  String get errorCreatingOffer;

  /// No description provided for @offerCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Offer created successfully!'**
  String get offerCreatedSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
