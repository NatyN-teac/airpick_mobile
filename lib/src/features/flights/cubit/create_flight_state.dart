import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import '../../airports/models/airport.dart';
import '../models/flight_models.dart';

enum CreateFlightStatus { initial, loading, success, failure }

class CreateFlightState extends Equatable {
  final FlightType flightType;
  final Airport? fromAirport;
  final Airport? toAirport;
  final DateTime? departureDate;
  final TimeOfDay? departureTime;
  final DateTime? arrivalDate;
  final TimeOfDay? arrivalTime;
  // Return leg — airports pre-filled as outbound swap, user can override
  final Airport? returnFromAirport;
  final Airport? returnToAirport;
  final DateTime? returnDepartureDate;
  final TimeOfDay? returnDepartureTime;
  final DateTime? returnArrivalDate;
  final TimeOfDay? returnArrivalTime;
  final CreateFlightStatus status;
  final FlightResponse? createdFlight;
  final String? error;

  const CreateFlightState({
    this.flightType = FlightType.oneWay,
    this.fromAirport,
    this.toAirport,
    this.departureDate,
    this.departureTime,
    this.arrivalDate,
    this.arrivalTime,
    this.returnFromAirport,
    this.returnToAirport,
    this.returnDepartureDate,
    this.returnDepartureTime,
    this.returnArrivalDate,
    this.returnArrivalTime,
    this.status = CreateFlightStatus.initial,
    this.createdFlight,
    this.error,
  });

  bool get isValid =>
      fromAirport != null &&
      toAirport != null &&
      departureDate != null &&
      departureTime != null &&
      arrivalDate != null &&
      arrivalTime != null &&
      (flightType == FlightType.oneWay ||
          (returnFromAirport != null &&
              returnToAirport != null &&
              returnDepartureDate != null &&
              returnDepartureTime != null &&
              returnArrivalDate != null &&
              returnArrivalTime != null));

  CreateFlightState copyWith({
    FlightType? flightType,
    Airport? fromAirport,
    Airport? toAirport,
    DateTime? departureDate,
    TimeOfDay? departureTime,
    DateTime? arrivalDate,
    TimeOfDay? arrivalTime,
    Airport? returnFromAirport,
    Airport? returnToAirport,
    DateTime? returnDepartureDate,
    TimeOfDay? returnDepartureTime,
    DateTime? returnArrivalDate,
    TimeOfDay? returnArrivalTime,
    CreateFlightStatus? status,
    FlightResponse? createdFlight,
    String? error,
  }) =>
      CreateFlightState(
        flightType: flightType ?? this.flightType,
        fromAirport: fromAirport ?? this.fromAirport,
        toAirport: toAirport ?? this.toAirport,
        departureDate: departureDate ?? this.departureDate,
        departureTime: departureTime ?? this.departureTime,
        arrivalDate: arrivalDate ?? this.arrivalDate,
        arrivalTime: arrivalTime ?? this.arrivalTime,
        returnFromAirport: returnFromAirport ?? this.returnFromAirport,
        returnToAirport: returnToAirport ?? this.returnToAirport,
        returnDepartureDate: returnDepartureDate ?? this.returnDepartureDate,
        returnDepartureTime: returnDepartureTime ?? this.returnDepartureTime,
        returnArrivalDate: returnArrivalDate ?? this.returnArrivalDate,
        returnArrivalTime: returnArrivalTime ?? this.returnArrivalTime,
        status: status ?? this.status,
        createdFlight: createdFlight ?? this.createdFlight,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [
        flightType,
        fromAirport, toAirport,
        departureDate, departureTime, arrivalDate, arrivalTime,
        returnFromAirport, returnToAirport,
        returnDepartureDate, returnDepartureTime, returnArrivalDate, returnArrivalTime,
        status, createdFlight, error,
      ];
}
