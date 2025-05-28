import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/chat_config.dart';
import '../services/llm_service.dart';
import '../widgets/message_widget.dart';
import '../widgets/chat_input.dart';
import '../widgets/model_info_panel.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final LLMService _llmService = LLMService();
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isPredicting = false;
  double _loadProgress = 0.0;
  ChatConfig _config = const ChatConfig();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    _addSystemMessage(
      "🚀 Welcome to LLM Chat Flutter - Pythia-410M Demo!",
    );
    _addSystemMessage(
      "This is a demonstration of the LLMFarm framework running a simulated Pythia-410M language model (410M parameters, ~320MB).",
    );
    _addSystemMessage(
      "✨ Try these demo commands to explore AI capabilities:\n"
      "• 'hello' - Get a friendly greeting\n"
      "• 'what can you do' - Learn about capabilities\n"
      "• 'tell me about yourself' - Model information\n"
      "• 'python' - Discuss programming\n"
      "• 'ai' - Talk about artificial intelligence\n"
      "• 'flutter' - Chat about app development\n"
      "• 'llmfarm' - Learn about the framework\n"
      "• 'demo' - Understand this demonstration",
    );
    _addSystemMessage("Click 'Load Model' to start chatting with the AI! 🤖");
  }

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add(
        Message(
          sender: MessageSender.system,
          state: MessageState.typed,
          text: text,
        ),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
      _loadProgress = 0.0;
    });

    try {
      // Simulate loading progress
      for (int i = 0; i <= 100; i += 10) {
        setState(() {
          _loadProgress = i / 100.0;
        });
        await Future.delayed(const Duration(milliseconds: 200));
      }

      final success = await _llmService.loadModel(_config);
      if (success) {
        _addSystemMessage(
          "✅ Pythia-410M model loaded successfully! You can now start chatting.",
        );
      } else {
        _addSystemMessage("❌ Failed to load model. Please try again.");
      }
    } catch (e) {
      _addSystemMessage("❌ Error loading model: $e");
    }

    setState(() {
      _isLoading = false;
      _loadProgress = 0.0;
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(
        Message(
          sender: MessageSender.user,
          state: MessageState.typed,
          text: text,
        ),
      );
    });
    _textController.clear();
    _scrollToBottom();

    // Load model if not loaded
    if (!_llmService.isLoaded) {
      await _loadModel();
      if (!_llmService.isLoaded) return;
    }

    // Create system response message
    final systemMessage = Message(
      sender: MessageSender.system,
      state: MessageState.predicting,
      text: "",
    );

    setState(() {
      _messages.add(systemMessage);
      _isPredicting = true;
    });
    _scrollToBottom();

    try {
      // Start streaming response
      await for (final token in _llmService.generateResponse(text)) {
        setState(() {
          if (_messages.isNotEmpty &&
              _messages.last.sender == MessageSender.system) {
            _messages.last.text += token;
            _messages.last.state = MessageState.predicting;
          }
        });
        _scrollToBottom();
      }

      // Mark as completed
      setState(() {
        if (_messages.isNotEmpty &&
            _messages.last.sender == MessageSender.system) {
          _messages.last.state = MessageState.predicted;
          final metrics = _llmService.getPerformanceMetrics();
          _messages.last.tokSec = metrics['tokens_per_second'] ?? 0.0;
        }
        _isPredicting = false;
      });
    } catch (e) {
      setState(() {
        if (_messages.isNotEmpty &&
            _messages.last.sender == MessageSender.system) {
          _messages.last.state = MessageState.error;
          _messages.last.text = "Error: $e";
        }
        _isPredicting = false;
      });
    }
  }

  void _stopGeneration() {
    _llmService.stopGeneration();
    setState(() {
      if (_messages.isNotEmpty &&
          _messages.last.sender == MessageSender.system) {
        _messages.last.state = MessageState.predicted;
      }
      _isPredicting = false;
    });
  }

  void _clearMessages() {
    setState(() {
      _messages.clear();
    });
    _initializeChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LLM Chat Flutter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: _loadProgress,
                  strokeWidth: 2,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showModelInfo(context),
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Model status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _llmService.isLoaded
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  _llmService.isLoaded ? Icons.check_circle : Icons.warning,
                  color: _llmService.isLoaded ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _llmService.isLoaded
                      ? 'Pythia-410M Ready'
                      : 'Model Not Loaded',
                  style: TextStyle(
                    color: _llmService.isLoaded ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (!_llmService.isLoaded)
                  TextButton(
                    onPressed: _isLoading ? null : _loadModel,
                    child: const Text('Load Model'),
                  ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageWidget(message: _messages[index]);
              },
            ),
          ),

          // Chat input
          ChatInput(
            controller: _textController,
            onSend: _sendMessage,
            onStop: _stopGeneration,
            isPredicting: _isPredicting,
            isModelLoaded: _llmService.isLoaded,
          ),
        ],
      ),
    );
  }

  void _showModelInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ModelInfoPanel(
        stats: _llmService.getModelStats(),
        metrics: _llmService.getPerformanceMetrics(),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
