import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

extension UserEntityMapper on UserEntity {
  UserModel toModel() => UserModel(
        id: id,
        name: name,
        email: email,
        phone: phone,
        role: role.name,
      );
}
