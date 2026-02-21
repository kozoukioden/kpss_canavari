# KPSS CANAVARI - Google Colab Notebooks

Bu klasörde KPSS Canavari uygulamasının AI model eğitimi için gerekli Google Colab notebook'ları bulunmaktadır.

## 📚 Notebook'lar

### 1. `01_data_preprocessing.ipynb`
**Amaç:** Google Drive'daki ~1000 KPSS kitabını işleyerek RAG sistemi için hazırlar.

**İşlemler:**
- Google Drive'a bağlanma
- PDF dosyalarını okuma ve metin çıkarma
- Veri temizleme
- Metinleri chunk'lara bölme (1000 karakter/chunk)
- Checkpoint sistemi ile güvenli işleme

**Tahmini Süre:** 6-10 saat
**Gereksinim:** Google Colab (ücretsiz) veya Colab Pro

---

### 2. `02_embedding_creation.ipynb`
**Amaç:** Chunk'lanmış metinlerden embedding'ler oluşturur.

**İşlemler:**
- Türkçe embedding modeli yükleme (intfloat/multilingual-e5-large)
- GPU accelerated embedding oluşturma
- Batch processing (32 batch size)
- Checkpoint sistemi

**Tahmini Süre:** 3-6 saat
**Gereksinim:** GPU Runtime (T4 veya daha iyi önerilir)

---

### 3. `03_vector_db_upload.ipynb`
**Amaç:** Embedding'leri Vector Database'e (Pinecone veya ChromaDB) yükler.

**İşlemler:**
- Vector DB seçimi (Pinecone/ChromaDB)
- Batch upload
- Index oluşturma
- Test sorguları

**Tahmini Süre:** 1-2 saat
**Seçenekler:**
- **Pinecone:** Hızlı, managed, $70/ay (Free tier: 1M vector)
- **ChromaDB:** Ücretsiz, self-hosted, biraz daha yavaş

---

### 4. `04_rag_testing.ipynb`
**Amaç:** Tam RAG pipeline'ı Gemini API ile test eder.

**İşlemler:**
- Gemini 2.5 Pro API entegrasyonu
- RAG pipeline testi
- Performans değerlendirmesi
- API fonksiyonu oluşturma (Flutter için)

