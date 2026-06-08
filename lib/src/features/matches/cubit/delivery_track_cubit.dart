import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  DeliveryTrackCubit(this._matches) : super(const DeliveryTrackState());

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
