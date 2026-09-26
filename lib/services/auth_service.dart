import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authState => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // OTP bhejein
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'OTP bhejne mein masla hua');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // OTP verify karein
  Future<bool> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final result = await _auth.signInWithCredential(credential);
      if (result.user != null) {
        await _saveUser(result.user!);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // User ka record Firestore mein save karein
  Future<void> _saveUser(User user) async {
    final doc = _db.collection('users').doc(user.uid);
    final exists = (await doc.get()).exists;
    if (!exists) {
      await doc.set({
        'phone': user.phoneNumber,
        'name': '',
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
