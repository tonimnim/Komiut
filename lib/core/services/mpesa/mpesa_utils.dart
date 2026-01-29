/// M-Pesa utility functions.
///
/// Contains phone number validation and formatting for Kenyan mobile numbers.
/// Supports Safaricom (07XX, 01XX) and all valid Kenyan formats.
library;

/// M-Pesa phone number utilities.
///
/// Handles validation and formatting of Kenyan phone numbers
/// for M-Pesa STK Push transactions.
class MpesaUtils {
  const MpesaUtils._();

  // ─────────────────────────────────────────────────────────────────────────
  // Constants
  // ─────────────────────────────────────────────────────────────────────────

  /// Kenya country code.
  static const String kenyaCountryCode = '254';

  /// STK Push timeout in seconds.
  static const int stkPushTimeoutSeconds = 30;

  /// Status polling interval in seconds.
  static const int statusPollIntervalSeconds = 3;

  /// Maximum number of status poll attempts.
  static const int maxPollAttempts = 10;

  /// Minimum M-Pesa transaction amount in KES.
  static const double minAmount = 1.0;

  /// Maximum M-Pesa transaction amount in KES.
  static const double maxAmount = 150000.0;

  // ─────────────────────────────────────────────────────────────────────────
  // Phone Number Validation
  // ─────────────────────────────────────────────────────────────────────────

  /// Regular expression for valid Kenyan phone number formats.
  ///
  /// Matches:
  /// - +254XXXXXXXXX (international format with +)
  /// - 254XXXXXXXXX (international format without +)
  /// - 07XXXXXXXX (local Safaricom format)
  /// - 01XXXXXXXX (local Safaricom format)
  /// - 7XXXXXXXX (without leading 0)
  /// - 1XXXXXXXX (without leading 0)
  static final RegExp _phoneRegex = RegExp(
    r'^(?:\+?254|0)?([17]\d{8})$',
  );

  /// Validates a Kenyan phone number.
  ///
  /// Returns `true` if the phone number is valid for M-Pesa transactions.
  ///
  /// Valid formats:
  /// - +254712345678
  /// - 254712345678
  /// - 0712345678
  /// - 712345678
  /// - 0112345678 (Safaricom 011X numbers)
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return false;

    // Remove spaces, dashes, and parentheses
    final cleaned = _cleanPhoneNumber(phone);

    return _phoneRegex.hasMatch(cleaned);
  }

  /// Formats a phone number to M-Pesa API format (254XXXXXXXXX).
  ///
  /// Takes any valid Kenyan phone format and converts to 254XXXXXXXXX.
  /// Returns `null` if the phone number is invalid.
  ///
  /// Examples:
  /// - +254712345678 -> 254712345678
  /// - 0712345678 -> 254712345678
  /// - 712345678 -> 254712345678
  static String? formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return null;

    // Remove spaces, dashes, and parentheses
    final cleaned = _cleanPhoneNumber(phone);

    // Match and extract the local number
    final match = _phoneRegex.firstMatch(cleaned);
    if (match == null) return null;

    // Extract the 9-digit local number (without country code or leading 0)
    final localNumber = match.group(1);
    if (localNumber == null) return null;

    // Return in 254XXXXXXXXX format
    return '$kenyaCountryCode$localNumber';
  }

  /// Cleans a phone number by removing formatting characters.
  static String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
  }

  /// Validates a phone number and returns an error message if invalid.
  ///
  /// Returns `null` if the phone number is valid.
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }

    final cleaned = _cleanPhoneNumber(phone);

    if (cleaned.length < 9) {
      return 'Phone number is too short';
    }

    if (cleaned.length > 13) {
      return 'Phone number is too long';
    }

    if (!isValidPhoneNumber(cleaned)) {
      return 'Please enter a valid Kenyan phone number';
    }

    return null;
  }

  /// Masks a phone number for display (e.g., 254712****78).
  ///
  /// Shows first 6 and last 2 digits, masks the middle.
  static String maskPhoneNumber(String phone) {
    final formatted = formatPhoneNumber(phone);
    if (formatted == null || formatted.length < 12) return phone;

    return '${formatted.substring(0, 6)}****${formatted.substring(10)}';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Amount Validation
  // ─────────────────────────────────────────────────────────────────────────

  /// Validates an M-Pesa transaction amount.
  ///
  /// Returns `null` if the amount is valid, otherwise returns an error message.
  static String? validateAmount(double? amount) {
    if (amount == null) {
      return 'Amount is required';
    }

    if (amount < minAmount) {
      return 'Minimum amount is KES ${minAmount.toStringAsFixed(0)}';
    }

    if (amount > maxAmount) {
      return 'Maximum amount is KES ${maxAmount.toStringAsFixed(0)}';
    }

    return null;
  }

  /// Validates an amount from string input.
  static String? validateAmountString(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    return validateAmount(amount);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Formatting Utilities
  // ─────────────────────────────────────────────────────────────────────────

  /// Formats an amount for display in KES.
  static String formatAmount(double amount) {
    return 'KES ${amount.toStringAsFixed(2)}';
  }

  /// Generates a unique account reference for a transaction.
  ///
  /// Format: KOMIUT-{timestamp}-{suffix}
  static String generateAccountReference([String? suffix]) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = 'KOMIUT-$timestamp';
    return suffix != null ? '$ref-$suffix' : ref;
  }

  /// Creates a transaction description for STK Push.
  static String createTransactionDescription({
    required String purpose,
    String? routeName,
    String? bookingId,
  }) {
    final parts = <String>[purpose];

    if (routeName != null) {
      parts.add('for $routeName');
    }

    if (bookingId != null) {
      parts.add('(Ref: $bookingId)');
    }

    return parts.join(' ');
  }
}

/// Extension methods for String phone number handling.
extension PhoneNumberStringExtensions on String {
  /// Validates this string as a Kenyan phone number.
  bool get isValidKenyanPhone => MpesaUtils.isValidPhoneNumber(this);

  /// Formats this string to M-Pesa API format.
  String? get toMpesaFormat => MpesaUtils.formatPhoneNumber(this);

  /// Masks this phone number for display.
  String get maskedPhone => MpesaUtils.maskPhoneNumber(this);
}
