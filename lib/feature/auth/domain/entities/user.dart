/// User entity representing domain model for authenticated user
class User {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const User({required this.id, this.email, this.displayName, this.photoUrl});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode =>
      id.hashCode ^ email.hashCode ^ displayName.hashCode ^ photoUrl.hashCode;

  @override
  String toString() {
    return 'User{id: $id, email: $email, displayName: $displayName, photoUrl: $photoUrl}';
  }
}
