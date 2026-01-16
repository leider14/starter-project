import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? uid;
  final String? email;
  final String? fullName;
  final String? photoUrl;
  final String? bio;

  const UserEntity({
    this.uid,
    this.email,
    this.fullName,
    this.photoUrl,
    this.bio,
  });

  @override
  List<Object?> get props => [uid, email, fullName, photoUrl, bio];
}
