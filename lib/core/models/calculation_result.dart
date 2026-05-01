import 'package:equatable/equatable.dart';

class UserCost extends Equatable {
  final String userId;
  final String name;
  final double usage;
  final double cost;

  const UserCost({
    required this.userId,
    required this.name,
    required this.usage,
    required this.cost,
  });

  @override
  List<Object?> get props => [userId, name, usage, cost];
}

class CalculationResult extends Equatable {
  final double totalUsersUsage;
  final double companyUsage;
  final double planLimit;
  final double pricePerGB;
  final double userLimit;
  final List<UserCost> userCosts;

  const CalculationResult({
    required this.totalUsersUsage,
    required this.companyUsage,
    required this.planLimit,
    required this.pricePerGB,
    required this.userLimit,
    required this.userCosts,
  });

  @override
  List<Object?> get props => [
    totalUsersUsage,
    companyUsage,
    planLimit,
    pricePerGB,
    userLimit,
    userCosts,
  ];
}
