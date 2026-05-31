import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'exception.dart';

class FirebaseErrorHandler {
  /// Handles Firebase Auth errors
  static HealAppExceptions handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        throw const RemoteException('The email address is not valid.');
      case 'user-disabled':
        throw const RemoteException('This user has been disabled.');
      case 'user-not-found':
        throw const RemoteException('No user found for that email.');
      case 'wrong-password':
        throw const RemoteException('Incorrect password provided.');
      case 'email-already-in-use':
        throw const RemoteException('This email is already in use.');
      case 'weak-password':
        throw const RemoteException('The password is too weak.');
      case 'operation-not-allowed':
        throw const RemoteException('This operation is not allowed.');
      case 'too-many-requests':
        throw const RemoteException('Too many requests. Please try again later.');
      case 'network-request-failed':
        throw const RemoteException('No internet connection. Please check your network.');
      default:
        throw RemoteException('Auth error: ${e.message}');
    }
  }

  /// Handles Firestore-specific errors
  static HealAppExceptions handleFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        throw const RemoteException('You don’t have permission to perform this action.');
      case 'unavailable':
        throw const RemoteException('Firestore service is currently unavailable. Try again later.');
      case 'not-found':
        throw const RemoteException('The requested document was not found.');
      case 'already-exists':
        throw const RemoteException('The document already exists.');
      case 'deadline-exceeded':
        throw const RemoteException('The request took too long. Please try again.');
      case 'resource-exhausted':
        throw const RemoteException('Resource limit exceeded. Try again later.');
      case 'cancelled':
        throw const RemoteException('The request was cancelled.');
      case 'unauthenticated':
        throw const RemoteException('You must be authenticated to perform this action.');
      default:
        throw RemoteException('Firestore error: ${e.message}');
    }
  }

  /// Handles any other Firebase exception (Storage, Functions, Messaging, etc.)
  static HealAppExceptions handleFirebaseGeneralError(FirebaseException e) {
    switch (e.code) {
      case 'quota-exceeded':
        throw const RemoteException('Quota exceeded. Please try again later.');
      case 'unauthorized':
        throw const RemoteException('Unauthorized request. Check your permissions.');
      case 'cancelled':
        throw const RemoteException('The request was cancelled.');
      case 'unavailable':
        throw const RemoteException('Firebase service is unavailable. Try again later.');
      default:
        throw RemoteException('Firebase error: ${e.message}');
    }
  }
}
