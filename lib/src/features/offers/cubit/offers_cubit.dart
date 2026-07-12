import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../models/offer_response.dart';
import '../repository/offer_repository.dart';

const kOfferStatuses = ['OPEN', 'MATCHED', 'IN_DELIVERY', 'COMPLETED', 'EXPIRED'];

String offerStatusLabel(String s, AppLocalizations l) => switch (s) {
      'OPEN' => l.statusOpen,
      'MATCHED' => l.statusMatched,
      'IN_DELIVERY' => l.sectionInDelivery,
      'COMPLETED' => l.statusCompleted,
      'EXPIRED' => l.statusExpired,
      'CANCELLED' => l.statusCancelled,
      _ => s,
    };

class OffersState extends Equatable {
  final List<OfferResponse> offers;
  final bool loading;
  final String? error;
  final String? statusFilter;
  final String? latestId;

  const OffersState({
    this.offers = const [],
    this.loading = false,
    this.error,
    this.statusFilter,
    this.latestId,
  });

  List<OfferResponse> get visible => statusFilter == null
      ? offers
      : offers.where((o) => o.status == statusFilter).toList();

  OffersState copyWith({
    List<OfferResponse>? offers,
    bool? loading,
    String? error,
    Object? statusFilter = _s,
    String? latestId,
  }) =>
      OffersState(
        offers: offers ?? this.offers,
        loading: loading ?? this.loading,
        error: error,
        statusFilter:
            statusFilter == _s ? this.statusFilter : statusFilter as String?,
        latestId: latestId,
      );

  @override
  List<Object?> get props => [offers, loading, error, statusFilter, latestId];
}

const _s = Object();

class OffersCubit extends Cubit<OffersState> {
  final OfferRepository _repo;
  bool _loadedOnce = false;

  OffersCubit(this._repo) : super(const OffersState());

  Future<void> load({bool force = false}) async {
    if (_loadedOnce && !force) return;
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await _repo.fetchMyOffers();
      _loadedOnce = true;
      emit(state.copyWith(offers: list, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void setFilter(String? status) => emit(state.copyWith(statusFilter: status));

  // Optimistic: new offer lands on top with a brief highlight.
  void prepend(OfferResponse offer) {
    emit(state.copyWith(offers: [offer, ...state.offers], latestId: offer.id));
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!isClosed) emit(state.copyWith(latestId: null));
    });
  }

  void update(OfferResponse offer) {
    emit(state.copyWith(
        offers:
            state.offers.map((o) => o.id == offer.id ? offer : o).toList()));
  }

  void remove(String id) {
    emit(state.copyWith(offers: state.offers.where((o) => o.id != id).toList()));
  }
}
