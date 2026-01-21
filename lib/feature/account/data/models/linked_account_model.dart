import 'package:cloud_firestore/cloud_firestore.dart';

class LinkedAccount {
  final String id; // Document ID
  final String accountName; // e.g., "Facebook", "Google"
  final String username; // URL like "https://facebook.com/username"
  final String logo; // Logo filename like "facebook.png"
  final bool isConnected;
  final DateTime? connectedAt;

  LinkedAccount({
    required this.id,
    required this.accountName,
    required this.username,
    required this.logo,
    this.isConnected = false,
    this.connectedAt,
  });

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'accountName': accountName,
      'username': username,
      'logo': logo,
      'isConnected': isConnected,
      'connectedAt': connectedAt != null
          ? Timestamp.fromDate(connectedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore
  factory LinkedAccount.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LinkedAccount(
      id: doc.id,
      accountName: data['accountName'] ?? '',
      username: data['username'] ?? '',
      logo: data['logo'] ?? '',
      isConnected: data['isConnected'] ?? false,
      connectedAt: data['connectedAt'] != null
          ? (data['connectedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // CopyWith method for updates
  LinkedAccount copyWith({
    String? id,
    String? accountName,
    String? username,
    String? logo,
    bool? isConnected,
    DateTime? connectedAt,
  }) {
    return LinkedAccount(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      username: username ?? this.username,
      logo: logo ?? this.logo,
      isConnected: isConnected ?? this.isConnected,
      connectedAt: connectedAt ?? this.connectedAt,
    );
  }
}
