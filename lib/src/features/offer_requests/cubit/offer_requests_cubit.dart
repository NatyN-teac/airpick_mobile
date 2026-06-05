import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/offer_request_models.dart';
import '../repository/offer_request_repository.dart';

// Status filter options (null = All)
const kOfferRequestStatuses = [
  'OPEN',
  'PENDING_ITEM_APPROVAL',
  'PROPOSAL_RECEIVED',
  'ACCEPTED',
  'EXPIRED',
];

String offerRequestStatusLabel(String status) => switch (status) {
      'OPEN' => 'Open',
      'PENDING_ITEM_APPROVAL' => 'Pending',
      'PROPOSAL_RECEIVED' => 'Proposals',
      'ACCEPTED' => 'Accepted',
      'EXPIRED' => 'Expired',
      _ => status,
    };

// ── State ─────────────────────────────────────────────────────────────────────

class OfferRequestsState extends Equatable {
  final List<OfferRequestResponse> requests;
  final bool loading;
  final String? error;
  final String? statusFilter; // null = All
  final String? latestId; // triggers entrance animation on newly added card

  const OfferRequestsState({
    this.requests = const [],
    this.loading = false,
    this.error,
    this.statusFilter,
    this.latestId,
  });

  List<OfferRequestResponse> get visible => statusFilter == null
      ? requests
      : requests.where((r) => r.status == statusFilter).toList();

  OfferRequestsState copyWith({
    List<OfferRequestResponse>? requests,
    bool? loading,
    String? error,
    Object? statusFilter = _sentinel,
    String? latestId,
  }) =>
      OfferRequestsState(
        requests: requests ?? this.requests,
        loading: loading ?? this.loading,
        error: error,
        statusFilter: statusFilter == _sentinel
            ? this.statusFilter
            : statusFilter as String?,
        latestId: latestId,
      );

  @override
  List<Object?> get props => [requests, loading, error, statusFilter, latestId];
}

const _sentinel = Object();

// ── Cubit ─────────────────────────────────────────────────────────────────────

class OfferRequestsCubit extends Cubit<OfferRequestsState> {
  final OfferRequestRepository _repo;
  bool _loadedOnce = false;

  OfferRequestsCubit(this._repo) : super(const OfferRequestsState());

  // Fetches the current user's requests. Skips refetch unless forced.
  Future<void> load({bool force = false}) async {
    if (_loadedOnce && !force) return;
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await _repo.fetchMyOfferRequests();
      _loadedOnce = true;
      emit(state.copyWith(requests: list, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void setFilter(String? status) =>
      emit(state.copyWith(statusFilter: status));

  // Optimistic prepend — adds to top instantly, highlights briefly
  void prepend(OfferRequestResponse request) {
    emit(state.copyWith(
      requests: [request, ...state.requests],
      latestId: request.id,
    ));
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!isClosed) emit(state.copyWith(latestId: null));
    });
  }

  // Replace an existing request in place after an edit.
  void update(OfferRequestResponse request) {
    emit(state.copyWith(
      requests: state.requests
          .map((r) => r.id == request.id ? request : r)
          .toList(),
    ));
  }

  // Remove a request after deletion.
  void remove(String id) {
    emit(state.copyWith(
        requests: state.requests.where((r) => r.id != id).toList()));
  }
}
