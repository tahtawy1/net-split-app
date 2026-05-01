import 'package:equatable/equatable.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/calculation_result.dart';

class CalculationState extends Equatable {
  final double totalPlanLimit;
  final double planPrice;
  final List<UserModel> users;
  final CalculationResult? result;
  final String? error;
  final String? warning;

  const CalculationState({
    this.totalPlanLimit = 0.0,
    this.planPrice = 0.0,
    this.users = const [],
    this.result,
    this.error,
    this.warning,
  });

  CalculationState copyWith({
    double? totalPlanLimit,
    double? planPrice,
    List<UserModel>? users,
    CalculationResult? result,
    String? error,
    String? warning,
    bool clearResult = false,
    bool clearError = false,
    bool clearWarning = false,
  }) {
    return CalculationState(
      totalPlanLimit: totalPlanLimit ?? this.totalPlanLimit,
      planPrice: planPrice ?? this.planPrice,
      users: users ?? this.users,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
      warning: clearWarning ? null : (warning ?? this.warning),
    );
  }

  @override
  List<Object?> get props => [
    totalPlanLimit,
    planPrice,
    users,
    result,
    error,
    warning,
  ];
}
