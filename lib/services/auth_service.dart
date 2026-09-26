import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Aakhri login/OTP error (diagnostic ke liye)
  static String? lastError;

  Stream<User?> get authState => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // OTP bhejein
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    Function()? onAutoVerified,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Test number ya auto-verification: foran sign-in, OTP screen nahi aati
        try {
          final result = await _auth.signInWithCredential(credential);
          if (result.user != null) {
            await _saveUser(result.user!);
            onAutoVerified?.call();
          }
        } catch (e) {
          onError('Auto login mein masla hua');
        }
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

  // OTP verify karein — true = kamyab, false = nakam (wajah lastError mein)
  Future<bool> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    lastError = null;
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
      lastError = 'Server ne khaali jawab diya';
      return false;
    } on FirebaseAuthException catch (e) {
      lastError = '${e.code}\n${e.message ?? ''}';
      return false;
    } catch (e) {
      lastError = e.toString();
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
