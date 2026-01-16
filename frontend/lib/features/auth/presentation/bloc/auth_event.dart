import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String? bio;
  final File? image;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    this.bio,
    this.image,
  });

  @override
  List<Object?> get props => [email, password, fullName, bio, image];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthProfileUpdateRequested extends AuthEvent {
  final String? fullName;
  final String? bio;
  final File? image;

  const AuthProfileUpdateRequested({this.fullName, this.bio, this.image});

  @override
  List<Object?> get props => [fullName, bio, image];
}
