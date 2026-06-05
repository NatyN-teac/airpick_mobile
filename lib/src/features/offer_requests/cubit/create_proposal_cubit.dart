import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../airports/models/airport.dart';
import '../../airports/repository/airport_repository.dart';
import '../../flights/models/flight_models.dart';
import '../../offers/models/offer_models.dart';
import '../models/offer_request_models.dart';
import '../models/proposal_models.dart';
import '../repository/offer_request_repository.dart';
import 'create_proposal_state.dart';

class CreateProposalCubit extends Cubit<CreateProposalState> {
  final AirportRepository _airports;
  final OfferRequestRepository _offerRequests;
  final OfferRequestResponse request;

  CreateProposalCubit({
    required AirportRepository airports,
    required OfferRequestRepository offerRequests,
    required this.request,
  })  : _airports = airports,
        _offerRequests = offerRequests,
        super(CreateProposalState(
          partialAllowed: request.partialProposalAccepted,
          items: request.items
              .map((i) => ProposalItemDraft(item: i))
              .toList(),
        ));

  Future<void> loadAirports() async {
    if (state.airports.isNotEmpty) return;
    emit(state.copyWith(airportsLoading: true));
    try {
      final list = await _airports.fetchAirports();
      emit(state.copyWith(airports: list, airportsLoading: false));
    } catch (e) {
      emit(state.copyWith(
          airportsLoading: false, airportsError: e.toString()));
    }
  }

  // Flight
  void setFromAirport(Airport a) => emit(state.copyWith(fromAirport: a));
  void setToAirport(Airport a) => emit(state.copyWith(toAirport: a));
  void setDepartureDate(DateTime d) => emit(state.copyWith(departureDate: d));
  void setDepartureTime(TimeOfDay t) => emit(state.copyWith(departureTime: t));
  void setArrivalDate(DateTime d) => emit(state.copyWith(arrivalDate: d));
  void setArrivalTime(TimeOfDay t) => emit(state.copyWith(arrivalTime: t));

  // Proposal
  void setPickupArea(String v) => emit(state.copyWith(pickupArea: v));
  void setDeliveryArea(String v) => emit(state.copyWith(deliveryArea: v));
  void setDiscount(double? v) => emit(state.copyWith(discount: v));
  void setNote(String v) => emit(state.copyWith(note: v));

  void togglePaymentMethod(PaymentMethod m) {
    final list = [...state.paymentMethods];
    list.contains(m) ? list.remove(m) : list.add(m);
    emit(state.copyWith(paymentMethods: list));
  }

  void addMeetupPlace(String place) {
    if (place.trim().isEmpty) return;
    emit(state.copyWith(meetupPlaces: [...state.meetupPlaces, place.trim()]));
  }

  void removeMeetupPlace(int i) {
    final list = [...state.meetupPlaces]..removeAt(i);
    emit(state.copyWith(meetupPlaces: list));
  }

  void toggleItem(String offerRequestItemId) {
    if (!state.partialAllowed) return;
    emit(state.copyWith(
      items: state.items
          .map((d) => d.item.id == offerRequestItemId
              ? d.copyWith(selected: !d.selected)
              : d)
          .toList(),
    ));
  }

  void setItemPrice(String offerRequestItemId, double price) {
    emit(state.copyWith(
      items: state.items
          .map((d) =>
              d.item.id == offerRequestItemId ? d.copyWith(price: price) : d)
          .toList(),
    ));
  }

  Future<void> submit() async {
    if (!state.isValid || state.submitting) return;
    emit(state.copyWith(submitting: true, error: null));
    try {
      // The flight is created together with the proposal (single request).
      final flight = CreateFlightRequest(
        flightType: FlightType.oneWay,
        legs: [
          FlightLegRequest(
            srcAirportId: state.fromAirport!.id,
            destAirportId: state.toAirport!.id,
            departureDate: _fmtDate(state.departureDate!),
            departureTime: _fmtTime(state.departureTime!),
            arrivalDate: _fmtDate(state.arrivalDate!),
            arrivalTime: _fmtTime(state.arrivalTime!),
          ),
        ],
      );

      await _offerRequests.createProposal(
        request.id,
        CreateProposalRequest(
          flight: flight,
          pickupArea: state.pickupArea,
          deliveryArea: state.deliveryArea,
          discount: state.discount,
          meetupPlaces: state.meetupPlaces,
          paymentMethods: state.paymentMethods,
          note: state.note.isEmpty ? null : state.note,
          items: state.selectedItems
              .map((d) => ProposalItemRequest(
                    offerRequestItemId: d.item.id,
                    pricePerItem: d.price,
                  ))
              .toList(),
        ),
      );
      emit(state.copyWith(submitting: false, created: true));
    } catch (e) {
      emit(state.copyWith(
          submitting: false,
          error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
}
