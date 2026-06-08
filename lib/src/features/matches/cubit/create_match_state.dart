part of 'create_match_cubit.dart';

class MatchItemDraft {
  final OfferItemResponse item;
  double quantity;
  bool selected;

  MatchItemDraft({
    required this.item,
    this.quantity = 0,
    this.selected = false,
  });

  double get maxQuantity => item.remainingQuantity;

  double get lineTotal =>
      selected && quantity > 0 ? quantity * item.pricePerItem : 0;
}

enum CreateMatchStatus { editing, uploadingPhoto, submitting, success, failure }

class CreateMatchState {
  final CreateMatchStatus status;
  final List<MatchItemDraft> items;
  final bool receiverNeeded;
  final String firstName;
  final String lastName;
  final String phone;
  final String? photoIdUrl;
  final String? photoLocalPath;
  final String? error;
  final MatchResponse? result;

  const CreateMatchState({
    this.status = CreateMatchStatus.editing,
    this.items = const [],
    this.receiverNeeded = false,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.photoIdUrl,
    this.photoLocalPath,
    this.error,
    this.result,
  });

  bool get isBusy =>
      status == CreateMatchStatus.uploadingPhoto ||
      status == CreateMatchStatus.submitting;

  List<MatchItemDraft> get selectedItems =>
      items.where((d) => d.selected && d.quantity > 0).toList();

  double get totalPrice =>
      selectedItems.fold(0.0, (sum, d) => sum + d.lineTotal);

  bool get hasValidItems {
    if (selectedItems.isEmpty) return false;
    for (final d in selectedItems) {
      if (d.quantity <= 0 || d.quantity > d.maxQuantity + 0.0001) {
        return false;
      }
    }
    return true;
  }

  bool get hasValidReceiver {
    if (!receiverNeeded) return true;
    return firstName.trim().isNotEmpty &&
        lastName.trim().isNotEmpty &&
        phone.trim().isNotEmpty &&
        (photoIdUrl?.isNotEmpty == true || photoLocalPath?.isNotEmpty == true);
  }

  bool get canSubmit => hasValidItems && hasValidReceiver && !isBusy;

  CreateMatchState copyWith({
    CreateMatchStatus? status,
    List<MatchItemDraft>? items,
    bool? receiverNeeded,
    String? firstName,
    String? lastName,
    String? phone,
    Object? photoIdUrl = _sentinel,
    Object? photoLocalPath = _sentinel,
    Object? error = _sentinel,
    Object? result = _sentinel,
  }) =>
      CreateMatchState(
        status: status ?? this.status,
        items: items ?? this.items,
        receiverNeeded: receiverNeeded ?? this.receiverNeeded,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone ?? this.phone,
        photoIdUrl: photoIdUrl == _sentinel
            ? this.photoIdUrl
            : photoIdUrl as String?,
        photoLocalPath: photoLocalPath == _sentinel
            ? this.photoLocalPath
            : photoLocalPath as String?,
        error:
            error == _sentinel ? this.error : error as String?,
        result: result == _sentinel
            ? this.result
            : result as MatchResponse?,
      );
}

const _sentinel = Object();
