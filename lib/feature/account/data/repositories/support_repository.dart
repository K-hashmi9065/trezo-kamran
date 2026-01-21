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
      // First try to get channels from the support_menu/contact_support/channels subcollection
      try {
        final snapshot = await _firestore
            .collection('support_menu')
            .doc('contact_support')
            .collection('channels')
            .get();

        if (snapshot.docs.isNotEmpty) {
          final channels = snapshot.docs
              .map((doc) => SupportChannel.fromFirestore(doc))
              .toList();
          // Sort by order if available
          channels.sort((a, b) => a.order.compareTo(b.order));
          return channels;
        }
      } catch (e) {
        // If subcollection doesn't exist or has issues, continue to fallback
        print('Error fetching from channels subcollection: $e');
      }

      // If no channels found in subcollection, try the customer_support collection
      final customerSupportSnapshot = await _firestore
          .collection('customer_support')
          .get();

      if (customerSupportSnapshot.docs.isNotEmpty) {
        final channels = customerSupportSnapshot.docs
            .map((doc) => SupportChannel.fromFirestore(doc))
            .toList();
        // Sort by order if available
        channels.sort((a, b) => a.order.compareTo(b.order));
        return channels;
      }

      return [];
    } catch (e) {
      // Log error for debugging
      print('Error fetching contact channels: $e');
      return [];
    }
  }

  // Fetch privacy policy content
  Future<PrivacyPolicyContent> getPrivacyPolicyContent() async {
    try {
      // Get all documents from the content subcollection
      final sectionsSnapshot = await _firestore
          .collection('support_menu')
          .doc('privacy_policy')
          .collection('content')
          .get();

      String effectiveDate = '';
      final sectionDocs = <PrivacyPolicySection>[];

      // Process each document
      for (final doc in sectionsSnapshot.docs) {
        if (doc.id == 'effective_date') {
          // Read effective date from the title field of this document
          final data = doc.data();
          effectiveDate = data['title'] ?? '';
        } else {
          // Regular section document
          final section = PrivacyPolicySection.fromFirestore(doc);
          // Only add if it has valid title and body
          if (section.title.isNotEmpty && section.body.isNotEmpty) {
            sectionDocs.add(section);
          }
        }
      }

      // Sort sections by order
      sectionDocs.sort((a, b) => a.order.compareTo(b.order));

      return PrivacyPolicyContent(
        effectiveDate: effectiveDate,
        sections: sectionDocs,
      );
    } catch (e) {
      print('Error fetching privacy policy: $e');
      return PrivacyPolicyContent(effectiveDate: '', sections: []);
    }
  }

  // Fetch terms of service content
  Future<TermsOfServiceContent> getTermsOfServiceContent() async {
    try {
      // Get all documents from the content subcollection
      final sectionsSnapshot = await _firestore
          .collection('support_menu')
          .doc('terms_of_service')
          .collection('content')
          .get();

      String effectiveDate = '';
      final sectionDocs = <TermsOfServiceSection>[];

      // Process each document
      for (final doc in sectionsSnapshot.docs) {
        if (doc.id == 'effective_date') {
          // Read effective date from the title field of this document
          final data = doc.data();
          effectiveDate = data['title'] ?? '';
        } else {
          // Regular section document
          final section = TermsOfServiceSection.fromFirestore(doc);
          // Only add if it has valid title and body
          if (section.title.isNotEmpty && section.body.isNotEmpty) {
            sectionDocs.add(section);
          }
        }
      }

      // Sort sections by order
      sectionDocs.sort((a, b) => a.order.compareTo(b.order));

      return TermsOfServiceContent(
        effectiveDate: effectiveDate,
        sections: sectionDocs,
      );
    } catch (e) {
      print('Error fetching terms of service: $e');
      return TermsOfServiceContent(effectiveDate: '', sections: []);
    }
  }

  // Fetch FAQ content
  Future<FaqContent> getFaqContent() async {
    try {
      final snapshot = await _firestore
          .collection('support_menu')
          .doc('faq')
          .collection('questions')
          .get();

      final items = snapshot.docs
          .map((doc) => FaqItem.fromFirestore(doc))
          .where((item) => item.question.isNotEmpty && item.answer.isNotEmpty)
          .toList();

      // Sort by order
      items.sort((a, b) => a.order.compareTo(b.order));

      return FaqContent(items: items);
    } catch (e) {
      print('Error fetching FAQ: $e');
      return FaqContent(items: []);
    }
  }
}

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository(FirebaseFirestore.instance);
});
