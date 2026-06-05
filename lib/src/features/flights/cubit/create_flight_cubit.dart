import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../airports/models/airport.dart';
import '../models/flight_models.dart';
import '../repository/flight_repository.dart';
import 'create_flight_state.dart';

class CreateFlightCubit extends Cubit<CreateFlightState> {
  final FlightRepository _flights;

  CreateFlightCubit(this._flights) : super(const CreateFlightState());

  // ── Flight type ────────────────────────────────────────────────────────────

  void setFlightType(FlightType type) => emit(state.copyWith(flightType: type));

  // ── Outbound leg ───────────────────────────────────────────────────────────

  // Auto-fill return airports as the outbound swap; user can override after.
  void setFromAirport(Airport a) =>
      emit(state.copyWith(fromAirport: a, returnToAirport: a));
  void setToAirport(Airport a) =>
      emit(state.copyWith(toAirport: a, returnFromAirport: a));

  void setDepartureDate(DateTime d) => emit(state.copyWith(departureDate: d));
  void setDepartureTime(TimeOfDay t) => emit(state.copyWith(departureTime: t));
  void setArrivalDate(DateTime d) => emit(state.copyWith(arrivalDate: d));
  void setArrivalTime(TimeOfDay t) => emit(state.copyWith(arrivalTime: t));

  // ── Return leg ─────────────────────────────────────────────────────────────

  void setReturnFromAirport(Airport a) =>
      emit(state.copyWith(returnFromAirport: a));
  void setReturnToAirport(Airport a) =>
      emit(state.copyWith(returnToAirport: a));

  void setReturnDepartureDate(DateTime d) =>
      emit(state.copyWith(returnDepartureDate: d));
  void setReturnDepartureTime(TimeOfDay t) =>
      emit(state.copyWith(returnDepartureTime: t));
  void setReturnArrivalDate(DateTime d) =>
      emit(state.copyWith(returnArrivalDate: d));
  void setReturnArrivalTime(TimeOfDay t) =>
      emit(state.copyWith(returnArrivalTime: t));

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: CreateFlightStatus.loading, error: null));
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
      final flight = await _flights.createFlight(
        CreateFlightRequest(flightType: state.flightType, legs: legs),
      );
      emit(state.copyWith(
        status: CreateFlightStatus.success,
        createdFlight: flight,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CreateFlightStatus.failure,
        error: e.toString(),
      ));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
}
