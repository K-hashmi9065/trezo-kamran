import 'package:hive/hive.dart';
import '../models/user_security_model.dart';

class UserSecurityLocalDataSource {
  final Box<Map<dynamic, dynamic>> _box;

  static const String _lastUserIdKey = 'last_user_id_sec';

  UserSecurityLocalDataSource(this._box);

  String _getSecurityKey(String userId) => 'security_$userId';

  Future<void> saveUserSecurity(
    String userId,
    UserSecurityModel security,
  ) async {
    await _box.put(_getSecurityKey(userId), security.toJson());
    await _box.put(_lastUserIdKey, {'userId': userId});
  }

  Future<UserSecurityModel?> getUserSecurity(String userId) async {
    final data = _box.get(_getSecurityKey(userId));
    if (data != null) {
      return UserSecurityModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<UserSecurityModel?> getLastUserSecurity() async {
    final lastUserMap = _box.get(_lastUserIdKey);
    if (lastUserMap != null && lastUserMap['userId'] != null) {
      final userId = lastUserMap['userId'] as String;
      return getUserSecurity(userId);
    }
    return null;
  }
}
