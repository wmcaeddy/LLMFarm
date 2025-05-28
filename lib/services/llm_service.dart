import 'dart:async';
import 'dart:io';
import 'dart:math';
import '../models/message.dart';
import '../models/chat_config.dart';
import '../models/llm_model.dart';
import 'llm_platform_interface.dart';
import 'package:flutter/foundation.dart';

enum LLMState { idle, loading, loaded, generating, error }

class LLMService {
  static final LLMService _instance = LLMService._internal();
  factory LLMService() => _instance;
  LLMService._internal();

  final LLMPlatformInterface _platform = LLMPlatformInterface.instance;

  LLMState _state = LLMState.idle;
  LLMModel? _currentModel;
  LLMModelVariant? _currentVariant;
  ChatConfig _config = const ChatConfig();
  String _lastError = '';

  // State getters
  LLMState get state => _state;
  LLMModel? get currentModel => _currentModel;
  LLMModelVariant? get currentVariant => _currentVariant;
  ChatConfig get config => _config;
  String get lastError => _lastError;
  bool get isLoaded => _state == LLMState.loaded;
  bool get isGenerating => _state == LLMState.generating;

  // Current model display name
  String get currentModelDisplayName {
    if (_currentModel == null) return 'No Model Loaded';
    String name = _currentModel!.name;
    if (_currentVariant != null) {
      name += ' (${_currentVariant!.quantization})';
    }
    return name;
  }

  // Load a model with configuration
  Future<bool> loadModel({
    required LLMModel model,
    LLMModelVariant? variant,
    ChatConfig? config,
  }) async {
    try {
      _setState(LLMState.loading);
      _lastError = '';

      // Update configuration if provided
      if (config != null) {
        _config = config;
      }

      // Use the first variant if none specified
      final selectedVariant = variant ?? model.recommendedVariant;

      // Ensure we have a valid variant
      if (selectedVariant == null && !model.name.contains('Demo')) {
        _lastError = 'No suitable variant available for model: ${model.name}';
        _setState(LLMState.error);
        return false;
      }

      // For demo model, we simulate successful loading
      if (model.name.contains('Demo')) {
        await Future.delayed(const Duration(milliseconds: 500));
        _currentModel = model;
        _currentVariant = selectedVariant;
        _setState(LLMState.loaded);
        return true;
      }

      // Build model file path (in Documents/models/ directory)
      final modelPath = 'models/${selectedVariant!.fileName}';

      // Load model using platform interface
      final success = await _platform.loadModel(
        modelPath: modelPath,
        config: _config,
        model: model,
        variant: selectedVariant,
      );

      if (success) {
        _currentModel = model;
        _currentVariant = selectedVariant;
        _setState(LLMState.loaded);
        return true;
      } else {
        _lastError = 'Failed to load model: ${model.name}';
        _setState(LLMState.error);
        return false;
      }
    } catch (e) {
      _lastError = 'Error loading model: $e';
      _setState(LLMState.error);
      return false;
    }
  }

  // Unload the current model
  Future<void> unloadModel() async {
    try {
      await _platform.unloadModel();
      _currentModel = null;
      _currentVariant = null;
      _setState(LLMState.idle);
    } catch (e) {
      _lastError = 'Error unloading model: $e';
      _setState(LLMState.error);
    }
  }

  // Generate a response to a prompt
  Stream<String> generateResponse(String prompt) async* {
    if (_state != LLMState.loaded) {
      yield 'Error: No model loaded';
      return;
    }

    try {
      _setState(LLMState.generating);

      // For demo model, use simulated responses
      if (_currentModel?.name.contains('Demo') == true) {
        yield* _generateDemoResponse(prompt);
        return;
      }

      // Format prompt according to model's requirements
      final formattedPrompt = _formatPrompt(prompt);

      // Stream response from native LLM
      await for (final chunk in _platform.generateResponse(formattedPrompt)) {
        yield chunk;
      }
    } catch (e) {
      yield 'Error generating response: $e';
    } finally {
      _setState(LLMState.loaded);
    }
  }

  // Stop generation
  Future<void> stopGeneration() async {
    try {
      await _platform.stopGeneration();
      _setState(LLMState.loaded);
    } catch (e) {
      _lastError = 'Error stopping generation: $e';
    }
  }

  // Get model specifications
  Map<String, dynamic> getModelSpecs() {
    if (_currentModel == null) return {};

    return {
      'name': _currentModel!.name,
      'parameters': _currentModel!.parameterCount ?? 'Unknown',
      'architecture': _currentModel!.architecture,
      'quantization': _currentVariant?.quantization ?? 'Unknown',
      'size': _currentVariant?.size ?? 'Unknown',
      'context': _config.context,
      'temperature': _config.temp,
      'top_p': _config.topP,
      'top_k': _config.topK,
      'repeat_penalty': _config.repeatPenalty,
    };
  }

