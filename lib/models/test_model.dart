import 'package:cloud_firestore/cloud_firestore.dart';
import 'question_model.dart';

class TestModel {
  final String id;
  final String title;
  final String? description;
  final List<String> questionIds; // Question ID'leri
  final List<QuestionModel>? questions; // Populate edildiğinde doldurulur
  final String createdBy; // User ID veya 'system'
  final DateTime createdAt;
  final String type; // 'Practice', 'Weekly', 'Custom', 'MockExam'
  final List<String> topics; // Hangi konuları kapsıyor
  final int totalQuestions;
  final int? timeLimit; // Dakika cinsinden (null ise sınırsız)
  final String difficulty; // 'Karma', 'Kolay', 'Orta', 'Zor'
  final bool isPublic; // Diğer kullanıcılar görebilir mi?

  // Statistics
  final int timesTaken; // Kaç kez çözüldü
  final double? averageScore; // Ortalama puan

  TestModel({
    required this.id,
    required this.title,
    this.description,
    required this.questionIds,
    this.questions,
    required this.createdBy,
    required this.createdAt,
    required this.type,
    required this.topics,
    required this.totalQuestions,
    this.timeLimit,
    required this.difficulty,
    this.isPublic = false,
    this.timesTaken = 0,
    this.averageScore,
  });

  // JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questionIds': questionIds,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'type': type,
      'topics': topics,
      'totalQuestions': totalQuestions,
      'timeLimit': timeLimit,
      'difficulty': difficulty,
      'isPublic': isPublic,
      'timesTaken': timesTaken,
      'averageScore': averageScore,
    };
  }

  // JSON'dan oluşturma
  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      questionIds: List<String>.from(json['questionIds']),
      createdBy: json['createdBy'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      type: json['type'] as String,
      topics: List<String>.from(json['topics']),
      totalQuestions: json['totalQuestions'] as int,
      timeLimit: json['timeLimit'] as int?,
      difficulty: json['difficulty'] as String,
      isPublic: json['isPublic'] as bool? ?? false,
      timesTaken: json['timesTaken'] as int? ?? 0,
      averageScore: json['averageScore'] as double?,
    );
  }

  // Firestore DocumentSnapshot'tan oluşturma
  factory TestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestModel.fromJson({...data, 'id': doc.id});
  }

  // Copy with method
  TestModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? questionIds,
    List<QuestionModel>? questions,
    String? createdBy,
    DateTime? createdAt,
    String? type,
    List<String>? topics,
    int? totalQuestions,
    int? timeLimit,
    String? difficulty,
    bool? isPublic,
    int? timesTaken,
    double? averageScore,
  }) {
    return TestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      questionIds: questionIds ?? this.questionIds,
      questions: questions ?? this.questions,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      topics: topics ?? this.topics,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      timeLimit: timeLimit ?? this.timeLimit,
      difficulty: difficulty ?? this.difficulty,
      isPublic: isPublic ?? this.isPublic,
      timesTaken: timesTaken ?? this.timesTaken,
      averageScore: averageScore ?? this.averageScore,
    );
  }
}

class TestResultModel {
  final String id;
  final String testId;
  final String userId;
  final Map<String, String> userAnswers; // Question ID -> Selected Answer
  final int correctCount;
  final int wrongCount;
  final int emptyCount;
  final double score; // 0-100 arası puan
  final int timeSpent; // Saniye cinsinden
  final DateTime completedAt;
  final Map<String, bool> questionResults; // Question ID -> isCorrect

  TestResultModel({
    required this.id,
    required this.testId,
    required this.userId,
    required this.userAnswers,
    required this.correctCount,
    required this.wrongCount,
    required this.emptyCount,
    required this.score,
    required this.timeSpent,
    required this.completedAt,
    required this.questionResults,
  });

  // Toplam soru sayısı
  int get totalQuestions => correctCount + wrongCount + emptyCount;

  // Accuracy
  double get accuracy {
    if (totalQuestions == 0) return 0.0;
    return (correctCount / totalQuestions) * 100;
  }

  // JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testId': testId,
      'userId': userId,
      'userAnswers': userAnswers,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'emptyCount': emptyCount,
      'score': score,
      'timeSpent': timeSpent,
      'completedAt': Timestamp.fromDate(completedAt),
      'questionResults': questionResults,
    };
  }

  // JSON'dan oluşturma
  factory TestResultModel.fromJson(Map<String, dynamic> json) {
    return TestResultModel(
      id: json['id'] as String,
      testId: json['testId'] as String,
      userId: json['userId'] as String,
      userAnswers: Map<String, String>.from(json['userAnswers']),
      correctCount: json['correctCount'] as int,
      wrongCount: json['wrongCount'] as int,
      emptyCount: json['emptyCount'] as int,
      score: (json['score'] as num).toDouble(),
      timeSpent: json['timeSpent'] as int,
      completedAt: (json['completedAt'] as Timestamp).toDate(),
      questionResults: Map<String, bool>.from(json['questionResults']),
    );
  }

  // Firestore DocumentSnapshot'tan oluşturma
  factory TestResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestResultModel.fromJson({...data, 'id': doc.id});
  }
}
