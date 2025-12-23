class WalletEntity {
  final int id;
  final int userId;
  final double balance;
  final int points;
  final String currency;

  const WalletEntity({
    required this.id,
    required this.userId,
    required this.balance,
    required this.points,
    required this.currency,
  });

  String get formattedBalance {
    return '$currency ${balance.toStringAsFixed(2)}';
  }

  String get formattedPoints {
    return '$points pts';
  }
}
