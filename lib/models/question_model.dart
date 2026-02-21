import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String text;
  final String? imageUrl;
  final List<String> options; // A, B, C, D, E seçenekleri
  final String correctAnswer; // Doğru cevap (örn: "A")
  final String topic; // Türkçe, Matematik, Tarih vb.
  final String? subTopic; // Alt konu
  final String difficulty; // 'Kolay', 'Orta', 'Zor'
  final String? source; // Hangi kaynaktan geldiği (kitap adı veya 'AI Generated')
  final int? examYear; // Hangi KPSS sınavından (örn: 2023)
  final String? examSession; // İlkbahar, Sonbahar vb.
  final String explanation; // Sorunun açıklaması/çözümü
  final List<String> tags; // Etiketler (örn: ['oran-orantı', 'çarpma'])
  final DateTime createdAt;
  final String? createdBy; // User ID (AI için null olabilir)
  final bool isVerified; // Admin tarafından doğrulandı mı?

  // Statistics
  final int timesAsked; // Kaç kez soruldu
  final int timesCorrect; // Kaç kez doğru cevaplandı
  final int timesWrong; // Kaç kez yanlış cevaplandı

  QuestionModel({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.options,
    required this.correctAnswer,
    required this.topic,
    this.subTopic,
    required this.difficulty,
    this.source,
    this.examYear,
    this.examSession,
    required this.explanation,
    this.tags = const [],
    required this.createdAt,
    this.createdBy,
    this.isVerified = false,
    this.timesAsked = 0,
    this.timesCorrect = 0,
    this.timesWrong = 0,
  });

  // Accuracy hesaplama
  double get accuracy {
    if (timesAsked == 0) return 0.0;
    return (timesCorrect / timesAsked) * 100;
  }

  // Zorluk seviyesini sayıya çevirme
  int get difficultyLevel {
    switch (difficulty) {
      case 'Kolay':
        return 1;
      case 'Orta':
        return 2;
      case 'Zor':
        return 3;
      default:
        return 2;
    }
  }

  // JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'imageUrl': imageUrl,
      'options': options,
      'correctAnswer': correctAnswer,
      'topic': topic,
      'subTopic': subTopic,
      'difficulty': difficulty,
      'source': source,
      'examYear': examYear,
      'examSession': examSession,
      'explanation': explanation,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'isVerified': isVerified,
      'timesAsked': timesAsked,
      'timesCorrect': timesCorrect,
      'timesWrong': timesWrong,
    };
  }

  // JSON'dan oluşturma
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'] as String,
      topic: json['topic'] as String,
      subTopic: json['subTopic'] as String?,
      difficulty: json['difficulty'] as String,
      source: json['source'] as String?,
      examYear: json['examYear'] as int?,
      examSession: json['examSession'] as String?,
      explanation: json['explanation'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      createdBy: json['createdBy'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      timesAsked: json['timesAsked'] as int? ?? 0,
      timesCorrect: json['timesCorrect'] as int? ?? 0,
      timesWrong: json['timesWrong'] as int? ?? 0,
    );
  }

  // Firestore DocumentSnapshot'tan oluşturma
  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel.fromJson({...data, 'id': doc.id});
  }

  // Copy with method
  QuestionModel copyWith({
    String? id,
    String? text,
    String? imageUrl,
    List<String>? options,
    String? correctAnswer,
    String? topic,
    String? subTopic,
    String? difficulty,
    String? source,
    int? examYear,
    String? examSession,
    String? explanation,
    List<String>? tags,
    DateTime? createdAt,
    String? createdBy,
    bool? isVerified,
    int? timesAsked,
    int? timesCorrect,
    int? timesWrong,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      topic: topic ?? this.topic,
      subTopic: subTopic ?? this.subTopic,
      difficulty: difficulty ?? this.difficulty,
      source: source ?? this.source,
      examYear: examYear ?? this.examYear,
      examSession: examSession ?? this.examSession,
      explanation: explanation ?? this.explanation,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      isVerified: isVerified ?? this.isVerified,
      timesAsked: timesAsked ?? this.timesAsked,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      timesWrong: timesWrong ?? this.timesWrong,
    );
  }
}
