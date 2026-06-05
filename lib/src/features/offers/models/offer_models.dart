// ── Enums ─────────────────────────────────────────────────────────────────────

enum Currency {
  // North America
  usd, cad,
  // Europe / UK
  gbp, eur,
  // Middle East
  aed, sar, kwd, qar, bhd, omr, jod,
  // Asia
  cny,
  // Africa
  etb,
}

extension CurrencyX on Currency {
  String get apiValue => name.toUpperCase();

  String get label => switch (this) {
        Currency.usd => 'US Dollar (USD)',
        Currency.cad => 'Canadian Dollar (CAD)',
        Currency.gbp => 'British Pound (GBP)',
        Currency.eur => 'Euro (EUR)',
        Currency.aed => 'UAE Dirham (AED)',
        Currency.sar => 'Saudi Riyal (SAR)',
        Currency.kwd => 'Kuwaiti Dinar (KWD)',
        Currency.qar => 'Qatari Riyal (QAR)',
        Currency.bhd => 'Bahraini Dinar (BHD)',
        Currency.omr => 'Omani Rial (OMR)',
        Currency.jod => 'Jordanian Dinar (JOD)',
        Currency.cny => 'Chinese Yuan (CNY)',
        Currency.etb => 'Ethiopian Birr (ETB)',
      };

  String get symbol => switch (this) {
        Currency.usd || Currency.cad => '\$',
        Currency.gbp => '£',
        Currency.eur => '€',
        Currency.cny => '¥',
        Currency.etb => 'Br',
        Currency.kwd => 'KD',
        Currency.bhd => 'BD',
        Currency.omr => 'OMR',
        Currency.jod => 'JD',
        _ => name.toUpperCase(),
      };
}

enum MeetupPlace { cafe, airport, publicPark, hotel, gasStation, other }

extension MeetupPlaceX on MeetupPlace {
  String get label => switch (this) {
        MeetupPlace.cafe => 'Cafe',
        MeetupPlace.airport => 'Airport',
        MeetupPlace.publicPark => 'Public Park',
        MeetupPlace.hotel => 'Hotel',
        MeetupPlace.gasStation => 'Gas Station',
        MeetupPlace.other => 'Other',
      };
}

enum UrgencyLevel { urgent, flexible, normal }

extension UrgencyLevelX on UrgencyLevel {
  String get apiValue => switch (this) {
        UrgencyLevel.urgent => 'URGENT',
        UrgencyLevel.flexible => 'FLEXIBLE',
        UrgencyLevel.normal => 'NORMAL',
      };
  String get label => switch (this) {
        UrgencyLevel.urgent => 'Urgent',
        UrgencyLevel.flexible => 'Flexible',
        UrgencyLevel.normal => 'Normal',
      };
}

enum PaymentMethod {
  cash,
  cashApp,
  zelle,
  venmo,
  payPal,
  applePay,
  googlePay,
  wise,
  revolut,
  westernUnion,
  moneyGram,
}

extension PaymentMethodX on PaymentMethod {
  String get apiValue => switch (this) {
        PaymentMethod.cash => 'CASH',
        PaymentMethod.cashApp => 'CASHAPP',
        PaymentMethod.zelle => 'ZELLE',
        PaymentMethod.venmo => 'VENMO',
        PaymentMethod.payPal => 'PAYPAL',
        PaymentMethod.applePay => 'APPLE_PAY',
        PaymentMethod.googlePay => 'GOOGLE_PAY',
        PaymentMethod.wise => 'WISE',
        PaymentMethod.revolut => 'REVOLUT',
        PaymentMethod.westernUnion => 'WESTERN_UNION',
        PaymentMethod.moneyGram => 'MONEYGRAM',
      };

  String get label => switch (this) {
        PaymentMethod.cash => 'Cash',
        PaymentMethod.cashApp => 'CashApp',
        PaymentMethod.zelle => 'Zelle',
        PaymentMethod.venmo => 'Venmo',
        PaymentMethod.payPal => 'PayPal',
        PaymentMethod.applePay => 'Apple Pay',
        PaymentMethod.googlePay => 'Google Pay',
        PaymentMethod.wise => 'Wise',
        PaymentMethod.revolut => 'Revolut',
        PaymentMethod.westernUnion => 'Western Union',
        PaymentMethod.moneyGram => 'MoneyGram',
      };
}

// ── Request models ────────────────────────────────────────────────────────────

class OfferItemRequest {
  final String itemId;
  final int quantity;
  final double pricePerItem;

  const OfferItemRequest({
    required this.itemId,
    required this.quantity,
    required this.pricePerItem,
  });

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'quantity': quantity,
        'pricePerItem': pricePerItem,
      };
}

class CreateOfferRequest {
  final String flightId;
  final String deliveryArea;
  final String pickupArea;
  final UrgencyLevel urgencyLevel;
  final Currency currency;
  final double? discount;
  final String? specialNote;
  final List<String> meetupPlaces;
  final List<PaymentMethod> paymentMethods;
  final List<OfferItemRequest> items;
  final bool hasManualItem;

  const CreateOfferRequest({
    required this.flightId,
    required this.deliveryArea,
    required this.pickupArea,
    required this.urgencyLevel,
    required this.currency,
    required this.meetupPlaces,
    required this.paymentMethods,
    required this.items,
    this.hasManualItem = false,
    this.discount,
    this.specialNote,
  });

  Map<String, dynamic> toJson() => {
        'flightId': flightId,
        'deliveryArea': deliveryArea,
        'pickupArea': pickupArea,
        'urgencyLevel': urgencyLevel.apiValue,
        'currency': currency.apiValue,
        if (discount != null) 'discount': discount,
        if (specialNote != null && specialNote!.isNotEmpty)
          'specialNote': specialNote,
        'meetupPlaces': meetupPlaces,
        'paymentMethods': paymentMethods.map((m) => m.apiValue).toList(),
        'items': items.map((i) => i.toJson()).toList(),
        if (hasManualItem) 'hasManualItem': true,
      };
}
