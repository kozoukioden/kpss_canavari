import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

/// Authentication state management provider
/// Manages user authentication state and operations
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _firebaseUser != null;

  /// Initialize auth state listener
  void initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _firebaseUser = user;

      if (user != null) {
        await _loadUserModel(user.uid);
      } else {
        _userModel = null;
      }

      notifyListeners();
    });
  }

  /// Load user model from Firestore
  Future<void> _loadUserModel(String uid) async {
    final result = await _firestoreService.getUser(uid);

    if (result['success']) {
      _userModel = result['user'];
    } else {
      _userModel = null;
      _errorMessage = result['error'];
    }

    notifyListeners();
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    _setLoading(false);

    if (result['success']) {
      _firebaseUser = result['user'];
      await _loadUserModel(_firebaseUser!.uid);
      return true;
    } else {
      _errorMessage = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
    required String kpssType,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
      username: username,
      firstName: firstName,
      lastName: lastName,
      kpssType: kpssType,
    );

    _setLoading(false);

    if (result['success']) {
      _firebaseUser = result['user'];
      _userModel = result['userModel'];
      return true;
    } else {
      _errorMessage = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.signInWithGoogle();

    _setLoading(false);

    if (result['success']) {
      _firebaseUser = result['user'];
      final needsProfileCompletion = result['needsProfileCompletion'] ?? false;

      if (!needsProfileCompletion) {
        await _loadUserModel(_firebaseUser!.uid);
      }

      return true;
    } else {
      _errorMessage = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Complete user profile (for Google Sign-In users)
  Future<bool> completeProfile({
    required String username,
    required String firstName,
    required String lastName,
    required String kpssType,
  }) async {
    if (_firebaseUser == null) {
      _errorMessage = 'Kullanıcı oturumu bulunamadı';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.completeGoogleUserProfile(
      user: _firebaseUser!,
      username: username,
      firstName: firstName,
      lastName: lastName,
      kpssType: kpssType,
    );

    _setLoading(false);

    if (result['success']) {
      _userModel = result['userModel'];
      return true;
    } else {
      _errorMessage = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.resetPassword(email: email);

    _setLoading(false);

    if (result['success']) {
      return true;
    } else {
      _errorMessage = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    _setLoading(false);

    if (result['success']) {
      return true;
    } else {
      _errorMessage = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.updateUserData(updatedUser);

    _setLoading(false);

    if (result['success']) {
      _userModel = updatedUser;
      return true;
    } else {
      _errorMessage = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);

    await _authService.signOut();

    _firebaseUser = null;
    _userModel = null;
    _errorMessage = null;

    _setLoading(false);
  }

  /// Delete account
  Future<bool> deleteAccount(String password) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.deleteAccount(password: password);

    _setLoading(false);

    if (result['success']) {
      _firebaseUser = null;
      _userModel = null;
      return true;
    } else {
      _errorMessage = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Refresh user data from Firestore
  Future<void> refreshUserData() async {
    if (_firebaseUser != null) {
      await _loadUserModel(_firebaseUser!.uid);
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
