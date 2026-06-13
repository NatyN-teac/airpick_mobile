import '../../flights/models/flight_models.dart';

class MatchItemRequest {
  final String offerItemId;
  final double quantity;

  const MatchItemRequest({
    required this.offerItemId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'offerItemId': offerItemId,
        'quantity': quantity,
      };
}

class MatchReceiverRequest {
  final String firstName;
  final String lastName;
  final String phone;
  final String photoIdUrl;

  const MatchReceiverRequest({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.photoIdUrl,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'photoIdUrl': photoIdUrl,
      };
}

class CreateMatchRequest {
  final String offerId;
  final bool receiverNeeded;
  final MatchReceiverRequest? receiver;
  final List<MatchItemRequest> items;

  const CreateMatchRequest({
    required this.offerId,
    required this.receiverNeeded,
    required this.items,
    this.receiver,
  });

  Map<String, dynamic> toJson() => {
        'offerId': offerId,
        'receiverNeeded': receiverNeeded,
        'receiver': receiverNeeded ? receiver?.toJson() : null,
        'items': items.map((i) => i.toJson()).toList(),
      };
}

class MatchedItemResponse {
  final String id;
  final String offerItemId;
  final String itemName;
  final String? category;
  final double quantity;
  final double pricePerItem;
  final String? status;

  const MatchedItemResponse({
    required this.id,
    required this.offerItemId,
    required this.itemName,
    required this.quantity,
    required this.pricePerItem,
    this.category,
    this.status,
  });

  factory MatchedItemResponse.fromJson(Map<String, dynamic> json) {
    final item = json['item'] as Map<String, dynamic>?;
    return MatchedItemResponse(
      id: (json['id'] ?? '').toString(),
      offerItemId: (json['offerItemId'] ?? '').toString(),
      itemName: (item?['name'] ?? json['itemName'] ?? 'Item').toString(),
      category: (item?['category'] ?? json['category'])?.toString(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      pricePerItem: (json['pricePerItem'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString(),
    );
  }

  double get lineTotal => quantity * pricePerItem;

  /// Per-item lifecycle status from the API. `PENDING` means not yet picked up
  /// by the carrier — it is hidden in chat UI while the match is already accepted.
  String? get displayStatus {
    final s = status?.trim();
    if (s == null || s.isEmpty) return null;
    if (s.toUpperCase() == 'PENDING') return null;
    return s;
  }
}

class MatchResponse {
  final String id;
  final String offerId;
  final String status;
  final double totalPrice;
  final bool receiverNeeded;
  final List<MatchedItemResponse> matchedItems;
  final String? chatId;
  final String? pickupArea;
  final String? deliveryArea;
  final bool hasPickupPhoto;
  final String? pickupPhotoUploadedAt;
  final String? carrierId;
  final String? shipperId;
  final String? createdAt;
  final String? updatedAt;
  final FlightResponse? flight;
  final DateTime? expectedDeliveryAt;

  const MatchResponse({
    required this.id,
    required this.offerId,
    required this.status,
    required this.totalPrice,
    required this.receiverNeeded,
    required this.matchedItems,
    this.chatId,
    this.pickupArea,
    this.deliveryArea,
    this.hasPickupPhoto = false,
    this.pickupPhotoUploadedAt,
    this.carrierId,
    this.shipperId,
    this.createdAt,
    this.updatedAt,
    this.flight,
    this.expectedDeliveryAt,
  });

  factory MatchResponse.fromJson(Map<String, dynamic> json) {
    final offer = json['offer'] as Map<String, dynamic>?;
    final flight = _parseFlight(json['flight'] ?? offer?['flight']);
    return MatchResponse(
      id: (json['matchId'] ?? json['id'] ?? '').toString(),
      offerId: (json['offerId'] ?? '').toString(),
      status: (json['status'] ?? 'PENDING').toString(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      receiverNeeded: json['receiverNeeded'] as bool? ?? false,
      chatId: json['chatId'] as String?,
      carrierId: json['carrierId']?.toString(),
      shipperId: json['shipperId']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      pickupArea: (json['pickupArea'] ?? offer?['pickupArea'])?.toString(),
      deliveryArea:
          (json['deliveryArea'] ?? offer?['deliveryArea'])?.toString(),
      hasPickupPhoto: json['hasPickupPhoto'] as bool? ?? false,
      pickupPhotoUploadedAt: json['pickupPhotoUploadedAt']?.toString(),
      flight: flight,
      expectedDeliveryAt: _parseExpectedDelivery(flight, json),
      matchedItems: (json['matchedItems'] as List<dynamic>? ?? [])
          .map((e) => MatchedItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get hasAvailableChat =>
      chatId?.trim().isNotEmpty == true &&
      const {'ACCEPTED', 'IN_PROGRESS', 'IN_DELIVERY', 'COMPLETED'}
          .contains(status.toUpperCase());

  static FlightResponse? _parseFlight(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    try {
      return FlightResponse.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  static DateTime? _parseExpectedDelivery(
    FlightResponse? flight,
    Map<String, dynamic> json,
  ) {
    final explicit = json['expectedDeliveryAt'] ?? json['deliveryDeadline'];
    if (explicit != null) {
      return DateTime.tryParse(explicit.toString())?.toLocal();
    }
    final leg = flight?.legs.isNotEmpty == true ? flight!.legs.last : null;
    if (leg == null) return null;
    final date = leg.arrivalDate.trim();
    if (date.isEmpty) return null;
    final time = leg.arrivalTime.trim();
    return DateTime.tryParse(
      time.isEmpty ? date : '$date${time.contains('T') ? '' : 'T'}$time',
    )?.toLocal();
  }
}
