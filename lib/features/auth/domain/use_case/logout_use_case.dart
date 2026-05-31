import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/faliure.dart';
import '../repository/auth_repository.dart';

@lazySingleton
class LogoutUseCase {
  final AuthRepository _authRepository;

  const LogoutUseCase(this._authRepository);

  Future<Either<Failure, Unit>> call() => _authRepository.logout();
}
