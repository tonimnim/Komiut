/// Wallet domain entities.
///
/// Contains the core wallet and transaction domain models.
library;

/// Transaction types for wallet operations.
enum TransactionType {
  topup,
  payment,
  refund,
  bonus,
}

/// Extension methods for TransactionType.
extension TransactionTypeExtension on TransactionType {
  /// Human-readable label for the transaction type.
  String get label {
    switch (this) {
      case TransactionType.topup:
        return 'Top Up';
      case TransactionType.payment:
        return 'Payment';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.bonus:
        return 'Bonus';
    }
  }

  /// Whether this transaction adds money to wallet.
  bool get isCredit {
    switch (this) {
      case TransactionType.topup:
      case TransactionType.refund:
      case TransactionType.bonus:
        return true;
      case TransactionType.payment:
        return false;
    }
  }
}

/// Wallet transaction entity.
///
/// Represents a single wallet transaction (top-up, payment, refund, or bonus).
class WalletTransaction {
  /// Creates a wallet transaction.
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.reference,
    this.description,
    required this.timestamp,
  });

  /// Unique identifier for this transaction.
  final String id;

  /// Type of transaction.
  final TransactionType type;

  /// Transaction amount (always positive).
  final double amount;

  /// Wallet balance after this transaction.
  final double balanceAfter;

  /// External reference (e.g., M-Pesa receipt).
  final String? reference;

  /// Human-readable description.
  final String? description;

  /// When the transaction occurred.
  final DateTime timestamp;

  /// Whether this transaction is a credit (adds to balance).
  bool get isCredit => type.isCredit;

  /// Whether this transaction is a debit (subtracts from balance).
  bool get isDebit => !type.isCredit;

  /// Formatted amount with sign.
  String get signedAmount {
    final sign = isCredit ? '+' : '-';
    return '$sign KES ${amount.toStringAsFixed(0)}';
  }

  /// Formatted amount without sign.
  String get formattedAmount => 'KES ${amount.toStringAsFixed(0)}';

  /// Display label based on type.
  String get displayLabel => description ?? type.label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Wallet entity representing user's digital wallet.
class WalletEntity {
  /// Creates a wallet entity.
  const WalletEntity({
    required this.id,
    required this.userId,
    required this.balance,
    required this.points,
    required this.currency,
    this.lastUpdated,
    this.recentTransactions,
  });

  /// Unique wallet identifier.
  final int id;

  /// User ID who owns this wallet.
  final int userId;

  /// Current wallet balance.
  final double balance;

  /// Loyalty/reward points.
  final int points;

  /// Currency code (e.g., KES).
  final String currency;

  /// When the wallet was last updated.
  final DateTime? lastUpdated;

  /// Recent transactions (if loaded).
  final List<WalletTransaction>? recentTransactions;

  /// Formatted balance with currency.
  String get formattedBalance {
    return '$currency ${balance.toStringAsFixed(2)}';
  }

  /// Formatted balance short (no decimals).
  String get formattedBalanceShort {
    return '$currency ${balance.toStringAsFixed(0)}';
  }

  /// Formatted points.
  String get formattedPoints {
    return '$points pts';
  }

  /// Whether the wallet has sufficient balance for an amount.
  bool hasSufficientBalance(double amount) => balance >= amount;

  /// Create a copy with updated fields.
  WalletEntity copyWith({
    int? id,
    int? userId,
    double? balance,
    int? points,
    String? currency,
    DateTime? lastUpdated,
    List<WalletTransaction>? recentTransactions,
  }) {
    return WalletEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      points: points ?? this.points,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      recentTransactions: recentTransactions ?? this.recentTransactions,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
