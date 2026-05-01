import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/calculation_result.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/storage_service.dart';
import 'calculation_state.dart';

class CalculationCubit extends Cubit<CalculationState> {
  final StorageService _storageService;
  final _uuid = const Uuid();

  CalculationCubit(this._storageService) : super(const CalculationState()) {
    _loadData();
  }

  void _loadData() {
    final users = _storageService.getUsers();
    final planLimit = _storageService.getPlanLimit();
    final planPrice = _storageService.getPlanPrice();

    emit(
      state.copyWith(
        users: users,
        totalPlanLimit: planLimit,
        planPrice: planPrice,
      ),
    );

    if (users.isNotEmpty && planLimit > 0 && planPrice > 0) {
      calculate();
    }
  }

  void updateGlobalInputs({
    required double planLimit,
    required double planPrice,
  }) {
    emit(state.copyWith(totalPlanLimit: planLimit, planPrice: planPrice));
    _saveGlobalInputs();
    calculate();
  }

  void addUser(String name, double usage) {
    if (usage < 0) {
      emit(
        state.copyWith(error: "Usage cannot be negative", clearError: false),
      );
      return;
    }

    final newUser = UserModel(id: _uuid.v4(), name: name, internetUsage: usage);

    final updatedUsers = List<UserModel>.from(state.users)..add(newUser);
    emit(state.copyWith(users: updatedUsers, clearError: true));
    _saveUsers();
    calculate();
  }

  void updateUser(String id, String newName, double newUsage) {
    if (newUsage < 0) {
      emit(
        state.copyWith(error: "Usage cannot be negative", clearError: false),
      );
      return;
    }

    final updatedUsers = state.users.map((u) {
      if (u.id == id) {
        return u.copyWith(name: newName, internetUsage: newUsage);
      }
      return u;
    }).toList();

    emit(state.copyWith(users: updatedUsers, clearError: true));
    _saveUsers();
    calculate();
  }

  void removeUser(String id) {
    final updatedUsers = state.users.where((u) => u.id != id).toList();
    emit(state.copyWith(users: updatedUsers, clearError: true));
    _saveUsers();
    calculate();
  }

  void resetData() {
    emit(const CalculationState());
    _storageService.clearAll();
  }

  void _saveUsers() {
    _storageService.saveUsers(state.users);
  }

  void _saveGlobalInputs() {
    _storageService.saveGlobalInputs(
      planLimit: state.totalPlanLimit,
      planPrice: state.planPrice,
    );
  }

  void calculate() {
    if (state.users.isEmpty) {
      emit(
        state.copyWith(clearResult: true, clearWarning: true, clearError: true),
      );
      return;
    }

    if (state.planPrice <= 0) {
      emit(
        state.copyWith(
          error: "Plan price must be greater than 0",
          clearResult: true,
          clearWarning: true,
        ),
      );
      return;
    }

    if (state.totalPlanLimit <= 0) {
      emit(
        state.copyWith(
          error: "Plan limit must be greater than 0",
          clearResult: true,
          clearWarning: true,
        ),
      );
      return;
    }

    double totalUsersUsage = 0;
    for (var u in state.users) {
      totalUsersUsage += u.internetUsage;
    }

    final companyUsage = max(0.0, state.totalPlanLimit - totalUsersUsage);

    String? warning;
    if (totalUsersUsage > state.totalPlanLimit) {
      warning =
          "Total users usage (${totalUsersUsage.toStringAsFixed(2)} GB) exceeds the plan limit!";
    }

    final pricePerGB = state.planPrice / totalUsersUsage;

    List<UserCost> userCosts = [];
    final userLimit = totalUsersUsage / state.users.length;
    for (var u in state.users) {
      final cost = (userLimit - u.internetUsage) * pricePerGB;
      userCosts.add(
        UserCost(
          userId: u.id,
          name: u.name,
          usage: u.internetUsage,
          cost: cost,
        ),
      );
    }

    userCosts.sort((a, b) => b.usage.compareTo(a.usage));

    final result = CalculationResult(
      totalUsersUsage: totalUsersUsage,
      companyUsage: companyUsage,
      planLimit: state.totalPlanLimit,
      pricePerGB: pricePerGB,
      userLimit: userLimit,
      userCosts: userCosts,
    );

    emit(
      state.copyWith(
        result: result,
        warning: warning,
        clearError: true,
        clearWarning: warning == null,
      ),
    );
  }
}
