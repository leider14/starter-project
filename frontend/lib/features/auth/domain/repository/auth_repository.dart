import 'dart:io';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<DataState<UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<DataState<UserEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? bio,
    File? image,
  });

  Future<void> signOut();

  Future<DataState<UserEntity>> getCurrentUser();

  Future<DataState<UserEntity>> updateProfile({
    String? fullName,
    String? bio,
    File? image,
  });

  Future<DataState<UserEntity>> getUser(String userId);
}
