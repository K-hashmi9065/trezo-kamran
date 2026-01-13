import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_profile_remote_data_source.dart';

/// Provider for UserProfileRemoteDataSource
/// Uses FirebaseFirestore and FirebaseAuth
final userProfileRemoteDataSourceProvider =
    Provider<UserProfileRemoteDataSource>((ref) {
      return UserProfileRemoteDataSource(
        FirebaseFirestore.instance,
        FirebaseAuth.instance,
      );
    });
