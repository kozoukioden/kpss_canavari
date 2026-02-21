import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

/// User data state management provider
/// Manages current user statistics and performance data
class UserProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Statistics data
  Map<String, int> _topicProgress = {};
  List<String> _weakTopics = [];
  List<String> _strongTopics = [];
  double _overallAccuracy = 0.0;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, int> get topicProgress => _topicProgress;
  List<String> get weakTopics => _weakTopics;
  List<String> get strongTopics => _strongTopics;
  double get overallAccuracy => _overallAccuracy;

  /// Set current user
  void setUser(UserModel user) {
    _currentUser = user;
    _calculateStatistics();
    notifyListeners();
  }

  /// Load user from Firestore
  Future<void> loadUser(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _firestoreService.getUser(uid);

    _isLoading = false;

    if (result['success']) {
      _currentUser = result['user'];
      _calculateStatistics();
    } else {
      _errorMessage = result['error'];
    }

    notifyListeners();
  }

  /// Update user statistics after solving questions
  Future<bool> updateStats({
    required String uid,
    required int questionsAnswered,
    required int correctAnswers,
    required Map<String, int> topicScores,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _firestoreService.updateUserStats(
      uid: uid,
      totalQuestions: questionsAnswered,
      correctAnswers: correctAnswers,
      topicScores: topicScores,
    );

    _isLoading = false;

    if (result['success']) {
      // Update local user model
      if (_currentUser != null) {
        _currentUser = UserModel(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          username: _currentUser!.username,
          firstName: _currentUser!.firstName,
          lastName: _currentUser!.lastName,
          photoUrl: _currentUser!.photoUrl,
          kpssType: _currentUser!.kpssType,
          totalQuestionsSolved:
              _currentUser!.totalQuestionsSolved + questionsAnswered,
          correctAnswers: _currentUser!.correctAnswers + correctAnswers,
          topicScores: topicScores,
          weakTopics: _currentUser!.weakTopics,
          studyStreak: _currentUser!.studyStreak,
          lastStudyDate: DateTime.now(),
          createdAt: _currentUser!.createdAt,
          preferences: _currentUser!.preferences,
        );

        _calculateStatistics();
      }

      notifyListeners();
      return true;
    } else {
      _errorMessage = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Update study streak
  void updateStudyStreak() {
    if (_currentUser == null) return;

    final now = DateTime.now();
    final lastStudy = _currentUser!.lastStudyDate;

    int newStreak = _currentUser!.studyStreak;

    if (lastStudy != null) {
      final difference = now.difference(lastStudy).inDays;

      if (difference == 1) {
        // Consecutive day
        newStreak++;
      } else if (difference > 1) {
        // Streak broken
        newStreak = 1;
      }
      // Same day: no change
    } else {
      // First time studying
      newStreak = 1;
    }

    _currentUser = UserModel(
      uid: _currentUser!.uid,
      email: _currentUser!.email,
      username: _currentUser!.username,
      firstName: _currentUser!.firstName,
      lastName: _currentUser!.lastName,
      photoUrl: _currentUser!.photoUrl,
      kpssType: _currentUser!.kpssType,
      totalQuestionsSolved: _currentUser!.totalQuestionsSolved,
      correctAnswers: _currentUser!.correctAnswers,
      topicScores: _currentUser!.topicScores,
      weakTopics: _currentUser!.weakTopics,
      studyStreak: newStreak,
      lastStudyDate: now,
      createdAt: _currentUser!.createdAt,
      preferences: _currentUser!.preferences,
    );

    notifyListeners();

    // Save to Firestore
    _firestoreService.saveUser(_currentUser!);
  }

  /// Calculate statistics from user data
  void _calculateStatistics() {
    if (_currentUser == null) return;

    _topicProgress = _currentUser!.topicScores;

    // Calculate overall accuracy
    if (_currentUser!.totalQuestionsSolved > 0) {
      _overallAccuracy =
          (_currentUser!.correctAnswers / _currentUser!.totalQuestionsSolved) *
              100;
    } else {
      _overallAccuracy = 0.0;
    }

    // Identify weak and strong topics
    _weakTopics = [];
    _strongTopics = [];

    _topicProgress.forEach((topic, score) {
      if (score < 50) {
        _weakTopics.add(topic);
      } else if (score >= 75) {
        _strongTopics.add(topic);
      }
    });

    // Sort by score
    _weakTopics.sort((a, b) => _topicProgress[a]!.compareTo(_topicProgress[b]!));
    _strongTopics
        .sort((a, b) => _topicProgress[b]!.compareTo(_topicProgress[a]!));
  }

  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    if (_currentUser == null) {
      return {
        'totalQuestions': 0,
        'correctAnswers': 0,
        'accuracy': 0.0,
        'weakTopics': [],
        'strongTopics': [],
        'studyStreak': 0,
      };
    }

    return {
      'totalQuestions': _currentUser!.totalQuestionsSolved,
      'correctAnswers': _currentUser!.correctAnswers,
      'accuracy': _overallAccuracy,
      'weakTopics': _weakTopics,
      'strongTopics': _strongTopics,
      'studyStreak': _currentUser!.studyStreak,
      'topicScores': _topicProgress,
    };
  }

  /// Update user preferences
  Future<bool> updatePreferences(Map<String, dynamic> newPreferences) async {
    if (_currentUser == null) return false;

    _currentUser = UserModel(
      uid: _currentUser!.uid,
      email: _currentUser!.email,
      username: _currentUser!.username,
      firstName: _currentUser!.firstName,
      lastName: _currentUser!.lastName,
      photoUrl: _currentUser!.photoUrl,
      kpssType: _currentUser!.kpssType,
      totalQuestionsSolved: _currentUser!.totalQuestionsSolved,
      correctAnswers: _currentUser!.correctAnswers,
      topicScores: _currentUser!.topicScores,
      weakTopics: _currentUser!.weakTopics,
      studyStreak: _currentUser!.studyStreak,
      lastStudyDate: _currentUser!.lastStudyDate,
      createdAt: _currentUser!.createdAt,
      preferences: newPreferences,
    );

    notifyListeners();

    final result = await _firestoreService.saveUser(_currentUser!);
    return result['success'];
  }

  /// Update profile photo URL
  Future<bool> updatePhotoUrl(String photoUrl) async {
    if (_currentUser == null) return false;

    _currentUser = UserModel(
      uid: _currentUser!.uid,
      email: _currentUser!.email,
      username: _currentUser!.username,
      firstName: _currentUser!.firstName,
      lastName: _currentUser!.lastName,
      photoUrl: photoUrl,
      kpssType: _currentUser!.kpssType,
      totalQuestionsSolved: _currentUser!.totalQuestionsSolved,
      correctAnswers: _currentUser!.correctAnswers,
      topicScores: _currentUser!.topicScores,
      weakTopics: _currentUser!.weakTopics,
      studyStreak: _currentUser!.studyStreak,
      lastStudyDate: _currentUser!.lastStudyDate,
      createdAt: _currentUser!.createdAt,
      preferences: _currentUser!.preferences,
    );

    notifyListeners();

    final result = await _firestoreService.saveUser(_currentUser!);
    return result['success'];
  }

  /// Clear user data (on logout)
  void clear() {
    _currentUser = null;
    _topicProgress = {};
    _weakTopics = [];
    _strongTopics = [];
    _overallAccuracy = 0.0;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
