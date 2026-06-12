import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../airports/models/airport.dart';
import '../../airports/repository/airport_repository.dart';
import '../../flights/models/flight_models.dart';
import '../../flights/repository/flight_repository.dart';
import '../../items/models/item_models.dart';
import '../../items/repository/item_repository.dart';
import '../models/offer_models.dart';
import '../repository/offer_repository.dart';
import 'create_offer_state.dart';

class CreateOfferCubit extends Cubit<CreateOfferState> {
  final AirportRepository _airports;
  final FlightRepository _flights;
  final OfferRepository _offers;
  final ItemRepository _items;
  final _uuid = const Uuid();

  CreateOfferCubit({
    required AirportRepository airports,
    required FlightRepository flights,
    required OfferRepository offers,
    required ItemRepository items,
  })  : _airports = airports,
        _flights = flights,
        _offers = offers,
        _items = items,
        super(const CreateOfferState());

  // ── Airports ───────────────────────────────────────────────────────────────

  Future<void> loadAirports() async {
    if (state.airports.isNotEmpty) return;
    emit(state.copyWith(airportsLoading: true, airportsError: null));
    try {
      final list = await _airports.fetchAirports();
      emit(state.copyWith(airports: list, airportsLoading: false));
    } catch (e) {
      emit(state.copyWith(
          airportsLoading: false, airportsError: e.toString()));
    }
  }

  // ── Available items ────────────────────────────────────────────────────────

  Future<void> loadItems() async {
    if (state.availableItems.isNotEmpty || state.itemsLoading) return;
    emit(state.copyWith(itemsLoading: true, itemsError: null));
    try {
      debugPrint('[CreateOfferCubit] GET /items...');
      final list = await _items.fetchItems();
      debugPrint('[CreateOfferCubit] items loaded: ${list.length}');
      emit(state.copyWith(availableItems: list, itemsLoading: false));
    } catch (e, st) {
      debugPrint('[CreateOfferCubit] loadItems error: $e\n$st');
      emit(state.copyWith(itemsLoading: false, itemsError: e.toString()));
    }
  }

  // Creates a custom item on the backend, adds it to availableItems, returns it.
  Future<ItemModel?> createAndSelectItem(
      String name, ItemCategory category) async {
    final (type, unit) = category.defaultMeasurement;
    try {
      final item = await _items.createItem(
        name: name,
        category: category,
        measurementType: type,
        measurementUnit: unit,
      );
      // Prepend so it appears at the top of the picker list
      emit(state.copyWith(
          availableItems: [item, ...state.availableItems]));
      return item;
    } catch (e) {
      return null;
    }
  }

  // ── Flight form ────────────────────────────────────────────────────────────

  void setFlightType(FlightType type) =>
      emit(state.copyWith(flightType: type));

  void setFromAirport(Airport airport) =>
      emit(state.copyWith(fromAirport: airport, returnToAirport: airport));
  void setToAirport(Airport airport) =>
      emit(state.copyWith(toAirport: airport, returnFromAirport: airport));

  void setReturnFromAirport(Airport airport) =>
      emit(state.copyWith(returnFromAirport: airport));
  void setReturnToAirport(Airport airport) =>
      emit(state.copyWith(returnToAirport: airport));

  void setDepartureDate(DateTime d) => emit(state.copyWith(departureDate: d));
  void setDepartureTime(TimeOfDay t) => emit(state.copyWith(departureTime: t));
  void setArrivalDate(DateTime d) => emit(state.copyWith(arrivalDate: d));
  void setArrivalTime(TimeOfDay t) => emit(state.copyWith(arrivalTime: t));

  void setReturnDepartureDate(DateTime d) =>
      emit(state.copyWith(returnDepartureDate: d));
  void setReturnDepartureTime(TimeOfDay t) =>
      emit(state.copyWith(returnDepartureTime: t));
  void setReturnArrivalDate(DateTime d) =>
      emit(state.copyWith(returnArrivalDate: d));
  void setReturnArrivalTime(TimeOfDay t) =>
      emit(state.copyWith(returnArrivalTime: t));

  // ── Create flight → advance to offer step ─────────────────────────────────

