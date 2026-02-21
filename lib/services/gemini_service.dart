import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/constants.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  late final GenerativeModel _model;
  late final GenerativeModel _flashModel;

  // Initialize Gemini models
  Future<void> initialize() async {
    _model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppConstants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
      ],
    );

    // Flash model for faster responses (image generation vb için)
    _flashModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AppConstants.geminiApiKey,
    );
  }

  /// SORU ÇÖZME FONKSİYONU
  /// En kritik fonksiyon - PDF'deki gereksinimlere göre
  Future<Map<String, dynamic>> solveQuestion({
    required String questionText,
    String? imageUrl,
    List<String>? options,
    List<String>? context, // Vector DB'den gelen chunk'lar
  }) async {
    try {
      // Context oluştur
      final contextText = context != null && context.isNotEmpty
          ? '\n\nİLGİLİ KAYNAKLAR:\n${context.join('\n\n')}'
          : '';

      // Prompt hazırla (PDF gereksinimlerine göre)
      final prompt = '''Sen KPSS sınavına hazırlanan öğrencilere yardımcı olan uzman bir AI asistanısın.

ÖNEMLİ KURALLAR:
1. Çoktan seçmeli sorularda KESINLIKLE kesin cevap ver, yuvarlama yapma
2. Matematik sorularında adım adım çöz
3. Detaylı ve açıklayıcı ol
4. Sadece verilen seçeneklerden birini işaretle
5. Eğer emin değilsen, en mantıklı çözümü açıkla

${contextText.isNotEmpty ? contextText : ''}

SORU:
$questionText

${options != null && options.isNotEmpty ? '\nSEÇENEKLER:\n${options.asMap().entries.map((e) => '${String.fromCharCode(65 + e.key)}) ${e.value}').join('\n')}' : ''}

CEVAP FORMATI:
1. Kısa Cevap: [Eğer çoktan seçmeliyse sadece harf (A, B, C, D veya E), değilse doğrudan cevap]
2. Detaylı Açıklama: [Adım adım çözüm ve açıklama]
3. Önemli Noktalar: [Bu tür soruları çözmek için ipuçları]

CEVAP:''';

      // Gemini'ye gönder
      final response = await _model.generateContent([Content.text(prompt)]);

      final answerText = response.text ?? '';

      // Cevabı parse et
      final parsedAnswer = _parseAnswer(answerText, options);

      return {
        'success': true,
        'answer': parsedAnswer['shortAnswer'],
        'explanation': parsedAnswer['explanation'],
        'tips': parsedAnswer['tips'],
        'fullResponse': answerText,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// KONU ANLATIMI FONKSİYONU
  Future<Map<String, dynamic>> explainTopic({
    required String topic,
    String? subTopic,
    List<String>? context,
    bool voiceMode = false,
  }) async {
    try {
      final contextText = context != null && context.isNotEmpty
          ? '\n\nKAYNAKLAR:\n${context.join('\n\n')}'
          : '';

      final prompt = '''Sen KPSS konularını anlatan uzman bir eğitmensin.

${voiceMode ? 'Bu açıklamayı sesli okutma için hazırla. Doğal ve anlaşılır bir dil kullan.' : ''}

KONU: $topic
${subTopic != null ? 'ALT KONU: $subTopic' : ''}

$contextText

ÖNEMLİ:
1. Anlaşılır ve net açıkla
2. Örnekler ver
3. KPSS sınavlarında nasıl sorulduğunu anlat
4. Önemli noktaları vurgula
5. ${voiceMode ? 'Sohbet havasında anlat' : 'Yapılandırılmış şekilde anlat'}

ANLATIM:''';

      final response = await _model.generateContent([Content.text(prompt)]);

      return {
        'success': true,
        'explanation': response.text ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// TEST ÜRETME FONKSİYONU
  Future<Map<String, dynamic>> generateTest({
    required List<String> topics,
    required int questionCount,
    required String difficulty,
    String? sourceType, // 'original' veya 'ai-generated'
    List<String>? availableQuestions, // Original sorular için
  }) async {
    try {
      // Eğer original sorular isteniyorsa, mevcut sorulardan seç
      if (sourceType == 'original' && availableQuestions != null) {
        // Bu kısım Vector DB'den soru çekme işlemi yapacak
        // Şimdilik AI üretimi yapıyoruz
      }

      // AI Generated Test
      final prompt = '''KPSS sınavı için test oluştur.

GEREKSINIMLER:
- Konu(lar): ${topics.join(', ')}
- Soru Sayısı: $questionCount
- Zorluk: $difficulty

Her soru için:
1. Soru metni
2. 5 seçenek (A, B, C, D, E)
3. Doğru cevap
4. Kısa açıklama

${topics.contains('Geometri') ? 'NOT: Geometri soruları için şekil açıklamasını detaylı yaz.' : ''}
${topics.contains('Tarih') || topics.contains('Coğrafya') ? 'NOT: Tarih/coğrafya soruları için harita/görsel açıklaması ekle.' : ''}

Format:
---
SORU 1:
[Soru metni]

A) [Seçenek]
B) [Seçenek]
C) [Seçenek]
D) [Seçenek]
E) [Seçenek]

Doğru Cevap: [Harf]
Açıklama: [Kısa açıklama]
---

TEST:''';

      final response = await _model.generateContent([Content.text(prompt)]);

      final questions = _parseGeneratedTest(response.text ?? '');

      return {
        'success': true,
        'questions': questions,
        'total': questions.length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// COACHING/PERFORMANS ANALİZİ
  Future<Map<String, dynamic>> analyzePerformance({
    required Map<String, dynamic> userStats,
    required List<Map<String, dynamic>> recentResults,
  }) async {
    try {
      final prompt = '''Bir KPSS öğrencisinin performansını analiz et ve öneriler sun.

KULLANICI İSTATİSTİKLERİ:
${_formatUserStats(userStats)}

SON TEST SONUÇLARI:
${_formatRecentResults(recentResults)}

ANALİZ VE ÖNERİLER:
1. Güçlü Yönler
2. Zayıf Yönler
3. İyileştirme Önerileri
4. Çalışma Programı Önerisi
5. Hedef Puan Tahmini

DETAYLI ANALİZ:''';

      final response = await _model.generateContent([Content.text(prompt)]);

      return {
        'success': true,
        'analysis': response.text ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// CHATBOT FONKSİYONU
  Future<String> chat({
    required String message,
    List<String>? conversationHistory,
    List<String>? context,
  }) async {
    try {
      final contextText = context != null && context.isNotEmpty
          ? '\n\nİLGİLİ BİLGİLER:\n${context.join('\n\n')}'
          : '';

      final historyText = conversationHistory != null &&
              conversationHistory.isNotEmpty
          ? '\n\nÖNCEKİ KONUŞMA:\n${conversationHistory.join('\n')}'
          : '';

      final prompt = '''Sen KPSS Canavari asistanısın. KPSS sınavına hazırlanan öğrencilere yardımcı oluyorsun.

Yeteneklerin:
- Soru çözme
- Konu anlatımı
- Test oluşturma
- Performans analizi
- Genel KPSS danışmanlığı

$historyText
$contextText

KULLANICI: $message

ASISTAN:''';

      final response = await _model.generateContent([Content.text(prompt)]);

      return response.text ?? 'Üzgünüm, bir cevap oluşturamadım.';
    } catch (e) {
      return 'Hata: ${e.toString()}';
    }
  }

  /// PODCAST SCRIPT OLUŞTURMA
  Future<Map<String, dynamic>> generatePodcastScript({
    required String topic,
    int durationMinutes = 10,
  }) async {
    try {
      final prompt = '''$topic konusu hakkında $durationMinutes dakikalık eğlenceli bir podcast senaryosu oluştur.

İKİ KARAKTER:
- Sunucu 1 (Erkek): Enerjik ve şakacı
- Sunucu 2 (Kadın): Bilgili ve açıklayıcı

FORMAT:
[SUNUCU 1]: Diyalog
[SUNUCU 2]: Diyalog

KONUYU:
- Eğlenceli anlatın
- Örnekler verin
- KPSS'de nasıl sorulduğunu söyleyin
- Ezber teknikleri ekleyin

SENARYO:''';

      final response = await _model.generateContent([Content.text(prompt)]);

      return {
        'success': true,
        'script': response.text ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Helper: Cevabı parse et
  Map<String, String> _parseAnswer(String answer, List<String>? options) {
    String shortAnswer = '';
    String explanation = '';
    String tips = '';

    // Basit regex ile parse (gerçek uygulamada daha sofistike olabilir)
    final lines = answer.split('\n');

    for (var line in lines) {
      if (line.toLowerCase().contains('kısa cevap:')) {
        shortAnswer = line.split(':').last.trim();
      } else if (line.toLowerCase().contains('detaylı açıklama:')) {
        final idx = lines.indexOf(line);
        explanation = lines.sublist(idx + 1).join('\n').trim();
      } else if (line.toLowerCase().contains('önemli noktalar:')) {
        final idx = lines.indexOf(line);
        tips = lines.sublist(idx + 1).join('\n').trim();
      }
    }

    // Eğer parse edilemezse, tüm cevabı explanation olarak kullan
    if (shortAnswer.isEmpty && explanation.isEmpty) {
      explanation = answer;

      // Çoktan seçmeli ise ilk harfi bul
      if (options != null) {
        final match =
            RegExp(r'\b[A-E]\b').firstMatch(answer.substring(0, 50));
        if (match != null) {
          shortAnswer = match.group(0)!;
        }
      }
    }

    return {
      'shortAnswer': shortAnswer,
      'explanation': explanation,
      'tips': tips,
    };
  }

  // Helper: Test parse et
  List<Map<String, dynamic>> _parseGeneratedTest(String testText) {
    final questions = <Map<String, dynamic>>[];

    // Basit parse (gerçek uygulamada daha iyi olmalı)
    final questionBlocks = testText.split('---');

    for (var block in questionBlocks) {
      if (block.trim().isEmpty) continue;

      // Her soruyu parse et
      final lines = block.split('\n').where((l) => l.trim().isNotEmpty).toList();

      if (lines.length < 8) continue; // En az 8 satır olmalı (soru + 5 seçenek + cevap + açıklama)

      String questionText = '';
      List<String> options = [];
      String correctAnswer = '';
      String explanation = '';

      for (var line in lines) {
        if (line.startsWith('SORU')) {
          final idx = lines.indexOf(line);
          if (idx + 1 < lines.length) {
            questionText = lines[idx + 1];
          }
        } else if (line.trim().startsWith(RegExp(r'[A-E]\)'))) {
          options.add(line.substring(2).trim());
        } else if (line.contains('Doğru Cevap:')) {
          correctAnswer = line.split(':').last.trim();
        } else if (line.contains('Açıklama:')) {
          explanation = line.split(':').last.trim();
        }
      }

      if (questionText.isNotEmpty && options.length == 5) {
        questions.add({
          'text': questionText,
          'options': options,
          'correctAnswer': correctAnswer,
          'explanation': explanation,
        });
      }
    }

    return questions;
  }

  // Helper: User stats format
  String _formatUserStats(Map<String, dynamic> stats) {
    return '''
- Toplam Çözülen Soru: ${stats['totalQuestions'] ?? 0}
- Doğru: ${stats['correct'] ?? 0}
- Yanlış: ${stats['wrong'] ?? 0}
- Doğruluk Oranı: ${stats['accuracy'] ?? 0}%
- Çalışılan Konular: ${(stats['topics'] as List?)?.join(', ') ?? 'Yok'}
- Zayıf Konular: ${(stats['weakTopics'] as List?)?.join(', ') ?? 'Yok'}
''';
  }

  // Helper: Recent results format
  String _formatRecentResults(List<Map<String, dynamic>> results) {
    return results
        .map((r) =>
            '- ${r['topic']}: ${r['score']}% (${r['correct']}/${r['total']})')
        .join('\n');
  }
}
