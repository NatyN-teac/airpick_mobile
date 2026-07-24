import 'package:equatable/equatable.dart';

// ── Category ──────────────────────────────────────────────────────────────────

enum ItemCategory { beauty, clothing, documents, electronics, food }

extension ItemCategoryX on ItemCategory {
  String get apiValue => name.toUpperCase();

  String get label => switch (this) {
        ItemCategory.beauty => 'Beauty',
        ItemCategory.clothing => 'Clothing',
        ItemCategory.documents => 'Documents',
        ItemCategory.electronics => 'Electronics',
        ItemCategory.food => 'Food',
      };

  // Each category maps to a fixed measurement pair (mirrors backend constraints)
  (MeasurementType, MeasurementUnit) get defaultMeasurement => switch (this) {
        ItemCategory.beauty => (MeasurementType.liquid, MeasurementUnit.milliliter),
        ItemCategory.food => (MeasurementType.solidWeight, MeasurementUnit.kilogram),
        _ => (MeasurementType.solidPiece, MeasurementUnit.piece),
      };

  static ItemCategory fromApi(String v) => ItemCategory.values.firstWhere(
        (e) => e.apiValue == v,
        orElse: () => ItemCategory.clothing,
      );
}

// ── Measurement type ──────────────────────────────────────────────────────────

enum MeasurementType { liquid, solidPiece, solidWeight }

extension MeasurementTypeX on MeasurementType {
  String get apiValue => switch (this) {
        MeasurementType.liquid => 'LIQUID',
        MeasurementType.solidPiece => 'SOLID_PIECE',
        MeasurementType.solidWeight => 'SOLID_WEIGHT',
      };

  static MeasurementType fromApi(String v) => switch (v) {
        'LIQUID' => MeasurementType.liquid,
        'SOLID_PIECE' => MeasurementType.solidPiece,
        _ => MeasurementType.solidWeight,
      };
}

// ── Measurement unit ──────────────────────────────────────────────────────────

enum MeasurementUnit { milliliter, piece, kilogram }

extension MeasurementUnitX on MeasurementUnit {
  String get apiValue => switch (this) {
        MeasurementUnit.milliliter => 'MILLILITER',
        MeasurementUnit.piece => 'PIECE',
        MeasurementUnit.kilogram => 'KILOGRAM',
      };

  String get label => switch (this) {
        MeasurementUnit.milliliter => 'ml',
        MeasurementUnit.piece => 'pcs',
        MeasurementUnit.kilogram => 'kg',
      };

  static MeasurementUnit fromApi(String v) => switch (v) {
        'MILLILITER' => MeasurementUnit.milliliter,
        'PIECE' => MeasurementUnit.piece,
        _ => MeasurementUnit.kilogram,
      };
}

// ── Model ─────────────────────────────────────────────────────────────────────

class ItemModel extends Equatable {
  final String id;
  final String name;
  final ItemCategory category;
  final MeasurementType measurementType;
  final MeasurementUnit measurementUnit;
  final bool isApproved;
  final bool isManuallyCreated;

  const ItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.measurementType,
    required this.measurementUnit,
    this.isApproved = true,
    this.isManuallyCreated = false,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    print("fetched items states: $json");
    return
      ItemModel(
        id: json['id'] as String,
        name: json['name'] as String,
        category: ItemCategoryX.fromApi(json['category'] as String),
        measurementType:
        MeasurementTypeX.fromApi(json['measurementType'] as String),
        measurementUnit:
        MeasurementUnitX.fromApi(json['measurementUnit'] as String),
        isApproved: json['isApproved'] as bool? ?? true,
        isManuallyCreated: json['isManuallyCreated'] as bool? ?? false,
      );
  }

  @override
  List<Object?> get props => [
        id, name, category, measurementType, measurementUnit,
        isApproved, isManuallyCreated,
      ];
}
