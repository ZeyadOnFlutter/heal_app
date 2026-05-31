import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../auth/data/models/user_model.dart';

@lazySingleton
class AdminDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  const AdminDataSource(this._firestore, this._auth);

  CollectionReference<UserModel> get _users => _firestore
      .collection('users')
      .withConverter(
        fromFirestore: (snapshot, _) => UserModel.fromJson(
          {...snapshot.data()!, 'id': snapshot.id},
        ),
        toFirestore: (u, _) => u.toJson(),
      );

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _users.get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  Future<void> createUser(UserModel user, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: user.email,
      password: password,
    );
    final newUser = UserModel(
      id: cred.user!.uid,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
    );
    await _users.doc(newUser.id).set(newUser);
  }

  Future<void> updateUser(UserModel user, String oldRole) async {
    await _users.doc(user.id).set(user);
  }

  Future<void> deleteUser(String userId, String role) async {
    await _users.doc(userId).delete();
  }
}
