import 'package:cloud_firestore/cloud_firestore.dart';

class SupportMenuItem {
  final String id;
  final String title;
  final int order;
  final String? url;
  final String? type; // 'link', 'page', 'action'

  SupportMenuItem({
    required this.id,
    required this.title,
    required this.order,
    this.url,
    this.type,
  });

  factory SupportMenuItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportMenuItem(
      id: doc.id,
      title: data['title'] ?? '',
      order: data['order'] ?? 0,
      url: data['url'],
      type: data['type'],
    );
  }
}

class SupportChannel {
  final String id;
  final String title;
  final String? value; // URL, phone number, email
  final String? icon; // Icon name/identifier from Firebase
  final String
  type; // 'whatsapp', 'email', 'phone', 'web', 'facebook', 'instagram', 'twitter'
  final int order;

  SupportChannel({
    required this.id,
    required this.title,
    this.value,
    this.icon,
    this.type = 'web',
    this.order = 0,
  });

  factory SupportChannel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle order as either string or number
    int order = 0;
    final orderData = data['order'];
    if (orderData is int) {
      order = orderData;
    } else if (orderData is String) {
      order = int.tryParse(orderData) ?? 0;
    }

    return SupportChannel(
      id: doc.id,
      title: data['title'] ?? data['name'] ?? '',
      value: data['value'] ?? data['url'] ?? data['link'],
      icon: data['icon'],
      type: data['type'] ?? 'web',
      order: order,
    );
  }
}

class PrivacyPolicyContent {
  final String effectiveDate;
  final List<PrivacyPolicySection> sections;

  PrivacyPolicyContent({required this.effectiveDate, required this.sections});
}

class PrivacyPolicySection {
  final String id;
  final String title;
  final String body;
  final int order;

  PrivacyPolicySection({
    required this.id,
    required this.title,
    required this.body,
    required this.order,
  });

  factory PrivacyPolicySection.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle order as either string or number
    int order = 0;
    final orderData = data['order'];
    if (orderData is int) {
      order = orderData;
    } else if (orderData is String) {
      order = int.tryParse(orderData) ?? 0;
    }

    return PrivacyPolicySection(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      order: order,
    );
  }
}

class TermsOfServiceContent {
  final String effectiveDate;
  final List<TermsOfServiceSection> sections;

  TermsOfServiceContent({required this.effectiveDate, required this.sections});
}

class TermsOfServiceSection {
  final String id;
  final String title;
  final String body;
  final int order;

  TermsOfServiceSection({
    required this.id,
    required this.title,
    required this.body,
    required this.order,
  });

  factory TermsOfServiceSection.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle order as either string or number
    int order = 0;
    final orderData = data['order'];
    if (orderData is int) {
      order = orderData;
    } else if (orderData is String) {
      order = int.tryParse(orderData) ?? 0;
    }

    return TermsOfServiceSection(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      order: order,
    );
  }
}
