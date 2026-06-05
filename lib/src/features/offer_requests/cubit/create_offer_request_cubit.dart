import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../countries/models/country.dart';
import '../../countries/repository/country_repository.dart';
import '../../items/models/item_models.dart';
import '../../items/repository/item_repository.dart';
import '../../offers/models/offer_models.dart';
import '../models/offer_request_models.dart';
import '../repository/offer_request_repository.dart';
import 'create_offer_request_state.dart';

class CreateOfferRequestCubit extends Cubit<CreateOfferRequestState> {
  final ItemRepository _items;
  final OfferRequestRepository _offerRequests;
  final CountryRepository _countries;
  final _uuid = const Uuid();

  CreateOfferRequestCubit({
    required ItemRepository items,
    required OfferRequestRepository offerRequests,
    required CountryRepository countries,
  })  : _items = items,
        _offerRequests = offerRequests,
        _countries = countries,
        super(const CreateOfferRequestState());

  // ── Init ───────────────────────────────────────────────────────────────────
  // Loads reference data, then seeds the form when editing an existing request.

  Future<void> init({OfferRequestResponse? existing}) async {
    await Future.wait([loadCountries(), loadItems()]);
    if (existing != null) _seed(existing);
  }

  void _seed(OfferRequestResponse r) {
    Country? matchCountry(String name) {
      final hit = state.availableCountries.where((c) => c.name == name);
      return hit.isNotEmpty ? hit.first : null;
    }

    final urgency = switch (r.urgencyLevel) {
      'URGENT' => UrgencyLevel.urgent,
      'FLEXIBLE' => UrgencyLevel.flexible,
      _ => UrgencyLevel.normal,
    };

    final drafts = r.items
        .map((ri) => OfferRequestItemDraft(
              id: _uuid.v4(),
              item: _resolveItem(ri),
              quantity: ri.quantity,
            ))
        .toList();

    emit(state.copyWith(
      editingId: r.id,
      sourceCountry: matchCountry(r.sourceCountry),
      sourceCity: r.sourceCity,
      destinationCountry: matchCountry(r.destinationCountry),
      preferredDate: DateTime.tryParse(r.preferredDate),
      urgencyLevel: urgency,
      specialNote: r.specialNote ?? '',
      partialProposalAccepted: r.partialProposalAccepted,
      items: drafts,
    ));
  }

  // Resolve a response item back to a full ItemModel (from the loaded list,
  // or a minimal fallback so it still renders in the edit form).
  ItemModel _resolveItem(OfferRequestItem ri) {
    final hit = state.availableItems.where((i) => i.id == ri.itemId);
    if (hit.isNotEmpty) return hit.first;
    return ItemModel(
      id: ri.itemId,
      name: ri.name,
      category: ItemCategory.electronics,
      measurementType: MeasurementType.solidPiece,
      measurementUnit: ri.measurementUnit != null
          ? MeasurementUnitX.fromApi(ri.measurementUnit!)
          : MeasurementUnit.piece,
    );
  }

  // ── Countries ──────────────────────────────────────────────────────────────

  Future<void> loadCountries() async {
    if (state.availableCountries.isNotEmpty || state.countriesLoading) return;
    emit(state.copyWith(countriesLoading: true, countriesError: null));
    try {
      final list = await _countries.fetchCountries();
      emit(state.copyWith(
          availableCountries: list, countriesLoading: false));
    } catch (e, st) {
      print('[CreateOfferRequestCubit] loadCountries error: $e\n$st');
      emit(state.copyWith(
          countriesLoading: false, countriesError: e.toString()));
    }
  }

  // ── Items ──────────────────────────────────────────────────────────────────

  Future<void> loadItems() async {
    if (state.availableItems.isNotEmpty || state.itemsLoading) return;
    emit(state.copyWith(itemsLoading: true, itemsError: null));
    try {
      print('[CreateOfferRequestCubit] GET /items...');
      final list = await _items.fetchItems();
      print('[CreateOfferRequestCubit] items loaded: ${list.length}');
      emit(state.copyWith(availableItems: list, itemsLoading: false));
    } catch (e, st) {
      print('[CreateOfferRequestCubit] loadItems error: $e\n$st');
      emit(state.copyWith(itemsLoading: false, itemsError: e.toString()));
    }
  }

