import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

/// Forum and community chat state management provider
/// Manages forum posts and real-time chat messages
class ForumProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Map<String, dynamic>> _forumPosts = [];
  List<Map<String, dynamic>> _chatMessages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get forumPosts => _forumPosts;
  List<Map<String, dynamic>> get chatMessages => _chatMessages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize forum posts stream
  void initForumStream() {
    _firestoreService.forumPostsStream().listen(
      (posts) {
        _forumPosts = posts;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  /// Initialize chat messages stream
  void initChatStream() {
    _firestoreService.chatMessagesStream().listen(
      (messages) {
        _chatMessages = messages;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  /// Add a new forum post
  Future<bool> addForumPost({
    required String userId,
    required String username,
    required String title,
    required String content,
    String? category,
  }) async {
    _isLoading = true;
    notifyListeners();

    final post = {
      'userId': userId,
      'username': username,
      'title': title,
      'content': content,
      'category': category ?? 'Genel',
      'createdAt': DateTime.now().toIso8601String(),
      'likes': 0,
      'commentCount': 0,
      'likedBy': [],
    };

    final result = await _firestoreService.addForumPost(post);

    _isLoading = false;

    if (result['success']) {
      return true;
    } else {
      _errorMessage = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Send a chat message
  Future<bool> sendChatMessage({
    required String userId,
    required String username,
    required String message,
    String? photoUrl,
  }) async {
    if (message.trim().isEmpty) return false;

    final chatMessage = {
      'userId': userId,
      'username': username,
      'message': message,
      'photoUrl': photoUrl,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final result = await _firestoreService.addChatMessage(chatMessage);

    if (result['success']) {
      return true;
    } else {
      _errorMessage = result['error'];
      notifyListeners();
      return false;
    }
  }

  /// Get forum posts by category
  List<Map<String, dynamic>> getPostsByCategory(String category) {
    if (category == 'Tümü' || category.isEmpty) {
      return _forumPosts;
    }

    return _forumPosts
        .where((post) => post['category'] == category)
        .toList();
  }

  /// Search forum posts
  List<Map<String, dynamic>> searchPosts(String query) {
    if (query.trim().isEmpty) {
      return _forumPosts;
    }

    final lowerQuery = query.toLowerCase();

    return _forumPosts.where((post) {
      final title = (post['title'] ?? '').toString().toLowerCase();
      final content = (post['content'] ?? '').toString().toLowerCase();
      final username = (post['username'] ?? '').toString().toLowerCase();

      return title.contains(lowerQuery) ||
          content.contains(lowerQuery) ||
          username.contains(lowerQuery);
    }).toList();
  }

  /// Get recent chat messages (last N messages)
  List<Map<String, dynamic>> getRecentMessages(int count) {
    if (_chatMessages.length <= count) {
      return _chatMessages;
    }

    return _chatMessages.sublist(_chatMessages.length - count);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh forum posts
  void refreshPosts() {
    initForumStream();
  }

  /// Refresh chat messages
  void refreshChat() {
    initChatStream();
  }
}
