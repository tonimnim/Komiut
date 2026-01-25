/// Saved payment method entity.
///
/// Represents a saved payment method for the passenger.
/// Includes M-Pesa numbers, cards, and other payment options.
library;

import 'package:equatable/equatable.dart';

/// Types of saved payment methods.
enum SavedPaymentMethodType {
  /// M-Pesa mobile money number.
  mpesa,

  /// Credit or debit card.
  card,
}

/// Extension to convert SavedPaymentMethodType to display string.
extension SavedPaymentMethodTypeX on SavedPaymentMethodType {
  /// Returns a human-readable label for the payment method type.
  String get label {
    switch (this) {
      case SavedPaymentMethodType.mpesa:
        return 'M-Pesa';
      case SavedPaymentMethodType.card:
        return 'Card';
    }
  }

  /// Returns an icon name for the payment method type.
  String get iconName {
    switch (this) {
      case SavedPaymentMethodType.mpesa:
        return 'phone_android';
      case SavedPaymentMethodType.card:
        return 'credit_card';
    }
  }
}

/// Saved payment method entity.
///
/// Represents a payment method saved by the passenger for quick payments.
/// Supports M-Pesa numbers and cards with appropriate masking for security.
class SavedPaymentMethod extends Equatable {
  /// Creates a saved payment method instance.
  const SavedPaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.maskedNumber,
    this.isDefault = false,
    required this.addedAt,
    this.lastUsedAt,
    this.expiryDate,
    this.cardBrand,
  });

  /// Creates an M-Pesa payment method.
  factory SavedPaymentMethod.mpesa({
    required String id,
    required String phoneNumber,
    String? name,
    bool isDefault = false,
    DateTime? addedAt,
  }) {
    // Mask phone number: 07XX XXX XXX -> 07** *** **X
    final masked = _maskPhoneNumber(phoneNumber);
    return SavedPaymentMethod(
      id: id,
      type: SavedPaymentMethodType.mpesa,
      name: name ?? 'M-Pesa',
      maskedNumber: masked,
      isDefault: isDefault,
      addedAt: addedAt ?? DateTime.now(),
    );
  }

  /// Creates a card payment method.
  factory SavedPaymentMethod.card({
    required String id,
    required String lastFourDigits,
    required String cardBrand,
    String? name,
    bool isDefault = false,
    DateTime? addedAt,
    String? expiryDate,
  }) {
    return SavedPaymentMethod(
      id: id,
      type: SavedPaymentMethodType.card,
      name: name ?? '$cardBrand ending in $lastFourDigits',
      maskedNumber: '**** **** **** $lastFourDigits',
      isDefault: isDefault,
      addedAt: addedAt ?? DateTime.now(),
      expiryDate: expiryDate,
      cardBrand: cardBrand,
    );
  }

  /// Unique identifier for this saved payment method.
  final String id;

  /// Type of payment method (M-Pesa or card).
  final SavedPaymentMethodType type;

  /// Display name for the payment method.
  final String name;

  /// Masked number for display (phone number or card number).
  final String maskedNumber;

  /// Whether this is the default payment method.
  final bool isDefault;

  /// When the payment method was added.
  final DateTime addedAt;

  /// When the payment method was last used.
  final DateTime? lastUsedAt;

  /// Card expiry date (MM/YY format) if applicable.
  final String? expiryDate;

  /// Card brand (Visa, Mastercard, etc.) if applicable.
  final String? cardBrand;

  /// Returns true if this is an M-Pesa payment method.
  bool get isMpesa => type == SavedPaymentMethodType.mpesa;

  /// Returns true if this is a card payment method.
  bool get isCard => type == SavedPaymentMethodType.card;

  /// Returns a short display string for the payment method.
  String get shortDisplay {
    if (isMpesa) {
      return maskedNumber;
    } else {
      return '${cardBrand ?? 'Card'} *$maskedNumber'.split('*').last.trim();
    }
  }

  /// Creates a copy with modified fields.
  SavedPaymentMethod copyWith({
    String? id,
    SavedPaymentMethodType? type,
    String? name,
    String? maskedNumber,
    bool? isDefault,
    DateTime? addedAt,
    DateTime? lastUsedAt,
    String? expiryDate,
    String? cardBrand,
  }) {
    return SavedPaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      maskedNumber: maskedNumber ?? this.maskedNumber,
      isDefault: isDefault ?? this.isDefault,
      addedAt: addedAt ?? this.addedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      cardBrand: cardBrand ?? this.cardBrand,
    );
  }

  /// Marks the payment method as used.
  SavedPaymentMethod markAsUsed() {
    return copyWith(lastUsedAt: DateTime.now());
  }

  /// Sets this as the default payment method.
  SavedPaymentMethod setAsDefault() {
    return copyWith(isDefault: true);
  }

  /// Removes default status from this payment method.
  SavedPaymentMethod removeDefault() {
    return copyWith(isDefault: false);
  }

  /// Masks a phone number for display.
  static String _maskPhoneNumber(String phone) {
    // Remove any non-digit characters
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 4) return phone;

    // Keep first 2 and last 1 digit visible
    final visible = digits.substring(0, 2);
    final lastDigit = digits.substring(digits.length - 1);
    final maskedLength = digits.length - 3;
    final masked = '*' * maskedLength;

    return '$visible$masked$lastDigit';
  }

  @override
  List<Object?> get props => [
        id,
        type,
        name,
        maskedNumber,
        isDefault,
        addedAt,
        lastUsedAt,
        expiryDate,
        cardBrand,
      ];
}
