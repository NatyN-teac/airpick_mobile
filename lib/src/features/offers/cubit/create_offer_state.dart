import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import '../../airports/models/airport.dart';
import '../../flights/models/flight_models.dart';
import '../../items/models/item_models.dart';
import '../models/offer_models.dart';
import '../models/offer_response.dart';

enum CreateOfferStep { flight, offer }

// ── Item draft ────────────────────────────────────────────────────────────────

class OfferItemDraft extends Equatable {
  final String id;
  final ItemModel item;
  final int quantity;
  final double pricePerItem;

  const OfferItemDraft({
    required this.id,
    required this.item,
    required this.quantity,
    required this.pricePerItem,
  });

  OfferItemDraft copyWith({
    ItemModel? item,
    int? quantity,
    double? pricePerItem,
  }) =>
      OfferItemDraft(
        id: id,
        item: item ?? this.item,
        quantity: quantity ?? this.quantity,
        pricePerItem: pricePerItem ?? this.pricePerItem,
      );

  @override
  List<Object?> get props => [id, item, quantity, pricePerItem];
}

// ── State ─────────────────────────────────────────────────────────────────────

class CreateOfferState extends Equatable {
  final CreateOfferStep step;

  // Airports
  final List<Airport> airports;
  final bool airportsLoading;
  final String? airportsError;

  // Available items (loaded from backend for the picker)
  final List<ItemModel> availableItems;
  final bool itemsLoading;
  final String? itemsError;

  // Flight form
  final FlightType flightType;
  final Airport? fromAirport;
  final Airport? toAirport;
  final DateTime? departureDate;
  final TimeOfDay? departureTime;
  final DateTime? arrivalDate;
  final TimeOfDay? arrivalTime;
  // Return leg — airports pre-filled as outbound swap, independently editable
  final Airport? returnFromAirport;
  final Airport? returnToAirport;
  final DateTime? returnDepartureDate;
  final TimeOfDay? returnDepartureTime;
  final DateTime? returnArrivalDate;
  final TimeOfDay? returnArrivalTime;

  // Flight creation
  final bool creatingFlight;
  final String? flightId;
  final String? flightError;

  // Offer form
  final String pickupArea;
  final String deliveryArea;
  final UrgencyLevel urgencyLevel;
  final Currency currency;
  final double? discount;
  final String specialNote;
  final List<String> meetupPlaces;
  final List<PaymentMethod> paymentMethods;
  final List<OfferItemDraft> items;

  // Offer creation
  final bool creatingOffer;
  final bool offerCreated;
  final OfferResponse? createdOffer;
  final String? offerError;

  const CreateOfferState({
    this.step = CreateOfferStep.flight,
    this.airports = const [],
    this.airportsLoading = false,
    this.airportsError,
    this.availableItems = const [],
    this.itemsLoading = false,
    this.itemsError,
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
    this.creatingFlight = false,
    this.flightId,
    this.flightError,
    this.pickupArea = '',
    this.deliveryArea = '',
    this.urgencyLevel = UrgencyLevel.normal,
    this.currency = Currency.usd,
    this.discount,
    this.specialNote = '',
    this.meetupPlaces = const [],
    this.paymentMethods = const [],
    this.items = const [],
    this.creatingOffer = false,
    this.offerCreated = false,
    this.createdOffer,
    this.offerError,
  });

  CreateOfferState copyWith({
    CreateOfferStep? step,
    List<Airport>? airports,
    bool? airportsLoading,
    String? airportsError,
    List<ItemModel>? availableItems,
    bool? itemsLoading,
    String? itemsError,
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
    bool? creatingFlight,
    String? flightId,
    String? flightError,
    String? pickupArea,
    String? deliveryArea,
    UrgencyLevel? urgencyLevel,
    Currency? currency,
    double? discount,
    String? specialNote,
    List<String>? meetupPlaces,
    List<PaymentMethod>? paymentMethods,
    List<OfferItemDraft>? items,
    bool? creatingOffer,
    bool? offerCreated,
    OfferResponse? createdOffer,
    String? offerError,
  }) =>
      CreateOfferState(
        step: step ?? this.step,
        airports: airports ?? this.airports,
        airportsLoading: airportsLoading ?? this.airportsLoading,
        airportsError: airportsError ?? this.airportsError,
        availableItems: availableItems ?? this.availableItems,
        itemsLoading: itemsLoading ?? this.itemsLoading,
        itemsError: itemsError ?? this.itemsError,
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
        creatingFlight: creatingFlight ?? this.creatingFlight,
        flightId: flightId ?? this.flightId,
        flightError: flightError ?? this.flightError,
        pickupArea: pickupArea ?? this.pickupArea,
        deliveryArea: deliveryArea ?? this.deliveryArea,
        urgencyLevel: urgencyLevel ?? this.urgencyLevel,
        currency: currency ?? this.currency,
        discount: discount ?? this.discount,
        specialNote: specialNote ?? this.specialNote,
        meetupPlaces: meetupPlaces ?? this.meetupPlaces,
        paymentMethods: paymentMethods ?? this.paymentMethods,
        items: items ?? this.items,
        creatingOffer: creatingOffer ?? this.creatingOffer,
        offerCreated: offerCreated ?? this.offerCreated,
        createdOffer: createdOffer ?? this.createdOffer,
        offerError: offerError ?? this.offerError,
      );

  bool get flightFormValid =>
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

  double get totalPrice =>
      items.fold(0.0, (sum, d) => sum + d.pricePerItem * d.quantity);

  bool get offerFormValid =>
      pickupArea.isNotEmpty &&
      deliveryArea.isNotEmpty &&
      paymentMethods.isNotEmpty &&
      items.isNotEmpty &&
      items.every((d) => d.quantity > 0 && d.pricePerItem > 0);

  @override
  List<Object?> get props => [
        step,
        airports, airportsLoading, airportsError,
        availableItems, itemsLoading, itemsError,
        flightType, fromAirport, toAirport,
        departureDate, departureTime, arrivalDate, arrivalTime,
        returnFromAirport, returnToAirport,
        returnDepartureDate, returnDepartureTime,
        returnArrivalDate, returnArrivalTime,
        creatingFlight, flightId, flightError,
        pickupArea, deliveryArea, urgencyLevel, currency, discount, specialNote,
        meetupPlaces, paymentMethods, items,
        creatingOffer, offerCreated, createdOffer, offerError,
      ];
}
