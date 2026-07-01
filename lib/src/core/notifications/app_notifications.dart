import 'notification_service.dart';

/// Typed helpers for the on-device (local) notifications the app fires itself
/// for events it can observe locally: welcome, a proposal being sent, an offer
/// being posted, and the user getting verified.
///
/// These are true cross-user pushes only once a backend sends FCM messages;
/// until then they cover the client-observable events so users get immediate
/// feedback. Stable IDs per category keep repeat notifications from stacking.
class AppNotifications {
  AppNotifications._();

  static const _idWelcome = 1001;
  static const _idProposalSent = 1002;
  static const _idOfferPosted = 1003;
  static const _idVerified = 1004;

  static Future<void> welcome() => NotificationService.show(
        id: _idWelcome,
        title: 'Welcome to Airpick ✈️',
        body: 'Complete verification and set your mode to get started.',
      );

  static Future<void> proposalSent() => NotificationService.show(
        id: _idProposalSent,
        title: 'Proposal sent',
        body: 'Your proposal is on its way. We\'ll let you know when it\'s '
            'reviewed.',
      );

  static Future<void> offerPosted() => NotificationService.show(
        id: _idOfferPosted,
        title: 'Offer posted',
        body: 'Your offer is now live. Senders nearby can start reaching out.',
      );

  static Future<void> verified() => NotificationService.show(
        id: _idVerified,
        title: 'You\'re verified ✅',
        body: 'Your identity is confirmed. You can carry & send freely.',
      );
}
