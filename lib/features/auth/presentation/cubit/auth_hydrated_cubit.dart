import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/mappers/user_entity_mapper.dart';
import '../../data/mappers/user_mapper.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/use_case/login_use_case.dart';
import '../../domain/use_case/logout_use_case.dart';
import '../../domain/use_case/register_use_case.dart';
import 'auth_state.dart';

@singleton
class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
  ) : super(AuthInitial());
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await _loginUseCase(email, password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)), // user is UserEntity from repository
    );
  }

  Future<void> register(String name, String email, String password, String phone, String role) async {
    emit(AuthLoading());
    final result = await _registerUseCase(name, email, password, phone, role);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    final result = await _logoutUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) async {
        await clear(); // only clears this cubit's storage
        emit(Unauthenticated());
      },
    );
  }

  bool get isAuthenticated => state is Authenticated;
  UserEntity? get currentUser => state is Authenticated ? (state as Authenticated).user : null;

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is Authenticated) {
      // Convert Entity back to Model for storage
      final userModel = state.user.toModel();

      return {
        'type': 'authenticated',
        'user': userModel.toJson(),
      };
    }

    return null;
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'authenticated') {
        final userModel = UserModel.fromJson(json['user']);
        final userEntity = userModel.toEntity;

        return Authenticated(userEntity);
      }
    } catch (e) {
      // If restoration fails, start fresh
      return AuthInitial();
    }
    return AuthInitial();
  }
}
