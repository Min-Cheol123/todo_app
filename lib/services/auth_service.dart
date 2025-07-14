import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 현재 사용자 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // 자동 로그인 확인
  Future<bool> checkAutoLogin() async {
    await Future.delayed(Duration(seconds: 1)); // 스플래시 효과
    return currentUser != null;
  }

  // 구글 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      // 사용자 프로필 저장
      if (result.user != null) {
        await _saveUserProfile(result.user!);
      }

      return result;
    } catch (e) {
      print('구글 로그인 에러: $e');
      rethrow;
    }
  }

  // 사용자 프로필 저장
  Future<void> _saveUserProfile(User user) async {
    final userProfile = UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userProfile.toFirestore(), SetOptions(merge: true));
  }

  // 로그아웃
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // 이메일로 사용자 검색
  Future<List<UserProfile>> searchUsersByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(5)
          .get();

      return query.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
    } catch (e) {
      print('사용자 검색 에러: $e');
      return [];
    }
  }
}