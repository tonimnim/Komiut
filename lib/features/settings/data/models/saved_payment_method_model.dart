/// Saved payment method model for JSON serialization.
///
/// Data transfer object for saved payment methods with JSON support.
library;

import '../../domain/entities/saved_payment_method.dart';

/// Model for saved payment methods with JSON serialization.
class SavedPaymentMethodModel {
  /// Creates a saved payment method model.
  const SavedPaymentMethodModel({
    required this.id,
    required this.type,
    required this.name,
    required this.maskedNumber,
    required this.isDefault,
    required this.addedAt,
    this.lastUsedAt,
    this.expiryDate,
    this.cardBrand,
  });

  /// Creates a model from a domain entity.
  factory SavedPaymentMethodModel.fromEntity(SavedPaymentMethod entity) {
    return SavedPaymentMethodModel(
      id: entity.id,
      type: entity.type.name,
      name: entity.name,
      maskedNumber: entity.maskedNumber,
      isDefault: entity.isDefault,
      addedAt: entity.addedAt.toIso8601String(),
      lastUsedAt: entity.lastUsedAt?.toIso8601String(),
      expiryDate: entity.expiryDate,
      cardBrand: entity.cardBrand,
    );
  }

  /// Creates a model from JSON.
  factory SavedPaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return SavedPaymentMethodModel(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      maskedNumber: json['maskedNumber'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      addedAt: json['addedAt'] as String,
      lastUsedAt: json['lastUsedAt'] as String?,
      expiryDate: json['expiryDate'] as String?,
      cardBrand: json['cardBrand'] as String?,
    );
  }

  /// Unique identifier.
  final String id;

  /// Payment method type.
  final String type;

  /// Display name.
  final String name;

  /// Masked number for display.
  final String maskedNumber;

  /// Whether this is the default payment method.
  final bool isDefault;

  /// ISO 8601 timestamp when added.
  final String addedAt;

  /// ISO 8601 timestamp when last used.
  final String? lastUsedAt;

  /// Card expiry date if applicable.
  final String? expiryDate;

  /// Card brand if applicable.
  final String? cardBrand;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'maskedNumber': maskedNumber,
        'isDefault': isDefault,
        'addedAt': addedAt,
        if (lastUsedAt != null) 'lastUsedAt': lastUsedAt,
        if (expiryDate != null) 'expiryDate': expiryDate,
        if (cardBrand != null) 'cardBrand': cardBrand,
      };

  /// Converts to domain entity.
  SavedPaymentMethod toEntity() {
    return SavedPaymentMethod(
      id: id,
      type: _parseType(type),
      name: name,
      maskedNumber: maskedNumber,
      isDefault: isDefault,
      addedAt: DateTime.parse(addedAt),
      lastUsedAt: lastUsedAt != null ? DateTime.parse(lastUsedAt!) : null,
      expiryDate: expiryDate,
      cardBrand: cardBrand,
    );
  }

  /// Parses payment method type from string.
  static SavedPaymentMethodType _parseType(String value) {
    switch (value.toLowerCase()) {
      case 'mpesa':
        return SavedPaymentMethodType.mpesa;
      case 'card':
        return SavedPaymentMethodType.card;
      default:
        return SavedPaymentMethodType.mpesa;
    }
  }
}
