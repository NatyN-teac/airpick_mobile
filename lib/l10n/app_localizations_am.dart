// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appName => 'GuzoMy';

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
  String get createOffer => 'አቅርቦት ፍጠር';

  @override
  String get createAsCarrier => 'እንደ አጓጓዥ ፍጠር';

  @override
  String get createAsSender => 'እንደ ላኪ ፍጠር';

  @override
  String get stepFlightDetails => 'የበረራ ዝርዝሮች';

  @override
  String get stepOfferDetails => 'የአቅርቦት ዝርዝሮች';

  @override
  String get step1of2 => 'ደረጃ 1 ከ2';

  @override
  String get step2of2 => 'ደረጃ 2 ከ2';

  @override
  String get flightType => 'የበረራ ዓይነት';

  @override
  String get oneWay => 'አንድ አቅጣጫ';

  @override
  String get roundTrip => 'ደርሶ መልስ';

  @override
  String get fromAirport => 'ከ';

  @override
  String get toAirport => 'ወደ';

  @override
  String get searchAirport => 'አውሮፕላን ማረፊያ ወይም ከተማ ይፈልጉ…';

  @override
  String get departureDate => 'የመነሻ ቀን';

  @override
  String get departureTime => 'የመነሻ ሰዓት';

  @override
  String get arrivalDate => 'የመድረሻ ቀን';

  @override
  String get arrivalTime => 'የመድረሻ ሰዓት';

  @override
  String get returnLeg => 'የመመለሻ በረራ';

  @override
  String get continueToOffer => 'ቀጥል';

  @override
  String get pickupArea => 'የመውሰጃ አካባቢ';

  @override
  String get deliveryArea => 'የማድረሻ አካባቢ';

  @override
  String get urgencyLevel => 'አጣዳፊነት';

  @override
  String get urgencyNormal => 'መደበኛ';

  @override
  String get urgencyExpress => 'ፈጣን';

  @override
  String get discount => 'ቅናሽ (%)';

  @override
  String get specialNote => 'ልዩ ማስታወሻ';

  @override
  String get meetupPlaces => 'የመገናኛ ቦታዎች';

  @override
  String get addMeetupPlace => 'የመገናኛ ቦታ ጨምር';

  @override
  String get paymentMethods => 'የክፍያ ዘዴዎች';

  @override
  String get offerItems => 'እቃዎች';

  @override
  String get addItem => 'እቃ ጨምር';

  @override
  String get pricePerItem => 'የአንድ እቃ ዋጋ';

  @override
  String get quantity => 'ብዛት';

  @override
  String get createOfferButton => 'አቅርቦት ፍጠር';

  @override
  String get selectDate => 'ቀን ይምረጡ';

  @override
  String get selectTime => 'ሰዓት ይምረጡ';

  @override
  String get optional => 'አማራጭ';

  @override
  String get remove => 'አስወግድ';

  @override
  String get retry => 'እንደገና ሞክር';

  @override
  String get errorLoadingAirports => 'አውሮፕላን ማረፊያዎችን መጫን አልተሳካም';

  @override
  String get errorCreatingFlight => 'በረራ መፍጠር አልተሳካም';

  @override
  String get errorCreatingOffer => 'አቅርቦት መፍጠር አልተሳካም';

  @override
  String get offerCreatedSuccess => 'አቅርቦት በተሳካ ሁኔታ ተፈጥሯል!';

  @override
  String get logOut => 'ውጣ';

  @override
  String get logOutConfirmBody => 'ከመለያዎ መውጣት እንደሚፈልጉ እርግጠኛ ነዎት?';

  @override
  String get cancel => 'ሰርዝ';

  @override
  String get logOutSub => 'ከመለያዎ ይውጡ';

  @override
  String get profileUserDetails => 'የተጠቃሚ ዝርዝሮች';

  @override
  String get profileUserDetailsSub => 'ስምዎን እና የመገለጫ መረጃዎን ያዘምኑ';

  @override
  String get profileVerification => 'የመለያ ማረጋገጫ';

  @override
  String get profileVerificationSub => 'ማንነትዎን በፓስፖርት ያረጋግጡ';

  @override
  String get profileLanguage => 'ቋንቋ';

  @override
  String get profileLanguageSub => 'የሚመርጡትን ቋንቋ ይምረጡ';

  @override
  String get profileMode => 'ሁነታ';

  @override
  String get profileModeSub => 'በላኪ እና በአጓጓዥ መካከል ይቀያይሩ';

  @override
  String get profileAbout => 'ስለ';

  @override
  String get profileAboutSub => 'ስለ GuzoMy የበለጠ ይወቁ';

  @override
  String get profileCloseAccount => 'መለያ ዝጋ';

  @override
  String get profileCloseAccountSub => 'መለያዎን በቋሚነት ይሰርዙ';

  @override
  String get guest => 'እንግዳ';

  @override
  String get verified => 'የተረጋገጠ';

  @override
  String get unverified => 'ያልተረጋገጠ';

  @override
  String get modeChooseTitle => 'ሁነታዎን ይምረጡ';

  @override
  String get modeChooseSubtitle =>
      'GuzoMyን እንዴት መጠቀም እንደሚፈልጉ ይምረጡ። መገለጫዎ እና መነሻ ገጽዎ ወዲያውኑ ይዘምናሉ።';

  @override
  String aboutVersion(Object version) {
    return 'ስሪት $version';
  }

  @override
  String get aboutSectionTitle => 'ስለ GuzoMy';

  @override
  String get aboutBody =>
      'GuzoMy ተጓዦችንና ላኪዎችን በአውሮፕላን ማረፊያዎች መካከል ደህንነቱ ለተጠበቀ አቻ-ለ-አቻ የእሽግ ዴሊቨሪ ያገናኛል። እየተጓዙ እቃ መያዝ ቢችሉም ሆነ የሚደርስልዎ ነገር ቢፈልጉ፣ GuzoMy የታመኑ አጋሮችን እንዲያገኙ ይረዳዎታል።';

  @override
  String get aboutKeyFeatures => 'ዋና ዋና ባህሪያት';

  @override
  String get aboutFeature1 => 'ለታመነ ዴሊቨሪ የተረጋገጡ መለያዎች';

  @override
  String get aboutFeature2 => 'ለተጓዦች በአውሮፕላን ማረፊያ ላይ የተመሰረተ ማዛመድ';

  @override
  String get aboutFeature3 => 'እቃዎችን በቀላሉ ይላኩ እና ይቀበሉ';

  @override
  String get aboutFeature4 => 'በመተግበሪያ ውስጥ መልእክት (በቅርቡ)';

  @override
  String get closeVerifyRequiredSnack => 'መለያዎን ከመዝጋትዎ በፊት ማረጋገጥ አለብዎት።';

  @override
  String get closeTypeDeleteSnack => 'ለማረጋገጥ DELETE ብለው ይተይቡ።';

  @override
  String get closeUserIdNotFound => 'የተጠቃሚ መታወቂያ አልተገኘም።';

  @override
  String get closeNotConfirmed => 'የመለያ መዘጋት አልተረጋገጠም።';

  @override
  String get closeSuccessDefault => 'መለያ በተሳካ ሁኔታ ተዘግቷል።';

  @override
  String get closePermanentTitle => 'ይህ እርምጃ ቋሚ ነው';

  @override
  String get closePermanentBody =>
      'መለያዎን መዝጋት መገለጫዎን፣ አቅርቦቶችዎን እና ጥያቄዎችዎን በቋሚነት ይሰርዛል። ይህ መመለስ አይቻልም።';

  @override
  String get closeVerifyRequiredBanner => 'መለያዎን ከመዝጋትዎ በፊት የመለያ ማረጋገጫ ያስፈልጋል።';

  @override
  String get closeConfirmTitle => 'ስረዛን ያረጋግጡ';

  @override
  String get closeConfirmBody =>
      'መለያዎን በቋሚነት መዝጋት እንደሚፈልጉ ለማረጋገጥ ከታች DELETE ብለው ይተይቡ።';

  @override
  String get closeButton => 'መለያዬን ዝጋ';

  @override
  String get languageSelectTitle => 'ቋንቋ ይምረጡ';

  @override
  String get languageSelectSubtitle => 'ለመተግበሪያው የሚመርጡትን ቋንቋ ይምረጡ።';

  @override
  String get navHome => 'መነሻ';

  @override
  String get navChat => 'ውይይት';

  @override
  String get navAlerts => 'ማንቂያዎች';

  @override
  String get navProfile => 'መገለጫ';

  @override
  String get homeGreeting => 'እንኳን ደህና መጡ 👋';

  @override
  String get homeQuestion => 'ዛሬ ምን አለ?';

  @override
  String get sectionInDelivery => 'በመላክ ላይ';

  @override
  String get sectionEngagements => 'ተሳትፎዎች';

  @override
  String get sectionAvailableCarriers => 'ያሉ አጓጓዦች';

  @override
  String get sectionOfferRequests => 'የአቅርቦት ጥያቄዎች';

  @override
  String get seeAll => 'ሁሉንም ይመልከቱ';

  @override
  String get centerRequests => 'ጥያቄዎች';

  @override
  String get centerOffers => 'አቅርቦቶች';

  @override
  String get fabCreate => 'ፍጠር';

  @override
  String activeEngagements(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ንቁ ተሳትፎ',
    );
    return '$_temp0';
  }

  @override
  String get latestLabel => 'የቅርብ ጊዜ';

  @override
  String get modeSender => 'ላኪ';

  @override
  String get modeCarrier => 'አጓጓዥ';

  @override
  String get modeSenderPill => 'የላኪ ሁነታ';

  @override
  String get modeCarrierPill => 'የአጓጓዥ ሁነታ';

  @override
  String get modeSenderDesc => 'እቃዎች እንዲደርሱልኝ እፈልጋለሁ';

  @override
  String get modeCarrierDesc => 'እየተጓዝኩ ነው እና እቃ መያዝ እችላለሁ';

  @override
  String get modePickerTitle => 'ሁነታ ቀይር';

  @override
  String get modePickerQuestion => 'ዛሬ GuzoMyን እንዴት እየተጠቀሙ ነው?';

  @override
  String get active => 'ንቁ';

  @override
  String get verifyRequiredTitle => 'ማረጋገጫ ያስፈልጋል';

  @override
  String verifyRequiredBody(Object action) {
    return '$action ከመቻልዎ በፊት ማንነትዎን ማረጋገጥ አለብዎት። ማረጋገጫው ጥቂት ደቂቃዎችን ብቻ ይወስዳል።';
  }

  @override
  String get verifyMyIdentity => 'ማንነቴን አረጋግጥ';

  @override
  String get verifyActionDefault => 'አቅርቦቶች፣ ጥያቄዎች ወይም ሀሳቦች መፍጠር';

  @override
  String get verifyActionCreateOffer => 'አቅርቦት መፍጠር';

  @override
  String get verifyActionCreateRequest => 'ጥያቄ መፍጠር';

  @override
  String get udErrorRefresh =>
      'ከአገልጋዩ ማደስ አልተቻለም። የተቀመጠ መረጃ እየታየ ነው — አሁንም አርትዖት አድርገው ማስቀመጥ ይችላሉ።';

  @override
  String get udCouldNotLoad => 'መገለጫ መጫን አልተቻለም';

  @override
  String get userIdNotFound => 'የተጠቃሚ መታወቂያ አልተገኘም።';

  @override
  String get udUpdatedTitle => 'መገለጫ ተዘምኗል!';

  @override
  String get udUpdatedSub => 'ዝርዝሮችዎ ተቀምጠዋል።';

  @override
  String get sectionPersonal => 'የግል';

  @override
  String get sectionLocation => 'አድራሻ';

  @override
  String get firstName => 'የመጀመሪያ ስም';

  @override
  String get middleName => 'የአባት ስም';

  @override
  String get lastName => 'የአያት ስም';

  @override
  String get dateOfBirth => 'የልደት ቀን';

  @override
  String get city => 'ከተማ';

  @override
  String get stateRegion => 'ክልል / አካባቢ';

  @override
  String get country => 'ሀገር';

  @override
  String get bio => 'ስለ እርስዎ';

  @override
  String get bioHint => 'ስለ ራስዎ ለሌሎች ትንሽ ይንገሩ';

  @override
  String get firstNameRequired => 'የመጀመሪያ ስም ያስፈልጋል።';

  @override
  String get lastNameRequired => 'የአያት ስም ያስፈልጋል።';

  @override
  String get cityRequired => 'ከተማ ያስፈልጋል።';

  @override
  String get countryRequired => 'ሀገር ያስፈልጋል።';

  @override
  String get dobRequired => 'የልደት ቀን ያስፈልጋል።';

  @override
  String get saveChanges => 'ለውጦችን አስቀምጥ';

  @override
  String get avSubmittedTitle => 'ማረጋገጫ ገብቷል!';

  @override
  String get avSubmittedSub => 'መታወቂያዎን እየገመገምን ነው። ለቅርብ ጊዜ ሁኔታ ወደታች ይጎትቱ።';

  @override
  String get avVerifiedTitle => 'ተረጋግጠዋል!';

  @override
  String get avVerifiedSub => 'ማንነትዎ ተረጋግጧል። በGuzoMy ላይ ዝግጁ ነዎት።';

  @override
  String get avCouldNotLoad => 'ማረጋገጫ መጫን አልተቻለም';

  @override
  String get avLoadFailed => 'የማረጋገጫ ሁኔታ መጫን አልተሳካም።';

  @override
  String get avPreparing => 'ደህንነቱ የተጠበቀ ክፍለ ጊዜ በማዘጋጀት ላይ…';

  @override
  String get avChecking => 'የማረጋገጫ ሁኔታ በማጣራት ላይ…';

  @override
  String get avPoweredBy => 'በVeriff የተጎላበተ · ደህንነቱ የተጠበቀ የማንነት ማረጋገጫ';

  @override
  String get avStatusVerifiedTitle => 'ተረጋግጠዋል';

  @override
  String get avStatusVerifiedBody =>
      'ማንነትዎ ተረጋግጧል። GuzoMyን ደህንነቱ የተጠበቀ ለማድረግ ስለረዱ እናመሰግናለን።';

  @override
  String get avStatusReviewTitle => 'ግምገማ በሂደት ላይ';

  @override
  String get avStatusReviewBody =>
      'Veriff ማስረከቢያዎን በማስኬድ ላይ ነው። ይህ አብዛኛውን ጊዜ ጥቂት ደቂቃዎችን ይወስዳል።';

  @override
  String get avStatusResubmitTitle => 'እንደገና ማስረከብ ያስፈልጋል';

  @override
  String get avStatusDeclinedTitle => 'ማረጋገጫ ተቀባይነት አላገኘም';

  @override
  String get avStatusRejectedBody =>
      'እባክዎ ትክክለኛ፣ በደንብ የበራ መታወቂያ እና ግልጽ ሴልፊ ይዘው እንደገና ይሞክሩ።';

  @override
  String get avStatusDefaultTitle => 'ማንነትዎን ያረጋግጡ';

  @override
  String get avStatusDefaultBody =>
      'በVeriff የተጎላበተ ፈጣን የመታወቂያ ስካን እና ሴልፊ ማህበረሰባችንን የታመነ ያደርገዋል።';

  @override
  String get avStepPrepare => 'ተዘጋጅ';

  @override
  String get avStepIdScan => 'የመታወቂያ ስካን';

  @override
  String get avStepSelfie => 'ሴልፊ';

  @override
  String get avStepReview => 'ግምገማ';

  @override
  String get avBeforeStart => 'ከመጀመርዎ በፊት';

  @override
  String get avTipLighting => 'ጥሩ ብርሃን ይጠቀሙ — በመታወቂያዎ ላይ ብልጭታን ያስወግዱ';

  @override
  String get avTipId => 'ፓስፖርት ወይም የመንግስት መታወቂያ ያዘጋጁ';

  @override
  String get avTipSelfie => 'ለሕያውነት ማረጋገጫ ፈጣን ሴልፊ ያነሳሉ';

  @override
  String get avTipTime => 'ወደ 2 ደቂቃ ይወስዳል';

  @override
  String get avChipEncrypted => 'የተመሰጠረ';

  @override
  String get avChip230 => '230+ ሀገራት';

  @override
  String get avWhatWentWrong => 'ምን ተሳሳተ';

  @override
  String get avStartVerification => 'ማረጋገጫ ጀምር';

  @override
  String get avTryAgainVeriff => 'በVeriff እንደገና ይሞክሩ';

  @override
  String get notifTitle => 'ማሳወቂያዎች';

  @override
  String get notifNew => 'አዲስ';

  @override
  String get notifEarlier => 'ቀደም ብሎ';

  @override
  String get notifCaughtUp => 'ሁሉንም አይተዋል';

  @override
  String notifUnread(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count አዲስ ዝማኔ',
    );
    return '$_temp0';
  }

  @override
  String get markAllRead => 'ሁሉንም እንደተነበበ ምልክት አድርግ';

  @override
  String get notifEmptyTitle => 'ማሳወቂያ የለም';

  @override
  String get notifEmptyBody => 'ስለ ግጥሚያዎችና ዴሊቨሪዎች ዝማኔዎች እዚህ ይመጣሉ።';

  @override
  String get viewAll => 'ሁሉንም እይ';

  @override
  String get engEmptyActive => 'ንቁ ተሳትፎዎች የሉም።';

  @override
  String get tabSent => 'የተላኩ';

  @override
  String get tabReceived => 'የተቀበሉ';

  @override
  String get tabMatched => 'የተዛመዱ';

  @override
  String get emptyProposalsSent => 'እስካሁን የተላከ ሀሳብ የለም።';

  @override
  String get emptyProposalsReceived => 'እስካሁን የተቀበሉት ሀሳብ የለም።';

  @override
  String get emptyMatches => 'እስካሁን ግጥሚያ የለም።';

  @override
  String get offersTitle => 'አቅርቦት';

  @override
  String get offersLoadError => 'አቅርቦቶችን መጫን አልተቻለም';

  @override
  String get offersEmptyTitle => 'እስካሁን አቅርቦት የለም';

  @override
  String get offersEmptyBody => 'ከበረራዎ ጋር አቅርቦት ለመለጠፍ + ን ይጫኑ።';

  @override
  String get offersEmptyStatusTitle => 'በዚህ ሁኔታ ውስጥ አቅርቦት የለም';

  @override
  String get offersEmptyStatusBody => 'ሌሎች አቅርቦቶችዎን ለማየት ሌላ የሁኔታ ማጣሪያ ይምረጡ።';

  @override
  String get offerDeleted => 'አቅርቦት ተሰርዟል';

  @override
  String get offerDeleteConfirmTitle => 'ይህን አቅርቦት ይሰረዝ?';

  @override
  String get offerDeleteConfirmBody => 'ይህ አቅርቦትዎን በቋሚነት ያስወግዳል።';

  @override
  String get delete => 'ሰርዝ';

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count እቃ',
    );
    return '$_temp0';
  }

  @override
  String get statusAll => 'ሁሉም';

  @override
  String get statusOpen => 'ክፍት';

  @override
  String get statusMatched => 'ተዛምዷል';

  @override
  String get statusCompleted => 'ተጠናቋል';

  @override
  String get statusExpired => 'ጊዜው አልፎበታል';

  @override
  String get statusCancelled => 'ተሰርዟል';

  @override
  String get offerCurrency => 'ገንዘብ';

  @override
  String get offerDiscountLabel => 'ቅናሽ';

  @override
  String get offerPayment => 'ክፍያ';

  @override
  String get offerMeetup => 'መገናኛ';

  @override
  String get offerNote => 'ማስታወሻ';

  @override
  String get offerTotalValue => 'ጠቅላላ ዋጋ';

  @override
  String get offerMatchThis => 'ይህን አቅርቦት አዛምድ';

  @override
  String get offerNoFlight => 'የተያያዘ በረራ የለም';

  @override
  String offerCreatedAgo(Object ago) {
    return 'የተፈጠረው $ago';
  }

  @override
  String get carriersLoadError => 'አጓጓዦችን መጫን አልተቻለም';

  @override
  String get carriersEmptyTitle => 'ምንም አጓጓዥ የለም';

  @override
  String get carriersEmptyBody => 'አጓጓዦች ጉዞ ሲለጥፉ እዚህ ይታያሉ።';

  @override
  String get editOfferTitle => 'አቅርቦት አርትዕ';

  @override
  String get offerDiscountOptional => 'ቅናሽ (አማራጭ)';

  @override
  String get offerNoteOptional => 'ማስታወሻ (አማራጭ)';

  @override
  String get offerUpdated => 'አቅርቦት ተዘምኗል';

  @override
  String get offerFlightNotEditable => 'በረራ ማስተካከል አይቻልም';

  @override
  String get offerNoteHint => 'ለምሳሌ. ተሰባሪ እቃዎች በጥንቃቄ ይያዛሉ';

  @override
  String get offerDeliveryHint => 'ለምሳሌ. ላጎስ፣ ናይጄሪያ';

  @override
  String get offerPickupHint => 'ለምሳሌ. ሎስ አንጀለስ፣ ካሊፎርኒያ';

  @override
  String get requestsTitle => 'ጥያቄ';

  @override
  String get requestsLoadError => 'ጥያቄዎችን መጫን አልተቻለም';

  @override
  String get requestsEmptyTitle => 'እስካሁን ጥያቄ የለም';

  @override
  String get requestsEmptyBody => 'እንዲደርሱልዎ የሚፈልጓቸውን እቃዎች ጥያቄ ለመፍጠር + ን ይጫኑ።';

  @override
  String get requestsEmptyStatusTitle => 'በዚህ ሁኔታ ጥያቄ የለም';

  @override
  String get requestsEmptyStatusBody => 'ሌሎች ጥያቄዎችዎን ለማየት ሌላ የሁኔታ ማጣሪያ ይምረጡ።';

  @override
  String get requestDeleted => 'ጥያቄ ተሰርዟል';

  @override
  String get requestDeleteConfirmTitle => 'ይህን ጥያቄ ይሰረዝ?';

  @override
  String get requestDeleteConfirmBody =>
      'ይህ የአቅርቦት ጥያቄዎን በቋሚነት ያስወግዳል። ይህ እርምጃ መመለስ አይቻልም።';

  @override
  String proposalsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ሀሳብ',
    );
    return '$_temp0';
  }

  @override
  String get statusPending => 'በመጠባበቅ ላይ';

  @override
  String get statusProposals => 'ሀሳቦች';

  @override
  String get statusAccepted => 'ተቀባይነት አግኝቷል';

  @override
  String get statusClosed => 'ተዘግቷል';

  @override
  String get statusPendingApproval => 'በማጽደቅ ላይ';

  @override
  String get statusNotAccepted => 'ተቀባይነት አላገኘም';

  @override
  String get reqPartial => 'ከፊል ✓';

  @override
  String get urgencyUrgent => 'አስቸኳይ';

  @override
  String get urgencyFlexible => 'ተለዋዋጭ';

  @override
  String get browseRequestsTitle => 'ጥያቄዎችን አስስ';

  @override
  String get filterRequests => 'ጥያቄዎችን አጣራ';

  @override
  String get sourceCountry => 'የመነሻ ሀገር';

  @override
  String get sourceCity => 'የመነሻ ከተማ';

  @override
  String get destinationCountry => 'የመድረሻ ሀገር';

  @override
  String get anyCountry => 'ማንኛውም ሀገር';

  @override
  String get anyOption => 'ማንኛውም';

  @override
  String get apply => 'ተግብር';

  @override
  String get clear => 'አጽዳ';

  @override
  String get noMatchingRequests => 'ተዛማጅ ጥያቄ የለም';

  @override
  String get tryClearingFilters => 'ማጣሪያዎቹን ማጽዳት ወይም ሌላ መስመር መፈለግ ይሞክሩ።';

  @override
  String get requestsBrowseEmptyTitle => 'ምንም ጥያቄ የለም';

  @override
  String get requestsBrowseEmptyBody => 'የላኪዎች ክፍት ጥያቄዎች ሲለጠፉ እዚህ ይታያሉ።';

  @override
  String get requestDetailTitle => 'የጥያቄ ዝርዝሮች';

  @override
  String get reqPartialProposals => 'ከፊል ሀሳቦች';

  @override
  String get preferredDate => 'የሚመረጥ ቀን';

  @override
  String get reqNoItems => 'ምንም እቃ የለም';

  @override
  String get reqHasProposalsLocked =>
      'ይህ ጥያቄ ሀሳቦች አሉት እና ከዚህ በኋላ ማስተካከል ወይም መሰረዝ አይቻልም።';

  @override
  String reqStatusLocked(Object status) {
    return 'ይህ ጥያቄ $status ነው እና ከዚህ በኋላ ማስተካከል ወይም መሰረዝ አይቻልም።';
  }

  @override
  String get createProposalSent => 'ሀሳብ ተልኳል';

  @override
  String get sendProposal => 'ሀሳብ ላክ';

  @override
  String get yourFlight => 'የእርስዎ በረራ';

  @override
  String airportInCountry(Object country) {
    return 'በ$country ውስጥ ያለ አውሮፕላን ማረፊያ';
  }

  @override
  String get pickupDelivery => 'መውሰድ እና ማድረስ';

  @override
  String get priceTheItems => 'እቃዎቹን ዋጋ ስጥ';

  @override
  String get partialAllowed => 'ከፊል ይፈቀዳል';

  @override
  String get proposalCurrency => 'የሀሳብ ገንዘብ';

  @override
  String get submit => 'አስገባ';

  @override
  String get priceLabel => 'ዋጋ';

  @override
  String get totalLabel => 'ጠቅላላ';

  @override
  String get pickupAreaHelp =>
      'እቃዎቹን ከበረራዎ በፊት የሚሰበስቡበት አጠቃላይ አካባቢ (ለምሳሌ ከተማ ወይም ሰፈር)።';

  @override
  String get meetupHelp =>
      'እቃዎቹን በአካል ለማስረከብ ወይም ለማስቀመጥ ላኪውን ማግኘት የሚችሉባቸው የተወሰኑ ቦታዎች (ለምሳሌ ሞል፣ ካፌ ወይም ምልክት)።';

  @override
  String get proposalNoteHint => 'ለምሳሌ. ከደረስኩ በ2 ቀናት ውስጥ ማድረስ እችላለሁ';

  @override
  String get chatsTitle => 'መልእክቶች';

  @override
  String get chatsEmptyTitle => 'እስካሁን ውይይት የለም';

  @override
  String get chatsEmptyBody => 'የተዛመዱ ዴሊቨሪዎች እዚህ ይታያሉ።';

  @override
  String get chatNoMessagesYet => 'እስካሁን መልእክት የለም';

  @override
  String get chatStartConvo => 'ዝግጁ ሲሆኑ ውይይቱን ይጀምሩ።';

  @override
  String get chatLoadError => 'ውይይት መጫን አልተቻለም';

  @override
  String get chatMatchDetails => 'የግጥሚያ ዝርዝሮች';

  @override
  String get chatMessageHint => 'መልእክት…';

  @override
  String chatItemsCount(Object count) {
    return 'እቃዎች ($count)';
  }

  @override
  String get chatRoute => 'መስመር';

  @override
  String get chatConfirmPickup => 'መውሰድን አረጋግጥ';

  @override
  String get chatReadyForPickup => 'ለመውሰድ ዝግጁ';

  @override
  String get chatPickUp => 'ውሰድ';

  @override
  String get chatStartDelivery => 'ዴሊቨሪ ጀምር';

  @override
  String get chatTakePhoto => 'ዴሊቨሪ ለመጀመር የእቃዎቹን ፎቶ ያንሱ።';

  @override
  String get chatTapAddPhoto => 'ፎቶ ለመጨመር ይንኩ';

  @override
  String get chatPhotographItems =>
      'ከላኪው የተቀበሏቸውን እቃዎች ፎቶ ያንሱ። ይህ የተከታተለ ዴሊቨሪ ይጀምራል።';

  @override
  String get chatDeliveryInProgress => 'ዴሊቨሪ በሂደት ላይ — ወደ መድረሻው ያምሩ።';

  @override
  String get chatItemLoadError => 'የእቃ ዝርዝሮች መጫን አልተቻለም።';

  @override
  String get chatToday => 'ዛሬ';

  @override
  String get deliveriesLoadError => 'ዴሊቨሪዎችን መጫን አልተቻለም';

  @override
  String get deliveriesEmptyTitle => 'ንቁ ዴሊቨሪ የለም';

  @override
  String get deliveriesEmptyBody =>
      'ዴሊቨሪዎች ከተወሰዱ በኋላ እና በመንገድ ላይ እያሉ እዚህ ይታያሉ።';

  @override
  String get searchChooseFilter => 'የፍለጋ ማጣሪያ ይምረጡ';

  @override
  String get searchFilterCarriersBy => 'አጓጓዦችን በዚህ አጣራ';

  @override
  String get searchFilterRequestsBy => 'የላኪ ጥያቄዎችን በዚህ አጣራ';

  @override
  String get searchOriginCountry => 'የመነሻ ሀገር';

  @override
  String get searchOriginCity => 'የመነሻ ከተማ';

  @override
  String get searchDestination => 'መድረሻ';

  @override
  String get searchAnywhere => 'የትም ቦታ';

  @override
  String get searchQuickSearches => 'ፈጣን ፍለጋዎች';

  @override
  String searchNoResults(Object query) {
    return 'ከ\"$query\" ጋር የተዛመደ የላኪ ጥያቄ የለም።';
  }

  @override
  String searchResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ውጤት',
    );
    return '$_temp0';
  }

  @override
  String get matchOfferTitle => 'አቅርቦት አዛምድ';

  @override
  String get matchCreatedTitle => 'ግጥሚያ ተፈጥሯል!';

  @override
  String get matchCreatedBody =>
      'መውሰድና ማድረስን ማዘጋጀት እንዲችሉ ከአጓጓዡ ጋር ውይይትዎን በመክፈት ላይ።';

  @override
  String get matchWhatNeed => 'ምን ይፈልጋሉ?';

  @override
  String get matchSelectItems => 'ለማዛመድ እቃዎችንና ብዛቶችን ይምረጡ።';

  @override
  String get matchWhoReceives => 'ማን ይቀበላል?';

  @override
  String get matchItemsToMe => 'እቃዎቹ ወደ እኔ ይመጣሉ';

  @override
  String get matchSomeoneElse => 'ሌላ ሰው';

  @override
  String get matchThirdParty => 'ሶስተኛ ወገን ተቀባይ';

  @override
  String get matchReceiverDetails => 'የተቀባይ ዝርዝሮች';

  @override
  String get matchPhoneHint => 'ስልክ (ለምሳሌ +12025551234)';

  @override
  String get matchPhotoId => 'የፎቶ መታወቂያ';

  @override
  String get matchUploadId => 'በመንግስት የተሰጠ መታወቂያ ይስቀሉ';

  @override
  String get matchChange => 'ቀይር';

  @override
  String get cameraOption => 'ካሜራ';

  @override
  String get photoLibraryOption => 'የፎቶ ማከማቻ';

  @override
  String get matchSendMatch => 'ግጥሚያ ላክ';

  @override
  String get matchSending => 'ግጥሚያ በመላክ ላይ…';

  @override
  String get matchUploadingId => 'መታወቂያ በመስቀል ላይ…';

  @override
  String get matchEstimatedTotal => 'የተገመተ ጠቅላላ';

  @override
  String get matchPickup => 'መውሰጃ';

  @override
  String get matchDelivery => 'ማድረሻ';
}
