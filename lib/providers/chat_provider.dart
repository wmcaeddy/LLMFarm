import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../models/chat_config.dart';
import '../services/llm_service.dart';

enum ChatState { none, loading, ragIndexLoading, ragSearch, completed }

class ChatProvider with ChangeNotifier {
  final LLMService _llmService = LLMService();

  List<Message> _messages = [];
  ChatState _state = ChatState.none;
  bool _predicting = false;
  double _loadProgress = 0.0;
  String _title = "Demo Chat";
  bool _isMultimodal = false;
  int _currentEvalTokenNum = 0;
  int _queryTokensCount = 0;
  ChatConfig _config = const ChatConfig();
  StreamSubscription<String>? _responseSubscription;

  // Getters
  List<Message> get messages => _messages;
  ChatState get state => _state;
  bool get predicting => _predicting;
  double get loadProgress => _loadProgress;
  String get title => _title;
  bool get isMultimodal => _isMultimodal;
  int get currentEvalTokenNum => _currentEvalTokenNum;
  int get queryTokensCount => _queryTokensCount;
  ChatConfig get config => _config;
  bool get isModelLoaded => _llmService.isLoaded;

  void updateConfig(ChatConfig newConfig) {
    _config = newConfig;
    _title = newConfig.title;
    notifyListeners();
  }

  Future<void> loadModel() async {
    _state = ChatState.loading;
    _loadProgress = 0.0;
    notifyListeners();

    try {
      // Simulate loading progress
      for (int i = 0; i <= 100; i += 10) {
        _loadProgress = i / 100.0;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 200));
      }

      final success = await _llmService.loadModel(_config);
      if (success) {
        _state = ChatState.completed;
        _addSystemMessage(
          "Model loaded successfully! You can now start chatting with Pythia-410M.",
        );
      } else {
        _state = ChatState.none;
        _addSystemMessage("Failed to load model. Please try again.");
      }
    } catch (e) {
      _state = ChatState.none;
      _addSystemMessage("Error loading model: $e");
    }

    _loadProgress = 0.0;
    notifyListeners();
  }

  void unloadModel() {
    _llmService.unloadModel();
    _state = ChatState.none;
    _predicting = false;
    notifyListeners();
  }

  Future<void> sendMessage(
    String text, {
    String? attachment,
    String? attachmentType,
  }) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = Message(
      sender: MessageSender.user,
      state: MessageState.typed,
      text: text,
      attachment: attachment,
      attachmentType: attachmentType,
    );
    _messages.add(userMessage);
    notifyListeners();

    // Load model if not loaded
    if (!_llmService.isLoaded) {
      await loadModel();
      if (!_llmService.isLoaded) return;
    }

    // Create system response message
    final systemMessage = Message(
      sender: MessageSender.system,
      state: MessageState.predicting,
      text: "",
    );
    _messages.add(systemMessage);
    _predicting = true;
    notifyListeners();

    try {
      // Start streaming response
      final responseStream = _llmService.generateResponse(text);
      _responseSubscription = responseStream.listen(
        (token) {
          // Update the last message with new token
          if (_messages.isNotEmpty &&
              _messages.last.sender == MessageSender.system) {
            _messages.last.text += token;
            _messages.last.state = MessageState.predicting;
            notifyListeners();
          }
        },
        onDone: () {
          // Mark as completed
          if (_messages.isNotEmpty &&
              _messages.last.sender == MessageSender.system) {
            _messages.last.state = MessageState.predicted;
            final metrics = _llmService.getPerformanceMetrics();
            _messages.last.tokSec = metrics['tokens_per_second'] ?? 0.0;
          }
          _predicting = false;
          notifyListeners();
        },
        onError: (error) {
          if (_messages.isNotEmpty &&
              _messages.last.sender == MessageSender.system) {
            _messages.last.state = MessageState.error;
            _messages.last.text = "Error: $error";
          }
          _predicting = false;
          notifyListeners();
        },
      );
    } catch (e) {
      if (_messages.isNotEmpty &&
          _messages.last.sender == MessageSender.system) {
        _messages.last.state = MessageState.error;
        _messages.last.text = "Error: $e";
      }
      _predicting = false;
      notifyListeners();
    }
  }

  void stopGeneration() {
    _responseSubscription?.cancel();
    _llmService.stopGeneration();

    if (_messages.isNotEmpty && _messages.last.sender == MessageSender.system) {
      _messages.last.state = MessageState.predicted;
    }

    _predicting = false;
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void _addSystemMessage(String text) {
    final message = Message(
      sender: MessageSender.system,
      state: MessageState.typed,
      text: text,
    );
    _messages.add(message);
  }

  Map<String, dynamic> getModelStats() {
    return _llmService.getModelStats();
  }

  Map<String, double> getPerformanceMetrics() {
    return _llmService.getPerformanceMetrics();
  }

  void regenerateLastMessage() {
    if (_messages.length >= 2 &&
        _messages.last.sender == MessageSender.system &&
        _messages[_messages.length - 2].sender == MessageSender.user) {
      final userMessage = _messages[_messages.length - 2];
      _messages.removeLast(); // Remove the system response

      // Resend the user message
      sendMessage(
        userMessage.text,
        attachment: userMessage.attachment,
        attachmentType: userMessage.attachmentType,
      );
    }
  }

  @override
  void dispose() {
    _responseSubscription?.cancel();
    super.dispose();
  }
}
