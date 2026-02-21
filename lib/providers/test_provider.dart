import 'package:flutter/material.dart';
import 'dart:async';
import '../models/test_model.dart';
import '../models/question_model.dart';
import '../services/firestore_service.dart';

/// Test taking state management provider
/// Manages test session, timer, and answers
class TestProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  TestModel? _currentTest;
  List<QuestionModel> _questions = [];
  Map<String, String> _userAnswers = {};
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Timer
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;

  // Results
  TestResultModel? _lastTestResult;

  // Getters
  TestModel? get currentTest => _currentTest;
  List<QuestionModel> get questions => _questions;
  Map<String, String> get userAnswers => _userAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get remainingSeconds => _remainingSeconds;
  bool get isTimerRunning => _isTimerRunning;
  TestResultModel? get lastTestResult => _lastTestResult;

  int get totalQuestions => _questions.length;
  int get answeredCount => _userAnswers.length;
  int get unansweredCount => totalQuestions - answeredCount;
  bool get isLastQuestion => _currentQuestionIndex == totalQuestions - 1;
  bool get isFirstQuestion => _currentQuestionIndex == 0;

  QuestionModel? get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentQuestionIndex] : null;

  /// Start a new test
  Future<void> startTest({
    required TestModel test,
    required List<QuestionModel> questions,
  }) async {
    _currentTest = test;
    _questions = questions;
    _userAnswers = {};
    _currentQuestionIndex = 0;
    _errorMessage = null;
    _lastTestResult = null;

    // Start timer if test has time limit
    if (test.timeLimit != null && test.timeLimit! > 0) {
      _remainingSeconds = test.timeLimit! * 60; // Convert minutes to seconds
      _startTimer();
    }

    notifyListeners();
  }

  /// Start countdown timer
  void _startTimer() {
    _isTimerRunning = true;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        // Time's up - auto submit
        _timer?.cancel();
        _isTimerRunning = false;
        _autoSubmitTest();
      }
    });
  }

  /// Pause timer
  void pauseTimer() {
    _timer?.cancel();
    _isTimerRunning = false;
    notifyListeners();
  }

  /// Resume timer
  void resumeTimer() {
    if (_remainingSeconds > 0) {
      _startTimer();
    }
  }

  /// Auto submit when time runs out
  Future<void> _autoSubmitTest() async {
    await submitTest();
  }

  /// Answer current question
  void answerQuestion(String questionId, String answer) {
    _userAnswers[questionId] = answer;
    notifyListeners();
  }

  /// Navigate to specific question
  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  /// Go to next question
  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Go to previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Get user's answer for a question
  String? getUserAnswer(String questionId) {
    return _userAnswers[questionId];
  }

  /// Check if question is answered
  bool isQuestionAnswered(String questionId) {
    return _userAnswers.containsKey(questionId);
  }

  /// Submit test and calculate results
  Future<bool> submitTest() async {
    if (_currentTest == null || _questions.isEmpty) {
      _errorMessage = 'Test bulunamadı';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _timer?.cancel();
    _isTimerRunning = false;
    notifyListeners();

    // Calculate results
    int correctCount = 0;
    int timeSpent = (_currentTest!.timeLimit ?? 0) * 60 - _remainingSeconds;

    for (var question in _questions) {
      final userAnswer = _userAnswers[question.id];
      if (userAnswer != null && userAnswer == question.correctAnswer) {
        correctCount++;
      }
    }

    final score = (correctCount / totalQuestions) * 100;

    _lastTestResult = TestResultModel(
      userId: '', // Will be set by the calling code
      testId: _currentTest!.id ?? '',
      userAnswers: _userAnswers,
      correctCount: correctCount,
      score: score,
      timeSpent: timeSpent,
      completedAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();

    return true;
  }

  /// Save test result to Firestore
  Future<bool> saveTestResult(String userId) async {
    if (_lastTestResult == null || _currentTest == null) {
      _errorMessage = 'Test sonucu bulunamadı';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final result = await _firestoreService.saveTestResult(
      testId: _currentTest!.id ?? '',
      userId: userId,
      result: _lastTestResult!,
    );

    _isLoading = false;

    if (result['success']) {
      return true;
    } else {
      _errorMessage = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Get test results summary
  Map<String, dynamic> getResultsSummary() {
    if (_lastTestResult == null) {
      return {
        'correctCount': 0,
        'totalQuestions': 0,
        'score': 0.0,
        'timeSpent': 0,
        'accuracy': 0.0,
      };
    }

    return {
      'correctCount': _lastTestResult!.correctCount,
      'totalQuestions': totalQuestions,
      'score': _lastTestResult!.score,
      'timeSpent': _lastTestResult!.timeSpent,
      'accuracy': _lastTestResult!.score,
      'wrongCount': totalQuestions - _lastTestResult!.correctCount,
      'unansweredCount': totalQuestions - _userAnswers.length,
    };
  }

  /// Get detailed results per question
  List<Map<String, dynamic>> getDetailedResults() {
    if (_lastTestResult == null) return [];

    return _questions.map((question) {
      final userAnswer = _userAnswers[question.id];
      final isCorrect = userAnswer == question.correctAnswer;

      return {
        'question': question,
        'userAnswer': userAnswer,
        'correctAnswer': question.correctAnswer,
        'isCorrect': isCorrect,
        'wasAnswered': userAnswer != null,
      };
    }).toList();
  }

  /// Reset test state
  void resetTest() {
    _timer?.cancel();
    _currentTest = null;
    _questions = [];
    _userAnswers = {};
    _currentQuestionIndex = 0;
    _remainingSeconds = 0;
    _isTimerRunning = false;
    _lastTestResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Format remaining time as MM:SS
  String getFormattedTime() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if time is running out (less than 5 minutes)
  bool isTimeRunningOut() {
    return _remainingSeconds > 0 && _remainingSeconds <= 300; // 5 minutes
  }

  /// Check if time is critical (less than 1 minute)
  bool isTimeCritical() {
    return _remainingSeconds > 0 && _remainingSeconds <= 60; // 1 minute
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
