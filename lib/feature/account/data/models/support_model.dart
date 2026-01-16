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
  final String
  type; // 'whatsapp', 'email', 'phone', 'web', 'facebook', 'instagram', 'twitter'
  final int order;

  SupportChannel({
    required this.id,
    required this.title,
    this.value,
    this.type = 'web',
    this.order = 0,
  });

  factory SupportChannel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportChannel(
      id: doc.id,
      title: data['title'] ?? data['name'] ?? '',
      value: data['value'] ?? data['url'],
      type: data['type'] ?? 'web',
      order: data['order'] ?? 0,
    );
  }
}
