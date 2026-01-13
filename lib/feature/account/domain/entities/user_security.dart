import 'package:equatable/equatable.dart';

class UserSecurity extends Equatable {
  final bool isBiometricIdEnabled;
  final bool isFaceIdEnabled;
  final bool isSmsAuthenticatorEnabled;
  final bool isGoogleAuthenticatorEnabled;
  final DateTime updatedAt;

  const UserSecurity({
    required this.isBiometricIdEnabled,
    required this.isFaceIdEnabled,
    required this.isSmsAuthenticatorEnabled,
    required this.isGoogleAuthenticatorEnabled,
    required this.updatedAt,
  });

  UserSecurity copyWith({
    bool? isBiometricIdEnabled,
    bool? isFaceIdEnabled,
    bool? isSmsAuthenticatorEnabled,
    bool? isGoogleAuthenticatorEnabled,
    DateTime? updatedAt,
  }) {
    return UserSecurity(
      isBiometricIdEnabled: isBiometricIdEnabled ?? this.isBiometricIdEnabled,
      isFaceIdEnabled: isFaceIdEnabled ?? this.isFaceIdEnabled,
      isSmsAuthenticatorEnabled:
          isSmsAuthenticatorEnabled ?? this.isSmsAuthenticatorEnabled,
      isGoogleAuthenticatorEnabled:
          isGoogleAuthenticatorEnabled ?? this.isGoogleAuthenticatorEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    isBiometricIdEnabled,
    isFaceIdEnabled,
    isSmsAuthenticatorEnabled,
    isGoogleAuthenticatorEnabled,
    updatedAt,
  ];
}
