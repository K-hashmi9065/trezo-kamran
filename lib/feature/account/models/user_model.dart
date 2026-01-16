class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? photoUrl;
  final String? phone;
  final Map<String, dynamic>? sleepStats;
  final bool isPro;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.photoUrl,
    this.phone,
    this.sleepStats,
    this.isPro = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phone: json['phone'] as String?,
      sleepStats: json['sleepStats'] as Map<String, dynamic>?,
      isPro: json['isPro'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phone': phone,
      'sleepStats': sleepStats,
      'isPro': isPro,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? phone,
    Map<String, dynamic>? sleepStats,
    bool? isPro,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      sleepStats: sleepStats ?? this.sleepStats,
      isPro: isPro ?? this.isPro,
    );
  }
}
