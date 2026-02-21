import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Is signed in
  bool get isSignedIn => currentUser != null;

  /// EMAIL/PASSWORD İLE KAYIT
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
    required String kpssType,
    String? department,
    String? school,
    String? phone,
    String? city,
  }) async {
    try {
      // Firebase Auth ile kayıt
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'error': 'Kullanıcı oluşturulamadı'};
      }

      // Kullanıcı profili oluştur
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        username: username,
        firstName: firstName,
        lastName: lastName,
        department: department,
        school: school,
        phone: phone,
        kpssType: kpssType,
        city: city,
        createdAt: DateTime.now(),
      );

      // Firestore'a kaydet
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toJson());

      // Display name güncelle
      await user.updateDisplayName('$firstName $lastName');

      return {
        'success': true,
        'user': userModel,
        'message': AppConstants.successRegister,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _handleAuthError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Beklenmeyen bir hata oluştu: ${e.toString()}',
      };
    }
  }

  /// EMAIL/PASSWORD İLE GİRİŞ
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'error': 'Giriş yapılamadı'};
      }

      // Kullanıcı verisini al
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        return {'success': false, 'error': 'Kullanıcı verisi bulunamadı'};
      }

      final userModel = UserModel.fromFirestore(userDoc);

      return {
        'success': true,
        'user': userModel,
        'message': AppConstants.successLogin,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _handleAuthError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Beklenmeyen bir hata oluştu: ${e.toString()}',
      };
    }
  }

  /// GOOGLE İLE GİRİŞ
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {'success': false, 'error': 'Google girişi iptal edildi'};
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        return {'success': false, 'error': 'Google girişi başarısız'};
      }

      // Kullanıcı zaten var mı kontrol et
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Mevcut kullanıcı
        final userModel = UserModel.fromFirestore(userDoc);
        return {
          'success': true,
          'user': userModel,
          'isNewUser': false,
          'message': AppConstants.successLogin,
        };
      } else {
        // Yeni kullanıcı - profil tamamlanması gerekiyor
        final nameParts = user.displayName?.split(' ') ?? ['', ''];
        final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        final lastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          username: user.email?.split('@')[0] ?? '',
          firstName: firstName,
          lastName: lastName,
          kpssType: 'Lisans', // Default, sonra güncellenecek
          profileImageUrl: user.photoURL,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toJson());

        return {
          'success': true,
          'user': userModel,
          'isNewUser': true,
          'message': 'Profil bilgilerinizi tamamlayın',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Google girişi hatası: ${e.toString()}',
      };
    }
  }

  /// ÇIKIŞ YAP
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// ŞİFRE SIFIRLAMA
  Future<Map<String, dynamic>> resetPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _handleAuthError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Beklenmeyen bir hata oluştu: ${e.toString()}',
      };
    }
  }

  /// ŞİFRE DEĞİŞTİRME
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        return {'success': false, 'error': 'Kullanıcı bulunamadı'};
      }

      // Önce mevcut şifre ile yeniden giriş yap
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Şifreyi güncelle
      await user.updatePassword(newPassword);

      return {
        'success': true,
        'message': 'Şifreniz başarıyla güncellendi',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _handleAuthError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Beklenmeyen bir hata oluştu: ${e.toString()}',
      };
    }
  }

  /// KULLANICI VERİSİNİ AL
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// KULLANICI VERİSİNİ GÜNCELLE
  Future<Map<String, dynamic>> updateUserData({
    required String uid,
    Map<String, dynamic>? updates,
  }) async {
    try {
      if (updates == null || updates.isEmpty) {
        return {'success': false, 'error': 'Güncellenecek veri yok'};
      }

      // updatedAt ekle
      updates['updatedAt'] = Timestamp.now();

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(updates);

      return {
        'success': true,
        'message': 'Profil başarıyla güncellendi',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Güncelleme hatası: ${e.toString()}',
      };
    }
  }

  /// KULLANICI SİL
  Future<Map<String, dynamic>> deleteAccount({
    required String password,
  }) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        return {'success': false, 'error': 'Kullanıcı bulunamadı'};
      }

      // Önce yeniden authenticate et
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Firestore'dan sil
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();

      // Auth'dan sil
      await user.delete();

      return {
        'success': true,
        'message': 'Hesabınız başarıyla silindi',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _handleAuthError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Hesap silme hatası: ${e.toString()}',
      };
    }
  }

  /// Firebase Auth hatalarını çevir
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Şifre çok zayıf';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Hatalı şifre';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakıldı';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin';
      case 'operation-not-allowed':
        return 'Bu işlem şu an için kullanılamıyor';
      case 'requires-recent-login':
        return 'Bu işlem için yeniden giriş yapmanız gerekiyor';
      default:
        return 'Bir hata oluştu: ${e.message}';
    }
  }
}
