import 'match_models.dart';

/// Backend track buckets — maps to match lifecycle groups.
enum DeliveryTrackGroup { collected, inProgress, completed }

extension DeliveryTrackGroupX on DeliveryTrackGroup {
  String get label => switch (this) {
        DeliveryTrackGroup.collected => 'Picked up',
        DeliveryTrackGroup.inProgress => 'In progress',
        DeliveryTrackGroup.completed => 'Delivered',
      };

  /// Three-step progress: 1/3, 2/3, 3/3.
  int get activeSteps => switch (this) {
        DeliveryTrackGroup.collected => 1,
        DeliveryTrackGroup.inProgress => 2,
        DeliveryTrackGroup.completed => 3,
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

  List<TrackedDeliveryItem> filtered(DeliveryTrackFilter filter) =>
      switch (filter) {
        DeliveryTrackFilter.all => all,
        DeliveryTrackFilter.collected => collected,
        DeliveryTrackFilter.inProgress => inProgress,
        DeliveryTrackFilter.completed => completed,
      };
}

enum DeliveryTrackFilter { all, collected, inProgress, completed }

extension DeliveryTrackFilterX on DeliveryTrackFilter {
  String get label => switch (this) {
        DeliveryTrackFilter.all => 'All',
        DeliveryTrackFilter.collected => 'Picked up',
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
