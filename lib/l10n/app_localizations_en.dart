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

  @override
  String get logOut => 'Log out';

  @override
  String get logOutConfirmBody =>
      'Are you sure you want to log out of your account?';

  @override
  String get cancel => 'Cancel';

  @override
  String get logOutSub => 'Sign out of your account';

  @override
  String get profileUserDetails => 'User details';

  @override
  String get profileUserDetailsSub => 'Update your name and profile info';

  @override
  String get profileVerification => 'Account verification';

  @override
  String get profileVerificationSub => 'Verify your identity with a passport';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLanguageSub => 'Choose your preferred language';

  @override
  String get profileMode => 'Mode';

  @override
  String get profileModeSub => 'Switch between Sender and Carrier';

  @override
  String get profileAbout => 'About';

  @override
  String get profileAboutSub => 'Learn more about Airpick';

  @override
  String get profileCloseAccount => 'Close account';

  @override
  String get profileCloseAccountSub => 'Permanently delete your account';

  @override
  String get guest => 'Guest';

  @override
  String get verified => 'Verified';

  @override
  String get unverified => 'Unverified';

  @override
  String get modeChooseTitle => 'Choose your mode';

  @override
  String get modeChooseSubtitle =>
      'Select how you want to use Airpick. Your profile and home screen update instantly.';

  @override
  String aboutVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get aboutSectionTitle => 'About Airpick';

  @override
  String get aboutBody =>
      'Airpick connects travelers and senders for secure, peer-to-peer package delivery between airports. Whether you are traveling and can carry items, or need something delivered, Airpick helps you find trusted matches.';

  @override
  String get aboutKeyFeatures => 'Key features';

  @override
  String get aboutFeature1 => 'Verified accounts for trusted delivery';

  @override
  String get aboutFeature2 => 'Airport-based matching for travelers';

  @override
  String get aboutFeature3 => 'Send and receive items with ease';

  @override
  String get aboutFeature4 => 'In-app messaging (coming soon)';

  @override
  String get closeVerifyRequiredSnack =>
      'You must verify your account before closing it.';

  @override
  String get closeTypeDeleteSnack => 'Type DELETE to confirm.';

  @override
  String get closeUserIdNotFound => 'User ID not found.';

  @override
  String get closeNotConfirmed => 'Account closure was not confirmed.';

  @override
  String get closeSuccessDefault => 'Account closed successfully.';

  @override
  String get closePermanentTitle => 'This action is permanent';

  @override
  String get closePermanentBody =>
      'Closing your account will permanently delete your profile, offers, and requests. This cannot be undone.';

  @override
  String get closeVerifyRequiredBanner =>
      'Account verification is required before you can close your account.';

  @override
  String get closeConfirmTitle => 'Confirm deletion';

  @override
  String get closeConfirmBody =>
      'Type DELETE below to confirm you want to permanently close your account.';

  @override
  String get closeButton => 'Close my account';

  @override
  String get languageSelectTitle => 'Select language';

  @override
  String get languageSelectSubtitle =>
      'Choose your preferred language for the app.';

  @override
  String get navHome => 'Home';

  @override
  String get navChat => 'Chat';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeGreeting => 'Good to have you back 👋';

  @override
  String get homeQuestion => 'What\'s happening today?';

  @override
  String get sectionInDelivery => 'In delivery';

  @override
  String get sectionEngagements => 'Engagements';

  @override
  String get sectionAvailableCarriers => 'Available carriers';

  @override
  String get sectionOfferRequests => 'Offer requests';

  @override
  String get seeAll => 'See all';

  @override
  String get centerRequests => 'Requests';

  @override
  String get centerOffers => 'Offers';

  @override
  String activeEngagements(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active engagements',
      one: '1 active engagement',
    );
    return '$_temp0';
  }

  @override
  String get latestLabel => 'Latest';

  @override
  String get modeSender => 'Sender';

  @override
  String get modeCarrier => 'Carrier';

  @override
  String get modeSenderPill => 'Sender mode';

  @override
  String get modeCarrierPill => 'Carrier mode';

  @override
  String get modeSenderDesc => 'I need items delivered';

  @override
  String get modeCarrierDesc => 'I\'m traveling & can carry items';

  @override
  String get modePickerTitle => 'Switch mode';

  @override
  String get modePickerQuestion => 'How are you using Airpick today?';

  @override
  String get active => 'Active';

  @override
  String get verifyRequiredTitle => 'Verification required';

  @override
  String verifyRequiredBody(Object action) {
    return 'You need to verify your identity before you can $action. Verification takes just a few minutes.';
  }

  @override
  String get verifyMyIdentity => 'Verify my identity';

  @override
  String get verifyActionDefault => 'create offers, requests, or proposals';

  @override
  String get verifyActionCreateOffer => 'create an offer';

  @override
  String get udErrorRefresh =>
      'Could not refresh from server. Showing saved info — you can still edit and save.';

  @override
  String get udCouldNotLoad => 'Could not load profile';

  @override
  String get userIdNotFound => 'User ID not found.';

  @override
  String get udUpdatedTitle => 'Profile Updated!';

  @override
  String get udUpdatedSub => 'Your details have been saved.';

  @override
  String get sectionPersonal => 'Personal';

  @override
  String get sectionLocation => 'Location';

  @override
  String get firstName => 'First name';

  @override
  String get middleName => 'Middle name';

  @override
  String get lastName => 'Last name';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get city => 'City';

  @override
  String get stateRegion => 'State / Region';

  @override
  String get country => 'Country';

  @override
  String get bio => 'Bio';

  @override
  String get bioHint => 'Tell others a little about yourself';

  @override
  String get firstNameRequired => 'First name is required.';

  @override
  String get lastNameRequired => 'Last name is required.';

  @override
  String get cityRequired => 'City is required.';

  @override
  String get countryRequired => 'Country is required.';

  @override
  String get dobRequired => 'Date of birth is required.';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get avSubmittedTitle => 'Verification submitted!';

  @override
  String get avSubmittedSub =>
      'We\'re reviewing your ID. Pull down to refresh for the latest status.';

  @override
  String get avVerifiedTitle => 'You\'re verified!';

  @override
  String get avVerifiedSub =>
      'Your identity is confirmed. You\'re all set on Airpick.';

  @override
  String get avCouldNotLoad => 'Could not load verification';

  @override
  String get avLoadFailed => 'Failed to load verification status.';

  @override
  String get avPreparing => 'Preparing secure session…';

  @override
  String get avChecking => 'Checking verification status…';

  @override
  String get avPoweredBy => 'Powered by Veriff · Secure identity verification';

  @override
  String get avStatusVerifiedTitle => 'You\'re verified';

  @override
  String get avStatusVerifiedBody =>
      'Your identity has been confirmed. Thanks for helping keep Airpick safe.';

  @override
  String get avStatusReviewTitle => 'Review in progress';

  @override
  String get avStatusReviewBody =>
      'Veriff is processing your submission. This usually takes a few minutes.';

  @override
  String get avStatusResubmitTitle => 'Resubmission needed';

  @override
  String get avStatusDeclinedTitle => 'Verification declined';

  @override
  String get avStatusRejectedBody =>
      'Please try again with a valid, well-lit ID and a clear selfie.';

  @override
  String get avStatusDefaultTitle => 'Verify your identity';

  @override
  String get avStatusDefaultBody =>
      'A quick ID scan and selfie powered by Veriff keeps our community trusted.';

  @override
  String get avStepPrepare => 'Prepare';

  @override
  String get avStepIdScan => 'ID scan';

  @override
  String get avStepSelfie => 'Selfie';

  @override
  String get avStepReview => 'Review';

  @override
  String get avBeforeStart => 'Before you start';

  @override
  String get avTipLighting => 'Use good lighting — avoid glare on your ID';

  @override
  String get avTipId => 'Have a passport or government ID ready';

  @override
  String get avTipSelfie => 'You\'ll take a quick selfie for liveness check';

  @override
  String get avTipTime => 'Takes about 2 minutes';

  @override
  String get avChipEncrypted => 'Encrypted';

  @override
  String get avChip230 => '230+ countries';

  @override
  String get avWhatWentWrong => 'What went wrong';

  @override
  String get avStartVerification => 'Start verification';

  @override
  String get avTryAgainVeriff => 'Try again with Veriff';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifNew => 'New';

  @override
  String get notifEarlier => 'Earlier';

  @override
  String get notifCaughtUp => 'You\'re all caught up';

  @override
  String notifUnread(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new updates',
      one: '1 new update',
    );
    return '$_temp0';
  }

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get notifEmptyTitle => 'No notifications';

  @override
  String get notifEmptyBody =>
      'Updates about matches and deliveries land here.';

  @override
  String get viewAll => 'View all';

  @override
  String get engEmptyActive => 'No active engagements.';

  @override
  String get tabSent => 'Sent';

  @override
  String get tabReceived => 'Received';

  @override
  String get tabMatched => 'Matched';

  @override
  String get emptyProposalsSent => 'No proposals sent yet.';

  @override
  String get emptyProposalsReceived => 'No proposals received yet.';

  @override
  String get emptyMatches => 'No matches yet.';

  @override
  String get offersTitle => 'Offer';

  @override
  String get offersLoadError => 'Could not load offers';

  @override
  String get offersEmptyTitle => 'No offers yet';

  @override
  String get offersEmptyBody => 'Tap + to post an offer with your flight.';

  @override
  String get offersEmptyStatusTitle => 'No offers with this status';

  @override
  String get offersEmptyStatusBody =>
      'Choose another status filter to see your other offers.';

  @override
  String get offerDeleted => 'Offer deleted';

  @override
  String get offerDeleteConfirmTitle => 'Delete this offer?';

  @override
  String get offerDeleteConfirmBody => 'This removes your offer permanently.';

  @override
  String get delete => 'Delete';

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get statusAll => 'All';

  @override
  String get statusOpen => 'Open';

  @override
  String get statusMatched => 'Matched';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get offerCurrency => 'Currency';

  @override
  String get offerDiscountLabel => 'Discount';

  @override
  String get offerPayment => 'Payment';

  @override
  String get offerMeetup => 'Meetup';

  @override
  String get offerNote => 'Note';

  @override
  String get offerTotalValue => 'Total value';

  @override
  String get offerMatchThis => 'Match this offer';

  @override
  String get offerNoFlight => 'No flight attached';

  @override
  String offerCreatedAgo(Object ago) {
    return 'Created $ago';
  }

  @override
  String get carriersLoadError => 'Could not load carriers';

  @override
  String get carriersEmptyTitle => 'No carriers available';

  @override
  String get carriersEmptyBody =>
      'Available carriers will show here when they post trips.';

  @override
  String get editOfferTitle => 'Edit Offer';

  @override
  String get offerDiscountOptional => 'Discount (optional)';

  @override
  String get offerNoteOptional => 'Note (optional)';

  @override
  String get offerUpdated => 'Offer updated';

  @override
  String get offerFlightNotEditable => 'Flight not editable';

  @override
  String get offerNoteHint => 'e.g. Fragile items handled with care';

  @override
  String get offerDeliveryHint => 'e.g. Lagos, Nigeria';

  @override
  String get offerPickupHint => 'e.g. Los Angeles, CA';

  @override
  String get requestsTitle => 'Request';

  @override
  String get requestsLoadError => 'Could not load requests';

  @override
  String get requestsEmptyTitle => 'No requests yet';

  @override
  String get requestsEmptyBody =>
      'Tap + to create a request for items you need delivered.';

  @override
  String get requestsEmptyStatusTitle => 'No requests with this status';

  @override
  String get requestsEmptyStatusBody =>
      'Choose another status filter to see your other requests.';

  @override
  String get requestDeleted => 'Request deleted';

  @override
  String get requestDeleteConfirmTitle => 'Delete this request?';

  @override
  String get requestDeleteConfirmBody =>
      'This permanently removes your offer request. This action cannot be undone.';

  @override
  String proposalsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count proposals',
      one: '1 proposal',
    );
    return '$_temp0';
  }

  @override
  String get statusPending => 'Pending';

  @override
  String get statusProposals => 'Proposals';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusClosed => 'Closed';

  @override
  String get statusPendingApproval => 'Pending approval';

  @override
  String get statusNotAccepted => 'Not accepted';

  @override
  String get reqPartial => 'Partial ✓';

  @override
  String get urgencyUrgent => 'Urgent';

  @override
  String get urgencyFlexible => 'Flexible';

  @override
  String get browseRequestsTitle => 'Browse Requests';

  @override
  String get filterRequests => 'Filter requests';

  @override
  String get sourceCountry => 'Source country';

  @override
  String get sourceCity => 'Source city';

  @override
  String get destinationCountry => 'Destination country';

  @override
  String get anyCountry => 'Any country';

  @override
  String get anyOption => 'Any';

  @override
  String get apply => 'Apply';

  @override
  String get clear => 'Clear';

  @override
  String get noMatchingRequests => 'No matching requests';

  @override
  String get tryClearingFilters =>
      'Try clearing the filters or searching another route.';

  @override
  String get requestsBrowseEmptyTitle => 'No requests available';

  @override
  String get requestsBrowseEmptyBody =>
      'Open shipper requests will show here when senders post them.';

  @override
  String get requestDetailTitle => 'Request Details';

  @override
  String get reqPartialProposals => 'Partial proposals';

  @override
  String get preferredDate => 'Preferred date';

  @override
  String get reqNoItems => 'No items';

  @override
  String get reqHasProposalsLocked =>
      'This request has proposals and can no longer be edited or deleted.';

  @override
  String reqStatusLocked(Object status) {
    return 'This request is $status and can no longer be edited or deleted.';
  }

  @override
  String get createProposalSent => 'Proposal sent';

  @override
  String get sendProposal => 'Send Proposal';

  @override
  String get yourFlight => 'Your flight';

  @override
  String airportInCountry(Object country) {
    return 'Airport in $country';
  }

  @override
  String get pickupDelivery => 'Pickup & delivery';

  @override
  String get priceTheItems => 'Price the items';

  @override
  String get partialAllowed => 'Partial allowed';

  @override
  String get proposalCurrency => 'Proposal currency';

  @override
  String get submit => 'Submit';

  @override
  String get priceLabel => 'Price';

  @override
  String get totalLabel => 'Total';

  @override
  String get pickupAreaHelp =>
      'The general area where you\'ll collect the items before your flight (e.g. a city or neighbourhood).';

  @override
  String get meetupHelp =>
      'Specific spots where you can meet the sender in person to hand over or drop off the items (e.g. a mall, cafe or landmark).';

  @override
  String get proposalNoteHint => 'e.g. I can deliver within 2 days of arrival';

  @override
  String get chatsTitle => 'Messages';

  @override
  String get chatsEmptyTitle => 'No conversations yet';

  @override
  String get chatsEmptyBody => 'Matched deliveries will appear here.';

  @override
  String get chatNoMessagesYet => 'No messages yet';

  @override
  String get chatStartConvo => 'Start the conversation when you are ready.';

  @override
  String get chatLoadError => 'Could not load chat';

  @override
  String get chatMatchDetails => 'Match details';

  @override
  String get chatMessageHint => 'Message…';

  @override
  String chatItemsCount(Object count) {
    return 'Items ($count)';
  }

  @override
  String get chatRoute => 'Route';

  @override
  String get chatConfirmPickup => 'Confirm pickup';

  @override
  String get chatReadyForPickup => 'Ready for pickup';

  @override
  String get chatPickUp => 'Pick up';

  @override
  String get chatStartDelivery => 'Start delivery';

  @override
  String get chatTakePhoto => 'Take a photo of the items to start delivery.';

  @override
  String get chatTapAddPhoto => 'Tap to add photo';

  @override
  String get chatPhotographItems =>
      'Photograph the items you received from the sender. This starts tracked delivery.';

  @override
  String get chatDeliveryInProgress =>
      'Delivery in progress — head to the destination.';

  @override
  String get chatItemLoadError => 'Item details could not be loaded.';

  @override
  String get chatToday => 'Today';

  @override
  String get deliveriesLoadError => 'Could not load deliveries';

  @override
  String get deliveriesEmptyTitle => 'No active deliveries';

  @override
  String get deliveriesEmptyBody =>
      'Deliveries appear here after pickup and while en route.';

  @override
  String get searchChooseFilter => 'Choose search filter';

  @override
  String get searchFilterCarriersBy => 'Filter carriers by';

  @override
  String get searchFilterRequestsBy => 'Filter shipper requests by';

  @override
  String get searchOriginCountry => 'Origin country';

  @override
  String get searchOriginCity => 'Origin city';

  @override
  String get searchDestination => 'Destination';

  @override
  String get searchAnywhere => 'Anywhere';

  @override
  String get searchQuickSearches => 'Quick searches';

  @override
  String searchNoResults(Object query) {
    return 'No shipper requests matched \"$query\".';
  }

  @override
  String searchResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get matchOfferTitle => 'Match Offer';

  @override
  String get matchCreatedTitle => 'Match Created!';

  @override
  String get matchCreatedBody =>
      'Opening your chat with the carrier so you can arrange pickup and delivery.';

  @override
  String get matchWhatNeed => 'What do you need?';

  @override
  String get matchSelectItems => 'Select items and quantities to match.';

  @override
  String get matchWhoReceives => 'Who receives?';

  @override
  String get matchItemsToMe => 'Items come to me';

  @override
  String get matchSomeoneElse => 'Someone else';

  @override
  String get matchThirdParty => 'Third-party receiver';

  @override
  String get matchReceiverDetails => 'Receiver details';

  @override
  String get matchPhoneHint => 'Phone (e.g. +12025551234)';

  @override
  String get matchPhotoId => 'Photo ID';

  @override
  String get matchUploadId => 'Upload government-issued ID';

  @override
  String get matchChange => 'Change';

  @override
  String get cameraOption => 'Camera';

  @override
  String get photoLibraryOption => 'Photo library';

  @override
  String get matchSendMatch => 'Send Match';

  @override
  String get matchSending => 'Sending match…';

  @override
  String get matchUploadingId => 'Uploading ID…';

  @override
  String get matchEstimatedTotal => 'Estimated total';

  @override
  String get matchPickup => 'Pickup';

  @override
  String get matchDelivery => 'Delivery';
}
