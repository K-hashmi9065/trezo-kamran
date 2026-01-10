// User authentication state provider

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/user_model.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Current user data provider
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        try {
          final data = doc.data()!;
          data['id'] = doc.id;
          return UserModel.fromJson(data);
        } catch (e) {
          // print('Error mapping user data: $e');
          return UserModel(
            id: user.uid,
            email: user.email,
            name: user.displayName,
            photoUrl: user.photoURL,
          );
        }
      });
});

// User profile notifier for managing user data
class UserProfileNotifier extends StateNotifier<UserModel?> {
  UserProfileNotifier() : super(null);

  // Create initial user document
  Future<void> createUserDocument(User firebaseUser) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        final newUser = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName,
          email: firebaseUser.email,
          photoUrl: firebaseUser.photoURL,
          sleepStats: {},
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toJson());
      }
    } catch (e) {
      // print('Error creating user document: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? photoUrl,
    String? phone,
    Map<String, dynamic>? sleepStats,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final updates = {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (phone != null) 'phone': phone,
        if (sleepStats != null) 'sleepStats': sleepStats,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updates);

      // Update state if we have current state
      if (state != null) {
        state = state!.copyWith(
          name: name,
          email: email,
          photoUrl: photoUrl,
          phone: phone,
          sleepStats: sleepStats,
        );
      }
    } catch (e) {
      // print('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      state = null;
    } catch (e) {
      // print('Error signing out: $e');
      rethrow;
    }
  }
}

// User profile state notifier provider
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserModel?>((ref) {
      return UserProfileNotifier();
    });
