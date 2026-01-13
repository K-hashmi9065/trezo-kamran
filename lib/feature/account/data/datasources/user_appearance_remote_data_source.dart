import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_appearance_model.dart';

class UserAppearanceRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserAppearanceRemoteDataSource(this._firestore);

  Future<UserAppearanceModel> getUserAppearance(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserAppearanceModel.fromJson(docSnapshot.data()!);
      } else {
        final initial = UserAppearanceModel.initial();
        await saveUserAppearance(userId, initial);
        return initial;
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> saveUserAppearance(
    String userId,
    UserAppearanceModel appearance,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .set(appearance.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
