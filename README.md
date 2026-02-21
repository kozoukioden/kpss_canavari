# 🎓 KPSS Canavari

**AI-Powered KPSS Exam Preparation Application**

KPSS Canavari, yapay zeka destekli KPSS sınav hazırlık platformudur. Google Gemini 2.5 Pro API ve RAG (Retrieval-Augmented Generation) teknolojisi kullanılarak geliştirilmiştir.

---

## 📱 Platform Desteği

- ✅ **Windows** (.exe)
- ✅ **Android** (.apk)
- 🔜 iOS (gelecekte)
- 🔜 Web (gelecekte)

---

## ✨ Özellikler

### 🤖 AI Soru Çözücü
- Gemini 2.5 Pro ile görsel/metin soru çözümü
- OCR ile görüntüden soru okuma
- PDF yükleme ve çözümleme
- Detaylı adım adım açıklamalar
- Çoktan seçmeli sorularda kesin cevap (yuvarlamasız)

### 📝 Akıllı Test Üretici
- Konu bazlı otomatik test oluşturma
- Zorluk seviyesi seçimi (Kolay/Orta/Zor)
- Orijinal KPSS soruları veya AI üretimi
- Geometri şekilleri ve harita görselleri

### 📊 Performans Analizi & Coaching
- Detaylı kullanıcı istatistikleri
- Güçlü/zayıf yönler analizi
- AI destekli kişisel danışmanlık
- Konuya dayalı çalışma programı önerisi

### 🎯 Tercih Robotu
- Geçmiş KPSS yerleşme verileri analizi
- Güncel ilan takibi
- Yerleşme tahmini

### 📅 Haftalık Deneme Sınavları
- Otomatik sınav oluşturma
- Sıralama ve analiz

### 🎙️ Podcast Üretici & Topluluk
- Konu bazlı eğlenceli podcastler
- Forum ve mesajlaşma

### 📚 Geçmiş Sorular Arşivi
- Tüm KPSS soruları
- Detaylı filtreleme

---

## 🏗️ Teknoloji Stack

- **Flutter 3.35.2** + **Dart 3.9.0**
- **Firebase** (Auth, Firestore, Storage, Functions)
- **Google Gemini 2.5 Pro API**
- **RAG System** (Sentence Transformers + Vector DB)
- **Google Colab** (Model training)

---

## 🚀 Hızlı Başlangıç

### 1. Gereksinimler
- Flutter SDK 3.x+
- Android Studio / VS Code
- Firebase account
- Google account (Colab için)

### 2. Kurulum

```bash
# Projeyi klonlayın
cd kpss_canavari

# Paketleri yükleyin
flutter pub get

# Firebase yapılandırması
flutterfire configure
```

### 3. Çalıştırma

```bash
# Windows
flutter run -d windows

# Android
flutter run
```

### 4. AI Model Eğitimi

Detaylı talimatlar için: `colab_notebooks/README.md`

```bash
# Google Colab'da sırayla çalıştırın:
1. 01_data_preprocessing.ipynb
2. 02_embedding_creation.ipynb
3. 03_vector_db_upload.ipynb
4. 04_rag_testing.ipynb
```

---

## 📦 Build

### Windows .exe
```bash
flutter build windows --release
# Output: build\windows\x64\runner\Release\
```

### Android .apk
```bash
flutter build apk --release
# Output: build\app\outputs\flutter-apk\app-release.apk
```

---

## 📁 Proje Yapısı

```
kpss_canavari/
├── lib/
│   ├── main.dart
│   ├── models/         # User, Question, Test models
│   ├── services/       # Auth, Gemini, Firebase
│   ├── screens/        # UI screens
│   ├── widgets/        # Reusable widgets
│   ├── theme/          # App theme & colors
│   └── utils/          # Constants, helpers
├── colab_notebooks/    # AI training notebooks
├── assets/             # Images, fonts
└── pubspec.yaml
```

---

## 🔑 API & Credentials

### Gemini API
```dart
// lib/utils/constants.dart
static const geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

### Firebase
```bash
# Firebase yapılandırması
flutterfire configure

# Project: Kpss
# ID: gen-lang-client-0308346152
```

---

## 🎨 Tasarım

- **Primary Gradient:** Indigo → Purple
- **Modern gradient UI**
- **Material Design 3**
- **Dark mode support**
- **Responsive layout**

---

## 🗺️ Roadmap

### v1.0.0 (Current)
- [x] Core structure
- [x] AI services (Gemini)
- [x] Firebase setup
- [x] Colab notebooks
- [ ] Auth screens
- [ ] Main features
- [ ] Build & release

### v2.0.0 (Future)
- [ ] iOS support
- [ ] Advanced features
- [ ] Gamification

---


## 📝 Lisans

Özel proje - Tüm hakları saklıdır.

---

**🚀 KPSS Canavari ile başarıya ulaşın!**


