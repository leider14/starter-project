import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class GetUserUseCase implements UseCase<DataState<UserEntity>, String> {
  final AuthRepository _authRepository;

  GetUserUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call({String? params}) {
    return _authRepository.getUser(params!);
  }
}
