import '../../../../../core/database/app_database.dart';
import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.id,
    required super.userId,
    required super.balance,
    required super.points,
    required super.currency,
  });

  factory WalletModel.fromDatabase(Wallet wallet) {
    return WalletModel(
      id: wallet.id,
      userId: wallet.userId,
      balance: wallet.balance,
      points: wallet.points,
      currency: wallet.currency,
    );
  }
}
