import 'package:dartz/dartz.dart';

import '../../../../core/error/faliure.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> register(
    String name,
    String email,
    String password,
    String phone,
    String role,
  );
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, Unit>> logout();
}
