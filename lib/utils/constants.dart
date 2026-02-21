// KPSS Canavari - Constants
// Tüm sabit değerler bu dosyada tanımlanır

class AppConstants {
  // App Info
  static const String appName = 'KPSS Canavari';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'AI-Powered KPSS Exam Preparation Assistant';

  // Gemini API
  static const String geminiApiKey =
      'YOUR_GEMINI_API_KEY_HERE';
  static const String geminiModel = 'gemini-1.5-pro-latest';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String questionsCollection = 'questions';
  static const String testsCollection = 'tests';
  static const String weeklyExamsCollection = 'weeklyExams';
  static const String forumCollection = 'forum';
  static const String placementDataCollection = 'placementData';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String questionImagesPath = 'question_images';
  static const String pdfUploadsPath = 'pdf_uploads';

  // Shared Preferences Keys
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyThemeMode = 'theme_mode';

  // RAG System (Vector DB seçildiğinde güncellenecek)
  static const String vectorDbType = 'pinecone'; // veya 'chromadb'
  static const String pineconeIndexName = 'kpss-canavari';

  // Chunk retrieval settings
  static const int defaultTopK = 5; // Kaç chunk döndürülecek
  static const double minSimilarityScore = 0.7; // Minimum benzerlik skoru

  // Question Solving
  static const int maxQuestionLength = 5000; // Max karakter
  static const int maxContextLength = 10000; // Max context karakter

  // Test Generation
  static const int defaultTestQuestionCount = 20;
  static const List<String> difficultyLevels = ['Kolay', 'Orta', 'Zor'];

  // KPSS Topics (Ana konular)
  static const List<String> kpssTopics = [
    'Türkçe',
    'Matematik',
    'Geometri',
    'Tarih',
    'Coğrafya',
    'Vatandaşlık',
    'Güncel Bilgiler',
    'Anayasa',
    'Ekonomi',
  ];

  // KPSS Exam Types
  static const List<String> kpssExamTypes = [
    'Lisans',
    'Önlisans',
    'Ortaöğretim',
  ];

  // Weekly Exam
  static const String weeklyExamDay = 'Sunday'; // Pazar günü
  static const String weeklyExamTime = '10:00'; // Saat 10:00

  // Pagination
  static const int questionsPerPage = 20;
  static const int testsPerPage = 10;
  static const int forumPostsPerPage = 15;

  // Cache durations (milliseconds)
  static const int imageCacheDuration = 7 * 24 * 60 * 60 * 1000; // 7 gün
  static const int dataCacheDuration = 60 * 60 * 1000; // 1 saat

  // Error Messages
  static const String errorGeneric = 'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String errorNetwork =
      'İnternet bağlantısı yok. Lütfen kontrol edin.';
  static const String errorAuth = 'Giriş yapmanız gerekiyor.';
  static const String errorPermission = 'İzin verilmedi.';

  // Success Messages
  static const String successLogin = 'Giriş başarılı!';
  static const String successRegister = 'Kayıt başarılı!';
  static const String successQuestionSolved = 'Soru çözüldü!';
  static const String successTestCreated = 'Test oluşturuldu!';

  // URLs
  static const String termsOfServiceUrl = 'https://kpss-canavari.com/terms';
  static const String privacyPolicyUrl = 'https://kpss-canavari.com/privacy';
  static const String supportEmail = 'support@kpss-canavari.com';

  // GitHub
  static const String githubRepo = 'https://github.com/kozoukioden';
}

class FirebaseConstants {
  // Cloud Functions
  static const String functionSolveQuestion = 'solveQuestion';
  static const String functionGenerateTest = 'generateTest';
  static const String functionAnalyzePerformance = 'analyzePerformance';
  static const String functionGetCoachingAdvice = 'getCoachingAdvice';
  static const String functionSearchPlacement = 'searchPlacement';
  static const String functionGeneratePodcast = 'generatePodcast';

  // Firebase Storage Rules
  static const int maxImageSize = 10 * 1024 * 1024; // 10 MB
  static const int maxPdfSize = 50 * 1024 * 1024; // 50 MB

  // Firestore Limits
  static const int maxBatchSize = 500;
  static const int maxQueryLimit = 100;
}
