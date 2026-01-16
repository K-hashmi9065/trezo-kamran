import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart';

/// User data model extending domain entity
class UserModel extends User {
  const UserModel({
    required super.id,
    super.email,
    super.displayName,
    super.photoUrl,
    super.phoneNumber,
    super.gender,
    super.isPro,
  });

  /// Create UserModel from Firebase User
  factory UserModel.fromFirebase(firebase_auth.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      isPro: false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'isPro': isPro,
    };
  }

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: (json['phoneNumber'] ?? json['phone']) as String?,
      gender: json['gender'] as String?,
      isPro: json['isPro'] as bool? ?? false,
    );
  }

  /// Convert UserModel to User entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      gender: gender,
      isPro: isPro,
    );
  }
}
