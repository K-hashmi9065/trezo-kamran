import 'package:hive/hive.dart';
import '../models/user_appearance_model.dart';

class UserAppearanceLocalDataSource {
  final Box<Map<dynamic, dynamic>> _box;

  // Key to store the ID of the last active user to load their prefs on start
  static const String _lastUserIdKey = 'last_user_id';

  UserAppearanceLocalDataSource(this._box);

  String _getAppearanceKey(String userId) => 'appearance_$userId';

  Future<void> saveUserAppearance(
    String userId,
    UserAppearanceModel appearance,
  ) async {
    await _box.put(_getAppearanceKey(userId), appearance.toJson());
    // Also save as last active user
    await _box.put(_lastUserIdKey, {'userId': userId});
  }

  Future<UserAppearanceModel?> getUserAppearance(String userId) async {
    final data = _box.get(_getAppearanceKey(userId));
    if (data != null) {
      return UserAppearanceModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  /// Try to load appearance for the last active user (for app start)
  Future<UserAppearanceModel?> getLastUserAppearance() async {
    final lastUserMap = _box.get(_lastUserIdKey);
    if (lastUserMap != null && lastUserMap['userId'] != null) {
      final userId = lastUserMap['userId'] as String;
      return getUserAppearance(userId);
    }
    return null;
  }
}
