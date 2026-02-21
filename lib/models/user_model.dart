import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? department;
  final String? school;
  final String? phone;
  final String kpssType; // 'Lisans' veya 'Önlisans'
  final String? city;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Statistics
  final int totalQuestionsSolved;
  final int correctAnswers;
  final int wrongAnswers;
  final int testsTaken;
  final List<String> studiedTopics;
  final Map<String, int> topicScores; // Topic -> Score mapping
  final List<String> weakTopics;

  // Preferences
  final bool notificationsEnabled;
  final bool weeklyExamReminder;
  final String preferredStudyTime; // 'Sabah', 'Öğle', 'Akşam'

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.department,
    this.school,
    this.phone,
    required this.kpssType,
    this.city,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
    this.totalQuestionsSolved = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.testsTaken = 0,
    this.studiedTopics = const [],
    this.topicScores = const {},
    this.weakTopics = const [],
    this.notificationsEnabled = true,
    this.weeklyExamReminder = true,
    this.preferredStudyTime = 'Akşam',
  });

  // Accuracy hesaplama
  double get accuracy {
    if (totalQuestionsSolved == 0) return 0.0;
    return (correctAnswers / totalQuestionsSolved) * 100;
  }

  // Average score hesaplama
  double get averageScore {
    if (topicScores.isEmpty) return 0.0;
    final total = topicScores.values.reduce((a, b) => a + b);
    return total / topicScores.length;
  }

  // JSON'a çevirme (Firestore için)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'department': department,
      'school': school,
      'phone': phone,
      'kpssType': kpssType,
      'city': city,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'totalQuestionsSolved': totalQuestionsSolved,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'testsTaken': testsTaken,
      'studiedTopics': studiedTopics,
      'topicScores': topicScores,
      'weakTopics': weakTopics,
      'notificationsEnabled': notificationsEnabled,
      'weeklyExamReminder': weeklyExamReminder,
      'preferredStudyTime': preferredStudyTime,
    };
  }

  // JSON'dan oluşturma
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      department: json['department'] as String?,
      school: json['school'] as String?,
      phone: json['phone'] as String?,
      kpssType: json['kpssType'] as String? ?? 'Lisans',
      city: json['city'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      totalQuestionsSolved: json['totalQuestionsSolved'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      wrongAnswers: json['wrongAnswers'] as int? ?? 0,
      testsTaken: json['testsTaken'] as int? ?? 0,
      studiedTopics: List<String>.from(json['studiedTopics'] ?? []),
      topicScores: Map<String, int>.from(json['topicScores'] ?? {}),
      weakTopics: List<String>.from(json['weakTopics'] ?? []),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      weeklyExamReminder: json['weeklyExamReminder'] as bool? ?? true,
      preferredStudyTime: json['preferredStudyTime'] as String? ?? 'Akşam',
    );
  }

  // Firestore DocumentSnapshot'tan oluşturma
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  // Copy with method (güncelleme için)
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? department,
    String? school,
    String? phone,
    String? kpssType,
    String? city,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalQuestionsSolved,
    int? correctAnswers,
    int? wrongAnswers,
    int? testsTaken,
    List<String>? studiedTopics,
    Map<String, int>? topicScores,
    List<String>? weakTopics,
    bool? notificationsEnabled,
    bool? weeklyExamReminder,
    String? preferredStudyTime,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      department: department ?? this.department,
      school: school ?? this.school,
      phone: phone ?? this.phone,
      kpssType: kpssType ?? this.kpssType,
      city: city ?? this.city,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalQuestionsSolved: totalQuestionsSolved ?? this.totalQuestionsSolved,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      testsTaken: testsTaken ?? this.testsTaken,
      studiedTopics: studiedTopics ?? this.studiedTopics,
      topicScores: topicScores ?? this.topicScores,
      weakTopics: weakTopics ?? this.weakTopics,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      weeklyExamReminder: weeklyExamReminder ?? this.weeklyExamReminder,
      preferredStudyTime: preferredStudyTime ?? this.preferredStudyTime,
    );
  }

  // Full name
  String get fullName => '$firstName $lastName';

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, username: $username, fullName: $fullName)';
  }
}
