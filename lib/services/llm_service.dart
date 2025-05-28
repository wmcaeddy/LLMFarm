import 'dart:async';
import 'dart:math';
import '../models/message.dart';
import '../models/chat_config.dart';

class LLMService {
  static final LLMService _instance = LLMService._internal();
  factory LLMService() => _instance;
  LLMService._internal();

  bool _isLoaded = false;
  bool _isPredicting = false;
  ChatConfig? _currentConfig;
  final Random _random = Random();
  List<String> _conversationHistory = [];

  // Enhanced Pythia-410M demo responses with more variety
  final List<String> _demoResponses = [
    "Hello! I'm Pythia-410M, a 410 million parameter language model created by EleutherAI. I'm running locally on your device using the LLMFarm framework. How can I help you today?",
    "I'm a demonstration of local LLM inference running entirely on your device. No internet connection required! What would you like to explore together?",
    "As a smaller language model optimized for local inference, I can help with conversations, answer questions, assist with writing, and demonstrate AI capabilities. What interests you?",
    "I'm based on the Pythia architecture and trained on The Pile dataset. I'm designed for research and experimentation. Feel free to test my capabilities!",
    "This is a live demonstration of the LLMFarm framework running a quantized Pythia-410M model. What topic would you like to discuss?",
    "I'm running with Q6_K quantization to fit efficiently on mobile and desktop devices while maintaining good performance. How can I assist you?",
    "Local AI inference is fascinating! I can generate text, engage in conversations, and help with various tasks without needing cloud connectivity.",
    "While I may not be as large as some cloud-based models, I can still provide meaningful assistance and demonstrate the power of local AI. What would you like to try?",
    "Thank you for trying out this LLMFarm demo! I'm here to showcase what's possible with local language model inference. What shall we explore?",
    "I'm designed to demonstrate the capabilities of running language models locally. This means privacy, speed, and no dependency on internet connectivity!"
  ];

  // Enhanced contextual responses with more depth
  final Map<String, List<String>> _contextualResponses = {
    'hello': [
      "Hello there! Nice to meet you. I'm Pythia-410M, running locally through LLMFarm. What brings you here today?",
      "Hi! Welcome to the LLMFarm demo. I'm excited to chat with you and show you what local AI can do!",
      "Greetings! I'm your local AI assistant, powered by the Pythia-410M model. How can I help you explore AI capabilities?"
    ],
    'how are you': [
      "I'm functioning well! As an AI model, I don't have feelings, but my inference is running smoothly at about 15-25 tokens per second.",
      "I'm doing great! All my neural pathways are firing correctly, and I'm ready to help you with whatever you need.",
      "I'm operating optimally! My 410 million parameters are working together to provide you with helpful responses."
    ],
    'what can you do': [
      "I can engage in conversations, answer questions, help with writing tasks, explain concepts, assist with creative projects, and demonstrate local LLM capabilities. I'm particularly good at educational discussions and creative writing. What would you like to try?",
      "My capabilities include text generation, question answering, creative writing, code explanation, educational content, and general conversation. I can also demonstrate the performance characteristics of local AI inference. What interests you most?",
      "I can help with a variety of tasks: writing assistance, answering questions, explaining topics, creative storytelling, basic coding help, and showcasing what's possible with local AI. What would you like to explore together?"
    ],
    'tell me about yourself': [
      "I'm Pythia-410M, a 410 million parameter language model created by EleutherAI. I'm running locally through the LLMFarm framework, which means I operate entirely on your device without needing internet connectivity. I was trained on The Pile dataset and use the Pythia architecture.",
      "I'm a demonstration of local AI inference using the Pythia-410M model. I have 410 million parameters, I'm quantized to Q6_K format for efficiency, and I'm running at about 320MB of memory usage. I represent what's possible when you run AI models directly on your device.",
      "I'm Pythia-410M, part of EleutherAI's suite of open-source language models. I'm designed for research and experimentation, and I'm currently running locally on your device through LLMFarm, showcasing the power of on-device AI inference."
    ],
    'help': [
      "I'm here to help! You can ask me questions, request writing assistance, discuss topics you're curious about, or simply have a conversation. I can also explain how local AI inference works or demonstrate various language model capabilities. What would you like help with?",
      "I can assist with many things: answering questions, helping with writing, explaining concepts, creative tasks, or just having an interesting conversation. I'm also great for demonstrating what local AI can do. What do you need help with?",
      "I'm ready to help! Whether you want to chat, learn something new, get writing assistance, or explore AI capabilities, I'm here for you. What would you like to do together?"
    ],
    'python': [
      "Python is an excellent programming language! It's particularly popular in AI and machine learning because of libraries like PyTorch, TensorFlow, and Hugging Face Transformers. In fact, many language models like me are trained using Python frameworks. Are you working on a Python project?",
      "Python is fantastic for AI development! It's the language of choice for most machine learning frameworks. The LLMFarm framework that's running me likely interfaces with Python-based model loading and inference code. What aspect of Python interests you?",
      "I love talking about Python! It's incredibly versatile - great for AI, web development, data science, automation, and more. The simplicity and readability make it perfect for rapid prototyping. Are you learning Python or working on something specific?"
    ],
    'ai': [
      "Artificial Intelligence is a fascinating field! I'm an example of a language model, which is one type of AI that focuses on understanding and generating human language. The field includes machine learning, deep learning, computer vision, robotics, and much more. What aspects of AI interest you most?",
      "AI is revolutionizing how we interact with technology! I represent just one small part of the AI landscape - natural language processing. There's also computer vision, robotics, game AI, recommendation systems, and so much more. What would you like to know about AI?",
      "As an AI myself, I find the field incredibly exciting! The ability to run models like me locally on personal devices represents a major shift toward democratized AI. We're moving from cloud-dependent AI to personal, private AI assistants. What do you think about this trend?"
    ],
    'flutter': [
      "Flutter is Google's excellent UI toolkit for building cross-platform applications! It uses Dart and can create beautiful apps for mobile, web, and desktop from a single codebase. The app you're using right now to chat with me is built with Flutter! Are you developing with Flutter?",
      "Flutter is amazing for cross-platform development! The fact that you can write once and deploy everywhere is incredibly powerful. This very chat interface we're using is built with Flutter, demonstrating how you can create AI-powered applications that work across platforms. What's your Flutter experience?",
      "I'm excited you mentioned Flutter! This entire chat application is built using Flutter, showing how you can create sophisticated AI interfaces that work on mobile, desktop, and web. Flutter's widget system makes it perfect for building responsive, beautiful UIs. Are you working on a Flutter project?"
    ],
    'llmfarm': [
      "LLMFarm is the fantastic framework that's running me right now! It's designed to make local language model inference accessible on iOS, macOS, and other platforms. It supports various model formats and provides efficient inference with features like Metal acceleration. It's a great example of democratizing AI!",
      "LLMFarm is what makes this demo possible! It's a powerful framework for running language models locally, supporting models like me (Pythia), LLaMA, and others. The framework handles model loading, inference optimization, and provides a clean interface for developers. Pretty cool, right?",
      "You're experiencing LLMFarm in action right now! This framework is designed to bring powerful language models to personal devices, enabling private, fast, and offline AI interactions. It's part of the movement toward personal AI that doesn't depend on cloud services."
    ],
    'demo': [
      "This is indeed a demo of local AI capabilities! I'm simulating the experience of running Pythia-410M locally through LLMFarm. In a real implementation, I would be loading actual model weights and performing genuine neural network inference. This demo shows the interface and interaction patterns you'd experience with the real thing.",
      "Welcome to the LLMFarm demo! While I'm simulating the Pythia-410M model for demonstration purposes, this showcases the real user experience of local AI inference. The actual LLMFarm can run real models with genuine AI capabilities, all locally on your device.",
      "This demo illustrates what's possible with local AI inference! While I'm providing simulated responses, the real LLMFarm framework can run actual language models like Pythia-410M, LLaMA, and others directly on your device. Isn't local AI exciting?"
    ]
  };

