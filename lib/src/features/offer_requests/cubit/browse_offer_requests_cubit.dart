import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/offer_request_models.dart';
import '../repository/offer_request_repository.dart';

class BrowseOfferRequestsState extends Equatable {
  final List<OfferRequestResponse> requests;
  final bool loading;
  final String? error;
  final String? sourceCountry;
  final String? destinationCountry;
  final String? sourceCity;

  const BrowseOfferRequestsState({
    this.requests = const [],
    this.loading = false,
    this.error,
    this.sourceCountry,
    this.destinationCountry,
    this.sourceCity,
  });

  bool get hasFilters =>
      (sourceCountry?.isNotEmpty ?? false) ||
      (destinationCountry?.isNotEmpty ?? false) ||
      (sourceCity?.isNotEmpty ?? false);

  BrowseOfferRequestsState copyWith({
    List<OfferRequestResponse>? requests,
    bool? loading,
    String? error,
    Object? sourceCountry = _s,
    Object? destinationCountry = _s,
    Object? sourceCity = _s,
  }) =>
      BrowseOfferRequestsState(
        requests: requests ?? this.requests,
        loading: loading ?? this.loading,
        error: error,
        sourceCountry:
            sourceCountry == _s ? this.sourceCountry : sourceCountry as String?,
        destinationCountry: destinationCountry == _s
            ? this.destinationCountry
            : destinationCountry as String?,
        sourceCity:
            sourceCity == _s ? this.sourceCity : sourceCity as String?,
      );

  @override
  List<Object?> get props =>
      [requests, loading, error, sourceCountry, destinationCountry, sourceCity];
}

const _s = Object();

class BrowseOfferRequestsCubit extends Cubit<BrowseOfferRequestsState> {
  final OfferRequestRepository _repo;
  bool _loadedOnce = false;

  BrowseOfferRequestsCubit(this._repo)
      : super(const BrowseOfferRequestsState());

  Future<void> load({bool force = false}) async {
    if (_loadedOnce && !force) return;
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await _repo.browseOfferRequests(
        sourceCountry: state.sourceCountry,
        destinationCountry: state.destinationCountry,
        sourceCity: state.sourceCity,
      );
      _loadedOnce = true;
      emit(state.copyWith(requests: list, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> applyFilters({
    String? sourceCountry,
    String? destinationCountry,
    String? sourceCity,
  }) async {
    emit(state.copyWith(
      sourceCountry: sourceCountry,
      destinationCountry: destinationCountry,
      sourceCity: sourceCity,
    ));
    await load(force: true);
  }

  Future<void> clearFilters() async {
    emit(state.copyWith(
        sourceCountry: null, destinationCountry: null, sourceCity: null));
    await load(force: true);
  }

  // After a proposal is sent the request is no longer OPEN — drop it from view.
  void remove(String id) {
    emit(state.copyWith(
        requests: state.requests.where((r) => r.id != id).toList()));
  }
}
