import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_security_model.dart';

class UserSecurityRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserSecurityRemoteDataSource(this._firestore);

  Future<UserSecurityModel> getUserSecurity(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('security')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserSecurityModel.fromJson(docSnapshot.data()!);
      } else {
        final initial = UserSecurityModel.initial();
        await saveUserSecurity(userId, initial);
        return initial;
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> saveUserSecurity(
    String userId,
    UserSecurityModel security,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('security')
          .set(security.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
