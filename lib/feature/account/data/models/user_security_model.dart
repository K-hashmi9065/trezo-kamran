import '../../domain/entities/user_security.dart';

class UserSecurityModel extends UserSecurity {
  const UserSecurityModel({
    required super.isBiometricIdEnabled,
    required super.isFaceIdEnabled,
    required super.isSmsAuthenticatorEnabled,
    required super.isGoogleAuthenticatorEnabled,
    required super.updatedAt,
  });

  factory UserSecurityModel.fromJson(Map<String, dynamic> json) {
    return UserSecurityModel(
      isBiometricIdEnabled: json['isBiometricIdEnabled'] as bool? ?? false,
      isFaceIdEnabled: json['isFaceIdEnabled'] as bool? ?? false,
      isSmsAuthenticatorEnabled:
          json['isSmsAuthenticatorEnabled'] as bool? ?? false,
      isGoogleAuthenticatorEnabled:
          json['isGoogleAuthenticatorEnabled'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  factory UserSecurityModel.fromEntity(UserSecurity security) {
    return UserSecurityModel(
      isBiometricIdEnabled: security.isBiometricIdEnabled,
      isFaceIdEnabled: security.isFaceIdEnabled,
      isSmsAuthenticatorEnabled: security.isSmsAuthenticatorEnabled,
      isGoogleAuthenticatorEnabled: security.isGoogleAuthenticatorEnabled,
      updatedAt: security.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isBiometricIdEnabled': isBiometricIdEnabled,
      'isFaceIdEnabled': isFaceIdEnabled,
      'isSmsAuthenticatorEnabled': isSmsAuthenticatorEnabled,
      'isGoogleAuthenticatorEnabled': isGoogleAuthenticatorEnabled,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserSecurityModel.initial() {
    return UserSecurityModel(
      isBiometricIdEnabled: false,
      isFaceIdEnabled: false,
      isSmsAuthenticatorEnabled: false,
      isGoogleAuthenticatorEnabled: false,
      updatedAt: DateTime.now(),
    );
  }
}
