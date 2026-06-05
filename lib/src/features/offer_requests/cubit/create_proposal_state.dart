import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import '../../airports/models/airport.dart';
import '../../offers/models/offer_models.dart';
import '../models/offer_request_models.dart';

class ProposalItemDraft extends Equatable {
  final OfferRequestItem item;
  final bool selected;
  final double price;

  const ProposalItemDraft({
    required this.item,
    this.selected = true,
    this.price = 0,
  });

  ProposalItemDraft copyWith({bool? selected, double? price}) =>
      ProposalItemDraft(
        item: item,
        selected: selected ?? this.selected,
        price: price ?? this.price,
      );

  @override
  List<Object?> get props => [item, selected, price];
}

class CreateProposalState extends Equatable {
  final bool partialAllowed;

  // Airports
  final List<Airport> airports;
  final bool airportsLoading;
  final String? airportsError;

  // Flight (one-way)
  final Airport? fromAirport;
  final Airport? toAirport;
  final DateTime? departureDate;
  final TimeOfDay? departureTime;
  final DateTime? arrivalDate;
  final TimeOfDay? arrivalTime;

  // Proposal
  final String pickupArea;
  final String deliveryArea;
  final double? discount;
  final String note;
  final List<String> meetupPlaces;
  final List<PaymentMethod> paymentMethods;
  final List<ProposalItemDraft> items;

  // Submission
  final bool submitting;
  final bool created;
  final String? error;

  const CreateProposalState({
    this.partialAllowed = false,
    this.airports = const [],
    this.airportsLoading = false,
    this.airportsError,
    this.fromAirport,
    this.toAirport,
    this.departureDate,
    this.departureTime,
    this.arrivalDate,
    this.arrivalTime,
    this.pickupArea = '',
    this.deliveryArea = '',
    this.discount,
    this.note = '',
    this.meetupPlaces = const [],
    this.paymentMethods = const [],
    this.items = const [],
    this.submitting = false,
    this.created = false,
    this.error,
  });

  List<ProposalItemDraft> get selectedItems =>
      items.where((d) => d.selected).toList();

  bool get isPartial => items.any((d) => !d.selected);

  bool get flightValid =>
      fromAirport != null &&
      toAirport != null &&
      departureDate != null &&
      departureTime != null &&
      arrivalDate != null &&
      arrivalTime != null;

  bool get isValid =>
      flightValid &&
      pickupArea.isNotEmpty &&
      deliveryArea.isNotEmpty &&
      paymentMethods.isNotEmpty &&
      selectedItems.isNotEmpty &&
      (partialAllowed || !isPartial) &&
      selectedItems.every((d) => d.price > 0);

  double get total => selectedItems.fold(0.0, (s, d) => s + d.price);

  CreateProposalState copyWith({
    bool? partialAllowed,
    List<Airport>? airports,
    bool? airportsLoading,
    String? airportsError,
    Airport? fromAirport,
    Airport? toAirport,
    DateTime? departureDate,
    TimeOfDay? departureTime,
    DateTime? arrivalDate,
    TimeOfDay? arrivalTime,
    String? pickupArea,
    String? deliveryArea,
    double? discount,
    String? note,
    List<String>? meetupPlaces,
    List<PaymentMethod>? paymentMethods,
    List<ProposalItemDraft>? items,
    bool? submitting,
    bool? created,
    String? error,
  }) =>
      CreateProposalState(
        partialAllowed: partialAllowed ?? this.partialAllowed,
        airports: airports ?? this.airports,
        airportsLoading: airportsLoading ?? this.airportsLoading,
        airportsError: airportsError,
        fromAirport: fromAirport ?? this.fromAirport,
        toAirport: toAirport ?? this.toAirport,
        departureDate: departureDate ?? this.departureDate,
        departureTime: departureTime ?? this.departureTime,
        arrivalDate: arrivalDate ?? this.arrivalDate,
        arrivalTime: arrivalTime ?? this.arrivalTime,
        pickupArea: pickupArea ?? this.pickupArea,
        deliveryArea: deliveryArea ?? this.deliveryArea,
        discount: discount ?? this.discount,
        note: note ?? this.note,
        meetupPlaces: meetupPlaces ?? this.meetupPlaces,
        paymentMethods: paymentMethods ?? this.paymentMethods,
        items: items ?? this.items,
        submitting: submitting ?? this.submitting,
        created: created ?? this.created,
        error: error,
      );

  @override
  List<Object?> get props => [
        partialAllowed,
        airports, airportsLoading, airportsError,
        fromAirport, toAirport,
        departureDate, departureTime, arrivalDate, arrivalTime,
        pickupArea, deliveryArea, discount, note,
        meetupPlaces, paymentMethods, items,
        submitting, created, error,
      ];
}
