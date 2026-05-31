import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/faliure.dart';
import '../entities/user_entity.dart';
import '../repository/auth_repository.dart';

@lazySingleton
class RegisterUseCase {
  final AuthRepository _authRepository;

  const RegisterUseCase(this._authRepository);
  Future<Either<Failure, UserEntity>> call(
    String name,
    String email,
    String password,
    String phone,
    String role,
  ) => _authRepository.register(name, email, password, phone, role);
}
