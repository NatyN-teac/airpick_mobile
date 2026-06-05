import 'package:equatable/equatable.dart';

class Country extends Equatable {
  final String id;
  final String name;
  final String countryCode;

  const Country({
    required this.id,
    required this.name,
    required this.countryCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json['id'] as String,
        name: json['name'] as String,
        countryCode: json['countryCode'] as String? ?? '',
      );

  // Flag emoji derived from the ISO country code (e.g. "US" → 🇺🇸)
  String get flag {
    if (countryCode.length != 2) return '🏳️';
    final base = 0x1F1E6;
    final upper = countryCode.toUpperCase();
    final first = base + (upper.codeUnitAt(0) - 0x41);
    final second = base + (upper.codeUnitAt(1) - 0x41);
    return String.fromCharCode(first) + String.fromCharCode(second);
  }

  @override
  List<Object?> get props => [id, name, countryCode];
}
