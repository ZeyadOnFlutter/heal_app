import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/exception.dart';
import '../../../../../core/error/firebase_error_handler.dart';
import '../../models/user_model.dart';
import 'firebase_auth_data_source.dart';

@LazySingleton(as: FirebaseAuthDataSource)
class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  const FirebaseAuthDataSourceImpl(this._auth, this._firestore);

  // Single users collection — all roles live here
  CollectionReference<UserModel> get _users => _firestore
      .collection('users')
      .withConverter(
        fromFirestore: (snapshot, _) => UserModel.fromJson(
          {...snapshot.data()!, 'id': snapshot.id},
        ),
        toFirestore: (user, _) => user.toJson(),
      );

  @override
  CollectionReference<UserModel> getUserCollection() => _users;

  @override
  Future<void> addUserToFireStore(UserModel user) async {
    await _users.doc(user.id).set(user);
  }

  @override
  Future<UserModel> getUserFromFireStore(UserModel user) async {
    final doc = await _users.doc(user.id).get();
    final data = doc.data();
    if (data == null) throw const RemoteException('User data not found.');
    return data;
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      FirebaseErrorHandler.handleFirebaseAuthError(e);
    }
  }

  @override
  Future<UserModel?> register(String name, String email, String password, String phone, String role) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
      );
      if (credential.additionalUserInfo!.isNewUser) await addUserToFireStore(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc = await _users.doc(credential.user!.uid).get();
      if (doc.exists && doc.data() != null) return doc.data();
      throw const RemoteException('User data not found.');
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorHandler.handleFirebaseAuthError(e);
    } on RemoteException {
      rethrow;
    } catch (e) {
      throw RemoteException(e.toString());
    }
  }

  @override
  Future<void> addDiabetesRecord(String userId, DiabetesRecord record) async {
    await _users.doc(userId).update({
      'diabetesRecords': FieldValue.arrayUnion([record.toJson()]),
    });
  }

  @override
  Future<void> addDiabetesSurvey(String userId, DiabetesSurvey survey) async {
    await _users.doc(userId).update({
      'diabetesSurveys': FieldValue.arrayUnion([survey.toJson()]),
    });
  }

  @override
  Future<void> addSkinCancerRecord(String userId, SkinCancerRecord record) async {
    await _users.doc(userId).update({
      'skinCancerRecords': FieldValue.arrayUnion([record.toJson()]),
    });
  }

  @override
  Future<void> addSkinCancerSurvey(String userId, SkinCancerSurvey survey) async {
    await _users.doc(userId).update({
      'skinCancerSurveys': FieldValue.arrayUnion([survey.toJson()]),
    });
  }

  @override
  Future<void> addCombinedResult(String userId, CombinedAnalysisResult result) async {
    await _users.doc(userId).update({
      'combinedResults': FieldValue.arrayUnion([result.toJson()]),
    });
  }

  @override
  Future<void> saveDoctorFeedback(String patientId, String timestamp, String feedback, String doctorId) async {
    final doc = await _users.doc(patientId).get();
    if (!doc.exists) return;
    final results = List<Map<String, dynamic>>.from(
      (doc.data()!.toJson()['combinedResults'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e)),
    );
    final index = results.indexWhere((r) => r['timestamp'] == timestamp);
    if (index == -1) return;
    results[index]['doctorFeedback'] = feedback;
    results[index]['doctorId'] = doctorId;
    await _users.doc(patientId).update({'combinedResults': results});
  }

  @override
  Future<UserModel?> getUserData(String userId) async {
    final doc = await _users.doc(userId).get();
    return doc.data();
  }
}
