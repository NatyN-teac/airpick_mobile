import 'package:equatable/equatable.dart';
import '../../countries/models/country.dart';
import '../../items/models/item_models.dart';
import '../../offers/models/offer_models.dart';
import '../models/offer_request_models.dart';

// ── Item draft (quantity only — no price for offer requests) ──────────────────

class OfferRequestItemDraft extends Equatable {
  final String id;
  final ItemModel item;
  final int quantity;

  const OfferRequestItemDraft({
    required this.id,
    required this.item,
    required this.quantity,
  });

  OfferRequestItemDraft copyWith({int? quantity}) => OfferRequestItemDraft(
        id: id,
        item: item,
        quantity: quantity ?? this.quantity,
      );

  @override
  List<Object?> get props => [id, item, quantity];
}

// ── State ─────────────────────────────────────────────────────────────────────

class CreateOfferRequestState extends Equatable {
  // Available items for picker
  final List<ItemModel> availableItems;
  final bool itemsLoading;
  final String? itemsError;

  // Available countries for pickers
  final List<Country> availableCountries;
  final bool countriesLoading;
  final String? countriesError;

  // Form fields — country fields hold the selected Country (name sent in payload)
  final Country? sourceCountry;
  final String sourceCity;
  final Country? destinationCountry;
  final DateTime? preferredDate;
  final UrgencyLevel urgencyLevel;
  final String specialNote;
  final bool partialProposalAccepted;
  final List<OfferRequestItemDraft> items;

  // Edit mode — null when creating, request id when editing
  final String? editingId;

  // Submission
  final bool submitting;
  final bool created;
  final OfferRequestResponse? result;
  final String? error;

  const CreateOfferRequestState({
    this.availableItems = const [],
    this.itemsLoading = false,
    this.itemsError,
    this.availableCountries = const [],
    this.countriesLoading = false,
    this.countriesError,
    this.sourceCountry,
    this.sourceCity = '',
    this.destinationCountry,
    this.preferredDate,
    this.urgencyLevel = UrgencyLevel.normal,
    this.specialNote = '',
    this.partialProposalAccepted = false,
    this.items = const [],
    this.editingId,
    this.submitting = false,
    this.created = false,
    this.result,
    this.error,
  });

  bool get isEditing => editingId != null;

  bool get isValid =>
      sourceCountry != null &&
      sourceCity.isNotEmpty &&
      destinationCountry != null &&
      preferredDate != null &&
      items.isNotEmpty &&
      items.every((d) => d.quantity > 0);

  CreateOfferRequestState copyWith({
    List<ItemModel>? availableItems,
    bool? itemsLoading,
    String? itemsError,
    List<Country>? availableCountries,
    bool? countriesLoading,
    String? countriesError,
    Country? sourceCountry,
    String? sourceCity,
    Country? destinationCountry,
    DateTime? preferredDate,
    UrgencyLevel? urgencyLevel,
    String? specialNote,
    bool? partialProposalAccepted,
    List<OfferRequestItemDraft>? items,
    String? editingId,
    bool? submitting,
    bool? created,
    OfferRequestResponse? result,
    String? error,
  }) =>
      CreateOfferRequestState(
        availableItems: availableItems ?? this.availableItems,
        itemsLoading: itemsLoading ?? this.itemsLoading,
        itemsError: itemsError ?? this.itemsError,
        availableCountries: availableCountries ?? this.availableCountries,
        countriesLoading: countriesLoading ?? this.countriesLoading,
        countriesError: countriesError ?? this.countriesError,
        sourceCountry: sourceCountry ?? this.sourceCountry,
        sourceCity: sourceCity ?? this.sourceCity,
        destinationCountry: destinationCountry ?? this.destinationCountry,
        preferredDate: preferredDate ?? this.preferredDate,
        urgencyLevel: urgencyLevel ?? this.urgencyLevel,
        specialNote: specialNote ?? this.specialNote,
        partialProposalAccepted:
            partialProposalAccepted ?? this.partialProposalAccepted,
        items: items ?? this.items,
        editingId: editingId ?? this.editingId,
        submitting: submitting ?? this.submitting,
        created: created ?? this.created,
        result: result ?? this.result,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [
        availableItems, itemsLoading, itemsError,
        availableCountries, countriesLoading, countriesError,
        sourceCountry, sourceCity, destinationCountry,
        preferredDate, urgencyLevel, specialNote, partialProposalAccepted,
        items, editingId, submitting, created, result, error,
      ];
}
