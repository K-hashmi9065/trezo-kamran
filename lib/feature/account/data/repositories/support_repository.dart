import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/support_model.dart';

class SupportRepository {
  final FirebaseFirestore _firestore;

  SupportRepository(this._firestore);

  // Fetch main menu items
  Future<List<SupportMenuItem>> getSupportMenuItems() async {
    try {
      final snapshot = await _firestore
          .collection('support_menu')
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => SupportMenuItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch support menu: $e');
    }
  }

  // Fetch contact channels subcollection
  Future<List<SupportChannel>> getContactChannels() async {
    try {
      // Assuming 'contact_support' is the ID of the document.
      // If the ID isn't fixed, we might need to query for it or pass it.
      // Based on screenshot, the ID is 'contact_support'.
      final snapshot = await _firestore
          .collection('support_menu')
          .doc('contact_support')
          .collection('channels')
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => SupportChannel.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Optional: Log error
      // If collection doesn't exist, this might return empty or throw.
      // We'll try to find any document with channels if 'contact_support' ID isn't guaranteed,
      // but 'contact_support' is the most likely ID given the screenshot.
      return [];
    }
  }
}

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository(FirebaseFirestore.instance);
});