  Future<void> createFlight() async {
    if (!state.flightFormValid) return;
    emit(state.copyWith(creatingFlight: true, flightError: null));
    try {
      final legs = [
        FlightLegRequest(
          srcAirportId: state.fromAirport!.id,
          destAirportId: state.toAirport!.id,
          departureDate: _fmtDate(state.departureDate!),
          departureTime: _fmtTime(state.departureTime!),
          arrivalDate: _fmtDate(state.arrivalDate!),
          arrivalTime: _fmtTime(state.arrivalTime!),
        ),
        if (state.flightType == FlightType.roundTrip)
          FlightLegRequest(
            srcAirportId: state.returnFromAirport!.id,
            destAirportId: state.returnToAirport!.id,
            departureDate: _fmtDate(state.returnDepartureDate!),
            departureTime: _fmtTime(state.returnDepartureTime!),
            arrivalDate: _fmtDate(state.returnArrivalDate!),
            arrivalTime: _fmtTime(state.returnArrivalTime!),
          ),
      ];
      final request =
          CreateFlightRequest(flightType: state.flightType, legs: legs);
      debugPrint('[CreateOfferCubit] POST /flights payload: ${request.toJson()}');
      final flight = await _flights.createFlight(request);
      debugPrint('[CreateOfferCubit] flight created id=${flight.id}');
      emit(state.copyWith(
        creatingFlight: false,
        flightId: flight.id,
        step: CreateOfferStep.offer,
      ));
    } catch (e, st) {
      debugPrint('[CreateOfferCubit] createFlight error: $e\n$st');
      emit(state.copyWith(
          creatingFlight: false, flightError: e.toString()));
    }
  }

  // ── Offer form ─────────────────────────────────────────────────────────────

  void setPickupArea(String v) => emit(state.copyWith(pickupArea: v));
  void setDeliveryArea(String v) => emit(state.copyWith(deliveryArea: v));
  void setUrgencyLevel(UrgencyLevel v) => emit(state.copyWith(urgencyLevel: v));
  void setCurrency(Currency v) => emit(state.copyWith(currency: v));
  void setDiscount(double? v) => emit(state.copyWith(discount: v));
  void setSpecialNote(String v) => emit(state.copyWith(specialNote: v));

  void addMeetupPlace(String place) {
    if (place.trim().isEmpty) return;
    emit(state.copyWith(
        meetupPlaces: [...state.meetupPlaces, place.trim()]));
  }

  void removeMeetupPlace(int index) {
    final updated = [...state.meetupPlaces]..removeAt(index);
    emit(state.copyWith(meetupPlaces: updated));
  }

  void togglePaymentMethod(PaymentMethod method) {
    final current = [...state.paymentMethods];
    current.contains(method) ? current.remove(method) : current.add(method);
    emit(state.copyWith(paymentMethods: current));
  }

  void addItems(List<ItemModel> items) {
    final existing = state.items.map((d) => d.item.id).toSet();
    final newDrafts = items
        .where((i) => !existing.contains(i.id))
        .map((i) => OfferItemDraft(
              id: _uuid.v4(),
              item: i,
              quantity: 1,
              pricePerItem: 0,
            ))
        .toList();
    emit(state.copyWith(items: [...state.items, ...newDrafts]));
  }

  void updateItem(String id, {int? quantity, double? pricePerItem}) {
    final updated = state.items.map((draft) {
      if (draft.id != id) return draft;
      return draft.copyWith(quantity: quantity, pricePerItem: pricePerItem);
    }).toList();
    emit(state.copyWith(items: updated));
  }

  void removeItem(String id) {
    emit(state.copyWith(
        items: state.items.where((i) => i.id != id).toList()));
  }

  // ── Create offer ───────────────────────────────────────────────────────────

  Future<void> createOffer() async {
    if (!state.offerFormValid || state.flightId == null) return;
    emit(state.copyWith(creatingOffer: true, offerError: null));
    try {
      final hasManualItem = state.items.any((d) => d.item.isManuallyCreated);
      final created = await _offers.createOffer(CreateOfferRequest(
        flightId: state.flightId!,
        pickupArea: state.pickupArea,
        deliveryArea: state.deliveryArea,
        urgencyLevel: state.urgencyLevel,
        currency: state.currency,
        hasManualItem: hasManualItem,
        discount: state.discount,
        specialNote: state.specialNote.isEmpty ? null : state.specialNote,
        meetupPlaces: state.meetupPlaces,
        paymentMethods: state.paymentMethods,
        items: state.items
            .map((d) => OfferItemRequest(
                  itemId: d.item.id,
                  quantity: d.quantity,
                  pricePerItem: d.pricePerItem,
                ))
            .toList(),
      ));
      emit(state.copyWith(
          creatingOffer: false, offerCreated: true, createdOffer: created));
    } catch (e) {
      emit(state.copyWith(
          creatingOffer: false, offerError: e.toString()));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
}
