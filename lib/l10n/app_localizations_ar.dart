// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'GuzoMy';

  @override
  String get skip => 'تخطّي';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get onboardingTitle1 => 'مجتمع موثوق';

  @override
  String get onboardingSubtitle1 =>
      'انضم إلى شبكة موثّقة من المسافرين والمُرسِلين بثقة.';

  @override
  String get onboardingTitle2 => 'توصيل سريع وموثوق';

  @override
  String get onboardingSubtitle2 =>
      'تواصل مع مسافرين متجهين إلى وجهتك واستلم أغراضك في الوقت المحدد.';

  @override
  String get onboardingTitle3 => 'بسيط وآمن';

  @override
  String get onboardingSubtitle3 => 'تابع التقدّم وأكمل التوصيل بكل اطمئنان.';

  @override
  String get authTitle => 'تسجيل الدخول أو\nإنشاء حساب';

  @override
  String get authSubtitle => 'تابع باستخدام حساب اجتماعي للبدء.';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get continueWithApple => 'المتابعة باستخدام Apple';

  @override
  String get peerToPeerDelivery => 'توصيل بين الأفراد';

  @override
  String get termsPrefix => 'بالمتابعة، فإنك توافق على ';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get and => ' و ';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String signInCancelledTitle(String provider) {
    return 'تم إلغاء تسجيل الدخول عبر $provider';
  }

  @override
  String get signInCancelledBody =>
      'لقد أغلقت نافذة تسجيل الدخول قبل الانتهاء. لم يتم إجراء أي تغييرات.';

  @override
  String tryAgain(String provider) {
    return 'حاول عبر $provider مرة أخرى';
  }

  @override
  String get maybeLater => 'ربما لاحقًا';

  @override
  String get createOffer => 'إنشاء عرض';

  @override
  String get createAsCarrier => 'إنشاء كناقل';

  @override
  String get createAsSender => 'إنشاء كمُرسِل';

  @override
  String get stepFlightDetails => 'تفاصيل الرحلة';

  @override
  String get stepOfferDetails => 'تفاصيل العرض';

  @override
  String get step1of2 => 'الخطوة 1 من 2';

  @override
  String get step2of2 => 'الخطوة 2 من 2';

  @override
  String get flightType => 'نوع الرحلة';

  @override
  String get oneWay => 'ذهاب فقط';

  @override
  String get roundTrip => 'ذهاب وإياب';

  @override
  String get fromAirport => 'من';

  @override
  String get toAirport => 'إلى';

  @override
  String get searchAirport => 'ابحث عن مطار أو مدينة…';

  @override
  String get departureDate => 'تاريخ المغادرة';

  @override
  String get departureTime => 'وقت المغادرة';

  @override
  String get arrivalDate => 'تاريخ الوصول';

  @override
  String get arrivalTime => 'وقت الوصول';

  @override
  String get returnLeg => 'رحلة العودة';

  @override
  String get continueToOffer => 'متابعة';

  @override
  String get pickupArea => 'منطقة الاستلام';

  @override
  String get deliveryArea => 'منطقة التسليم';

  @override
  String get urgencyLevel => 'الأولوية';

  @override
  String get urgencyNormal => 'عادي';

  @override
  String get urgencyExpress => 'سريع';

  @override
  String get discount => 'خصم (%)';

  @override
  String get specialNote => 'ملاحظة خاصة';

  @override
  String get meetupPlaces => 'أماكن اللقاء';

  @override
  String get addMeetupPlace => 'إضافة مكان لقاء';

  @override
  String get paymentMethods => 'طرق الدفع';

  @override
  String get offerItems => 'العناصر';

  @override
  String get addItem => 'إضافة عنصر';

  @override
  String get pricePerItem => 'السعر لكل عنصر';

  @override
  String get quantity => 'الكمية';

  @override
  String get createOfferButton => 'إنشاء عرض';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get optional => 'اختياري';

  @override
  String get remove => 'إزالة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get errorLoadingAirports => 'فشل تحميل المطارات';

  @override
  String get errorCreatingFlight => 'فشل إنشاء الرحلة';

  @override
  String get errorCreatingOffer => 'فشل إنشاء العرض';

  @override
  String get offerCreatedSuccess => 'تم إنشاء العرض بنجاح!';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get logOutConfirmBody =>
      'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get logOutSub => 'تسجيل الخروج من حسابك';

  @override
  String get profileUserDetails => 'تفاصيل المستخدم';

  @override
  String get profileUserDetailsSub => 'حدّث اسمك ومعلومات ملفك الشخصي';

  @override
  String get profileVerification => 'التحقق من الحساب';

  @override
  String get profileVerificationSub => 'تحقّق من هويتك باستخدام جواز السفر';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileLanguageSub => 'اختر لغتك المفضّلة';

  @override
  String get profileMode => 'الوضع';

  @override
  String get profileModeSub => 'بدّل بين المُرسِل والناقل';

  @override
  String get profileAbout => 'حول';

  @override
  String get profileAboutSub => 'تعرّف أكثر على GuzoMy';

  @override
  String get profileCloseAccount => 'إغلاق الحساب';

  @override
  String get profileCloseAccountSub => 'احذف حسابك نهائيًا';

  @override
  String get guest => 'ضيف';

  @override
  String get verified => 'موثّق';

  @override
  String get unverified => 'غير موثّق';

  @override
  String get modeChooseTitle => 'اختر وضعك';

  @override
  String get modeChooseSubtitle =>
      'اختر كيف تريد استخدام GuzoMy. سيتم تحديث ملفك الشخصي وشاشتك الرئيسية فورًا.';

  @override
  String aboutVersion(Object version) {
    return 'الإصدار $version';
  }

  @override
  String get aboutSectionTitle => 'حول GuzoMy';

  @override
  String get aboutBody =>
      'يربط GuzoMy المسافرين والمُرسِلين لتوصيل الطرود بشكل آمن بين الأفراد عبر المطارات. سواء كنت مسافرًا ويمكنك حمل الأغراض، أو تحتاج إلى توصيل شيء ما، يساعدك GuzoMy في العثور على شركاء موثوقين.';

  @override
  String get aboutKeyFeatures => 'الميزات الرئيسية';

  @override
  String get aboutFeature1 => 'حسابات موثّقة لتوصيل آمن';

  @override
  String get aboutFeature2 => 'مطابقة قائمة على المطارات للمسافرين';

  @override
  String get aboutFeature3 => 'أرسل واستلم الأغراض بسهولة';

  @override
  String get aboutFeature4 => 'المراسلة داخل التطبيق (قريبًا)';

  @override
  String get closeVerifyRequiredSnack => 'يجب التحقق من حسابك قبل إغلاقه.';

  @override
  String get closeTypeDeleteSnack => 'اكتب DELETE للتأكيد.';

  @override
  String get closeUserIdNotFound => 'لم يتم العثور على معرّف المستخدم.';

  @override
  String get closeNotConfirmed => 'لم يتم تأكيد إغلاق الحساب.';

  @override
  String get closeSuccessDefault => 'تم إغلاق الحساب بنجاح.';

  @override
  String get closePermanentTitle => 'هذا الإجراء دائم';

  @override
  String get closePermanentBody =>
      'سيؤدي إغلاق حسابك إلى حذف ملفك الشخصي وعروضك وطلباتك نهائيًا. لا يمكن التراجع عن هذا.';

  @override
  String get closeVerifyRequiredBanner =>
      'التحقق من الحساب مطلوب قبل أن تتمكن من إغلاق حسابك.';

  @override
  String get closeConfirmTitle => 'تأكيد الحذف';

  @override
  String get closeConfirmBody =>
      'اكتب DELETE أدناه لتأكيد رغبتك في إغلاق حسابك نهائيًا.';

  @override
  String get closeButton => 'إغلاق حسابي';

  @override
  String get languageSelectTitle => 'اختر اللغة';

  @override
  String get languageSelectSubtitle => 'اختر لغتك المفضّلة للتطبيق.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navChat => 'المحادثة';

  @override
  String get navAlerts => 'التنبيهات';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get homeGreeting => 'سعداء بعودتك 👋';

  @override
  String get homeQuestion => 'ماذا يحدث اليوم؟';

  @override
  String get sectionInDelivery => 'قيد التوصيل';

  @override
  String get sectionEngagements => 'الارتباطات';

  @override
  String get sectionAvailableCarriers => 'الناقلون المتاحون';

  @override
  String get sectionOfferRequests => 'طلبات العروض';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get centerRequests => 'الطلبات';

  @override
  String get centerOffers => 'العروض';

  @override
  String activeEngagements(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ارتباط نشط',
    );
    return '$_temp0';
  }

  @override
  String get latestLabel => 'الأحدث';

  @override
  String get modeSender => 'مُرسِل';

  @override
  String get modeCarrier => 'ناقل';

  @override
  String get modeSenderPill => 'وضع المُرسِل';

  @override
  String get modeCarrierPill => 'وضع الناقل';

  @override
  String get modeSenderDesc => 'أحتاج إلى توصيل أغراض';

  @override
  String get modeCarrierDesc => 'أنا مسافر ويمكنني حمل الأغراض';

  @override
  String get modePickerTitle => 'تبديل الوضع';

  @override
  String get modePickerQuestion => 'كيف تستخدم GuzoMy اليوم؟';

  @override
  String get active => 'نشط';

  @override
  String get verifyRequiredTitle => 'التحقق مطلوب';

  @override
  String verifyRequiredBody(Object action) {
    return 'يجب عليك التحقق من هويتك قبل أن تتمكن من $action. لا يستغرق التحقق سوى بضع دقائق.';
  }

  @override
  String get verifyMyIdentity => 'تحقّق من هويتي';

  @override
  String get verifyActionDefault => 'إنشاء العروض أو الطلبات أو المقترحات';

  @override
  String get verifyActionCreateOffer => 'إنشاء عرض';

  @override
  String get udErrorRefresh =>
      'تعذّر التحديث من الخادم. يتم عرض المعلومات المحفوظة — لا يزال بإمكانك التعديل والحفظ.';

  @override
  String get udCouldNotLoad => 'تعذّر تحميل الملف الشخصي';

  @override
  String get userIdNotFound => 'لم يتم العثور على معرّف المستخدم.';

  @override
  String get udUpdatedTitle => 'تم تحديث الملف الشخصي!';

  @override
  String get udUpdatedSub => 'تم حفظ بياناتك.';

  @override
  String get sectionPersonal => 'شخصي';

  @override
  String get sectionLocation => 'الموقع';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get middleName => 'الاسم الأوسط';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get city => 'المدينة';

  @override
  String get stateRegion => 'الولاية / المنطقة';

  @override
  String get country => 'الدولة';

  @override
  String get bio => 'نبذة';

  @override
  String get bioHint => 'أخبر الآخرين قليلاً عن نفسك';

  @override
  String get firstNameRequired => 'الاسم الأول مطلوب.';

  @override
  String get lastNameRequired => 'اسم العائلة مطلوب.';

  @override
  String get cityRequired => 'المدينة مطلوبة.';

  @override
  String get countryRequired => 'الدولة مطلوبة.';

  @override
  String get dobRequired => 'تاريخ الميلاد مطلوب.';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get avSubmittedTitle => 'تم إرسال طلب التحقق!';

  @override
  String get avSubmittedSub =>
      'نقوم بمراجعة هويتك. اسحب للأسفل للتحديث لمعرفة أحدث حالة.';

  @override
  String get avVerifiedTitle => 'تم التحقق منك!';

  @override
  String get avVerifiedSub => 'تم تأكيد هويتك. أنت جاهز على GuzoMy.';

  @override
  String get avCouldNotLoad => 'تعذّر تحميل التحقق';

  @override
  String get avLoadFailed => 'فشل تحميل حالة التحقق.';

  @override
  String get avPreparing => 'جارٍ تجهيز جلسة آمنة…';

  @override
  String get avChecking => 'جارٍ التحقق من حالة التحقق…';

  @override
  String get avPoweredBy => 'مدعوم بواسطة Veriff · تحقق آمن من الهوية';

  @override
  String get avStatusVerifiedTitle => 'تم التحقق منك';

  @override
  String get avStatusVerifiedBody =>
      'تم تأكيد هويتك. شكرًا لمساعدتك في الحفاظ على أمان GuzoMy.';

  @override
  String get avStatusReviewTitle => 'المراجعة قيد التقدم';

  @override
  String get avStatusReviewBody =>
      'يقوم Veriff بمعالجة طلبك. يستغرق هذا عادةً بضع دقائق.';

  @override
  String get avStatusResubmitTitle => 'يلزم إعادة الإرسال';

  @override
  String get avStatusDeclinedTitle => 'تم رفض التحقق';

  @override
  String get avStatusRejectedBody =>
      'يرجى المحاولة مرة أخرى بهوية صالحة وجيدة الإضاءة وصورة سيلفي واضحة.';

  @override
  String get avStatusDefaultTitle => 'تحقّق من هويتك';

  @override
  String get avStatusDefaultBody =>
      'مسح سريع للهوية وصورة سيلفي مدعومان بـ Veriff يحافظان على ثقة مجتمعنا.';

  @override
  String get avStepPrepare => 'التحضير';

  @override
  String get avStepIdScan => 'مسح الهوية';

  @override
  String get avStepSelfie => 'سيلفي';

  @override
  String get avStepReview => 'المراجعة';

  @override
  String get avBeforeStart => 'قبل أن تبدأ';

  @override
  String get avTipLighting => 'استخدم إضاءة جيدة — تجنّب الوهج على هويتك';

  @override
  String get avTipId => 'جهّز جواز سفر أو هوية حكومية';

  @override
  String get avTipSelfie => 'ستلتقط صورة سيلفي سريعة للتحقق من الحيوية';

  @override
  String get avTipTime => 'يستغرق حوالي دقيقتين';

  @override
  String get avChipEncrypted => 'مشفّر';

  @override
  String get avChip230 => '+230 دولة';

  @override
  String get avWhatWentWrong => 'ما الخطأ الذي حدث';

  @override
  String get avStartVerification => 'ابدأ التحقق';

  @override
  String get avTryAgainVeriff => 'حاول مرة أخرى مع Veriff';

  @override
  String get notifTitle => 'الإشعارات';

  @override
  String get notifNew => 'جديد';

  @override
  String get notifEarlier => 'سابقًا';

  @override
  String get notifCaughtUp => 'أنت على اطّلاع بكل شيء';

  @override
  String notifUnread(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تحديث جديد',
    );
    return '$_temp0';
  }

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get notifEmptyTitle => 'لا توجد إشعارات';

  @override
  String get notifEmptyBody => 'تظهر هنا التحديثات حول المطابقات والتوصيلات.';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get engEmptyActive => 'لا توجد ارتباطات نشطة.';

  @override
  String get tabSent => 'المُرسَلة';

  @override
  String get tabReceived => 'المُستلَمة';

  @override
  String get tabMatched => 'المتطابقة';

  @override
  String get emptyProposalsSent => 'لم يتم إرسال أي مقترحات بعد.';

  @override
  String get emptyProposalsReceived => 'لم يتم استلام أي مقترحات بعد.';

  @override
  String get emptyMatches => 'لا توجد مطابقات بعد.';

  @override
  String get offersTitle => 'عرض';

  @override
  String get offersLoadError => 'تعذّر تحميل العروض';

  @override
  String get offersEmptyTitle => 'لا توجد عروض بعد';

  @override
  String get offersEmptyBody => 'اضغط + لنشر عرض مع رحلتك.';

  @override
  String get offersEmptyStatusTitle => 'لا توجد عروض بهذه الحالة';

  @override
  String get offersEmptyStatusBody =>
      'اختر عامل تصفية حالة آخر لرؤية عروضك الأخرى.';

  @override
  String get offerDeleted => 'تم حذف العرض';

  @override
  String get offerDeleteConfirmTitle => 'حذف هذا العرض؟';

  @override
  String get offerDeleteConfirmBody => 'سيؤدي هذا إلى إزالة عرضك نهائيًا.';

  @override
  String get delete => 'حذف';

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر',
    );
    return '$_temp0';
  }

  @override
  String get statusAll => 'الكل';

  @override
  String get statusOpen => 'مفتوح';

  @override
  String get statusMatched => 'تمت المطابقة';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusExpired => 'منتهي الصلاحية';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get offerCurrency => 'العملة';

  @override
  String get offerDiscountLabel => 'خصم';

  @override
  String get offerPayment => 'الدفع';

  @override
  String get offerMeetup => 'اللقاء';

  @override
  String get offerNote => 'ملاحظة';

  @override
  String get offerTotalValue => 'القيمة الإجمالية';

  @override
  String get offerMatchThis => 'طابِق هذا العرض';

  @override
  String get offerNoFlight => 'لا توجد رحلة مرفقة';

  @override
  String offerCreatedAgo(Object ago) {
    return 'تم الإنشاء $ago';
  }

  @override
  String get carriersLoadError => 'تعذّر تحميل الناقلين';

  @override
  String get carriersEmptyTitle => 'لا يوجد ناقلون متاحون';

  @override
  String get carriersEmptyBody =>
      'سيظهر الناقلون المتاحون هنا عند نشر رحلاتهم.';

  @override
  String get editOfferTitle => 'تعديل العرض';

  @override
  String get offerDiscountOptional => 'خصم (اختياري)';

  @override
  String get offerNoteOptional => 'ملاحظة (اختياري)';

  @override
  String get offerUpdated => 'تم تحديث العرض';

  @override
  String get offerFlightNotEditable => 'لا يمكن تعديل الرحلة';

  @override
  String get offerNoteHint =>
      'مثال: يتم التعامل مع العناصر القابلة للكسر بعناية';

  @override
  String get offerDeliveryHint => 'مثال: لاغوس، نيجيريا';

  @override
  String get offerPickupHint => 'مثال: لوس أنجلوس، كاليفورنيا';

  @override
  String get requestsTitle => 'طلب';

  @override
  String get requestsLoadError => 'تعذّر تحميل الطلبات';

  @override
  String get requestsEmptyTitle => 'لا توجد طلبات بعد';

  @override
  String get requestsEmptyBody =>
      'اضغط + لإنشاء طلب للأغراض التي تحتاج إلى توصيلها.';

  @override
  String get requestsEmptyStatusTitle => 'لا توجد طلبات بهذه الحالة';

  @override
  String get requestsEmptyStatusBody =>
      'اختر عامل تصفية حالة آخر لرؤية طلباتك الأخرى.';

  @override
  String get requestDeleted => 'تم حذف الطلب';

  @override
  String get requestDeleteConfirmTitle => 'حذف هذا الطلب؟';

  @override
  String get requestDeleteConfirmBody =>
      'سيؤدي هذا إلى إزالة طلب عرضك نهائيًا. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String proposalsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مقترح',
    );
    return '$_temp0';
  }

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusProposals => 'مقترحات';

  @override
  String get statusAccepted => 'مقبول';

  @override
  String get statusClosed => 'مغلق';

  @override
  String get statusPendingApproval => 'في انتظار الموافقة';

  @override
  String get statusNotAccepted => 'غير مقبول';

  @override
  String get reqPartial => 'جزئي ✓';

  @override
  String get urgencyUrgent => 'عاجل';

  @override
  String get urgencyFlexible => 'مرن';

  @override
  String get browseRequestsTitle => 'تصفّح الطلبات';

  @override
  String get filterRequests => 'تصفية الطلبات';

  @override
  String get sourceCountry => 'بلد المصدر';

  @override
  String get sourceCity => 'مدينة المصدر';

  @override
  String get destinationCountry => 'بلد الوجهة';

  @override
  String get anyCountry => 'أي بلد';

  @override
  String get anyOption => 'أي';

  @override
  String get apply => 'تطبيق';

  @override
  String get clear => 'مسح';

  @override
  String get noMatchingRequests => 'لا توجد طلبات مطابقة';

  @override
  String get tryClearingFilters =>
      'حاول مسح عوامل التصفية أو البحث عن مسار آخر.';

  @override
  String get requestsBrowseEmptyTitle => 'لا توجد طلبات متاحة';

  @override
  String get requestsBrowseEmptyBody =>
      'ستظهر طلبات المُرسِلين المفتوحة هنا عند نشرها.';

  @override
  String get requestDetailTitle => 'تفاصيل الطلب';

  @override
  String get reqPartialProposals => 'مقترحات جزئية';

  @override
  String get preferredDate => 'التاريخ المفضّل';

  @override
  String get reqNoItems => 'لا توجد عناصر';

  @override
  String get reqHasProposalsLocked =>
      'يحتوي هذا الطلب على مقترحات ولم يعد من الممكن تعديله أو حذفه.';

  @override
  String reqStatusLocked(Object status) {
    return 'هذا الطلب $status ولم يعد من الممكن تعديله أو حذفه.';
  }

  @override
  String get createProposalSent => 'تم إرسال المقترح';

  @override
  String get sendProposal => 'إرسال مقترح';

  @override
  String get yourFlight => 'رحلتك';

  @override
  String airportInCountry(Object country) {
    return 'مطار في $country';
  }

  @override
  String get pickupDelivery => 'الاستلام والتسليم';

  @override
  String get priceTheItems => 'حدّد أسعار العناصر';

  @override
  String get partialAllowed => 'يُسمح بالجزئي';

  @override
  String get proposalCurrency => 'عملة المقترح';

  @override
  String get submit => 'إرسال';

  @override
  String get priceLabel => 'السعر';

  @override
  String get totalLabel => 'الإجمالي';

  @override
  String get pickupAreaHelp =>
      'المنطقة العامة التي ستجمع فيها الأغراض قبل رحلتك (مثل مدينة أو حي).';

  @override
  String get meetupHelp =>
      'أماكن محددة يمكنك فيها مقابلة المُرسِل شخصيًا لتسليم العناصر (مثل مركز تجاري أو مقهى أو معلم).';

  @override
  String get proposalNoteHint => 'مثال: يمكنني التوصيل خلال يومين من الوصول';

  @override
  String get chatsTitle => 'الرسائل';

  @override
  String get chatsEmptyTitle => 'لا توجد محادثات بعد';

  @override
  String get chatsEmptyBody => 'ستظهر عمليات التوصيل المتطابقة هنا.';

  @override
  String get chatNoMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get chatStartConvo => 'ابدأ المحادثة عندما تكون جاهزًا.';

  @override
  String get chatLoadError => 'تعذّر تحميل المحادثة';

  @override
  String get chatMatchDetails => 'تفاصيل المطابقة';

  @override
  String get chatMessageHint => 'رسالة…';

  @override
  String chatItemsCount(Object count) {
    return 'العناصر ($count)';
  }

  @override
  String get chatRoute => 'المسار';

  @override
  String get chatConfirmPickup => 'تأكيد الاستلام';

  @override
  String get chatReadyForPickup => 'جاهز للاستلام';

  @override
  String get chatPickUp => 'استلام';

  @override
  String get chatStartDelivery => 'بدء التوصيل';

  @override
  String get chatTakePhoto => 'التقط صورة للعناصر لبدء التوصيل.';

  @override
  String get chatTapAddPhoto => 'اضغط لإضافة صورة';

  @override
  String get chatPhotographItems =>
      'صوّر العناصر التي استلمتها من المُرسِل. هذا يبدأ التوصيل المتتبَّع.';

  @override
  String get chatDeliveryInProgress => 'التوصيل قيد التقدم — توجّه إلى الوجهة.';

  @override
  String get chatItemLoadError => 'تعذّر تحميل تفاصيل العنصر.';

  @override
  String get chatToday => 'اليوم';

  @override
  String get deliveriesLoadError => 'تعذّر تحميل عمليات التوصيل';

  @override
  String get deliveriesEmptyTitle => 'لا توجد عمليات توصيل نشطة';

  @override
  String get deliveriesEmptyBody =>
      'تظهر عمليات التوصيل هنا بعد الاستلام وأثناء الطريق.';

  @override
  String get searchChooseFilter => 'اختر عامل تصفية البحث';

  @override
  String get searchFilterCarriersBy => 'تصفية الناقلين حسب';

  @override
  String get searchFilterRequestsBy => 'تصفية طلبات المُرسِلين حسب';

  @override
  String get searchOriginCountry => 'بلد المنشأ';

  @override
  String get searchOriginCity => 'مدينة المنشأ';

  @override
  String get searchDestination => 'الوجهة';

  @override
  String get searchAnywhere => 'أي مكان';

  @override
  String get searchQuickSearches => 'عمليات بحث سريعة';

  @override
  String searchNoResults(Object query) {
    return 'لا توجد طلبات مُرسِلين مطابقة لـ \"$query\".';
  }

  @override
  String searchResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
    );
    return '$_temp0';
  }

  @override
  String get matchOfferTitle => 'مطابقة العرض';

  @override
  String get matchCreatedTitle => 'تم إنشاء المطابقة!';

  @override
  String get matchCreatedBody =>
      'جارٍ فتح محادثتك مع الناقل لترتيب الاستلام والتوصيل.';

  @override
  String get matchWhatNeed => 'ماذا تحتاج؟';

  @override
  String get matchSelectItems => 'اختر العناصر والكميات للمطابقة.';

  @override
  String get matchWhoReceives => 'من يستلم؟';

  @override
  String get matchItemsToMe => 'العناصر تأتي إليّ';

  @override
  String get matchSomeoneElse => 'شخص آخر';

  @override
  String get matchThirdParty => 'مستلِم طرف ثالث';

  @override
  String get matchReceiverDetails => 'تفاصيل المستلِم';

  @override
  String get matchPhoneHint => 'الهاتف (مثال +12025551234)';

  @override
  String get matchPhotoId => 'بطاقة هوية بصورة';

  @override
  String get matchUploadId => 'قم بتحميل هوية صادرة عن الحكومة';

  @override
  String get matchChange => 'تغيير';

  @override
  String get cameraOption => 'الكاميرا';

  @override
  String get photoLibraryOption => 'مكتبة الصور';

  @override
  String get matchSendMatch => 'إرسال المطابقة';

  @override
  String get matchSending => 'جارٍ إرسال المطابقة…';

  @override
  String get matchUploadingId => 'جارٍ تحميل الهوية…';

  @override
  String get matchEstimatedTotal => 'الإجمالي التقديري';

  @override
  String get matchPickup => 'الاستلام';

  @override
  String get matchDelivery => 'التوصيل';
}
