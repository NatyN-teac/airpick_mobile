import 'match_models.dart';

/// Backend track buckets — maps to match lifecycle groups.
enum DeliveryTrackGroup { collected, inProgress, completed }

/// Ordered labels for the 5-stage delivery phase (progress bar segments). Shared
/// so the status chip and the progress bar can't drift. "Delivered" = the carrier
/// dropped off (awaiting sender confirmation); "Confirmed" = fully complete.
const deliveryStageLabels = <String>[
  'Awaiting pickup',
  'Picked up',
  'In transit',
  'Delivered',
  'Confirmed',
];

/// 0-based index into [deliveryStageLabels] for a match status (0..4).
/// CARRIER_DELIVERED sits at "Delivered"; COMPLETED at "Confirmed".
int deliveryStageForStatus(String status, bool hasPickupPhoto) =>
    switch (status.toUpperCase()) {
      'ACCEPTED' => hasPickupPhoto ? 1 : 0,
      'IN_PROGRESS' || 'IN_DELIVERY' => 2,
      'CARRIER_DELIVERED' => 3,
      'COMPLETED' => 4,
      _ => 0,
    };

/// 0-based index into [deliveryStageLabels] for the current phase. The ACCEPTED
/// (`collected`) bucket splits into "awaiting pickup" vs "picked up" by whether
/// the carrier has uploaded the pickup photo.
int deliveryStageIndex(DeliveryTrackGroup group, bool hasPickupPhoto) =>
    switch (group) {
      DeliveryTrackGroup.collected => hasPickupPhoto ? 1 : 0,
      DeliveryTrackGroup.inProgress => 2,
      DeliveryTrackGroup.completed => 4,
    };

extension DeliveryTrackGroupX on DeliveryTrackGroup {
  String get label => switch (this) {
        DeliveryTrackGroup.collected => 'Awaiting pickup',
        DeliveryTrackGroup.inProgress => 'In progress',
        DeliveryTrackGroup.completed => 'Delivered',
      };
}

class TrackedDeliveryItem {
  final MatchResponse match;
  final DeliveryTrackGroup group;

  const TrackedDeliveryItem({required this.match, required this.group});
}

class DeliveryTrackResponse {
  final List<TrackedDeliveryItem> collected;
  final List<TrackedDeliveryItem> inProgress;
  final List<TrackedDeliveryItem> completed;

  const DeliveryTrackResponse({
    this.collected = const [],
    this.inProgress = const [],
    this.completed = const [],
  });

  factory DeliveryTrackResponse.fromJson(Map<String, dynamic> json) {
    List<TrackedDeliveryItem> parseList(
      String key,
      DeliveryTrackGroup group,
    ) {
      final raw = json[key] as List<dynamic>? ?? [];
      return raw
          .map((e) => TrackedDeliveryItem(
                match: MatchResponse.fromJson(e as Map<String, dynamic>),
                group: group,
              ))
          .toList();
    }

    return DeliveryTrackResponse(
      collected: parseList('collected', DeliveryTrackGroup.collected),
      inProgress: parseList('inProgress', DeliveryTrackGroup.inProgress),
      completed: parseList('completed', DeliveryTrackGroup.completed),
    );
  }

  List<TrackedDeliveryItem> get all => [
        ...collected,
        ...inProgress,
        ...completed,
      ];

  List<TrackedDeliveryItem> preview({int limit = 5}) =>
      all.take(limit).toList();

  int get totalCount => all.length;

  bool get isEmpty => totalCount == 0;

  List<TrackedDeliveryItem> filtered(DeliveryTrackFilter filter) {
    print("FILTERED: $filter");
    return switch (filter) {
      DeliveryTrackFilter.all => all,
      DeliveryTrackFilter.collected => collected,
      DeliveryTrackFilter.inProgress => inProgress,
      DeliveryTrackFilter.completed => completed,
    };
  }
}

enum DeliveryTrackFilter { all, collected, inProgress, completed }

extension DeliveryTrackFilterX on DeliveryTrackFilter {
  String get label => switch (this) {
        DeliveryTrackFilter.all => 'All',
        DeliveryTrackFilter.collected => 'Awaiting pickup',
        DeliveryTrackFilter.inProgress => 'In progress',
        DeliveryTrackFilter.completed => 'Delivered',
      };
}

extension TrackedDeliveryPresentation on TrackedDeliveryItem {
  String get itemTitle {
    final items = match.matchedItems;
    if (items.isEmpty) return 'Delivery';
    if (items.length == 1) return items.first.itemName;
    return '${items.first.itemName} +${items.length - 1}';
  }

  String? get routeLabel {
    final leg = match.flight?.legs.isNotEmpty == true
        ? match.flight!.legs.last
        : null;
    if (leg != null) {
      final from = leg.srcAirport.iataCode.isNotEmpty
          ? leg.srcAirport.iataCode
          : leg.srcAirport.name;
      final to = leg.destAirport.iataCode.isNotEmpty
          ? leg.destAirport.iataCode
          : leg.destAirport.name;
      return '$from → $to';
    }
    final from = match.pickupArea?.trim();
    final to = match.deliveryArea?.trim();
    if (from != null && from.isNotEmpty && to != null && to.isNotEmpty) {
      return '$from → $to';
    }
    return null;
  }

  int? get daysUntilDelivery {
    final target = match.expectedDeliveryAt;
    if (target == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(target.year, target.month, target.day);
    return due.difference(today).inDays;
  }

  String? get daysLeftLabel {
    if (group == DeliveryTrackGroup.completed) return 'Delivered';
    final days = daysUntilDelivery;
    if (days == null) return null;
    if (days > 1) return '$days days left';
    if (days == 1) return '1 day left';
    if (days == 0) return 'Due today';
    return '${days.abs()}d overdue';
  }

  String partnerRoleLabel({required bool viewerIsCarrier}) =>
      viewerIsCarrier ? 'Shipper' : 'Carrier';
}
