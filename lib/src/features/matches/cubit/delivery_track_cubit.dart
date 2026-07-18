import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_refresh_bus.dart';
import '../../home/cubit/user_mode_cubit.dart';
import '../models/delivery_track_models.dart';
import '../repository/match_repository.dart';

class DeliveryTrackState extends Equatable {
  final DeliveryTrackResponse? data;
  final bool loading;
  final String? error;

  const DeliveryTrackState({
    this.data,
    this.loading = false,
    this.error,
  });

  bool get hasDeliveries => data != null && !data!.isEmpty;

  DeliveryTrackState copyWith({
    DeliveryTrackResponse? data,
    bool? loading,
    String? error,
  }) =>
      DeliveryTrackState(
        data: data ?? this.data,
        loading: loading ?? this.loading,
        error: error,
      );

  @override
  List<Object?> get props => [data, loading, error];
}

class DeliveryTrackCubit extends Cubit<DeliveryTrackState> {
  final MatchRepository _matches;
  UserMode _mode = UserMode.sender;
  bool _loadedOnce = false;
  StreamSubscription<void>? _refreshSub;

  DeliveryTrackCubit(this._matches) : super(const DeliveryTrackState()) {
    // A match advancing elsewhere (e.g. the carrier confirming pickup in chat)
    // invalidates this list — re-fetch so stage indicators stay in sync.
    _refreshSub = AppRefreshBus.instance.on(RefreshTopic.deliveries).listen((_) {
      if (_loadedOnce) reload();
    });
  }

  @override
  Future<void> close() {
    _refreshSub?.cancel();
    return super.close();
  }

  Future<void> load({required UserMode mode, bool force = false}) async {
    _mode = mode;
    if (_loadedOnce && !force) return;
    emit(state.copyWith(loading: true, error: null));
    try {
      final data = mode == UserMode.carrier
          ? await _matches.fetchCarrierTrack()
          : await _matches.fetchShipperTrack();
      _loadedOnce = true;
      emit(state.copyWith(data: data, loading: false));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> reload() => load(mode: _mode, force: true);
}
