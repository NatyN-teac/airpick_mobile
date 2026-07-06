import '../../../core/utils/time_format.dart';
import '../../offers/models/offer_models.dart';

// ── Request ───────────────────────────────────────────────────────────────────

class OfferRequestItemRequest {
  final String itemId;
  final int quantity;

  const OfferRequestItemRequest({
    required this.itemId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'quantity': quantity,
      };
}

class CreateOfferRequestRequest {
  final String sourceCountry;
  final String sourceCity;
  final String destinationCountry;
  final String preferredDate;
  final UrgencyLevel urgencyLevel;
  final String? specialNote;
  final bool partialProposalAccepted;
  final List<OfferRequestItemRequest> items;
  final bool hasManualItem;

  const CreateOfferRequestRequest({
    required this.sourceCountry,
    required this.sourceCity,
    required this.destinationCountry,
    required this.preferredDate,
    required this.urgencyLevel,
    required this.items,
    this.partialProposalAccepted = false,
    this.specialNote,
    this.hasManualItem = false,
  });

  Map<String, dynamic> toJson() => {
        'sourceCountry': sourceCountry,
        'sourceCity': sourceCity,
        'destinationCountry': destinationCountry,
        'preferredDate': preferredDate,
        'urgencyLevel': urgencyLevel.apiValue,
        'partialProposalAccepted': partialProposalAccepted,
        if (specialNote != null && specialNote!.isNotEmpty)
          'specialNote': specialNote,
        'items': items.map((i) => i.toJson()).toList(),
        if (hasManualItem) 'hasManualItem': true,
      };
}

// ── Update request ────────────────────────────────────────────────────────────
// All fields optional — only non-null are sent. Source/destination country
// cannot be changed after creation, so they're intentionally excluded.

class UpdateOfferRequestRequest {
  final String? sourceCity;
  final String? preferredDate;
  final UrgencyLevel? urgencyLevel;
  final String? specialNote;
  final bool? partialProposalAccepted;
  final List<OfferRequestItemRequest>? items;
  final bool? hasManualItem;

  const UpdateOfferRequestRequest({
    this.sourceCity,
    this.preferredDate,
    this.urgencyLevel,
    this.specialNote,
    this.partialProposalAccepted,
    this.items,
    this.hasManualItem,
  });

  Map<String, dynamic> toJson() => {
        if (sourceCity != null) 'sourceCity': sourceCity,
        if (preferredDate != null) 'preferredDate': preferredDate,
        if (urgencyLevel != null) 'urgencyLevel': urgencyLevel!.apiValue,
        if (specialNote != null) 'specialNote': specialNote,
        if (partialProposalAccepted != null)
          'partialProposalAccepted': partialProposalAccepted,
        if (items != null) 'items': items!.map((i) => i.toJson()).toList(),
        if (hasManualItem != null) 'hasManualItem': hasManualItem,
      };
}

// ── Response item ─────────────────────────────────────────────────────────────
// Parsed defensively — the backend may nest the full item or flatten its fields.

class OfferRequestItem {
  final String id; // the offer-request-item id (used as offerRequestItemId)
  final String itemId; // the catalog item id
  final String name;
  final int quantity;
  final String? measurementUnit;

  const OfferRequestItem({
    required this.id,
    required this.itemId,
    required this.name,
    required this.quantity,
    this.measurementUnit,
  });

  factory OfferRequestItem.fromJson(Map<String, dynamic> json) {
    // Item details may be nested under `item`, flattened, or use `itemName`.
    final nested = json['item'] as Map<String, dynamic>?;
    final source = nested ?? json;
    return OfferRequestItem(
      id: (json['id'] ?? '') as String,
      itemId: (json['itemId'] ?? source['id'] ?? '') as String,
      name: (json['itemName'] ?? source['name'] ?? json['name'] ?? 'Item')
          as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      measurementUnit:
          (source['measurementUnit'] ?? json['measurementUnit']) as String?,
    );
  }
}

// ── Shipper (sender summary on browse responses) ──────────────────────────────

class Shipper {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;

  const Shipper({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePictureUrl,
  });

  factory Shipper.fromJson(Map<String, dynamic> json) => Shipper(
        id: json['id'] as String? ?? '',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        profilePictureUrl: json['profilePictureUrl'] as String?,
      );

  String get fullName => '$firstName $lastName'.trim();
  String get initial =>
      (firstName.isNotEmpty ? firstName[0] : '?').toUpperCase();
}

// ── Response ──────────────────────────────────────────────────────────────────

class OfferRequestResponse {
  final String id;
  final String shipperId;
  final Shipper? shipper;
  final String sourceCountry;
  final String sourceCity;
  final String destinationCountry;
  final String preferredDate;
  final String urgencyLevel;
  final String? specialNote;
  final String status;
  final bool partialProposalAccepted;
  final bool hasManualItem;
  final int proposalCount;
  final List<OfferRequestItem> items;
  final String createdAt;
  final String updatedAt;

  const OfferRequestResponse({
    required this.id,
    required this.shipperId,
    required this.sourceCountry,
    required this.sourceCity,
    required this.destinationCountry,
    required this.preferredDate,
    required this.urgencyLevel,
    required this.status,
    required this.partialProposalAccepted,
    required this.hasManualItem,
    required this.proposalCount,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.shipper,
    this.specialNote,
  });

  factory OfferRequestResponse.fromJson(Map<String, dynamic> json) =>
      OfferRequestResponse(
        id: json['id'] as String,
        shipperId: (json['shipperId'] ??
            (json['shipper'] as Map<String, dynamic>?)?['id'] ??
            '') as String,
        shipper: json['shipper'] != null
            ? Shipper.fromJson(json['shipper'] as Map<String, dynamic>)
            : null,
        sourceCountry: json['sourceCountry'] as String,
        sourceCity: json['sourceCity'] as String,
        destinationCountry: json['destinationCountry'] as String,
        preferredDate: json['preferredDate'] as String,
        urgencyLevel: json['urgencyLevel'] as String,
        specialNote: json['specialNote'] as String?,
        status: json['status'] as String? ?? 'OPEN',
        partialProposalAccepted:
            json['partialProposalAccepted'] as bool? ?? false,
        hasManualItem: json['hasManualItem'] as bool? ?? false,
        proposalCount: json['proposalCount'] as int? ?? 0,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => OfferRequestItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: json['createdAt'] as String? ?? '',
        updatedAt: json['updatedAt'] as String? ?? '',
      );

  // Display helpers
  String get urgencyLabel {
    switch (urgencyLevel) {
      case 'URGENT':
        return 'Urgent';
      case 'FLEXIBLE':
        return 'Flexible';
      default:
        return 'Normal';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'OPEN':
        return 'Open';
      case 'PENDING_ITEM_APPROVAL':
        return 'Pending approval';
      case 'CLOSED':
        return 'Closed';
      case 'ACCEPTED':
        return 'Accepted';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Deletable only when no proposals and not already accepted/cancelled.
  bool get canDelete =>
      proposalCount == 0 && status != 'ACCEPTED' && status != 'CANCELLED';

  int get totalQuantity => items.fold(0, (sum, i) => sum + i.quantity);

  // Relative "x ago" representation of createdAt.
  String get createdAgo => TimeFormat.relativeLong(createdAt);
}
