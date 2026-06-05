import '../../airports/models/airport.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

enum FlightType { oneWay, roundTrip }

extension FlightTypeX on FlightType {
  String get apiValue =>
      this == FlightType.oneWay ? 'ONE_WAY' : 'ROUND_TRIP';
}

// ── Request models ────────────────────────────────────────────────────────────

class FlightLegRequest {
  final String srcAirportId;
  final String destAirportId;
  final String departureDate;
  final String departureTime;
  final String arrivalDate;
  final String arrivalTime;

  const FlightLegRequest({
    required this.srcAirportId,
    required this.destAirportId,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalDate,
    required this.arrivalTime,
  });

  Map<String, dynamic> toJson() => {
        'srcAirportId': srcAirportId,
        'destAirportId': destAirportId,
        'departureDate': departureDate,
        'departureTime': departureTime,
        'arrivalDate': arrivalDate,
        'arrivalTime': arrivalTime,
      };
}

class CreateFlightRequest {
  final FlightType flightType;
  final List<FlightLegRequest> legs;

  const CreateFlightRequest({
    required this.flightType,
    required this.legs,
  });

  Map<String, dynamic> toJson() => {
        'flightType': flightType.apiValue,
        'legs': legs.map((l) => l.toJson()).toList(),
      };
}

// ── Response models ───────────────────────────────────────────────────────────

class FlightLegResponse {
  final String id;
  final int legOrder;
  final Airport srcAirport;
  final Airport destAirport;
  final String departureDate;
  final String departureTime;
  final String arrivalDate;
  final String arrivalTime;

  const FlightLegResponse({
    required this.id,
    required this.legOrder,
    required this.srcAirport,
    required this.destAirport,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalDate,
    required this.arrivalTime,
  });

  factory FlightLegResponse.fromJson(Map<String, dynamic> json) =>
      FlightLegResponse(
        id: json['id'] as String,
        legOrder: json['legOrder'] as int,
        srcAirport: Airport.fromJson(json['srcAirport'] as Map<String, dynamic>),
        destAirport:
            Airport.fromJson(json['destAirport'] as Map<String, dynamic>),
        departureDate: json['departureDate'] as String,
        departureTime: json['departureTime'] as String,
        arrivalDate: json['arrivalDate'] as String,
        arrivalTime: json['arrivalTime'] as String,
      );
}

class FlightResponse {
  final String id;
  final FlightType flightType;
  final List<FlightLegResponse> legs;

  const FlightResponse({
    required this.id,
    required this.flightType,
    required this.legs,
  });

  factory FlightResponse.fromJson(Map<String, dynamic> json) => FlightResponse(
        id: json['id'] as String,
        flightType: (json['flightType'] as String) == 'ONE_WAY'
            ? FlightType.oneWay
            : FlightType.roundTrip,
        legs: (json['legs'] as List<dynamic>)
            .map((l) => FlightLegResponse.fromJson(l as Map<String, dynamic>))
            .toList(),
      );
}
