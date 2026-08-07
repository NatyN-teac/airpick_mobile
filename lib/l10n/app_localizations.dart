import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'GuzoMy'**
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

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get logOutConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logOutSub.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get logOutSub;

  /// No description provided for @profileUserDetails.
  ///
  /// In en, this message translates to:
  /// **'User details'**
  String get profileUserDetails;

  /// No description provided for @profileUserDetailsSub.
  ///
  /// In en, this message translates to:
  /// **'Update your name and profile info'**
  String get profileUserDetailsSub;

  /// No description provided for @profileVerification.
  ///
  /// In en, this message translates to:
  /// **'Account verification'**
  String get profileVerification;

  /// No description provided for @profileVerificationSub.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity with a passport'**
  String get profileVerificationSub;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileLanguageSub.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get profileLanguageSub;

  /// No description provided for @profileMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get profileMode;

  /// No description provided for @profileModeSub.
  ///
  /// In en, this message translates to:
  /// **'Switch between Sender and Carrier'**
  String get profileModeSub;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAbout;

  /// No description provided for @profileAboutSub.
  ///
  /// In en, this message translates to:
  /// **'Learn more about GuzoMy'**
  String get profileAboutSub;

  /// No description provided for @profileCloseAccount.
  ///
  /// In en, this message translates to:
  /// **'Close account'**
  String get profileCloseAccount;

  /// No description provided for @profileCloseAccountSub.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get profileCloseAccountSub;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// No description provided for @modeChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your mode'**
  String get modeChooseTitle;

  /// No description provided for @modeChooseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select how you want to use GuzoMy. Your profile and home screen update instantly.'**
  String get modeChooseSubtitle;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(Object version);

  /// No description provided for @aboutSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'About GuzoMy'**
  String get aboutSectionTitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'GuzoMy connects travelers and senders for secure, peer-to-peer package delivery between airports. Whether you are traveling and can carry items, or need something delivered, GuzoMy helps you find trusted matches.'**
  String get aboutBody;

  /// No description provided for @aboutKeyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key features'**
  String get aboutKeyFeatures;

  /// No description provided for @aboutFeature1.
  ///
  /// In en, this message translates to:
  /// **'Verified accounts for trusted delivery'**
  String get aboutFeature1;

  /// No description provided for @aboutFeature2.
  ///
  /// In en, this message translates to:
  /// **'Airport-based matching for travelers'**
  String get aboutFeature2;

  /// No description provided for @aboutFeature3.
  ///
  /// In en, this message translates to:
  /// **'Send and receive items with ease'**
  String get aboutFeature3;

  /// No description provided for @aboutFeature4.
  ///
  /// In en, this message translates to:
  /// **'In-app messaging (coming soon)'**
  String get aboutFeature4;

  /// No description provided for @closeVerifyRequiredSnack.
  ///
  /// In en, this message translates to:
  /// **'You must verify your account before closing it.'**
  String get closeVerifyRequiredSnack;

  /// No description provided for @closeTypeDeleteSnack.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm.'**
  String get closeTypeDeleteSnack;

  /// No description provided for @closeUserIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'User ID not found.'**
  String get closeUserIdNotFound;

  /// No description provided for @closeNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Account closure was not confirmed.'**
  String get closeNotConfirmed;

  /// No description provided for @closeSuccessDefault.
  ///
  /// In en, this message translates to:
  /// **'Account closed successfully.'**
  String get closeSuccessDefault;

  /// No description provided for @closePermanentTitle.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent'**
  String get closePermanentTitle;

  /// No description provided for @closePermanentBody.
  ///
  /// In en, this message translates to:
  /// **'Closing your account will permanently delete your profile, offers, and requests. This cannot be undone.'**
  String get closePermanentBody;

  /// No description provided for @closeVerifyRequiredBanner.
  ///
  /// In en, this message translates to:
  /// **'Account verification is required before you can close your account.'**
  String get closeVerifyRequiredBanner;

  /// No description provided for @closeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get closeConfirmTitle;

  /// No description provided for @closeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE below to confirm you want to permanently close your account.'**
  String get closeConfirmBody;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close my account'**
  String get closeButton;

  /// No description provided for @languageSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get languageSelectTitle;

  /// No description provided for @languageSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language for the app.'**
  String get languageSelectSubtitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good to have you back 👋'**
  String get homeGreeting;

  /// No description provided for @homeQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s happening today?'**
  String get homeQuestion;

  /// No description provided for @sectionInDelivery.
  ///
  /// In en, this message translates to:
  /// **'In delivery'**
  String get sectionInDelivery;

  /// No description provided for @sectionEngagements.
  ///
  /// In en, this message translates to:
  /// **'Engagements'**
  String get sectionEngagements;

  /// No description provided for @sectionAvailableCarriers.
  ///
  /// In en, this message translates to:
  /// **'Available carriers'**
  String get sectionAvailableCarriers;

  /// No description provided for @sectionOfferRequests.
  ///
  /// In en, this message translates to:
  /// **'Offer requests'**
  String get sectionOfferRequests;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @centerRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get centerRequests;

  /// No description provided for @centerOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get centerOffers;

  /// Label on the floating action button that opens the create offer/request sheet
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get fabCreate;

  /// Count of active engagements
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active engagement} other{{count} active engagements}}'**
  String activeEngagements(num count);

  /// No description provided for @latestLabel.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latestLabel;

  /// No description provided for @modeSender.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get modeSender;

  /// No description provided for @modeCarrier.
  ///
  /// In en, this message translates to:
  /// **'Carrier'**
  String get modeCarrier;

  /// No description provided for @modeSenderPill.
  ///
  /// In en, this message translates to:
  /// **'Sender mode'**
  String get modeSenderPill;

  /// No description provided for @modeCarrierPill.
  ///
  /// In en, this message translates to:
  /// **'Carrier mode'**
  String get modeCarrierPill;

  /// No description provided for @modeSenderDesc.
  ///
  /// In en, this message translates to:
  /// **'I need items delivered'**
  String get modeSenderDesc;

  /// No description provided for @modeCarrierDesc.
  ///
  /// In en, this message translates to:
  /// **'I\'m traveling & can carry items'**
  String get modeCarrierDesc;

  /// No description provided for @modePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch mode'**
  String get modePickerTitle;

  /// No description provided for @modePickerQuestion.
  ///
  /// In en, this message translates to:
  /// **'How are you using GuzoMy today?'**
  String get modePickerQuestion;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @verifyRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification required'**
  String get verifyRequiredTitle;

  /// Verification gate body; {action} is a verb phrase
  ///
  /// In en, this message translates to:
  /// **'You need to verify your identity before you can {action}. Verification takes just a few minutes.'**
  String verifyRequiredBody(Object action);

  /// No description provided for @verifyMyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify my identity'**
  String get verifyMyIdentity;

  /// No description provided for @verifyActionDefault.
  ///
  /// In en, this message translates to:
  /// **'create offers, requests, or proposals'**
  String get verifyActionDefault;

  /// No description provided for @verifyActionCreateOffer.
  ///
  /// In en, this message translates to:
  /// **'create an offer'**
  String get verifyActionCreateOffer;

  /// No description provided for @verifyActionCreateRequest.
  ///
  /// In en, this message translates to:
  /// **'create a request'**
  String get verifyActionCreateRequest;

  /// No description provided for @udErrorRefresh.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh from server. Showing saved info — you can still edit and save.'**
  String get udErrorRefresh;

  /// No description provided for @udCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile'**
  String get udCouldNotLoad;

  /// No description provided for @userIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'User ID not found.'**
  String get userIdNotFound;

  /// No description provided for @udUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Updated!'**
  String get udUpdatedTitle;

  /// No description provided for @udUpdatedSub.
  ///
  /// In en, this message translates to:
  /// **'Your details have been saved.'**
  String get udUpdatedSub;

  /// No description provided for @sectionPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get sectionPersonal;

  /// No description provided for @sectionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get sectionLocation;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @middleName.
  ///
  /// In en, this message translates to:
  /// **'Middle name'**
  String get middleName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @stateRegion.
  ///
  /// In en, this message translates to:
  /// **'State / Region'**
  String get stateRegion;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell others a little about yourself'**
  String get bioHint;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required.'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required.'**
  String get lastNameRequired;

  /// No description provided for @cityRequired.
  ///
  /// In en, this message translates to:
  /// **'City is required.'**
  String get cityRequired;

  /// No description provided for @countryRequired.
  ///
  /// In en, this message translates to:
  /// **'Country is required.'**
  String get countryRequired;

  /// No description provided for @dobRequired.
  ///
  /// In en, this message translates to:
  /// **'Date of birth is required.'**
  String get dobRequired;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @avSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification submitted!'**
  String get avSubmittedTitle;

  /// No description provided for @avSubmittedSub.
  ///
  /// In en, this message translates to:
  /// **'We\'re reviewing your ID. Pull down to refresh for the latest status.'**
  String get avSubmittedSub;

  /// No description provided for @avVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re verified!'**
  String get avVerifiedTitle;

  /// No description provided for @avVerifiedSub.
  ///
  /// In en, this message translates to:
  /// **'Your identity is confirmed. You\'re all set on GuzoMy.'**
  String get avVerifiedSub;

  /// No description provided for @avCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load verification'**
  String get avCouldNotLoad;

  /// No description provided for @avLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load verification status.'**
  String get avLoadFailed;

  /// No description provided for @avPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing secure session…'**
  String get avPreparing;

  /// No description provided for @avChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking verification status…'**
  String get avChecking;

  /// No description provided for @avPoweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by Veriff · Secure identity verification'**
  String get avPoweredBy;

  /// No description provided for @avStatusVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re verified'**
  String get avStatusVerifiedTitle;

  /// No description provided for @avStatusVerifiedBody.
  ///
  /// In en, this message translates to:
  /// **'Your identity has been confirmed. Thanks for helping keep GuzoMy safe.'**
  String get avStatusVerifiedBody;

  /// No description provided for @avStatusReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review in progress'**
  String get avStatusReviewTitle;

  /// No description provided for @avStatusReviewBody.
  ///
  /// In en, this message translates to:
  /// **'Veriff is processing your submission. This usually takes a few minutes.'**
  String get avStatusReviewBody;

  /// No description provided for @avStatusResubmitTitle.
  ///
  /// In en, this message translates to:
  /// **'Resubmission needed'**
  String get avStatusResubmitTitle;

  /// No description provided for @avStatusDeclinedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification declined'**
  String get avStatusDeclinedTitle;

  /// No description provided for @avStatusRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Please try again with a valid, well-lit ID and a clear selfie.'**
  String get avStatusRejectedBody;

  /// No description provided for @avStatusDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity'**
  String get avStatusDefaultTitle;

  /// No description provided for @avStatusDefaultBody.
  ///
  /// In en, this message translates to:
  /// **'A quick ID scan and selfie powered by Veriff keeps our community trusted.'**
  String get avStatusDefaultBody;

  /// No description provided for @avStepPrepare.
  ///
  /// In en, this message translates to:
  /// **'Prepare'**
  String get avStepPrepare;

  /// No description provided for @avStepIdScan.
  ///
  /// In en, this message translates to:
  /// **'ID scan'**
  String get avStepIdScan;

  /// No description provided for @avStepSelfie.
  ///
  /// In en, this message translates to:
  /// **'Selfie'**
  String get avStepSelfie;

  /// No description provided for @avStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get avStepReview;

  /// No description provided for @avBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get avBeforeStart;

  /// No description provided for @avTipLighting.
  ///
  /// In en, this message translates to:
  /// **'Use good lighting — avoid glare on your ID'**
  String get avTipLighting;

  /// No description provided for @avTipId.
  ///
  /// In en, this message translates to:
  /// **'Have a passport or government ID ready'**
  String get avTipId;

  /// No description provided for @avTipSelfie.
  ///
  /// In en, this message translates to:
  /// **'You\'ll take a quick selfie for liveness check'**
  String get avTipSelfie;

  /// No description provided for @avTipTime.
  ///
  /// In en, this message translates to:
  /// **'Takes about 2 minutes'**
  String get avTipTime;

  /// No description provided for @avChipEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Encrypted'**
  String get avChipEncrypted;

  /// No description provided for @avChip230.
  ///
  /// In en, this message translates to:
  /// **'230+ countries'**
  String get avChip230;

  /// No description provided for @avWhatWentWrong.
  ///
  /// In en, this message translates to:
  /// **'What went wrong'**
  String get avWhatWentWrong;

  /// No description provided for @avStartVerification.
  ///
  /// In en, this message translates to:
  /// **'Start verification'**
  String get avStartVerification;

  /// No description provided for @avTryAgainVeriff.
  ///
  /// In en, this message translates to:
  /// **'Try again with Veriff'**
  String get avTryAgainVeriff;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifTitle;

  /// No description provided for @notifNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notifNew;

  /// No description provided for @notifEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notifEarlier;

  /// No description provided for @notifCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get notifCaughtUp;

  /// Unread notifications count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new update} other{{count} new updates}}'**
  String notifUnread(num count);

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @notifEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notifEmptyTitle;

  /// No description provided for @notifEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Updates about matches and deliveries land here.'**
  String get notifEmptyBody;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @engEmptyActive.
  ///
  /// In en, this message translates to:
  /// **'No active engagements.'**
  String get engEmptyActive;

  /// No description provided for @tabSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get tabSent;

  /// No description provided for @tabReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get tabReceived;

  /// No description provided for @tabMatched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get tabMatched;

  /// No description provided for @emptyProposalsSent.
  ///
  /// In en, this message translates to:
  /// **'No proposals sent yet.'**
  String get emptyProposalsSent;

  /// No description provided for @emptyProposalsReceived.
  ///
  /// In en, this message translates to:
  /// **'No proposals received yet.'**
  String get emptyProposalsReceived;

  /// No description provided for @emptyMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches yet.'**
  String get emptyMatches;

  /// No description provided for @offersTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offersTitle;

  /// No description provided for @offersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load offers'**
  String get offersLoadError;

  /// No description provided for @offersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No offers yet'**
  String get offersEmptyTitle;

  /// No description provided for @offersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap + to post an offer with your flight.'**
  String get offersEmptyBody;

  /// No description provided for @offersEmptyStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'No offers with this status'**
  String get offersEmptyStatusTitle;

  /// No description provided for @offersEmptyStatusBody.
  ///
  /// In en, this message translates to:
  /// **'Choose another status filter to see your other offers.'**
  String get offersEmptyStatusBody;

  /// No description provided for @offerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Offer deleted'**
  String get offerDeleted;

  /// No description provided for @offerDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this offer?'**
  String get offerDeleteConfirmTitle;

  /// No description provided for @offerDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This removes your offer permanently.'**
  String get offerDeleteConfirmBody;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Number of items
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemsCount(num count);

  /// No description provided for @statusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statusAll;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// No description provided for @statusMatched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get statusMatched;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @offerCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get offerCurrency;

  /// No description provided for @offerDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get offerDiscountLabel;

  /// No description provided for @offerPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get offerPayment;

  /// No description provided for @offerMeetup.
  ///
  /// In en, this message translates to:
  /// **'Meetup'**
  String get offerMeetup;

  /// No description provided for @offerNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get offerNote;

  /// No description provided for @offerTotalValue.
  ///
  /// In en, this message translates to:
  /// **'Total value'**
  String get offerTotalValue;

  /// No description provided for @offerMatchThis.
  ///
  /// In en, this message translates to:
  /// **'Match this offer'**
  String get offerMatchThis;

  /// No description provided for @offerNoFlight.
  ///
  /// In en, this message translates to:
  /// **'No flight attached'**
  String get offerNoFlight;

  /// Relative creation time, e.g. Created 2h ago
  ///
  /// In en, this message translates to:
  /// **'Created {ago}'**
  String offerCreatedAgo(Object ago);

  /// No description provided for @carriersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load carriers'**
  String get carriersLoadError;

  /// No description provided for @carriersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No carriers available'**
  String get carriersEmptyTitle;

  /// No description provided for @carriersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Available carriers will show here when they post trips.'**
  String get carriersEmptyBody;

  /// No description provided for @editOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Offer'**
  String get editOfferTitle;

  /// No description provided for @offerDiscountOptional.
  ///
  /// In en, this message translates to:
  /// **'Discount (optional)'**
  String get offerDiscountOptional;

  /// No description provided for @offerNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get offerNoteOptional;

  /// No description provided for @offerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Offer updated'**
  String get offerUpdated;

  /// No description provided for @offerFlightNotEditable.
  ///
  /// In en, this message translates to:
  /// **'Flight not editable'**
  String get offerFlightNotEditable;

  /// No description provided for @offerNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Fragile items handled with care'**
  String get offerNoteHint;

  /// No description provided for @offerDeliveryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Lagos, Nigeria'**
  String get offerDeliveryHint;

  /// No description provided for @offerPickupHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Los Angeles, CA'**
  String get offerPickupHint;

  /// No description provided for @requestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get requestsTitle;

  /// No description provided for @requestsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load requests'**
  String get requestsLoadError;

  /// No description provided for @requestsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get requestsEmptyTitle;

  /// No description provided for @requestsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create a request for items you need delivered.'**
  String get requestsEmptyBody;

  /// No description provided for @requestsEmptyStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'No requests with this status'**
  String get requestsEmptyStatusTitle;

  /// No description provided for @requestsEmptyStatusBody.
  ///
  /// In en, this message translates to:
  /// **'Choose another status filter to see your other requests.'**
  String get requestsEmptyStatusBody;

  /// No description provided for @requestDeleted.
  ///
  /// In en, this message translates to:
  /// **'Request deleted'**
  String get requestDeleted;

  /// No description provided for @requestDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this request?'**
  String get requestDeleteConfirmTitle;

  /// No description provided for @requestDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes your offer request. This action cannot be undone.'**
  String get requestDeleteConfirmBody;

  /// Number of proposals
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 proposal} other{{count} proposals}}'**
  String proposalsCount(num count);

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusProposals.
  ///
  /// In en, this message translates to:
  /// **'Proposals'**
  String get statusProposals;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// No description provided for @statusPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get statusPendingApproval;

  /// No description provided for @statusNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'Not accepted'**
  String get statusNotAccepted;

  /// No description provided for @reqPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial ✓'**
  String get reqPartial;

  /// No description provided for @urgencyUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgencyUrgent;

  /// No description provided for @urgencyFlexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get urgencyFlexible;

  /// No description provided for @browseRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse Requests'**
  String get browseRequestsTitle;

  /// No description provided for @filterRequests.
  ///
  /// In en, this message translates to:
  /// **'Filter requests'**
  String get filterRequests;

  /// No description provided for @sourceCountry.
  ///
  /// In en, this message translates to:
  /// **'Source country'**
  String get sourceCountry;

  /// No description provided for @sourceCity.
  ///
  /// In en, this message translates to:
  /// **'Source city'**
  String get sourceCity;

  /// No description provided for @destinationCountry.
  ///
  /// In en, this message translates to:
  /// **'Destination country'**
  String get destinationCountry;

  /// No description provided for @anyCountry.
  ///
  /// In en, this message translates to:
  /// **'Any country'**
  String get anyCountry;

  /// No description provided for @anyOption.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyOption;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noMatchingRequests.
  ///
  /// In en, this message translates to:
  /// **'No matching requests'**
  String get noMatchingRequests;

  /// No description provided for @tryClearingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try clearing the filters or searching another route.'**
  String get tryClearingFilters;

  /// No description provided for @requestsBrowseEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No requests available'**
  String get requestsBrowseEmptyTitle;

  /// No description provided for @requestsBrowseEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Open shipper requests will show here when senders post them.'**
  String get requestsBrowseEmptyBody;

  /// No description provided for @requestDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get requestDetailTitle;

  /// No description provided for @reqPartialProposals.
  ///
  /// In en, this message translates to:
  /// **'Partial proposals'**
  String get reqPartialProposals;

  /// No description provided for @preferredDate.
  ///
  /// In en, this message translates to:
  /// **'Preferred date'**
  String get preferredDate;

  /// No description provided for @reqNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get reqNoItems;

  /// No description provided for @reqHasProposalsLocked.
  ///
  /// In en, this message translates to:
  /// **'This request has proposals and can no longer be edited or deleted.'**
  String get reqHasProposalsLocked;

  /// {status} is a lowercase status word
  ///
  /// In en, this message translates to:
  /// **'This request is {status} and can no longer be edited or deleted.'**
  String reqStatusLocked(Object status);

  /// No description provided for @createProposalSent.
  ///
  /// In en, this message translates to:
  /// **'Proposal sent'**
  String get createProposalSent;

  /// No description provided for @sendProposal.
  ///
  /// In en, this message translates to:
  /// **'Send Proposal'**
  String get sendProposal;

  /// No description provided for @yourFlight.
  ///
  /// In en, this message translates to:
  /// **'Your flight'**
  String get yourFlight;

  /// Airport search hint with country name
  ///
  /// In en, this message translates to:
  /// **'Airport in {country}'**
  String airportInCountry(Object country);

  /// No description provided for @pickupDelivery.
  ///
  /// In en, this message translates to:
  /// **'Pickup & delivery'**
  String get pickupDelivery;

  /// No description provided for @priceTheItems.
  ///
  /// In en, this message translates to:
  /// **'Price the items'**
  String get priceTheItems;

  /// No description provided for @partialAllowed.
  ///
  /// In en, this message translates to:
  /// **'Partial allowed'**
  String get partialAllowed;

  /// No description provided for @proposalCurrency.
  ///
  /// In en, this message translates to:
  /// **'Proposal currency'**
  String get proposalCurrency;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @pickupAreaHelp.
  ///
  /// In en, this message translates to:
  /// **'The general area where you\'ll collect the items before your flight (e.g. a city or neighbourhood).'**
  String get pickupAreaHelp;

  /// No description provided for @meetupHelp.
  ///
  /// In en, this message translates to:
  /// **'Specific spots where you can meet the sender in person to hand over or drop off the items (e.g. a mall, cafe or landmark).'**
  String get meetupHelp;

  /// No description provided for @proposalNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. I can deliver within 2 days of arrival'**
  String get proposalNoteHint;

  /// No description provided for @chatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chatsTitle;

  /// No description provided for @chatsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chatsEmptyTitle;

  /// No description provided for @chatsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Matched deliveries will appear here.'**
  String get chatsEmptyBody;

  /// No description provided for @chatNoMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get chatNoMessagesYet;

  /// No description provided for @chatStartConvo.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation when you are ready.'**
  String get chatStartConvo;

  /// No description provided for @chatLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load chat'**
  String get chatLoadError;

  /// No description provided for @chatMatchDetails.
  ///
  /// In en, this message translates to:
  /// **'Match details'**
  String get chatMatchDetails;

  /// No description provided for @chatMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Message…'**
  String get chatMessageHint;

  /// Items header with count
  ///
  /// In en, this message translates to:
  /// **'Items ({count})'**
  String chatItemsCount(Object count);

  /// No description provided for @chatRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get chatRoute;

  /// No description provided for @chatConfirmPickup.
  ///
  /// In en, this message translates to:
  /// **'Confirm pickup'**
  String get chatConfirmPickup;

  /// No description provided for @chatReadyForPickup.
  ///
  /// In en, this message translates to:
  /// **'Ready for pickup'**
  String get chatReadyForPickup;

  /// No description provided for @chatPickUp.
  ///
  /// In en, this message translates to:
  /// **'Pick up'**
  String get chatPickUp;

  /// No description provided for @chatStartDelivery.
  ///
  /// In en, this message translates to:
  /// **'Start delivery'**
  String get chatStartDelivery;

  /// No description provided for @chatTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the items to start delivery.'**
  String get chatTakePhoto;

  /// No description provided for @chatTapAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get chatTapAddPhoto;

  /// No description provided for @chatPhotographItems.
  ///
  /// In en, this message translates to:
  /// **'Photograph the items you received from the sender. This starts tracked delivery.'**
  String get chatPhotographItems;

  /// No description provided for @chatDeliveryInProgress.
  ///
  /// In en, this message translates to:
  /// **'Delivery in progress — head to the destination.'**
  String get chatDeliveryInProgress;

  /// No description provided for @chatItemLoadError.
  ///
  /// In en, this message translates to:
  /// **'Item details could not be loaded.'**
  String get chatItemLoadError;

  /// No description provided for @chatToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chatToday;

  /// No description provided for @deliveriesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load deliveries'**
  String get deliveriesLoadError;

  /// No description provided for @deliveriesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No active deliveries'**
  String get deliveriesEmptyTitle;

  /// No description provided for @deliveriesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Deliveries appear here after pickup and while en route.'**
  String get deliveriesEmptyBody;

  /// No description provided for @searchChooseFilter.
  ///
  /// In en, this message translates to:
  /// **'Choose search filter'**
  String get searchChooseFilter;

  /// No description provided for @searchFilterCarriersBy.
  ///
  /// In en, this message translates to:
  /// **'Filter carriers by'**
  String get searchFilterCarriersBy;

  /// No description provided for @searchFilterRequestsBy.
  ///
  /// In en, this message translates to:
  /// **'Filter shipper requests by'**
  String get searchFilterRequestsBy;

  /// No description provided for @searchOriginCountry.
  ///
  /// In en, this message translates to:
  /// **'Origin country'**
  String get searchOriginCountry;

  /// No description provided for @searchOriginCity.
  ///
  /// In en, this message translates to:
  /// **'Origin city'**
  String get searchOriginCity;

  /// No description provided for @searchDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get searchDestination;

  /// No description provided for @searchAnywhere.
  ///
  /// In en, this message translates to:
  /// **'Anywhere'**
  String get searchAnywhere;

  /// No description provided for @searchQuickSearches.
  ///
  /// In en, this message translates to:
  /// **'Quick searches'**
  String get searchQuickSearches;

  /// No search results for query
  ///
  /// In en, this message translates to:
  /// **'No shipper requests matched \"{query}\".'**
  String searchNoResults(Object query);

  /// Search results count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String searchResultsCount(num count);

  /// No description provided for @matchOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Match Offer'**
  String get matchOfferTitle;

  /// No description provided for @matchCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Match Created!'**
  String get matchCreatedTitle;

  /// No description provided for @matchCreatedBody.
  ///
  /// In en, this message translates to:
  /// **'Opening your chat with the carrier so you can arrange pickup and delivery.'**
  String get matchCreatedBody;

  /// No description provided for @matchWhatNeed.
  ///
  /// In en, this message translates to:
  /// **'What do you need?'**
  String get matchWhatNeed;

  /// No description provided for @matchSelectItems.
  ///
  /// In en, this message translates to:
  /// **'Select items and quantities to match.'**
  String get matchSelectItems;

  /// No description provided for @matchWhoReceives.
  ///
  /// In en, this message translates to:
  /// **'Who receives?'**
  String get matchWhoReceives;

  /// No description provided for @matchItemsToMe.
  ///
  /// In en, this message translates to:
  /// **'Items come to me'**
  String get matchItemsToMe;

  /// No description provided for @matchSomeoneElse.
  ///
  /// In en, this message translates to:
  /// **'Someone else'**
  String get matchSomeoneElse;

  /// No description provided for @matchThirdParty.
  ///
  /// In en, this message translates to:
  /// **'Third-party receiver'**
  String get matchThirdParty;

  /// No description provided for @matchReceiverDetails.
  ///
  /// In en, this message translates to:
  /// **'Receiver details'**
  String get matchReceiverDetails;

  /// No description provided for @matchPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone (e.g. +12025551234)'**
  String get matchPhoneHint;

  /// No description provided for @matchPhotoId.
  ///
  /// In en, this message translates to:
  /// **'Photo ID'**
  String get matchPhotoId;

  /// No description provided for @matchUploadId.
  ///
  /// In en, this message translates to:
  /// **'Upload government-issued ID'**
  String get matchUploadId;

  /// No description provided for @matchChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get matchChange;

  /// No description provided for @cameraOption.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraOption;

  /// No description provided for @photoLibraryOption.
  ///
  /// In en, this message translates to:
  /// **'Photo library'**
  String get photoLibraryOption;

  /// No description provided for @matchSendMatch.
  ///
  /// In en, this message translates to:
  /// **'Send Match'**
  String get matchSendMatch;

  /// No description provided for @matchSending.
  ///
  /// In en, this message translates to:
  /// **'Sending match…'**
  String get matchSending;

  /// No description provided for @matchUploadingId.
  ///
  /// In en, this message translates to:
  /// **'Uploading ID…'**
  String get matchUploadingId;

  /// No description provided for @matchEstimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated total'**
  String get matchEstimatedTotal;

  /// No description provided for @matchPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get matchPickup;

  /// No description provided for @matchDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get matchDelivery;
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
      <String>['am', 'ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
