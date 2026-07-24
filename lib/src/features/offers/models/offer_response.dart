import 'dart:math';

import '../../../core/utils/time_format.dart';
import '../../flights/models/flight_models.dart';
import 'offer_models.dart';

class CarrierSummary {
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final bool isVerified;
  final double? rating;

  const CarrierSummary({
    required this.firstName,
    required this.lastName,
    this.profilePictureUrl,
    this.isVerified = false,
    this.rating,
  });

  factory CarrierSummary.fromJson(Map<String, dynamic> json) => CarrierSummary(
        firstName: (json['firstName'] ?? '').toString(),
        lastName: (json['lastName'] ?? '').toString(),
        profilePictureUrl: json['profilePictureUrl'] as String?,
        isVerified: json['isVerified'] as bool? ?? false,
        rating: (json['rating'] as num?)?.toDouble(),
      );

  String get fullName => '$firstName $lastName'.trim();

  /// "John S." when both names exist.
  String get displayName {
    final first = firstName.trim();
    if (first.isEmpty) return 'Carrier';
    final last = lastName.trim();
    if (last.isNotEmpty) return '$first ${last[0].toUpperCase()}.';
    return first;
  }

  String get initial =>
      (firstName.isNotEmpty ? firstName[0] : '?').toUpperCase();
}

class OfferItemResponse {
  final String id; // offer-item id
  final String itemId; // catalog item id
  final String name;
  final String? measurementUnit;
  final String? measurementType;
  final double quantity;
  final double remainingQuantity;
  final double pricePerItem;

  const OfferItemResponse({
    required this.id,
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.remainingQuantity,
    required this.pricePerItem,
    this.measurementUnit,
    this.measurementType,
  });

  factory OfferItemResponse.fromJson(Map<String, dynamic> json) {
    final item = json['item'] as Map<String, dynamic>?;
    final qty = (json['quantity'] as num?)?.toDouble() ?? 1;
    return OfferItemResponse(
      id: (json['id'] ?? '').toString(),
      itemId: (item?['id'] ?? json['itemId'] ?? '').toString(),
      name: (item?['name'] ?? json['name'] ?? 'Item').toString(),
      measurementUnit: item?['measurementUnit'] as String?,
      measurementType: item?['measurementType'] as String?,
      quantity: qty,
      remainingQuantity: (json['remainingQuantity'] as num?)?.toDouble() ?? qty,
      pricePerItem: (json['pricePerItem'] as num?)?.toDouble() ?? 0,
    );
  }

  String get unitLabel {
    final u = measurementUnit?.toUpperCase();
    return switch (u) {
      'KG' => 'kg',
      'PIECE' || 'PIECES' => 'piece',
      _ => u?.toLowerCase() ?? 'unit',
    };
  }

  bool get allowsDecimal =>
      measurementType?.toUpperCase() == 'WEIGHT' || measurementUnit?.toUpperCase() == 'KG';

  double get quantityStep => allowsDecimal ? 0.5 : 1;
}

class OfferResponse {
  final String id;
  final String carrierId;
  final CarrierSummary? carrier;
  final String offerSource;
  final String status;
  final bool hasManualItem;
  final FlightResponse? flight;
  final String currency;
  final String deliveryArea;
  final String pickupArea;
  final String urgencyLevel;
  final double? discount;
  final String? specialNote;
  final List<String> meetupPlaces;
  final List<String> paymentMethods;
  final List<OfferItemResponse> items;
  final String createdAt;
  final String updatedAt;
  // Number of active matches on this offer (from GET /offers/me).
  final int matchCount;

  const OfferResponse({
    required this.id,
    required this.carrierId,
    this.carrier,
    required this.offerSource,
    required this.status,
    required this.hasManualItem,
    required this.flight,
    required this.currency,
    required this.deliveryArea,
    required this.pickupArea,
    required this.urgencyLevel,
    required this.meetupPlaces,
    required this.paymentMethods,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.discount,
    this.specialNote,
    this.matchCount = 0,
  });

  factory OfferResponse.fromJson(Map<String, dynamic> json) => OfferResponse(
        id: (json['id'] ?? '').toString(),
        carrierId: (json['carrierId'] ?? '').toString(),
        carrier: json['carrier'] is Map<String, dynamic>
            ? CarrierSummary.fromJson(json['carrier'] as Map<String, dynamic>)
            : null,
        offerSource: (json['offerSource'] ?? 'DIRECT').toString(),
        status: (json['status'] ?? 'OPEN').toString(),
        hasManualItem: json['hasManualItem'] as bool? ?? false,
        flight: json['flight'] != null
            ? FlightResponse.fromJson(json['flight'] as Map<String, dynamic>)
            : null,
        currency: (json['currency'] ?? 'USD').toString(),
        deliveryArea: (json['deliveryArea'] ?? '').toString(),
        pickupArea: (json['pickupArea'] ?? '').toString(),
        urgencyLevel: (json['urgencyLevel'] ?? 'NORMAL').toString(),
        discount: (json['discount'] as num?)?.toDouble(),
        specialNote: json['specialNote'] as String?,
        meetupPlaces: (json['meetupPlaces'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        paymentMethods: (json['paymentMethods'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => OfferItemResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: (json['createdAt'] ?? '').toString(),
        updatedAt: (json['updatedAt'] ?? '').toString(),
        matchCount: (json['matchCount'] as num?)?.toInt() ?? 0,
      );

  // ── Display helpers ──────────────────────────────────────────────────────

  FlightLegResponse? get firstLeg =>
      (flight?.legs.isNotEmpty ?? false) ? flight!.legs.first : null;

  String? get fromCode => firstLeg?.srcAirport.iataCode;
  String? get toCode => firstLeg?.destAirport.iataCode;
  String? get fromCity => firstLeg?.srcAirport.city;
  String? get toCity => firstLeg?.destAirport.city;
  String? get departureDate => firstLeg?.departureDate;

  double get totalQuantity =>
      items.fold(0.0, (s, i) => s + i.quantity);
  double get totalValue =>
      items.fold(0.0, (s, i) => s + i.pricePerItem * i.quantity);

  double get startingPrice => items.isEmpty
      ? 0
      : items.map((i) => i.pricePerItem).reduce(min);

  String get priceUnitLabel =>
      items.isNotEmpty ? items.first.unitLabel : 'unit';

  double get totalRemainingCapacity =>
      items.fold(0.0, (s, i) => s + i.remainingQuantity);

  String get capacityUnitLabel {
    if (items.isEmpty) return 'units';
    final units = items.map((i) => i.unitLabel).toSet();
    if (units.length == 1) {
      final u = units.first;
      if (u == 'piece' && totalRemainingCapacity != 1) return 'pieces';
      return u;
    }
    return 'units';
  }

  Currency get currencyEnum => CurrencyX.fromApi(currency);

  String get formattedDepartureDate {
    final raw = departureDate;
    if (raw == null || raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  static String formatQuantity(double n) =>
      n % 1 == 0 ? n.toInt().toString() : n.toStringAsFixed(1);

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

  bool get canDelete =>
      status != 'ACCEPTED' && status != 'CANCELLED' && status != 'COMPLETED';

  String get createdAgo => TimeFormat.relative(createdAt);
}
