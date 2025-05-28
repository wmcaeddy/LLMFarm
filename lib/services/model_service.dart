import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/llm_model.dart';

class ModelService {
  static final ModelService _instance = ModelService._internal();
  factory ModelService() => _instance;
  ModelService._internal();

  List<LLMModel> _availableModels = [];
  bool _isLoaded = false;

  List<LLMModel> get availableModels => _availableModels;
  bool get isLoaded => _isLoaded;

  Future<void> loadAvailableModels() async {
    if (_isLoaded) return;

    try {
      // Try to load from assets first (Flutter app bundle)
      String jsonString;
      try {
        jsonString =
            await rootBundle.loadString('assets/downloadable_models.json');
      } catch (e) {
        // If not found in assets, try to load from LLMFarm directory
        final file = File('LLMFarm/Settings/downloadable_models.json');
        if (await file.exists()) {
          jsonString = await file.readAsString();
        } else {
          // Fallback to built-in models if no file found
          jsonString = _getBuiltInModelsJson();
        }
      }

      final List<dynamic> modelsJson = json.decode(jsonString);
      _availableModels =
          modelsJson.map((modelJson) => LLMModel.fromJson(modelJson)).toList();

      // Add demo model at the beginning
      _availableModels.insert(0, _createDemoModel());

      _isLoaded = true;
    } catch (e) {
      print('Error loading models: $e');
      // Fallback to built-in models
      _availableModels = _getBuiltInModels();
      _isLoaded = true;
    }
  }

  LLMModel _createDemoModel() {
    return const LLMModel(
      name: "Demo - Pythia 410M",
      variants: [
        LLMModelVariant(
          url: "[DEMO]",
          fileName: "[DEMO].gguf",
          size: "320MB",
          quantization: "Q6_K",
        ),
      ],
      description: "A demonstration model for testing the LLMFarm framework",
      parameterCount: "410M",
      architecture: "Pythia (GPT-NeoX)",
    );
  }

  List<LLMModel> _getBuiltInModels() {
    return [
      _createDemoModel(),
      const LLMModel(
        name: "Llama 3.2 Instruct 1B",
        variants: [
          LLMModelVariant(
            url:
                "https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf",
            fileName: "Llama-3.2-1B-Instruct-Q4_K_M.gguf",
            size: "0.7GB",
            quantization: "Q4_K_M",
          ),
          LLMModelVariant(
            url:
                "https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q5_K_M.gguf",
            fileName: "Llama-3.2-1B-Instruct-Q5_K_M.gguf",
            size: "0.8GB",
            quantization: "Q5_K_M",
          ),
        ],
        description: "Llama 3.2 1B is a lightweight instruction-tuned model",
        parameterCount: "1B",
        architecture: "Llama",
      ),
      const LLMModel(
        name: "Qwen2.5-0.5B-Instruct",
        variants: [
          LLMModelVariant(
            url:
                "https://huggingface.co/bartowski/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/Qwen2.5-0.5B-Instruct-Q4_K_M.gguf",
            fileName: "Qwen2.5-0.5B-Instruct-Q4_K_M.gguf",
            size: "0.4GB",
            quantization: "Q4_K_M",
          ),
          LLMModelVariant(
            url:
                "https://huggingface.co/bartowski/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/Qwen2.5-0.5B-Instruct-IQ4_XS.gguf",
            fileName: "Qwen2.5-0.5B-Instruct-IQ4_XS.gguf",
            size: "0.35GB",
            quantization: "IQ4_XS",
          ),
        ],
        description:
            "Qwen2.5 0.5B is an ultra-lightweight instruction-tuned model by Alibaba Cloud with excellent performance for its size",
        parameterCount: "0.5B",
        architecture: "Qwen2.5",
      ),
      const LLMModel(
        name: "Phi-3.5-mini-instruct",
        variants: [
          LLMModelVariant(
            url:
                "https://huggingface.co/bartowski/Phi-3.5-mini-instruct-GGUF/resolve/main/Phi-3.5-mini-instruct-Q4_K_M.gguf",
            fileName: "Phi-3.5-mini-instruct-Q4_K_M.gguf",
            size: "2.2GB",
            quantization: "Q4_K_M",
          ),
        ],
        description: "Microsoft's Phi-3.5 mini instruction-following model",
        parameterCount: "3.8B",
        architecture: "Phi",
      ),
      const LLMModel(
        name: "Gemma v2 2B",
        variants: [
          LLMModelVariant(
            url:
                "https://huggingface.co/guinmoon/LLMFarm_Models/resolve/main/gemma_2b_it_v2_Q4_K_M.gguf",
            fileName: "gemma_2b_it_v2_Q4_K_M.gguf",
            size: "1.6GB",
            quantization: "Q4_K_M",
          ),
        ],
        description: "Google's Gemma v2 2B instruction-tuned model",
        parameterCount: "2B",
        architecture: "Gemma",
      ),
    ];
  }

  String _getBuiltInModelsJson() {
    return '''[
      {
        "name": "Llama 3.2 Instruct 1B",
        "models": [
          {
            "url": "https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf",
            "file_name": "Llama-3.2-1B-Instruct-Q4_K_M.gguf",
            "size": "0.7GB",
            "Q": "Q4_K_M"
          }
        ]
      },
      {
        "name": "Phi-3.5-mini-instruct",
        "models": [
          {
            "url": "https://huggingface.co/bartowski/Phi-3.5-mini-instruct-GGUF/resolve/main/Phi-3.5-mini-instruct-Q4_K_M.gguf",
            "file_name": "Phi-3.5-mini-instruct-Q4_K_M.gguf",
            "size": "2.2GB",
            "Q": "Q4_K_M"
          }
        ]
      }
    ]''';
  }

  // Get popular/recommended models for quick selection
  List<LLMModel> getRecommendedModels() {
    final recommended = <String>[
      "Demo - Pythia 410M",
      "Qwen2.5-0.5B-Instruct",
      "Llama 3.2 Instruct 1B",
      "Phi-3.5-mini-instruct",
      "Gemma v2 2B",
      "TinyLlama 1B"
    ];

    return _availableModels
        .where((model) => recommended.any((name) => model.name.contains(name)))
        .toList();
  }

  // Get models by size category
  List<LLMModel> getModelsBySize(String sizeCategory) {
    return _availableModels
        .where((model) => model.sizeCategory == sizeCategory)
        .toList();
  }

  // Search models by name
  List<LLMModel> searchModels(String query) {
    if (query.isEmpty) return _availableModels;

    final lowercaseQuery = query.toLowerCase();
    return _availableModels
        .where((model) =>
            model.name.toLowerCase().contains(lowercaseQuery) ||
            model.description?.toLowerCase().contains(lowercaseQuery) == true)
        .toList();
  }

  // Get model by name
  LLMModel? getModelByName(String name) {
    try {
      return _availableModels.firstWhere((model) => model.name == name);
    } catch (e) {
      return null;
    }
  }
}
