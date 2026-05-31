import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/faliure.dart';
import '../entities/user_entity.dart';
import '../repository/auth_repository.dart';

@lazySingleton
class LoginUseCase {
  final AuthRepository _authRepository;

  const LoginUseCase(this._authRepository);

  Future<Either<Failure, UserEntity>> call(String email, String password) =>
      _authRepository.login(email, password);
}
