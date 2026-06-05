// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appName => 'Airpick';

  @override
  String get skip => 'ዝለል';

  @override
  String get next => 'ቀጣይ';

  @override
  String get getStarted => 'ጀምር';

  @override
  String get onboardingTitle1 => 'የታመነ ማህበረሰብ';

  @override
  String get onboardingSubtitle1 => 'በእምነት ወደ ተረጋገጠ የተጓዦችና ላኪዎች ትስስር ይቀላቀሉ።';

  @override
  String get onboardingTitle2 => 'ፈጣን እና አስተማማኝ ዴሊቨሪ';

  @override
  String get onboardingSubtitle2 =>
      'ወደ አካባቢዎ ከሚጓዙ ተጓዦች ጋር ይገናኙ እና እቃዎን ወቅቱን ጠብቆ ያድርሱ።';

  @override
  String get onboardingTitle3 => 'ቀላል እና ደህንነቱ የተጠበቀ';

  @override
  String get onboardingSubtitle3 => 'ሂደቱን ይከታተሉ፣ ዴሊቨሪውን በሰላም ያጠናቅቁ።';

  @override
  String get authTitle => 'ይግቡ ወይም\nመለያ ይፍጠሩ';

  @override
  String get authSubtitle => 'ለመጀመር ከማህበራዊ መለያ ጋር ይቀጥሉ።';

  @override
  String get continueWithGoogle => 'ከGoogle ጋር ይቀጥሉ';

  @override
  String get continueWithApple => 'ከApple ጋር ይቀጥሉ';

  @override
  String get peerToPeerDelivery => 'አቻ-ለ-አቻ ዴሊቨሪ';

  @override
  String get termsPrefix => 'በመቀጠልዎ ከ';

  @override
  String get termsOfService => 'የአገልግሎት ውሎቻችን';

  @override
  String get and => ' እና ';

  @override
  String get privacyPolicy => 'የግላዊነት ፖሊሲያችን';

  @override
  String signInCancelledTitle(String provider) {
    return 'የ$provider መግቢያ ተሰርዟል';
  }

  @override
  String get signInCancelledBody =>
      'የመግቢያ መስኮቱን ከመዝጋትዎ በፊት ሂደቱ አልተጠናቀቀም። ምንም ለውጥ አልተደረገም።';

  @override
  String tryAgain(String provider) {
    return '$providerን እንደገና ሞክሩ';
  }

  @override
  String get maybeLater => 'ሌላ ጊዜ';

  @override
  String get createOffer => '';

  @override
  String get createAsCarrier => '';

  @override
  String get createAsSender => '';

  @override
  String get stepFlightDetails => '';

  @override
  String get stepOfferDetails => '';

  @override
  String get step1of2 => '';

  @override
  String get step2of2 => '';

  @override
  String get flightType => '';

  @override
  String get oneWay => '';

  @override
  String get roundTrip => '';

  @override
  String get fromAirport => '';

  @override
  String get toAirport => '';

  @override
  String get searchAirport => '';

  @override
  String get departureDate => '';

  @override
  String get departureTime => '';

  @override
  String get arrivalDate => '';

  @override
  String get arrivalTime => '';

  @override
  String get returnLeg => '';

  @override
  String get continueToOffer => '';

  @override
  String get pickupArea => '';

  @override
  String get deliveryArea => '';

  @override
  String get urgencyLevel => '';

  @override
  String get urgencyNormal => '';

  @override
  String get urgencyExpress => '';

  @override
  String get discount => '';

  @override
  String get specialNote => '';

  @override
  String get meetupPlaces => '';

  @override
  String get addMeetupPlace => '';

  @override
  String get paymentMethods => '';

  @override
  String get offerItems => '';

  @override
  String get addItem => '';

  @override
  String get pricePerItem => '';

  @override
  String get quantity => '';

  @override
  String get createOfferButton => '';

  @override
  String get selectDate => '';

  @override
  String get selectTime => '';

  @override
  String get optional => '';

  @override
  String get remove => '';

  @override
  String get retry => '';

  @override
  String get errorLoadingAirports => '';

  @override
  String get errorCreatingFlight => '';

  @override
  String get errorCreatingOffer => '';

  @override
  String get offerCreatedSuccess => '';
}
