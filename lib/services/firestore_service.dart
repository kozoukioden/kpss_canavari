import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/question_model.dart';
import '../models/test_model.dart';
import '../utils/constants.dart';

/// Firestore database operations service
/// Handles CRUD operations for users, questions, tests, and results
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton pattern
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  // ==================== USER OPERATIONS ====================

  /// Create or update user document
  Future<Map<String, dynamic>> saveUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toJson(), SetOptions(merge: true));

      return {'success': true, 'message': 'Kullanıcı başarıyla kaydedildi'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get user document by UID
  Future<Map<String, dynamic>> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        return {'success': false, 'error': 'Kullanıcı bulunamadı'};
      }

      final user = UserModel.fromJson(doc.data()!);
      return {'success': true, 'user': user};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Update user statistics
  Future<Map<String, dynamic>> updateUserStats({
    required String uid,
    required int totalQuestions,
    required int correctAnswers,
    required Map<String, int> topicScores,
  }) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
        'totalQuestionsSolved': FieldValue.increment(totalQuestions),
        'correctAnswers': FieldValue.increment(correctAnswers),
        'topicScores': topicScores,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'İstatistikler güncellendi'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Delete user document
  Future<Map<String, dynamic>> deleteUser(String uid) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .delete();

      return {'success': true, 'message': 'Kullanıcı silindi'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== QUESTION OPERATIONS ====================

  /// Add a new question to database
  Future<Map<String, dynamic>> addQuestion(QuestionModel question) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.questionsCollection)
          .add(question.toJson());

      return {
        'success': true,
        'message': 'Soru eklendi',
        'questionId': docRef.id
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get question by ID
  Future<Map<String, dynamic>> getQuestion(String questionId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.questionsCollection)
          .doc(questionId)
          .get();

      if (!doc.exists) {
        return {'success': false, 'error': 'Soru bulunamadı'};
      }

      final question = QuestionModel.fromJson({...doc.data()!, 'id': doc.id});
      return {'success': true, 'question': question};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get questions by topic
  Future<Map<String, dynamic>> getQuestionsByTopic({
    required String topic,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.questionsCollection)
          .where('topic', isEqualTo: topic)
          .limit(limit)
          .get();

      final questions = snapshot.docs
          .map((doc) => QuestionModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return {'success': true, 'questions': questions};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get questions by multiple filters
  Future<Map<String, dynamic>> getQuestions({
    String? topic,
    String? difficulty,
    int limit = 20,
  }) async {
    try {
      Query query =
          _firestore.collection(AppConstants.questionsCollection).limit(limit);

      if (topic != null) {
        query = query.where('topic', isEqualTo: topic);
      }

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      final snapshot = await query.get();

      final questions = snapshot.docs
          .map((doc) => QuestionModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      return {'success': true, 'questions': questions};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Update question statistics (times asked, times correct)
  Future<Map<String, dynamic>> updateQuestionStats({
    required String questionId,
    required bool wasCorrect,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.questionsCollection)
          .doc(questionId)
          .update({
        'timesAsked': FieldValue.increment(1),
        if (wasCorrect) 'timesCorrect': FieldValue.increment(1),
      });

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Search questions by text
  Future<Map<String, dynamic>> searchQuestions(String searchText) async {
    try {
      // Note: For better search, consider using Algolia or ElasticSearch
      // This is a basic search implementation
      final snapshot = await _firestore
          .collection(AppConstants.questionsCollection)
          .limit(50)
          .get();

      final questions = snapshot.docs
          .map((doc) => QuestionModel.fromJson({...doc.data(), 'id': doc.id}))
          .where((q) => q.text.toLowerCase().contains(searchText.toLowerCase()))
          .toList();

      return {'success': true, 'questions': questions};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== TEST OPERATIONS ====================

  /// Save test to database
  Future<Map<String, dynamic>> saveTest(TestModel test) async {
    try {
      final docRef =
          await _firestore.collection(AppConstants.testsCollection).add(test.toJson());

      return {'success': true, 'message': 'Test kaydedildi', 'testId': docRef.id};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get test by ID
  Future<Map<String, dynamic>> getTest(String testId) async {
    try {
      final doc =
          await _firestore.collection(AppConstants.testsCollection).doc(testId).get();

      if (!doc.exists) {
        return {'success': false, 'error': 'Test bulunamadı'};
      }

      final test = TestModel.fromJson({...doc.data()!, 'id': doc.id});
      return {'success': true, 'test': test};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get user's test history
  Future<Map<String, dynamic>> getUserTests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.testsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final tests = snapshot.docs
          .map((doc) => TestModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return {'success': true, 'tests': tests};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== TEST RESULT OPERATIONS ====================

  /// Save test result
  Future<Map<String, dynamic>> saveTestResult({
    required String testId,
    required String userId,
    required TestResultModel result,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.testsCollection)
          .doc(testId)
          .collection('results')
          .doc(userId)
          .set(result.toJson());

      return {'success': true, 'message': 'Test sonucu kaydedildi'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get test result
  Future<Map<String, dynamic>> getTestResult({
    required String testId,
    required String userId,
  }) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.testsCollection)
          .doc(testId)
          .collection('results')
          .doc(userId)
          .get();

      if (!doc.exists) {
        return {'success': false, 'error': 'Test sonucu bulunamadı'};
      }

      final result = TestResultModel.fromJson(doc.data()!);
      return {'success': true, 'result': result};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get all results for a test (for leaderboard)
  Future<Map<String, dynamic>> getTestResults(String testId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.testsCollection)
          .doc(testId)
          .collection('results')
          .orderBy('score', descending: true)
          .get();

      final results =
          snapshot.docs.map((doc) => TestResultModel.fromJson(doc.data())).toList();

      return {'success': true, 'results': results};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Add multiple questions at once
  Future<Map<String, dynamic>> addQuestionsBatch(
      List<QuestionModel> questions) async {
    try {
      final batch = _firestore.batch();

      for (var question in questions) {
        final docRef =
            _firestore.collection(AppConstants.questionsCollection).doc();
        batch.set(docRef, question.toJson());
      }

      await batch.commit();

      return {
        'success': true,
        'message': '${questions.length} soru eklendi'
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== REAL-TIME LISTENERS ====================

  /// Listen to user document changes
  Stream<UserModel?> userStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    });
  }

  /// Listen to test results updates (for leaderboard)
  Stream<List<TestResultModel>> testResultsStream(String testId) {
    return _firestore
        .collection(AppConstants.testsCollection)
        .doc(testId)
        .collection('results')
        .orderBy('score', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TestResultModel.fromJson(doc.data()))
          .toList();
    });
  }

  // ==================== FORUM OPERATIONS ====================

  /// Add forum post
  Future<Map<String, dynamic>> addForumPost(Map<String, dynamic> post) async {
    try {
      final docRef = await _firestore.collection('forum_posts').add(post);

      return {
        'success': true,
        'message': 'Gönderi eklendi',
        'postId': docRef.id
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get forum posts stream
  Stream<List<Map<String, dynamic>>> forumPostsStream() {
    return _firestore
        .collection('forum_posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  /// Add chat message
  Future<Map<String, dynamic>> addChatMessage(
      Map<String, dynamic> message) async {
    try {
      await _firestore.collection('chat_messages').add(message);

      return {'success': true, 'message': 'Mesaj gönderildi'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get chat messages stream
  Stream<List<Map<String, dynamic>>> chatMessagesStream() {
    return _firestore
        .collection('chat_messages')
        .orderBy('timestamp', descending: false)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }
}
