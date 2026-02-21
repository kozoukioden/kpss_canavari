import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

/// Firebase Storage service for file uploads
/// Handles image and PDF uploads with progress tracking
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // ==================== PROFILE IMAGE OPERATIONS ====================

  /// Upload user profile image
  /// Returns download URL on success
  Future<Map<String, dynamic>> uploadProfileImage({
    required String userId,
    required File imageFile,
    Function(double)? onProgress,
  }) async {
    try {
      final fileName = 'profile_$userId${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('profile_images/$fileName');

      final uploadTask = ref.putFile(imageFile);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();

      return {
        'success': true,
        'message': 'Profil resmi yüklendi',
        'url': downloadUrl,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Delete user profile image
  Future<Map<String, dynamic>> deleteProfileImage(String userId) async {
    try {
      // Try different image extensions
      final extensions = ['.jpg', '.jpeg', '.png', '.webp'];

      for (var ext in extensions) {
        try {
          final fileName = 'profile_$userId$ext';
          final ref = _storage.ref().child('profile_images/$fileName');
          await ref.delete();
        } catch (e) {
          // Continue if file doesn't exist
          continue;
        }
      }

      return {'success': true, 'message': 'Profil resmi silindi'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== QUESTION IMAGE OPERATIONS ====================

  /// Upload question image
  Future<Map<String, dynamic>> uploadQuestionImage({
    required File imageFile,
    Function(double)? onProgress,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'question_$timestamp${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('question_images/$fileName');

      final uploadTask = ref.putFile(imageFile);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();

      return {
        'success': true,
        'message': 'Soru resmi yüklendi',
        'url': downloadUrl,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Delete question image by URL
  Future<Map<String, dynamic>> deleteQuestionImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();

      return {'success': true, 'message': 'Soru resmi silindi'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== PDF OPERATIONS ====================

  /// Upload PDF file
  Future<Map<String, dynamic>> uploadPDF({
    required File pdfFile,
    required String userId,
    Function(double)? onProgress,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'pdf_${userId}_$timestamp.pdf';
      final ref = _storage.ref().child('pdfs/$fileName');

      final uploadTask = ref.putFile(
        pdfFile,
        SettableMetadata(contentType: 'application/pdf'),
      );

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();

      return {
        'success': true,
        'message': 'PDF yüklendi',
        'url': downloadUrl,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Delete PDF by URL
  Future<Map<String, dynamic>> deletePDF(String pdfUrl) async {
    try {
      final ref = _storage.refFromURL(pdfUrl);
      await ref.delete();

      return {'success': true, 'message': 'PDF silindi'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== PODCAST AUDIO OPERATIONS ====================

  /// Upload podcast audio file
  Future<Map<String, dynamic>> uploadPodcastAudio({
    required File audioFile,
    required String podcastId,
    Function(double)? onProgress,
  }) async {
    try {
      final fileName = 'podcast_$podcastId.mp3';
      final ref = _storage.ref().child('podcasts/$fileName');

      final uploadTask = ref.putFile(
        audioFile,
        SettableMetadata(contentType: 'audio/mpeg'),
      );

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();

      return {
        'success': true,
        'message': 'Podcast yüklendi',
        'url': downloadUrl,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Delete podcast audio
  Future<Map<String, dynamic>> deletePodcastAudio(String podcastId) async {
    try {
      final fileName = 'podcast_$podcastId.mp3';
      final ref = _storage.ref().child('podcasts/$fileName');
      await ref.delete();

      return {'success': true, 'message': 'Podcast silindi'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Upload multiple images at once
  Future<Map<String, dynamic>> uploadMultipleImages({
    required List<File> imageFiles,
    required String folderName,
    Function(int completed, int total)? onProgress,
  }) async {
    try {
      final urls = <String>[];
      int completed = 0;

      for (var file in imageFiles) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'image_$timestamp${path.extension(file.path)}';
        final ref = _storage.ref().child('$folderName/$fileName');

        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        urls.add(url);

        completed++;
        onProgress?.call(completed, imageFiles.length);
      }

      return {
        'success': true,
        'message': '${urls.length} resim yüklendi',
        'urls': urls,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Get file metadata
  Future<Map<String, dynamic>> getFileMetadata(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      final metadata = await ref.getMetadata();

      return {
        'success': true,
        'metadata': {
          'name': metadata.name,
          'size': metadata.size,
          'contentType': metadata.contentType,
          'timeCreated': metadata.timeCreated?.toIso8601String(),
          'updated': metadata.updated?.toIso8601String(),
        },
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get storage usage for a folder
  Future<Map<String, dynamic>> getFolderSize(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      final result = await ref.listAll();

      int totalSize = 0;
      for (var item in result.items) {
        final metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
      }

      return {
        'success': true,
        'totalSize': totalSize,
        'fileCoun': result.items.length,
        'sizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// List all files in a folder
  Future<Map<String, dynamic>> listFiles(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      final result = await ref.listAll();

      final files = <Map<String, dynamic>>[];
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        final metadata = await item.getMetadata();

        files.add({
          'name': metadata.name,
          'url': url,
          'size': metadata.size,
          'contentType': metadata.contentType,
        });
      }

      return {
        'success': true,
        'files': files,
        'count': files.length,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }
}
