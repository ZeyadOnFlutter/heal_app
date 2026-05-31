import '../../auth/data/models/user_model.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final List<UserModel> users;
  AdminLoaded(this.users);
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
}

class AdminSuccess extends AdminState {
  final String message;
  AdminSuccess(this.message);
}
