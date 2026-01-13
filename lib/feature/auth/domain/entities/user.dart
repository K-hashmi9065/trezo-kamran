/// User entity representing domain model for authenticated user
class User {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final String? gender;

  const User({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.gender,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl &&
          phoneNumber == other.phoneNumber &&
          gender == other.gender;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      photoUrl.hashCode ^
      phoneNumber.hashCode ^
      gender.hashCode;

  @override
  String toString() {
    return 'User{id: $id, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, gender: $gender}';
  }
}