**Tahmini Süre:** 1-2 saat
**Gereksinim:** Gemini API Key (PDF'de mevcut)

---

## 🚀 Kullanım Adımları

### Adım 1: Google Colab'a Notebook Yükleme

1. [Google Colab](https://colab.research.google.com/) açın
2. `File > Upload notebook` seçin
3. `01_data_preprocessing.ipynb` dosyasını yükleyin

### Adım 2: Google Drive Hazırlığı

1. Google Drive'ınızda bir klasör oluşturun: `KPSS_Kitaplar`
2. PDF'deki Google Drive linkinden (~1000 kitap) dosyaları bu klasöre kopyalayın veya paylaş
   - Link: `https://drive.google.com/drive/folders/1ZxEddSedrwIw5BjbJtTP12FZuMga_Ry6?usp=drive_link`
3. İşlenmiş veriler için klasör: `KPSS_Processed` (otomatik oluşturulacak)

### Adım 3: Notebook'ları Sırayla Çalıştırma

**Notebook 1: Data Preprocessing**
1. Runtime > Change runtime type > GPU seçin (önerilir)
2. Notebook'taki hücreleri sırayla çalıştırın
3. Drive mount izni verin
4. Checkpoint'ler otomatik kaydedilir (12 saat limitinde kaldığınız yerden devam edebilirsiniz)

**Notebook 2: Embedding Creation**
1. Runtime > GPU seçin (ZORUNLU)
2. Önceki notebook'tan `chunks.json` dosyası gerekli
3. Batch size'ı GPU memory'nize göre ayarlayın (varsayılan: 32)
4. Her 1000 chunk'ta checkpoint kaydet

**Notebook 3: Vector DB Upload**
1. Pinecone veya ChromaDB seçin
2. **Pinecone kullanıyorsanız:**
   - [Pinecone](https://www.pinecone.io/) hesabı oluşturun
   - API key alın
   - Notebook'a girin
3. **ChromaDB kullanıyorsanız:**
   - Herhangi bir ayar gerekmez (ücretsiz)
   - Drive'a kaydedilir

**Notebook 4: RAG Testing**
1. Vector DB bağlantısını test edin
2. Gemini API key'i girin (PDF'de mevcut)
3. Test sorguları çalıştırın
4. Performansı değerlendirin

---

## ⚙️ Önemli Ayarlar

### Checkpoint Sistemi

Her notebook'ta checkpoint sistemi var. Colab ücretsiz sürümde 12 saat limiti olduğu için:

```python
# Checkpoint kaydet
save_checkpoint(processed_files, extracted_data)

# Checkpoint yükle
processed_files, extracted_data = load_checkpoint()
```

Eğer işlem kesilirse, notebook'u yeniden başlatıp kaldığınız yerden devam edebilirsiniz.

### GPU Kullanımı

```python
import torch
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
```

GPU yoksa `Runtime > Change runtime type > GPU` seçin.

### Batch Size Ayarlama

GPU memory'nize göre:
- T4 GPU (ücretsiz Colab): BATCH_SIZE = 32
- V100/A100 (Colab Pro): BATCH_SIZE = 64-128

---

## 📊 Beklenen Sonuçlar

### Data Preprocessing
- **Girdi:** ~1000 PDF kitap (~47 GB)
- **Çıktı:** ~500K-1M chunk (~4-8 GB JSON)
- **Süre:** 6-10 saat

### Embedding Creation
- **Girdi:** ~1M chunk
- **Çıktı:** ~1M embedding vector (1024 dim) (~4 GB)
- **Süre:** 3-6 saat

### Vector DB Upload
- **Girdi:** 1M embedding
- **Çıktı:** Aranabilir vector index
- **Süre:** 1-2 saat

### RAG Testing
- **Ortalama Yanıt Süresi:** 2-5 saniye
- **Doğruluk:** Kaynaklara bağlı
- **Maliyet:** ~$0.07 / 1K request (Gemini API)

---

## 🔑 API Keys ve Credentials

### Gemini API
- **Key:** `YOUR_GEMINI_API_KEY_HERE`
- **Model:** Gemini 1.5 Pro (veya 2.5 Pro mevcut olduğunda)
- **Usage:** Pay-as-you-go

### Pinecone (Opsiyonel)
- **Hesap:** [pinecone.io](https://www.pinecone.io/)
- **Free Tier:** 1M vectors
- **Paid:** $70/month (unlimited)

### ChromaDB (Opsiyonel - Ücretsiz)
- Hesap gerekmez
- Google Drive'a kaydedilir

---

## 🐛 Sorun Giderme

### Problem: "GPU not found"
**Çözüm:** Runtime > Change runtime type > GPU seçin

### Problem: "Out of memory"
**Çözüm:** BATCH_SIZE'ı azaltın (32 → 16)

### Problem: "Session timeout (12 hours)"
**Çözüm:**
- Colab Pro ($10/ay) - 24 saat limit
- Checkpoint'ten devam et

### Problem: "Drive mount failed"
**Çözüm:**
- Colab'a Drive erişim izni verin
- `drive.mount('/content/drive', force_remount=True)`

### Problem: "Pinecone API error"
**Çözüm:**
- API key'i kontrol edin
- Environment region'ı doğrulayın
- Alternatif: ChromaDB kullanın

---

## 💡 İpuçları

1. **Colab Pro Kullanın:** Daha hızlı GPU, daha fazla RAM, daha uzun süre
2. **Gece Çalıştırın:** Uzun işlemleri gece başlatın
3. **Checkpoint'leri Silmeyin:** Hata durumunda kurtarır
4. **Batch Size:** Başlangıçta küçük tutun, sonra artırın
5. **Test Edin:** Her notebook'u test ettikten sonra bir sonrakine geçin

---

## 📈 Performans Optimizasyonu

### CPU/GPU Kullanımı
```python
# Multi-threading
from multiprocessing import Pool

# GPU memory management
torch.cuda.empty_cache()

# Batch processing
for batch in tqdm(batches):
    process_batch(batch)
```

### Memory Management
```python
# Büyük dosyaları chunk chunk işle
for chunk in read_large_file_in_chunks():
    process(chunk)
    del chunk
    gc.collect()
```

---

## ✅ Tamamlanma Kontrolü

Her notebook sonunda şu dosyalar oluşmalı:

### Notebook 1:
- ✅ `chunks.json` (~4-8 GB)
- ✅ `stats.json`
- ✅ `processing_checkpoint.pkl`

### Notebook 2:
- ✅ `embeddings.npy` (~4 GB)
- ✅ `embeddings_metadata.json`
- ✅ `embeddings_checkpoint.pkl`

### Notebook 3:
- ✅ `vector_db_config.json`
- ✅ Pinecone index VEYA ChromaDB klasörü

### Notebook 4:
- ✅ Test sonuçları başarılı
- ✅ API fonksiyonu çalışıyor

---

## 🔗 Sonraki Adımlar

Tüm notebook'lar tamamlandıktan sonra:

1. ✅ `vector_db_config.json` dosyasını kaydedin
2. ✅ Firebase Cloud Function kurulumuna geçin
3. ✅ Flutter app geliştirmeye başlayın
4. ✅ RAG pipeline'ı app'e entegre edin

---

## 📞 Destek

Herhangi bir sorun yaşarsanız:
- Notebook içindeki hata mesajlarını kontrol edin
- Checkpoint'leri kullanarak kaldığınız yerden devam edin
- GPU/RAM kullanımını kontrol edin

---

**Not:** Bu notebook'lar bilgisayarınıza hiçbir şey indirmeden tamamen Google Cloud üzerinde çalışır!
