class Airport {
  final String id;
  final String name;
  final String iataCode;
  final String country;
  final String city;
  final bool active;

  const Airport({
    required this.id,
    required this.name,
    required this.iataCode,
    required this.country,
    required this.city,
    required this.active,
  });

  factory Airport.fromJson(Map<String, dynamic> json) => Airport(
        id: json['id'] as String,
        name: json['name'] as String,
        iataCode: (json['iataCode'] ?? json['code']) as String,
        country: json['country'] as String,
        city: json['city'] as String,
        active: json['active'] as bool? ?? true,
      );

  String get displayLabel => '$iataCode — $city, $country';
}
