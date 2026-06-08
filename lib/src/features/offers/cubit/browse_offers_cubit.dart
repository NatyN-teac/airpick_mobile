import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../matches/models/match_models.dart';
import '../models/offer_response.dart';
import '../repository/offer_repository.dart';

class BrowseOffersState extends Equatable {
  final List<OfferResponse> offers;
  final bool loading;
  final String? error;

  const BrowseOffersState({
    this.offers = const [],
    this.loading = false,
    this.error,
  });

  BrowseOffersState copyWith({
    List<OfferResponse>? offers,
    bool? loading,
    String? error,
  }) =>
      BrowseOffersState(
        offers: offers ?? this.offers,
        loading: loading ?? this.loading,
        error: error,
      );

  @override
  List<Object?> get props => [offers, loading, error];
}

class BrowseOffersCubit extends Cubit<BrowseOffersState> {
  final OfferRepository _repo;
  bool _loadedOnce = false;

  BrowseOffersCubit(this._repo) : super(const BrowseOffersState());

  Future<void> load({bool force = false}) async {
    if (_loadedOnce && !force) return;
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await _repo.browseOffers();
      _loadedOnce = true;
      emit(state.copyWith(offers: list, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void remove(String id) {
    emit(state.copyWith(
        offers: state.offers.where((o) => o.id != id).toList()));
  }

  Future<void> afterMatch(OfferResponse offer, MatchResponse response) async {
    var fullyDepleted = offer.items.isNotEmpty;
    for (final item in offer.items) {
      final matched = response.matchedItems
          .where((m) => m.offerItemId == item.id)
          .fold(0.0, (s, m) => s + m.quantity);
      if (item.remainingQuantity - matched > 0.0001) {
        fullyDepleted = false;
        break;
      }
    }
    if (fullyDepleted) {
      remove(offer.id);
    } else {
      await load(force: true);
    }
  }
}
