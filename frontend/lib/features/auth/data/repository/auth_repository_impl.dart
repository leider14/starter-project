import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AuthRepositoryImpl(this._firebaseAuth, this._firestore, this._storage);

  @override
  Future<DataState<UserEntity>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          return DataSuccess(UserEntity(
            uid: user.uid,
            email: user.email,
            fullName: data['fullName'],
            bio: data['bio'],
            photoUrl: data['photoUrl'],
          ));
        }
      }
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: 'auth/current_user'),
        error: 'No user logged in',
      ));
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: 'auth/current_user'),
        error: e.toString(),
      ));
    }
  }

  @override
  Future<DataState<UserEntity>> signIn(
      {required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = credential.user!;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data()!;

      return DataSuccess(UserEntity(
        uid: user.uid,
        email: user.email,
        fullName: data['fullName'],
        bio: data['bio'],
        photoUrl: data['photoUrl'],
      ));
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: 'auth/signin'),
        error: e.toString(),
      ));
    }
  }

  @override
  Future<DataState<UserEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? bio,
    File? image,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = credential.user!;

      String? photoUrl;
      if (image != null) {
        final ref = _storage.ref().child('users/${user.uid}/profile.jpg');
        await ref.putFile(image);
        photoUrl = await ref.getDownloadURL();
      }

      final userData = {
        'fullName': fullName,
        'bio': bio ?? '',
        'photoUrl': photoUrl ?? '',
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(userData);

      return DataSuccess(UserEntity(
        uid: user.uid,
        email: email,
        fullName: fullName,
        bio: bio,
        photoUrl: photoUrl,
      ));
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: 'auth/signup'),
        error: e.toString(),
      ));
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<DataState<UserEntity>> updateProfile(
      {String? fullName, String? bio, File? image}) async {
    try {
      final user = _firebaseAuth.currentUser!;
      final Map<String, dynamic> updates = {};

      if (fullName != null) updates['fullName'] = fullName;
      if (bio != null) updates['bio'] = bio;

      if (image != null) {
        final ref = _storage.ref().child('users/${user.uid}/profile.jpg');
        await ref.putFile(image);
        updates['photoUrl'] = await ref.getDownloadURL();
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data()!;

      return DataSuccess(UserEntity(
        uid: user.uid,
        email: user.email,
        fullName: data['fullName'],
        bio: data['bio'],
        photoUrl: data['photoUrl'],
      ));
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: 'auth/update_profile'),
        error: e.toString(),
      ));
    }
  }

  @override
  Future<DataState<UserEntity>> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return DataSuccess(UserEntity(
          uid: userId,
          email: data['email'],
          fullName: data['fullName'],
          bio: data['bio'],
          photoUrl: data['photoUrl'],
        ));
      }
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: 'auth/get_user'),
        error: 'User not found',
      ));
    } catch (e) {
      return DataFailed(DioException(
        requestOptions: RequestOptions(path: 'auth/get_user'),
        error: e.toString(),
      ));
    }
  }
}
