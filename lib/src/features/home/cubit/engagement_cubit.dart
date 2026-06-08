import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../matches/models/match_models.dart';
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
  bool _loadedOnce = false;

  EngagementCubit(this._users, this._proposals) : super(const EngagementState());

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
