import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Authentication Tests', () {
    test('User can sign in with correct credentials', () async {
      final mockAuth = CustomMockFirebaseAuth();

      await mockAuth.createUserWithEmailAndPassword(
        email: "test@example.com",
        password: "password123",
      );

      final userCredential = await mockAuth.signInWithEmailAndPassword(
        email: "test@example.com",
        password: "password123",
      );

      expect(userCredential.user, isNotNull);
      expect(userCredential.user!.email, "test@example.com");
    });

    test('User fails to sign in with incorrect password', () async {
      final mockAuth = CustomMockFirebaseAuth();

      await mockAuth.createUserWithEmailAndPassword(
        email: "test@example.com",
        password: "password123",
      );

      try {
        await mockAuth.signInWithEmailAndPassword(
          email: "test@example.com",
          password: "wrongpassword",
        );
        fail('Expected an exception, but got none');
      } catch (e) {
        expect(e, isInstanceOf<FirebaseAuthException>());
      }
    });

    test('User fails to sign in with incorrect email', () async {
      final mockAuth = CustomMockFirebaseAuth();

      await mockAuth.createUserWithEmailAndPassword(
        email: "test@example.com",
        password: "password123",
      );

      try {
        await mockAuth.signInWithEmailAndPassword(
          email: "wrongemail@example.com",
          password: "password123",
        );
        fail('Expected an exception, but got none');
      } catch (e) {
        expect(e, isInstanceOf<FirebaseAuthException>());
      }
    });
  });
}


class CustomMockFirebaseAuth extends MockFirebaseAuth {
  final Map<String, String> _userPasswords = {};

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _userPasswords[email] = password;
    return super.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!_userPasswords.containsKey(email)) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found for that email.',
      );
    }
    if (_userPasswords[email] != password) {
      throw FirebaseAuthException(
        code: 'wrong-password',
        message: 'The password is incorrect.',
      );
    }
    return super.signInWithEmailAndPassword(email: email, password: password);
  }
}