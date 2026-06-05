import '../../flights/models/flight_models.dart';
import '../../offers/models/offer_models.dart';

class ProposalItemRequest {
  final String offerRequestItemId;
  final double pricePerItem;

  const ProposalItemRequest({
    required this.offerRequestItemId,
    required this.pricePerItem,
  });

  Map<String, dynamic> toJson() => {
        'offerRequestItemId': offerRequestItemId,
        'pricePerItem': pricePerItem,
      };
}

// POST /api/v1/offer-requests/{requestId}/proposals
// The flight is created together with the proposal (nested `flight` object).
class CreateProposalRequest {
  final CreateFlightRequest flight;
  final String deliveryArea;
  final String pickupArea;
  final double? discount;
  final List<String> meetupPlaces;
  final List<PaymentMethod> paymentMethods;
  final String? note;
  final List<ProposalItemRequest> items;

  const CreateProposalRequest({
    required this.flight,
    required this.deliveryArea,
    required this.pickupArea,
    required this.meetupPlaces,
    required this.paymentMethods,
    required this.items,
    this.discount,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'flight': flight.toJson(),
        'deliveryArea': deliveryArea,
        'pickupArea': pickupArea,
        if (discount != null) 'discount': discount,
        'meetupPlaces': meetupPlaces,
        // API sample uses display labels ("Cash", "Zelle")
        'paymentMethods': paymentMethods.map((m) => m.label).toList(),
        if (note != null && note!.isNotEmpty) 'note': note,
        'items': items.map((i) => i.toJson()).toList(),
      };
}
