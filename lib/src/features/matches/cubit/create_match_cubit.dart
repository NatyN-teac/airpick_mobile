import 'dart:convert';
import '../../../core/utils/app_logger.dart';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/media/upload_repository.dart';
import '../../offers/models/offer_response.dart';
import '../models/match_models.dart';
import '../repository/match_repository.dart';

part 'create_match_state.dart';

class CreateMatchCubit extends Cubit<CreateMatchState> {
  final MatchRepository _matches;
  final UploadRepository _uploads;
  final OfferResponse offer;

  CreateMatchCubit({
    required MatchRepository matches,
    required UploadRepository uploads,
    required this.offer,
  })  : _matches = matches,
        _uploads = uploads,
        super(CreateMatchState(
          items: offer.items
              .where((i) => i.remainingQuantity > 0)
              .map((i) => MatchItemDraft(item: i))
              .toList(),
        ));

  void setReceiverNeeded(bool value) =>
      emit(state.copyWith(receiverNeeded: value, error: null));

  void setFirstName(String v) =>
      emit(state.copyWith(firstName: v, error: null));

  void setLastName(String v) =>
      emit(state.copyWith(lastName: v, error: null));

  void setPhone(String v) => emit(state.copyWith(phone: v, error: null));

  void toggleItem(String offerItemId, bool selected) {
    final next = state.items.map((d) {
      if (d.item.id != offerItemId) return d;
      final draft = MatchItemDraft(
        item: d.item,
        selected: selected,
        quantity: selected
            ? (d.quantity > 0 ? d.quantity : d.item.quantityStep)
            : 0,
      );
      return draft;
    }).toList();
    emit(state.copyWith(items: next, error: null));
  }

  void setQuantity(String offerItemId, double quantity) {
    final next = state.items.map((d) {
      if (d.item.id != offerItemId) return d;
      final clamped = quantity.clamp(0, d.maxQuantity).toDouble();
      return MatchItemDraft(
        item: d.item,
        selected: clamped > 0,
        quantity: clamped,
      );
    }).toList();
    emit(state.copyWith(items: next, error: null));
  }

  void setPhotoLocal(String path) => emit(state.copyWith(
        photoLocalPath: path,
        photoIdUrl: null,
        error: null,
      ));

  CreateMatchRequest _buildRequest({String? photoUrl}) => CreateMatchRequest(
        offerId: offer.id,
        receiverNeeded: state.receiverNeeded,
        receiver: state.receiverNeeded
            ? MatchReceiverRequest(
                firstName: state.firstName.trim(),
                lastName: state.lastName.trim(),
                phone: state.phone.trim(),
                photoIdUrl: photoUrl ?? '',
              )
            : null,
        items: state.selectedItems
            .map((d) => MatchItemRequest(
                  offerItemId: d.item.id,
                  quantity: d.quantity,
                ))
            .toList(),
      );

  // Explains exactly which requirement is unmet, instead of a vague catch-all.
  String _incompleteReason() {
    if (state.selectedItems.isEmpty) {
      return 'Select at least one item and a quantity to match.';
    }
    if (!state.hasValidItems) {
      return 'One of your quantities exceeds what the carrier has remaining.';
    }
    if (state.receiverNeeded) {
      if (state.firstName.trim().isEmpty ||
          state.lastName.trim().isEmpty ||
          state.phone.trim().isEmpty) {
        return 'Add the receiver\'s first name, last name, and phone number.';
      }
      if (!(state.photoIdUrl?.isNotEmpty == true ||
          state.photoLocalPath?.isNotEmpty == true)) {
        return 'Attach a photo of the receiver\'s ID.';
      }
    }
    return 'Please complete all required fields.';
  }

  void _logPayload(CreateMatchRequest request, {String? note}) {
    final json = const JsonEncoder.withIndent('  ').convert(request.toJson());
    appLogger.d(
      '[CreateMatch] POST /matches payload${note != null ? ' ($note)' : ''}:\n$json',
    );
  }

  Future<void> submit() async {
    if (!state.canSubmit) {
      appLogger.w('[CreateMatch] Send Match pressed — form incomplete, not sending.');
      emit(state.copyWith(
        error: _incompleteReason(),
        status: CreateMatchStatus.failure,
      ));
      return;
    }

    // Log immediately on button press (photo URL filled in after upload if needed).
    _logPayload(
      _buildRequest(
        photoUrl: state.photoIdUrl ??
            (state.receiverNeeded && state.photoLocalPath != null
                ? '(upload pending)'
                : null),
      ),
      note: 'on Send Match',
    );

    emit(state.copyWith(
      status: CreateMatchStatus.submitting,
      error: null,
    ));

    try {
      String? photoUrl = state.photoIdUrl;
      if (state.receiverNeeded &&
          photoUrl == null &&
          state.photoLocalPath != null) {
        emit(state.copyWith(status: CreateMatchStatus.uploadingPhoto));
        photoUrl = await _uploads.uploadFile(File(state.photoLocalPath!));
      }

      if (state.receiverNeeded && (photoUrl == null || photoUrl.isEmpty)) {
        throw Exception('Receiver photo ID is required.');
      }

      final request = _buildRequest(photoUrl: photoUrl);

      _logPayload(request, note: 'sending to API');

      final result = await _matches.createMatch(request);
      emit(state.copyWith(
        status: CreateMatchStatus.success,
        result: result,
        photoIdUrl: photoUrl,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CreateMatchStatus.failure,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
