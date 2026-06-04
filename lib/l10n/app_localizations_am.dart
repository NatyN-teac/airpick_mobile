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
}
