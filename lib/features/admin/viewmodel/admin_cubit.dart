import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../auth/data/models/user_model.dart';
import '../data/admin_data_source.dart';
import 'admin_state.dart';

@lazySingleton
class AdminCubit extends Cubit<AdminState> {
  final AdminDataSource _dataSource;

  AdminCubit(this._dataSource) : super(AdminInitial());

  Future<void> loadUsers() async {
    emit(AdminLoading());
    try {
      final users = await _dataSource.getAllUsers();
      emit(AdminLoaded(users));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> createUser(UserModel user, String password) async {
    emit(AdminLoading());
    try {
      await _dataSource.createUser(user, password);
      emit(AdminSuccess('User created successfully'));
      await loadUsers();
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> updateUser(UserModel user, String oldRole) async {
    emit(AdminLoading());
    try {
      await _dataSource.updateUser(user, oldRole);
      emit(AdminSuccess('User updated successfully'));
      await loadUsers();
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> deleteUser(String userId, String role) async {
    emit(AdminLoading());
    try {
      await _dataSource.deleteUser(userId, role);
      emit(AdminSuccess('User deleted successfully'));
      await loadUsers();
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
