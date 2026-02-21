import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}

/// Chatbot state management provider
/// Manages conversation with AI chatbot
class ChatProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isChatbotVisible = true;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isChatbotVisible => _isChatbotVisible;

  /// Initialize with welcome message
  void init() {
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessage(
          text:
              'Merhaba! Ben KPSS Canavari AI asistanınızım. Size nasıl yardımcı olabilirim?\n\nŞunları yapabilirim:\n• Sorularınızı çözmek\n• Konuları anlatmak\n• Test oluşturmak\n• Performansınızı analiz etmek\n• Çalışma tavsiyeleri vermek',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  /// Send message to chatbot
  Future<void> sendMessage(String message, {List<String>? context}) async {
    if (message.trim().isEmpty) return;

    // Add user message
    _messages.add(
      ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    _isLoading = true;
    notifyListeners();

    try {
      // Get response from Gemini
      final response = await _geminiService.chat(
        message: message,
        context: context,
      );

      // Add AI response
      _messages.add(
        ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      // Add error message
      _messages.add(
        ChatMessage(
          text: 'Üzgünüm, bir hata oluştu: ${e.toString()}',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear chat history
  void clearChat() {
    _messages.clear();
    init(); // Add welcome message again
    notifyListeners();
  }

  /// Toggle chatbot visibility
  void toggleChatbotVisibility() {
    _isChatbotVisible = !_isChatbotVisible;
    notifyListeners();
  }

  /// Show chatbot
  void showChatbot() {
    _isChatbotVisible = true;
    notifyListeners();
  }

  /// Hide chatbot
  void hideChatbot() {
    _isChatbotVisible = false;
    notifyListeners();
  }

  /// Delete specific message
  void deleteMessage(int index) {
    if (index >= 0 && index < _messages.length) {
      _messages.removeAt(index);
      notifyListeners();
    }
  }

  /// Regenerate last AI response
  Future<void> regenerateLastResponse() async {
    if (_messages.length < 2) return;

    // Remove last AI message
    if (!_messages.last.isUser) {
      _messages.removeLast();
    }

    // Get last user message
    final lastUserMessage = _messages.lastWhere(
      (msg) => msg.isUser,
      orElse: () => ChatMessage(
        text: '',
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    if (lastUserMessage.text.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Get new response from Gemini
      final response = await _geminiService.chat(
        message: lastUserMessage.text,
      );

      // Add new AI response
      _messages.add(
        ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      _messages.add(
        ChatMessage(
          text: 'Üzgünüm, bir hata oluştu: ${e.toString()}',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get conversation context (last N messages)
  List<String> getContext({int messageCount = 5}) {
    final contextMessages = _messages.length > messageCount
        ? _messages.sublist(_messages.length - messageCount)
        : _messages;

    return contextMessages
        .map((msg) => '${msg.isUser ? "User" : "AI"}: ${msg.text}')
        .toList();
  }
}