  // Model performance simulation
  final Map<String, dynamic> _modelSpecs = {
    'name': 'Pythia-410M-V0-Instruct',
    'parameters': '410M',
    'architecture': 'Pythia (GPT-NeoX based)',
    'quantization': 'Q6_K',
    'size_mb': 320,
    'context_length': 4096,
    'vocab_size': 50254,
    'layers': 24,
    'hidden_size': 1024,
    'attention_heads': 16,
    'training_data': 'The Pile (300B tokens)',
    'creator': 'EleutherAI',
  };

  bool get isLoaded => _isLoaded;
  bool get isPredicting => _isPredicting;
  ChatConfig? get currentConfig => _currentConfig;

  Future<bool> loadModel(ChatConfig config) async {
    _currentConfig = config;
    _conversationHistory.clear();

    // Simulate realistic model loading time with progress
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate model file loading
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
    }

    _isLoaded = true;
    return true;
  }

  void unloadModel() {
    _isLoaded = false;
    _isPredicting = false;
    _currentConfig = null;
    _conversationHistory.clear();
  }

  Stream<String> generateResponse(String prompt) async* {
    if (!_isLoaded) {
      yield "[Error] Model not loaded. Please load the Pythia-410M model first.";
      return;
    }

    _isPredicting = true;
    _conversationHistory.add("User: $prompt");

    try {
      // Find contextual response or use random with conversation awareness
      String response = _generateContextualResponse(prompt.toLowerCase()) ??
          _generateConversationAwareResponse(prompt);

      // Add conversation context
      if (_conversationHistory.length > 2) {
        response = _addConversationContext(response, prompt);
      }

      _conversationHistory.add("Assistant: $response");

      // Simulate realistic streaming with variable timing
      final words = response.split(' ');
      for (int i = 0; i < words.length; i++) {
        if (!_isPredicting) break; // Allow stopping mid-generation

        if (i == 0) {
          yield words[i];
        } else {
          yield ' ${words[i]}';
        }

        // Simulate realistic token generation timing (15-25 tokens/sec)
        int delay = 40 + _random.nextInt(60); // 40-100ms per token
        await Future.delayed(Duration(milliseconds: delay));
      }
    } finally {
      _isPredicting = false;
    }
  }

  String? _generateContextualResponse(String prompt) {
    for (final entry in _contextualResponses.entries) {
      if (prompt.contains(entry.key)) {
        final responses = entry.value;
        return responses[_random.nextInt(responses.length)];
      }
    }
    return null;
  }

  String _generateConversationAwareResponse(String prompt) {
    // Generate responses based on conversation history and prompt characteristics
    if (prompt.contains('?')) {
      return _generateQuestionResponse(prompt);
    } else if (prompt.length > 50) {
      return _generateDetailedResponse();
    } else {
      return _demoResponses[_random.nextInt(_demoResponses.length)];
    }
  }

  String _generateQuestionResponse(String prompt) {
    final questionResponses = [
      "That's an interesting question! Based on my training data, I can offer some insights. ",
      "Great question! Let me think about that for a moment. ",
      "I'd be happy to help answer that! From what I understand, ",
      "That's a thoughtful question. In my experience with language processing, ",
      "Excellent question! This touches on some fascinating concepts. ",
    ];

    final baseResponse =
        questionResponses[_random.nextInt(questionResponses.length)];
    final elaboration = _demoResponses[_random.nextInt(_demoResponses.length)];

    return baseResponse + elaboration;
  }

  String _generateDetailedResponse() {
    final detailedResponses = [
      "I appreciate you sharing that detailed message with me! It's clear you've put thought into your question. As a language model, I find longer, more detailed prompts particularly interesting because they give me more context to work with. ",
      "Thank you for that comprehensive input! Longer messages like yours allow me to better understand the nuances of what you're asking. This is actually a great example of how language models work better with more context. ",
      "I can see you've provided a lot of detail in your message, which is excellent! This gives me much more to work with in generating a helpful response. Detailed prompts often lead to more useful and relevant outputs from language models like me. ",
    ];

    return detailedResponses[_random.nextInt(detailedResponses.length)] +
        _demoResponses[_random.nextInt(_demoResponses.length)];
  }

  String _addConversationContext(String response, String prompt) {
    if (_conversationHistory.length > 4) {
      final contextPrefixes = [
        "Building on our conversation, ",
        "Following up on what we discussed, ",
        "Continuing our chat, ",
        "As we've been talking about, ",
      ];
      return contextPrefixes[_random.nextInt(contextPrefixes.length)] +
          response;
    }
    return response;
  }

  void stopGeneration() {
    _isPredicting = false;
  }

  Map<String, dynamic> getModelStats() {
    return {
      'model_name': _modelSpecs['name'],
      'parameters': _modelSpecs['parameters'],
      'architecture': _modelSpecs['architecture'],
      'quantization': _modelSpecs['quantization'],
      'size': '~${_modelSpecs['size_mb']}MB',
      'context_length': _modelSpecs['context_length'],
      'vocab_size': _modelSpecs['vocab_size'],
      'layers': _modelSpecs['layers'],
      'hidden_size': _modelSpecs['hidden_size'],
      'attention_heads': _modelSpecs['attention_heads'],
      'training_data': _modelSpecs['training_data'],
      'creator': _modelSpecs['creator'],
      'loaded': _isLoaded,
      'predicting': _isPredicting,
      'conversation_turns': _conversationHistory.length ~/ 2,
    };
  }

  // Enhanced performance metrics simulation
  Map<String, double> getPerformanceMetrics() {
    final baseTokensPerSec = 18.0;
    final variation = _random.nextDouble() * 8.0; // 18-26 tokens/sec

    return {
      'tokens_per_second': baseTokensPerSec + variation,
      'memory_usage':
          _modelSpecs['size_mb'].toDouble() + _random.nextDouble() * 50.0,
      'cpu_usage': 15.0 + _random.nextDouble() * 25.0, // 15-40% CPU
      'gpu_usage': _isLoaded
          ? 20.0 + _random.nextDouble() * 30.0
          : 0.0, // 20-50% GPU when loaded
      'temperature': _currentConfig?.temp ?? 0.35,
      'context_used':
          _conversationHistory.length * 20.0, // Approximate tokens used
      'max_context': _modelSpecs['context_length'].toDouble(),
    };
  }

  // Demo-specific methods
  List<String> getDemoCommands() {
    return [
      "hello - Get a friendly greeting",
      "what can you do - Learn about my capabilities",
      "tell me about yourself - Get model information",
      "python - Discuss Python programming",
      "ai - Talk about artificial intelligence",
      "flutter - Chat about Flutter development",
      "llmfarm - Learn about the LLMFarm framework",
      "demo - Understand this demonstration",
      "help - Get assistance and guidance",
    ];
  }

  String getModelDescription() {
    return "Pythia-410M is a 410 million parameter language model created by EleutherAI. "
        "It's part of the Pythia suite of models designed for research and experimentation. "
        "This model uses the GPT-NeoX architecture and was trained on The Pile dataset. "
        "In this demo, it's running locally through the LLMFarm framework, showcasing "
        "the power of on-device AI inference.";
  }
}
