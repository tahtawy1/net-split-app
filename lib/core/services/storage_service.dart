import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class StorageService {
  static const String _boxName = 'appDataBox';
  static const String _usersKey = 'usersList';
  static const String _planLimitKey = 'planLimit';
  static const String _planPriceKey = 'planPrice';

  Box? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    try {
      _box = await Hive.openBox(_boxName);
    } catch (e) {
      debugPrint('Hive init error: $e');
      try {
        final documentsDir = Directory(
          '${Platform.environment['USERPROFILE']}\\Documents',
        );
        final lockFile = File('${documentsDir.path}\\$_boxName.lock');
        if (await lockFile.exists()) {
          await lockFile.delete();
        }
        _box = await Hive.openBox(_boxName);
      } catch (e2) {
        debugPrint('Hive retry failed: $e2');
      }
    }
  }

  Future<void> saveUsers(List<UserModel> users) async {
    await _box?.put(_usersKey, users);
  }

  List<UserModel> getUsers() {
    final data = _box?.get(_usersKey);
    if (data != null) {
      try {
        return List<UserModel>.from(data.cast<UserModel>());
      } catch (e) {
        debugPrint('Error reading users: $e');
        return [];
      }
    }
    return [];
  }

  Future<void> saveGlobalInputs({
    required double planLimit,
    required double planPrice,
  }) async {
    await _box?.put(_planLimitKey, planLimit);
    await _box?.put(_planPriceKey, planPrice);
  }

  double getPlanLimit() => _box?.get(_planLimitKey, defaultValue: 0.0) ?? 0.0;
  double getPlanPrice() => _box?.get(_planPriceKey, defaultValue: 0.0) ?? 0.0;

  Future<void> clearAll() async {
    await _box?.clear();
  }
}