  // Get performance metrics
  Future<Map<String, double>> getPerformanceMetrics() async {
    try {
      if (_currentModel?.name.contains('Demo') == true) {
        return _getDemoPerformanceMetrics();
      }

      return await _platform.getPerformanceMetrics();
    } catch (e) {
      return _getDemoPerformanceMetrics();
    }
  }

  // Format prompt according to model's template
  String _formatPrompt(String prompt) {
    if (_currentModel == null) return prompt;

    final template = _currentModel!.promptFormat;
    return template.replaceAll('{{prompt}}', prompt);
  }

  // Demo response generation for offline testing
  Stream<String> _generateDemoResponse(String prompt) async* {
    final platformName = _getPlatformName();
    final isNativePlatform = platformName == "macOS" || platformName == "iOS";

    // Add clear indicator this is simulated
    if (isNativePlatform) {
      yield "[DEMO MODE - Real LLM Available] ";
    } else {
      yield "[DEMO MODE - Simulation Only] ";
    }
    await Future.delayed(const Duration(milliseconds: 200));

    // Generate model-specific responses based on the selected model architecture
    String response;
    final modelName = _currentModel?.name.toLowerCase() ?? "";

    if (modelName.contains('llama')) {
      response =
          "I'm simulating a Llama model response. In real mode, I would use Meta's Llama architecture to provide helpful, harmless, and honest responses. ";
    } else if (modelName.contains('phi')) {
      response =
          "I'm simulating a Phi model response. In real mode, I would use Microsoft's efficient Phi architecture optimized for reasoning tasks. ";
    } else if (modelName.contains('gemma')) {
      response =
          "I'm simulating a Gemma model response. In real mode, I would use Google's responsible AI principles to provide safe and helpful assistance. ";
    } else if (modelName.contains('qwen')) {
      response =
          "I'm simulating a Qwen model response. In real mode, I would use Alibaba's multilingual capabilities to assist in multiple languages. ";
    } else {
      response =
          "I'm simulating an AI model response. In real mode with actual LLM inference, I would process your input: \"${prompt.length > 50 ? prompt.substring(0, 50) + "..." : prompt}\" and generate contextual responses. ";
    }

    // Add platform-specific explanation
    if (isNativePlatform) {
      response += "\n\n✅ GOOD NEWS: You're running on $platformName!\n";
      response += "• LLMFarm CAN run actual LLM inference on this platform\n";
      response += "• Download GGUF model files to ~/Documents/models/\n";
      response += "• Select a real model (not Demo) for actual AI responses\n";
      response += "• Metal GPU acceleration is available\n\n";
      response += "To get real responses:\n";
      response +=
          "1. Download a model like 'llama-3.2-1b-instruct-q4_k_m.gguf'\n";
      response += "2. Place it in ~/Documents/models/\n";
      response += "3. Select it from the model list\n";
      response += "4. Load it and start chatting with actual AI!";
    } else {
      response += "\n\n⚠️ NOTE: You're seeing simulated responses because:\n";
      response += "• LLMFarm only works on iOS/macOS (Apple platforms)\n";
      response += "• You're running on $platformName\n";
      response +=
          "• Real LLM inference requires native Swift/Metal support\n\n";
      response +=
          "To get actual AI responses, run this app on an iPhone, iPad, or Mac with downloaded GGUF model files.";
    }

    final words = response.split(' ');
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (i == 0) {
        yield words[i];
      } else {
        yield ' ${words[i]}';
      }
    }
  }

  String _getPlatformName() {
    // Simple platform detection for demo purposes
    try {
      // Check if we're running on macOS
      if (Platform.isMacOS) return "macOS";
      if (Platform.isIOS) return "iOS";
      if (Platform.isWindows) return "Windows";
      if (Platform.isLinux) return "Linux";
      if (Platform.isAndroid) return "Android";
    } catch (e) {
      // Fallback for web or other platforms
    }
    return "Web Browser"; // Default for web
  }

  // Demo performance metrics
  Map<String, double> _getDemoPerformanceMetrics() {
    return {
      'tokens_per_second': 25.0 + Random().nextDouble() * 10,
      'memory_usage_mb': 400.0 + Random().nextDouble() * 100,
      'cpu_usage_percent': 30.0 + Random().nextDouble() * 20,
      'gpu_usage_percent':
          _config.useMetal ? 15.0 + Random().nextDouble() * 10 : 0.0,
    };
  }

  // State management
  void _setState(LLMState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  // State stream for UI updates
  final StreamController<LLMState> _stateController =
      StreamController<LLMState>.broadcast();
  Stream<LLMState> get stateStream => _stateController.stream;

  // Cleanup
  void dispose() {
    _stateController.close();
    unloadModel();
  }

  // Check if model is demo
  bool get isDemoModel {
    return _currentModel?.name.contains('Demo') ?? true;
  }
}
