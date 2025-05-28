import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/chat_config.dart';
import '../models/llm_model.dart';
import '../services/llm_service.dart';
import '../services/model_service.dart';
import '../widgets/message_widget.dart';
import '../widgets/chat_input.dart';
import '../widgets/model_info_panel.dart';
import '../widgets/model_selection_dialog.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final LLMService _llmService = LLMService();
  final ModelService _modelService = ModelService();
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isPredicting = false;
  double _loadProgress = 0.0;
  ChatConfig _config = const ChatConfig();
  LLMModel? _currentModel;
  LLMModelVariant? _currentVariant;
  bool _isLoadingModel = false;
  String? _welcomeMessage;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _initializeModels();
  }

  @override
  void dispose() {
    _llmService.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    _addSystemMessage(
      "🚀 Welcome to LLM Chat Flutter!",
    );

    // Platform-specific welcome messages
    try {
      if (Platform.isMacOS || Platform.isIOS) {
        _addSystemMessage(
          "✅ GREAT! You're on ${Platform.isMacOS ? 'macOS' : 'iOS'} - Real LLM inference is supported!",
        );
        _addSystemMessage(
          "📱 For REAL AI responses: Download GGUF models to ~/Documents/models/ and select them.",
        );
        _addSystemMessage(
          "🤖 Available models (with real AI when downloaded):\n"
          "• Demo - Pythia 410M (Simulated for testing)\n"
          "• Llama 3.2 1B/3B (Real AI - download GGUF)\n"
          "• Phi-3.5 Mini (Real AI - download GGUF)\n"
          "• Gemma v2 2B (Real AI - download GGUF)\n"
          "• TinyLlama 1B (Real AI - download GGUF)\n"
          "• Qwen2.5-0.5B (Real AI - download GGUF)",
        );
        _addSystemMessage(
            "Click 'Select Model' and choose a real model for actual AI responses! 🤖");
      } else {
        _addSystemMessage(
          "⚠️ DEMO MODE ACTIVE: You're running on a platform that only supports simulated responses.",
        );
        _addSystemMessage(
          "📱 For REAL AI responses: Run this app on iOS/macOS with downloaded GGUF models.",
        );
        _addSystemMessage(
          "🤖 Available demo models (simulated responses only):\n"
          "• Demo - Pythia 410M (Simulated)\n"
          "• Llama 3.2 1B/3B (Simulated)\n"
          "• Phi-3.5 Mini (Simulated)\n"
          "• Gemma v2 2B (Simulated)\n"
          "• TinyLlama 1B (Simulated)\n"
          "• Qwen2.5-0.5B (Simulated)",
        );
        _addSystemMessage(
            "Click 'Select Model' to test the interface with simulated responses! 🎭");
      }
    } catch (e) {
      // Fallback for web
      _addSystemMessage(
        "⚠️ DEMO MODE ACTIVE: You're running on a web browser which only supports simulated responses.",
      );
      _addSystemMessage(
          "Click 'Select Model' to test the interface with simulated responses! 🎭");
    }
  }

  Future<void> _initializeModels() async {
    await _modelService.loadAvailableModels();

    // Set default demo model
    final demoModel = _modelService.getModelByName("Demo - Pythia 410M");
    if (demoModel != null) {
      setState(() {
        _currentModel = demoModel;
        _currentVariant = demoModel.recommendedVariant;
      });
    }
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

  void _showModelSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => ModelSelectionDialog(
        currentModel: _currentModel,
        onModelSelected: (model, variant) {
          setState(() {
            _currentModel = model;
            _currentVariant = variant;

            // Update config with model-specific settings
            _config = ChatConfig(
              model: variant.fileName,
              title: model.name,
              promptFormat: model.promptFormat,
              modelInference: _getModelInference(model),
            );
          });

          // Add system message about model change
          _addSystemMessage(
            "🔄 Switched to ${model.name} (${variant.quantization}). "
            "Click 'Load Model' to start chatting!",
          );

          // Unload current model so user needs to reload
          _llmService.unloadModel();
        },
      ),
    );
  }

  String _getModelInference(LLMModel model) {
    final modelName = model.name.toLowerCase();
    if (modelName.contains('llama')) return 'llama';
    if (modelName.contains('phi'))
      return 'llama'; // Phi models use llama inference
    if (modelName.contains('gemma'))
      return 'llama'; // Gemma models use llama inference
    if (modelName.contains('pythia')) return 'gpt-neox';
    return 'llama'; // Default to llama inference
  }

  Future<void> _loadModel() async {
    if (_currentModel == null || _currentVariant == null) {
      _addSystemMessage("❌ Please select a model first.");
      return;
    }

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

      final success = await _llmService.loadModel(
        model: _currentModel!,
        variant: _currentVariant,
        config: _config,
      );

      if (success) {
        _addSystemMessage(
          "✅ ${_currentModel!.name} loaded successfully! You can now start chatting.",
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

  Future<void> _loadSelectedModel() async {
    if (_currentModel == null) return;

    setState(() {
      _isLoadingModel = true;
    });

    final success = await _llmService.loadModel(
      model: _currentModel!,
      variant: _currentVariant,
      config: _config,
    );

    setState(() {
      _isLoadingModel = false;
    });

    if (success) {
      setState(() {
        _welcomeMessage = _getWelcomeMessage();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Model loaded: ${_currentModel!.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load model: ${_llmService.lastError}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getWelcomeMessage() {
    if (_currentModel == null) return "Welcome to LLM Chat!";

    final modelName = _currentModel!.name;
    if (modelName.contains('Demo')) {
      return "🚀 Demo model ready! This is a simulated AI for testing the interface.";
    } else if (modelName.contains('Llama')) {
      return "🦙 Llama model loaded! Ready for intelligent conversations.";
    } else if (modelName.contains('Phi')) {
      return "🔬 Phi model ready! Optimized for reasoning and efficiency.";
    } else if (modelName.contains('Gemma')) {
      return "💎 Gemma model loaded! Google's safe and helpful AI assistant.";
    } else if (modelName.contains('Qwen')) {
      return "🌟 Qwen model ready! Multilingual AI assistant from Alibaba Cloud.";
    }

    return "🤖 ${modelName} loaded and ready to chat!";
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
      await _loadSelectedModel();
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
        }
        _isPredicting = false;
      });

      // Get performance metrics and update message
      try {
        final metrics = await _llmService.getPerformanceMetrics();
        setState(() {
          if (_messages.isNotEmpty &&
              _messages.last.sender == MessageSender.system) {
            _messages.last.tokSec = metrics['tokens_per_second'] ?? 0.0;
          }
        });
      } catch (e) {
        print('Error getting performance metrics: $e');
      }
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

  void _showModelInfo(BuildContext context) async {
    final modelSpecs = _llmService.getModelSpecs();
    final performanceMetrics = await _llmService.getPerformanceMetrics();

    showDialog(
      context: context,
      builder: (context) => ModelInfoPanel(
        stats: modelSpecs,
        metrics: performanceMetrics,
      ),
    );
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
            icon: const Icon(Icons.smart_toy),
            onPressed: _showModelSelectionDialog,
            tooltip: 'Select Model',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showModelInfo(context),
            tooltip: 'Model Info',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearMessages,
            tooltip: 'Clear Messages',
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
                ? (_llmService.isDemoModel
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1))
                : Colors.orange.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  _llmService.isLoaded
                      ? (_llmService.isDemoModel
                          ? Icons.theaters
                          : Icons.check_circle)
                      : Icons.warning,
                  color: _llmService.isLoaded
                      ? (_llmService.isDemoModel ? Colors.blue : Colors.green)
                      : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _llmService.isLoaded
                            ? '${_llmService.isDemoModel ? "[DEMO] " : ""}${_llmService.currentModelDisplayName} Ready'
                            : _currentModel != null
                                ? '${_currentModel!.name} Not Loaded'
                                : 'No Model Selected',
                        style: TextStyle(
                          color: _llmService.isLoaded
                              ? (_llmService.isDemoModel
                                  ? Colors.blue
                                  : Colors.green)
                              : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          if (_currentVariant != null)
                            Text(
                              '${_currentVariant!.quantization} (${_currentVariant!.size})',
                              style: TextStyle(
                                color: _llmService.isLoaded
                                    ? (_llmService.isDemoModel
                                        ? Colors.blue.shade700
                                        : Colors.green.shade700)
                                    : Colors.orange.shade700,
                                fontSize: 12,
                              ),
                            ),
                          if (_llmService.isDemoModel &&
                              _llmService.isLoaded) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• Simulated on Web',
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (_currentModel == null)
                  ElevatedButton.icon(
                    onPressed: _showModelSelectionDialog,
                    icon: const Icon(Icons.smart_toy, size: 16),
                    label: const Text('Select Model'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  )
                else if (!_llmService.isLoaded)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadModel,
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Load Model'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
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
}
