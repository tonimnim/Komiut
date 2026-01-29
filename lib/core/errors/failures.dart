import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  /// HTTP status code if available.
  final int? statusCode;

  @override
  List<Object> get props => [message, if (statusCode != null) statusCode!];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);
}

class RealtimeFailure extends Failure {
  const RealtimeFailure(super.message);
}

class PaymentFailure extends Failure {
  const PaymentFailure(super.message, {this.transactionId});

  /// Transaction/checkout ID if available.
  final String? transactionId;

  @override
  List<Object> get props => [message, if (transactionId != null) transactionId!];
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
