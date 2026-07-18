import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_refresh_bus.dart';
import '../../matches/models/match_models.dart';
import '../../matches/repository/match_repository.dart';
import '../../offer_requests/models/proposal_models.dart';
import '../../offer_requests/repository/offer_request_repository.dart';
import '../../profile/repository/user_repository.dart';
import '../models/engagement_models.dart';

class EngagementState extends Equatable {
  final List<EngagementListItem> items;
  final EngagementResponse? response;
  final bool loading;
  final String? error;
  final String? mode;

  const EngagementState({
    this.items = const [],
    this.response,
    this.loading = false,
    this.error,
    this.mode,
  });

  EngagementState copyWith({
    List<EngagementListItem>? items,
    EngagementResponse? response,
    bool? loading,
    String? error,
    String? mode,
  }) =>
      EngagementState(
        items: items ?? this.items,
        response: response ?? this.response,
        loading: loading ?? this.loading,
        error: error,
        mode: mode ?? this.mode,
      );

  @override
  List<Object?> get props => [items, response, loading, error, mode];
}

class EngagementCubit extends Cubit<EngagementState> {
  final UserRepository _users;
  final OfferRequestRepository _proposals;
  final MatchRepository _matches;
  bool _loadedOnce = false;
  StreamSubscription<void>? _refreshSub;

  EngagementCubit(this._users, this._proposals, this._matches)
      : super(const EngagementState()) {
    // Reload whenever a proposal is created/mutated anywhere in the app, so the
    // engagements list updates live instead of only after an app restart.
    _refreshSub =
        AppRefreshBus.instance.on(RefreshTopic.engagements).listen((_) {
      load(force: true);
    });
  }

  @override
  Future<void> close() {
    _refreshSub?.cancel();
    return super.close();
  }

  Future<void> load({bool force = false}) async {
    if (_loadedOnce && !force) return;
    emit(state.copyWith(loading: true, error: null));
    try {
      final response = await _users.fetchEngagement();
      _loadedOnce = true;
      emit(state.copyWith(
        items: response.toListItems(),
        response: response,
        mode: response.mode,
        loading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  ProposalEngagement? proposalById(String id) {
    final response = state.response;
    if (response == null) return null;
    for (final p in [...response.proposalsSent, ...response.proposalsReceived]) {
      if (p.id == id) return p;
    }
    return null;
  }

  MatchEngagement? matchById(String id) {
    final response = state.response;
    if (response == null) return null;
    for (final m in response.matchedOffers) {
      if (m.id == id) return m;
    }
    return null;
  }

  Future<void> withdrawProposal(String proposalId) async {
    await _proposals.withdrawProposal(proposalId);
    _removeProposalLocally(proposalId);
  }

  Future<void> rejectProposal(String proposalId) async {
    await _proposals.rejectProposal(proposalId);
    _removeProposalLocally(proposalId);
  }

  Future<MatchResponse> acceptProposal(
    String proposalId,
    AcceptProposalRequest request,
  ) async {
    final match = await _proposals.acceptProposal(proposalId, request);
    await load(force: true);
    return match;
  }

  // Carrier accepts a PENDING match (offer path) → PATCH /matches/{id}/accept.
  Future<MatchResponse> acceptMatch(String matchId) async {
    final match = await _matches.acceptMatch(matchId);
    await load(force: true);
    return match;
  }

  // Carrier rejects a PENDING match → PATCH /matches/{id}/reject (reason required).
  Future<void> rejectMatch(String matchId, String reason) async {
    await _matches.rejectMatch(matchId, reason);
    await load(force: true);
  }

  void _removeProposalLocally(String proposalId) {
    final response = state.response;
    if (response == null) return;
    final updated = EngagementResponse(
      mode: response.mode,
      proposalsSent:
          response.proposalsSent.where((p) => p.id != proposalId).toList(),
      proposalsReceived:
          response.proposalsReceived.where((p) => p.id != proposalId).toList(),
      matchedOffers: response.matchedOffers,
    );
    emit(state.copyWith(
      response: updated,
      items: updated.toListItems(),
    ));
  }
}
