// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'GuzoMy';

  @override
  String get skip => 'Passer';

  @override
  String get next => 'Suivant';

  @override
  String get getStarted => 'Commencer';

  @override
  String get onboardingTitle1 => 'Une communauté de confiance';

  @override
  String get onboardingSubtitle1 =>
      'Rejoignez en toute confiance un réseau vérifié de voyageurs et d’expéditeurs.';

  @override
  String get onboardingTitle2 => 'Livraison rapide et fiable';

  @override
  String get onboardingSubtitle2 =>
      'Connectez-vous avec des voyageurs qui vont dans votre direction et recevez vos articles à temps.';

  @override
  String get onboardingTitle3 => 'Simple et sécurisé';

  @override
  String get onboardingSubtitle3 =>
      'Suivez la progression et finalisez la livraison en toute sérénité.';

  @override
  String get authTitle => 'Se connecter ou\ncréer un compte';

  @override
  String get authSubtitle => 'Continuez avec un compte social pour commencer.';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get peerToPeerDelivery => 'Livraison entre particuliers';

  @override
  String get termsPrefix => 'En continuant, vous acceptez nos ';

  @override
  String get termsOfService => 'Conditions d’utilisation';

  @override
  String get and => ' et ';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String signInCancelledTitle(String provider) {
    return 'Connexion $provider annulée';
  }

  @override
  String get signInCancelledBody =>
      'Vous avez fermé la fenêtre de connexion avant la fin. Aucune modification n’a été effectuée.';

  @override
  String tryAgain(String provider) {
    return 'Réessayer avec $provider';
  }

  @override
  String get maybeLater => 'Plus tard';

  @override
  String get createOffer => 'Créer une offre';

  @override
  String get createAsCarrier => 'Créer en tant que transporteur';

  @override
  String get createAsSender => 'Créer en tant qu’expéditeur';

  @override
  String get stepFlightDetails => 'Détails du vol';

  @override
  String get stepOfferDetails => 'Détails de l’offre';

  @override
  String get step1of2 => 'Étape 1 sur 2';

  @override
  String get step2of2 => 'Étape 2 sur 2';

  @override
  String get flightType => 'Type de vol';

  @override
  String get oneWay => 'Aller simple';

  @override
  String get roundTrip => 'Aller-retour';

  @override
  String get fromAirport => 'De';

  @override
  String get toAirport => 'À';

  @override
  String get searchAirport => 'Rechercher un aéroport ou une ville…';

  @override
  String get departureDate => 'Date de départ';

  @override
  String get departureTime => 'Heure de départ';

  @override
  String get arrivalDate => 'Date d’arrivée';

  @override
  String get arrivalTime => 'Heure d’arrivée';

  @override
  String get returnLeg => 'Vol retour';

  @override
  String get continueToOffer => 'Continuer';

  @override
  String get pickupArea => 'Zone de retrait';

  @override
  String get deliveryArea => 'Zone de livraison';

  @override
  String get urgencyLevel => 'Urgence';

  @override
  String get urgencyNormal => 'Normale';

  @override
  String get urgencyExpress => 'Express';

  @override
  String get discount => 'Remise (%)';

  @override
  String get specialNote => 'Note spéciale';

  @override
  String get meetupPlaces => 'Lieux de rencontre';

  @override
  String get addMeetupPlace => 'Ajouter un lieu de rencontre';

  @override
  String get paymentMethods => 'Moyens de paiement';

  @override
  String get offerItems => 'Articles';

  @override
  String get addItem => 'Ajouter un article';

  @override
  String get pricePerItem => 'Prix par article';

  @override
  String get quantity => 'Quantité';

  @override
  String get createOfferButton => 'Créer l’offre';

  @override
  String get selectDate => 'Choisir une date';

  @override
  String get selectTime => 'Choisir une heure';

  @override
  String get optional => 'Facultatif';

  @override
  String get remove => 'Supprimer';

  @override
  String get retry => 'Réessayer';

  @override
  String get errorLoadingAirports => 'Échec du chargement des aéroports';

  @override
  String get errorCreatingFlight => 'Échec de la création du vol';

  @override
  String get errorCreatingOffer => 'Échec de la création de l’offre';

  @override
  String get offerCreatedSuccess => 'Offre créée avec succès !';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get logOutConfirmBody =>
      'Voulez-vous vraiment vous déconnecter de votre compte ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get logOutSub => 'Déconnectez-vous de votre compte';

  @override
  String get profileUserDetails => 'Détails de l’utilisateur';

  @override
  String get profileUserDetailsSub =>
      'Mettez à jour votre nom et vos informations de profil';

  @override
  String get profileVerification => 'Vérification du compte';

  @override
  String get profileVerificationSub =>
      'Vérifiez votre identité avec un passeport';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileLanguageSub => 'Choisissez votre langue préférée';

  @override
  String get profileMode => 'Mode';

  @override
  String get profileModeSub => 'Basculez entre expéditeur et transporteur';

  @override
  String get profileAbout => 'À propos';

  @override
  String get profileAboutSub => 'En savoir plus sur GuzoMy';

  @override
  String get profileCloseAccount => 'Fermer le compte';

  @override
  String get profileCloseAccountSub => 'Supprimez définitivement votre compte';

  @override
  String get guest => 'Invité';

  @override
  String get verified => 'Vérifié';

  @override
  String get unverified => 'Non vérifié';

  @override
  String get modeChooseTitle => 'Choisissez votre mode';

  @override
  String get modeChooseSubtitle =>
      'Choisissez comment utiliser GuzoMy. Votre profil et votre écran d’accueil se mettent à jour instantanément.';

  @override
  String aboutVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get aboutSectionTitle => 'À propos d’GuzoMy';

  @override
  String get aboutBody =>
      'GuzoMy met en relation les voyageurs et les expéditeurs pour une livraison de colis sécurisée entre particuliers, d’un aéroport à l’autre. Que vous voyagiez et puissiez transporter des articles, ou que vous ayez besoin d’une livraison, GuzoMy vous aide à trouver des partenaires de confiance.';

  @override
  String get aboutKeyFeatures => 'Fonctionnalités clés';

  @override
  String get aboutFeature1 =>
      'Comptes vérifiés pour une livraison de confiance';

  @override
  String get aboutFeature2 =>
      'Mise en relation par aéroport pour les voyageurs';

  @override
  String get aboutFeature3 =>
      'Envoyez et recevez des articles en toute simplicité';

  @override
  String get aboutFeature4 => 'Messagerie intégrée (bientôt disponible)';

  @override
  String get closeVerifyRequiredSnack =>
      'Vous devez vérifier votre compte avant de le fermer.';

  @override
  String get closeTypeDeleteSnack => 'Tapez DELETE pour confirmer.';

  @override
  String get closeUserIdNotFound => 'Identifiant utilisateur introuvable.';

  @override
  String get closeNotConfirmed =>
      'La fermeture du compte n’a pas été confirmée.';

  @override
  String get closeSuccessDefault => 'Compte fermé avec succès.';

  @override
  String get closePermanentTitle => 'Cette action est définitive';

  @override
  String get closePermanentBody =>
      'La fermeture de votre compte supprimera définitivement votre profil, vos offres et vos demandes. Cette action est irréversible.';

  @override
  String get closeVerifyRequiredBanner =>
      'La vérification du compte est requise avant de pouvoir fermer votre compte.';

  @override
  String get closeConfirmTitle => 'Confirmer la suppression';

  @override
  String get closeConfirmBody =>
      'Tapez DELETE ci-dessous pour confirmer la fermeture définitive de votre compte.';

  @override
  String get closeButton => 'Fermer mon compte';

  @override
  String get languageSelectTitle => 'Choisir la langue';

  @override
  String get languageSelectSubtitle =>
      'Choisissez votre langue préférée pour l’application.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navChat => 'Discussion';

  @override
  String get navAlerts => 'Alertes';

  @override
  String get navProfile => 'Profil';

  @override
  String get homeGreeting => 'Content de vous revoir 👋';

  @override
  String get homeQuestion => 'Quoi de neuf aujourd’hui ?';

  @override
  String get sectionInDelivery => 'En cours de livraison';

  @override
  String get sectionEngagements => 'Engagements';

  @override
  String get sectionAvailableCarriers => 'Transporteurs disponibles';

  @override
  String get sectionOfferRequests => 'Demandes d’offres';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get centerRequests => 'Demandes';

  @override
  String get centerOffers => 'Offres';

  @override
  String activeEngagements(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count engagements actifs',
      one: '1 engagement actif',
    );
    return '$_temp0';
  }

  @override
  String get latestLabel => 'Dernier';

  @override
  String get modeSender => 'Expéditeur';

  @override
  String get modeCarrier => 'Transporteur';

  @override
  String get modeSenderPill => 'Mode expéditeur';

  @override
  String get modeCarrierPill => 'Mode transporteur';

  @override
  String get modeSenderDesc => 'J’ai besoin de faire livrer des articles';

  @override
  String get modeCarrierDesc => 'Je voyage et peux transporter des articles';

  @override
  String get modePickerTitle => 'Changer de mode';

  @override
  String get modePickerQuestion => 'Comment utilisez-vous GuzoMy aujourd’hui ?';

  @override
  String get active => 'Actif';

  @override
  String get verifyRequiredTitle => 'Vérification requise';

  @override
  String verifyRequiredBody(Object action) {
    return 'Vous devez vérifier votre identité avant de pouvoir $action. La vérification ne prend que quelques minutes.';
  }

  @override
  String get verifyMyIdentity => 'Vérifier mon identité';

  @override
  String get verifyActionDefault =>
      'créer des offres, des demandes ou des propositions';

  @override
  String get verifyActionCreateOffer => 'créer une offre';

  @override
  String get udErrorRefresh =>
      'Impossible d’actualiser depuis le serveur. Affichage des informations enregistrées — vous pouvez toujours modifier et enregistrer.';

  @override
  String get udCouldNotLoad => 'Impossible de charger le profil';

  @override
  String get userIdNotFound => 'Identifiant utilisateur introuvable.';

  @override
  String get udUpdatedTitle => 'Profil mis à jour !';

  @override
  String get udUpdatedSub => 'Vos informations ont été enregistrées.';

  @override
  String get sectionPersonal => 'Personnel';

  @override
  String get sectionLocation => 'Localisation';

  @override
  String get firstName => 'Prénom';

  @override
  String get middleName => 'Deuxième prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get dateOfBirth => 'Date de naissance';

  @override
  String get city => 'Ville';

  @override
  String get stateRegion => 'État / Région';

  @override
  String get country => 'Pays';

  @override
  String get bio => 'Bio';

  @override
  String get bioHint => 'Parlez un peu de vous aux autres';

  @override
  String get firstNameRequired => 'Le prénom est requis.';

  @override
  String get lastNameRequired => 'Le nom est requis.';

  @override
  String get cityRequired => 'La ville est requise.';

  @override
  String get countryRequired => 'Le pays est requis.';

  @override
  String get dobRequired => 'La date de naissance est requise.';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get avSubmittedTitle => 'Vérification soumise !';

  @override
  String get avSubmittedSub =>
      'Nous examinons votre pièce d’identité. Tirez vers le bas pour actualiser le statut.';

  @override
  String get avVerifiedTitle => 'Vous êtes vérifié !';

  @override
  String get avVerifiedSub =>
      'Votre identité est confirmée. Vous êtes prêt sur GuzoMy.';

  @override
  String get avCouldNotLoad => 'Impossible de charger la vérification';

  @override
  String get avLoadFailed => 'Échec du chargement du statut de vérification.';

  @override
  String get avPreparing => 'Préparation d’une session sécurisée…';

  @override
  String get avChecking => 'Vérification du statut…';

  @override
  String get avPoweredBy =>
      'Propulsé par Veriff · Vérification d’identité sécurisée';

  @override
  String get avStatusVerifiedTitle => 'Vous êtes vérifié';

  @override
  String get avStatusVerifiedBody =>
      'Votre identité a été confirmée. Merci de contribuer à la sécurité d’GuzoMy.';

  @override
  String get avStatusReviewTitle => 'Examen en cours';

  @override
  String get avStatusReviewBody =>
      'Veriff traite votre soumission. Cela prend généralement quelques minutes.';

  @override
  String get avStatusResubmitTitle => 'Nouvelle soumission requise';

  @override
  String get avStatusDeclinedTitle => 'Vérification refusée';

  @override
  String get avStatusRejectedBody =>
      'Veuillez réessayer avec une pièce d’identité valide, bien éclairée et un selfie net.';

  @override
  String get avStatusDefaultTitle => 'Vérifiez votre identité';

  @override
  String get avStatusDefaultBody =>
      'Un scan rapide de votre pièce d’identité et un selfie propulsés par Veriff garantissent la confiance de notre communauté.';

  @override
  String get avStepPrepare => 'Préparer';

  @override
  String get avStepIdScan => 'Scan ID';

  @override
  String get avStepSelfie => 'Selfie';

  @override
  String get avStepReview => 'Examen';

  @override
  String get avBeforeStart => 'Avant de commencer';

  @override
  String get avTipLighting =>
      'Utilisez un bon éclairage — évitez les reflets sur votre pièce d’identité';

  @override
  String get avTipId =>
      'Ayez un passeport ou une pièce d’identité officielle à portée de main';

  @override
  String get avTipSelfie =>
      'Vous prendrez un selfie rapide pour la vérification de vivacité';

  @override
  String get avTipTime => 'Prend environ 2 minutes';

  @override
  String get avChipEncrypted => 'Chiffré';

  @override
  String get avChip230 => '230+ pays';

  @override
  String get avWhatWentWrong => 'Ce qui n’a pas fonctionné';

  @override
  String get avStartVerification => 'Commencer la vérification';

  @override
  String get avTryAgainVeriff => 'Réessayer avec Veriff';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifNew => 'Nouveau';

  @override
  String get notifEarlier => 'Plus tôt';

  @override
  String get notifCaughtUp => 'Vous êtes à jour';

  @override
  String notifUnread(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouvelles mises à jour',
      one: '1 nouvelle mise à jour',
    );
    return '$_temp0';
  }

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get notifEmptyTitle => 'Aucune notification';

  @override
  String get notifEmptyBody =>
      'Les mises à jour sur les correspondances et les livraisons apparaissent ici.';

  @override
  String get viewAll => 'Tout voir';

  @override
  String get engEmptyActive => 'Aucun engagement actif.';

  @override
  String get tabSent => 'Envoyées';

  @override
  String get tabReceived => 'Reçues';

  @override
  String get tabMatched => 'Associées';

  @override
  String get emptyProposalsSent => 'Aucune proposition envoyée pour le moment.';

  @override
  String get emptyProposalsReceived =>
      'Aucune proposition reçue pour le moment.';

  @override
  String get emptyMatches => 'Aucune correspondance pour le moment.';

  @override
  String get offersTitle => 'Offre';

  @override
  String get offersLoadError => 'Impossible de charger les offres';

  @override
  String get offersEmptyTitle => 'Aucune offre pour le moment';

  @override
  String get offersEmptyBody =>
      'Appuyez sur + pour publier une offre avec votre vol.';

  @override
  String get offersEmptyStatusTitle => 'Aucune offre avec ce statut';

  @override
  String get offersEmptyStatusBody =>
      'Choisissez un autre filtre de statut pour voir vos autres offres.';

  @override
  String get offerDeleted => 'Offre supprimée';

  @override
  String get offerDeleteConfirmTitle => 'Supprimer cette offre ?';

  @override
  String get offerDeleteConfirmBody =>
      'Cela supprime votre offre définitivement.';

  @override
  String get delete => 'Supprimer';

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String get statusAll => 'Tout';

  @override
  String get statusOpen => 'Ouvert';

  @override
  String get statusMatched => 'Associé';

  @override
  String get statusCompleted => 'Terminé';

  @override
  String get statusExpired => 'Expiré';

  @override
  String get statusCancelled => 'Annulé';

  @override
  String get offerCurrency => 'Devise';

  @override
  String get offerDiscountLabel => 'Remise';

  @override
  String get offerPayment => 'Paiement';

  @override
  String get offerMeetup => 'Rencontre';

  @override
  String get offerNote => 'Note';

  @override
  String get offerTotalValue => 'Valeur totale';

  @override
  String get offerMatchThis => 'Associer cette offre';

  @override
  String get offerNoFlight => 'Aucun vol attaché';

  @override
  String offerCreatedAgo(Object ago) {
    return 'Créé $ago';
  }

  @override
  String get carriersLoadError => 'Impossible de charger les transporteurs';

  @override
  String get carriersEmptyTitle => 'Aucun transporteur disponible';

  @override
  String get carriersEmptyBody =>
      'Les transporteurs disponibles apparaîtront ici lorsqu’ils publieront des trajets.';

  @override
  String get editOfferTitle => 'Modifier l’offre';

  @override
  String get offerDiscountOptional => 'Remise (facultatif)';

  @override
  String get offerNoteOptional => 'Note (facultatif)';

  @override
  String get offerUpdated => 'Offre mise à jour';

  @override
  String get offerFlightNotEditable => 'Vol non modifiable';

  @override
  String get offerNoteHint => 'ex. Objets fragiles manipulés avec soin';

  @override
  String get offerDeliveryHint => 'ex. Lagos, Nigéria';

  @override
  String get offerPickupHint => 'ex. Los Angeles, CA';

  @override
  String get requestsTitle => 'Demande';

  @override
  String get requestsLoadError => 'Impossible de charger les demandes';

  @override
  String get requestsEmptyTitle => 'Aucune demande pour le moment';

  @override
  String get requestsEmptyBody =>
      'Appuyez sur + pour créer une demande pour les articles à livrer.';

  @override
  String get requestsEmptyStatusTitle => 'Aucune demande avec ce statut';

  @override
  String get requestsEmptyStatusBody =>
      'Choisissez un autre filtre de statut pour voir vos autres demandes.';

  @override
  String get requestDeleted => 'Demande supprimée';

  @override
  String get requestDeleteConfirmTitle => 'Supprimer cette demande ?';

  @override
  String get requestDeleteConfirmBody =>
      'Cela supprime définitivement votre demande d’offre. Cette action est irréversible.';

  @override
  String proposalsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count propositions',
      one: '1 proposition',
    );
    return '$_temp0';
  }

  @override
  String get statusPending => 'En attente';

  @override
  String get statusProposals => 'Propositions';

  @override
  String get statusAccepted => 'Accepté';

  @override
  String get statusClosed => 'Fermé';

  @override
  String get statusPendingApproval => 'En attente d’approbation';

  @override
  String get statusNotAccepted => 'Non accepté';

  @override
  String get reqPartial => 'Partiel ✓';

  @override
  String get urgencyUrgent => 'Urgent';

  @override
  String get urgencyFlexible => 'Flexible';

  @override
  String get browseRequestsTitle => 'Parcourir les demandes';

  @override
  String get filterRequests => 'Filtrer les demandes';

  @override
  String get sourceCountry => 'Pays d’origine';

  @override
  String get sourceCity => 'Ville d’origine';

  @override
  String get destinationCountry => 'Pays de destination';

  @override
  String get anyCountry => 'N’importe quel pays';

  @override
  String get anyOption => 'Tous';

  @override
  String get apply => 'Appliquer';

  @override
  String get clear => 'Effacer';

  @override
  String get noMatchingRequests => 'Aucune demande correspondante';

  @override
  String get tryClearingFilters =>
      'Essayez d’effacer les filtres ou de rechercher un autre itinéraire.';

  @override
  String get requestsBrowseEmptyTitle => 'Aucune demande disponible';

  @override
  String get requestsBrowseEmptyBody =>
      'Les demandes ouvertes des expéditeurs apparaîtront ici lorsqu’elles seront publiées.';

  @override
  String get requestDetailTitle => 'Détails de la demande';

  @override
  String get reqPartialProposals => 'Propositions partielles';

  @override
  String get preferredDate => 'Date préférée';

  @override
  String get reqNoItems => 'Aucun article';

  @override
  String get reqHasProposalsLocked =>
      'Cette demande a des propositions et ne peut plus être modifiée ou supprimée.';

  @override
  String reqStatusLocked(Object status) {
    return 'Cette demande est $status et ne peut plus être modifiée ou supprimée.';
  }

  @override
  String get createProposalSent => 'Proposition envoyée';

  @override
  String get sendProposal => 'Envoyer la proposition';

  @override
  String get yourFlight => 'Votre vol';

  @override
  String airportInCountry(Object country) {
    return 'Aéroport en $country';
  }

  @override
  String get pickupDelivery => 'Retrait et livraison';

  @override
  String get priceTheItems => 'Fixez le prix des articles';

  @override
  String get partialAllowed => 'Partiel autorisé';

  @override
  String get proposalCurrency => 'Devise de la proposition';

  @override
  String get submit => 'Soumettre';

  @override
  String get priceLabel => 'Prix';

  @override
  String get totalLabel => 'Total';

  @override
  String get pickupAreaHelp =>
      'La zone générale où vous récupérerez les articles avant votre vol (par ex. une ville ou un quartier).';

  @override
  String get meetupHelp =>
      'Des endroits précis où rencontrer l’expéditeur en personne pour remettre les articles (par ex. un centre commercial, un café ou un point de repère).';

  @override
  String get proposalNoteHint =>
      'ex. Je peux livrer dans les 2 jours suivant l’arrivée';

  @override
  String get chatsTitle => 'Messages';

  @override
  String get chatsEmptyTitle => 'Aucune conversation pour le moment';

  @override
  String get chatsEmptyBody => 'Les livraisons associées apparaîtront ici.';

  @override
  String get chatNoMessagesYet => 'Aucun message pour le moment';

  @override
  String get chatStartConvo =>
      'Commencez la conversation quand vous êtes prêt.';

  @override
  String get chatLoadError => 'Impossible de charger la discussion';

  @override
  String get chatMatchDetails => 'Détails de l’association';

  @override
  String get chatMessageHint => 'Message…';

  @override
  String chatItemsCount(Object count) {
    return 'Articles ($count)';
  }

  @override
  String get chatRoute => 'Itinéraire';

  @override
  String get chatConfirmPickup => 'Confirmer le retrait';

  @override
  String get chatReadyForPickup => 'Prêt pour le retrait';

  @override
  String get chatPickUp => 'Récupérer';

  @override
  String get chatStartDelivery => 'Démarrer la livraison';

  @override
  String get chatTakePhoto =>
      'Prenez une photo des articles pour démarrer la livraison.';

  @override
  String get chatTapAddPhoto => 'Appuyez pour ajouter une photo';

  @override
  String get chatPhotographItems =>
      'Photographiez les articles reçus de l’expéditeur. Cela démarre la livraison suivie.';

  @override
  String get chatDeliveryInProgress =>
      'Livraison en cours — dirigez-vous vers la destination.';

  @override
  String get chatItemLoadError =>
      'Impossible de charger les détails de l’article.';

  @override
  String get chatToday => 'Aujourd’hui';

  @override
  String get deliveriesLoadError => 'Impossible de charger les livraisons';

  @override
  String get deliveriesEmptyTitle => 'Aucune livraison active';

  @override
  String get deliveriesEmptyBody =>
      'Les livraisons apparaissent ici après le retrait et pendant le trajet.';

  @override
  String get searchChooseFilter => 'Choisir un filtre de recherche';

  @override
  String get searchFilterCarriersBy => 'Filtrer les transporteurs par';

  @override
  String get searchFilterRequestsBy => 'Filtrer les demandes par';

  @override
  String get searchOriginCountry => 'Pays d’origine';

  @override
  String get searchOriginCity => 'Ville d’origine';

  @override
  String get searchDestination => 'Destination';

  @override
  String get searchAnywhere => 'Partout';

  @override
  String get searchQuickSearches => 'Recherches rapides';

  @override
  String searchNoResults(Object query) {
    return 'Aucune demande ne correspond à « $query ».';
  }

  @override
  String searchResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
    );
    return '$_temp0';
  }

  @override
  String get matchOfferTitle => 'Associer l’offre';

  @override
  String get matchCreatedTitle => 'Association créée !';

  @override
  String get matchCreatedBody =>
      'Ouverture de votre discussion avec le transporteur pour organiser le retrait et la livraison.';

  @override
  String get matchWhatNeed => 'De quoi avez-vous besoin ?';

  @override
  String get matchSelectItems =>
      'Sélectionnez les articles et les quantités à associer.';

  @override
  String get matchWhoReceives => 'Qui reçoit ?';

  @override
  String get matchItemsToMe => 'Les articles me sont destinés';

  @override
  String get matchSomeoneElse => 'Quelqu’un d’autre';

  @override
  String get matchThirdParty => 'Destinataire tiers';

  @override
  String get matchReceiverDetails => 'Détails du destinataire';

  @override
  String get matchPhoneHint => 'Téléphone (ex. +12025551234)';

  @override
  String get matchPhotoId => 'Pièce d’identité avec photo';

  @override
  String get matchUploadId => 'Téléversez une pièce d’identité officielle';

  @override
  String get matchChange => 'Modifier';

  @override
  String get cameraOption => 'Appareil photo';

  @override
  String get photoLibraryOption => 'Photothèque';

  @override
  String get matchSendMatch => 'Envoyer l’association';

  @override
  String get matchSending => 'Envoi de l’association…';

  @override
  String get matchUploadingId => 'Téléversement de la pièce d’identité…';

  @override
  String get matchEstimatedTotal => 'Total estimé';

  @override
  String get matchPickup => 'Retrait';

  @override
  String get matchDelivery => 'Livraison';
}
