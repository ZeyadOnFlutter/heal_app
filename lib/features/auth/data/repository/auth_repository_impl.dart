import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/faliure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../data_source/firebase_data_source/firebase_auth_data_source.dart';
import '../mappers/user_mapper.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _firebaseAuthDataSource;

  AuthRepositoryImpl(this._firebaseAuthDataSource);
  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final response = await _firebaseAuthDataSource.login(email, password);
      return Right(response!.toEntity);
    } on RemoteException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _firebaseAuthDataSource.logout();
      return const Right(unit);
    } on RemoteException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
    String name,
    String email,
    String password,
    String phone,
    String role,
  ) async {
    try {
      final response = await _firebaseAuthDataSource.register(name, email, password, phone, role);
      return Right(response!.toEntity);
    } on RemoteException catch (e) {
      return Left(Failure(e.message));
    }
  }

}
