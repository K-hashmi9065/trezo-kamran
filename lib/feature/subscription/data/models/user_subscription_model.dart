import 'package:cloud_firestore/cloud_firestore.dart';

class UserSubscription {
  final String id;
  final String planId; // Reference to subscription_plans/{planId}
  final DateTime? subscriptionDate;
  final DateTime? expiryDate;
  final bool isActive;

  UserSubscription({
    required this.id,
    required this.planId,
    this.subscriptionDate,
    this.expiryDate,
    this.isActive = true,
  });

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'subscriptionDate': subscriptionDate != null
          ? Timestamp.fromDate(subscriptionDate!)
          : FieldValue.serverTimestamp(),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'isActive': isActive,
    };
  }

  // Create from Firestore
  factory UserSubscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSubscription(
      id: doc.id,
      planId: data['planId'] ?? '',
      subscriptionDate: data['subscriptionDate'] != null
          ? (data['subscriptionDate'] as Timestamp).toDate()
          : null,
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? false,
    );
  }

  // Format expiry date
  String getFormattedExpiryDate() {
    if (expiryDate == null) return 'No expiry date';
    final date = expiryDate!;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}. ${date.year}';
  }
}