  Future<ItemModel?> createAndSelectItem(
      String name, ItemCategory category) async {
    final (type, unit) = category.defaultMeasurement;
    try {
      final item = await _items.createItem(
        name: name,
        category: category,
        measurementType: type,
        measurementUnit: unit,
      );
      emit(state.copyWith(
          availableItems: [item, ...state.availableItems]));
      return item;
    } catch (_) {
      return null;
    }
  }

  // ── Form setters ───────────────────────────────────────────────────────────

  void setSourceCountry(Country v) => emit(state.copyWith(sourceCountry: v));
  void setSourceCity(String v) => emit(state.copyWith(sourceCity: v));
  void setDestinationCountry(Country v) =>
      emit(state.copyWith(destinationCountry: v));
  void setPreferredDate(DateTime d) => emit(state.copyWith(preferredDate: d));
  void setUrgencyLevel(UrgencyLevel v) =>
      emit(state.copyWith(urgencyLevel: v));
  void setSpecialNote(String v) => emit(state.copyWith(specialNote: v));
  void togglePartialProposal() => emit(state.copyWith(
      partialProposalAccepted: !state.partialProposalAccepted));

  // ── Item drafts ────────────────────────────────────────────────────────────

  void addItems(List<ItemModel> items) {
    final existing = state.items.map((d) => d.item.id).toSet();
    final newDrafts = items
        .where((i) => !existing.contains(i.id))
        .map((i) => OfferRequestItemDraft(
              id: _uuid.v4(),
              item: i,
              quantity: 1,
            ))
        .toList();
    emit(state.copyWith(items: [...state.items, ...newDrafts]));
  }

  void updateQuantity(String draftId, int quantity) {
    final updated = state.items.map((d) {
      if (d.id != draftId) return d;
      return d.copyWith(quantity: quantity);
    }).toList();
    emit(state.copyWith(items: updated));
  }

  void removeItem(String draftId) {
    emit(state.copyWith(
        items: state.items.where((d) => d.id != draftId).toList()));
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(submitting: true, error: null));
    try {
      final hasManualItem =
          state.items.any((d) => d.item.isManuallyCreated);
      final date = state.preferredDate!;
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final itemRequests = state.items
          .map((d) => OfferRequestItemRequest(
                itemId: d.item.id,
                quantity: d.quantity,
              ))
          .toList();

      final OfferRequestResponse result;
      if (state.isEditing) {
        // Source/destination country can't change — omitted from update.
        final request = UpdateOfferRequestRequest(
          sourceCity: state.sourceCity,
          preferredDate: dateStr,
          urgencyLevel: state.urgencyLevel,
          partialProposalAccepted: state.partialProposalAccepted,
          specialNote: state.specialNote.isEmpty ? null : state.specialNote,
          hasManualItem: hasManualItem,
          items: itemRequests,
        );
        print('[CreateOfferRequestCubit] PATCH /offer-requests/${state.editingId}: ${request.toJson()}');
        result = await _offerRequests.updateOfferRequest(
            state.editingId!, request);
        print('[CreateOfferRequestCubit] updated id=${result.id}');
      } else {
        final request = CreateOfferRequestRequest(
          sourceCountry: state.sourceCountry!.name,
          sourceCity: state.sourceCity,
          destinationCountry: state.destinationCountry!.name,
          preferredDate: dateStr,
          urgencyLevel: state.urgencyLevel,
          partialProposalAccepted: state.partialProposalAccepted,
          specialNote: state.specialNote.isEmpty ? null : state.specialNote,
          hasManualItem: hasManualItem,
          items: itemRequests,
        );
        print('[CreateOfferRequestCubit] POST /offer-requests: ${request.toJson()}');
        result = await _offerRequests.createOfferRequest(request);
        print('[CreateOfferRequestCubit] created id=${result.id}');
      }
      emit(state.copyWith(submitting: false, created: true, result: result));
    } catch (e, st) {
      print('[CreateOfferRequestCubit] submit error: $e\n$st');
      emit(state.copyWith(submitting: false, error: e.toString()));
    }
  }
}
