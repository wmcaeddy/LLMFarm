import 'dart:async';
import 'package:flutter/services.dart';
import '../models/llm_model.dart';
import '../models/chat_config.dart';

abstract class LLMPlatformInterface {
  static LLMPlatformInterface? _instance;

  static LLMPlatformInterface get instance =>
      _instance ??= LLMPlatformMethodChannel();

  static set instance(LLMPlatformInterface instance) {
    _instance = instance;
  }

  Future<bool> loadModel({
    required String modelPath,
    required ChatConfig config,
    LLMModel? model,
    LLMModelVariant? variant,
  });

  Future<void> unloadModel();

  Stream<String> generateResponse(String prompt);

  Future<void> stopGeneration();

  Future<Map<String, dynamic>> getModelStats();

  Future<Map<String, double>> getPerformanceMetrics();

  Future<bool> isModelLoaded();

  Future<String> getModelDisplayName();
}

class LLMPlatformMethodChannel extends LLMPlatformInterface {
  static const MethodChannel _channel = MethodChannel('llm_farm_flutter');
  static const EventChannel _responseStream =
      EventChannel('llm_farm_flutter/response_stream');

  StreamSubscription<dynamic>? _responseSubscription;
  StreamController<String>? _responseController;

  @override
  Future<bool> loadModel({
    required String modelPath,
    required ChatConfig config,
    LLMModel? model,
    LLMModelVariant? variant,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('loadModel', {
        'modelPath': modelPath,
        'config': {
          'temp': config.temp,
          'topK': config.topK,
          'topP': config.topP,
          'repeatPenalty': config.repeatPenalty,
          'context': config.context,
          'nBatch': config.nBatch,
          'numberOfThreads': config.numberOfThreads,
          'useMetal': config.useMetal,
          'flashAttn': config.flashAttn,
          'mlock': config.mlock,
          'mmap': config.mmap,
        },
        'modelInfo': model != null
            ? {
                'name': model.name,
                'architecture': model.architecture,
                'parameterCount': model.parameterCount,
                'promptFormat': model.promptFormat,
              }
            : null,
        'variantInfo': variant != null
            ? {
                'fileName': variant.fileName,
                'quantization': variant.quantization,
                'size': variant.size,
              }
            : null,
      });
      return result ?? false;
    } catch (e) {
      print('Error loading model: $e');
      return false;
    }
  }

  @override
  Future<void> unloadModel() async {
    try {
      await _channel.invokeMethod('unloadModel');
      await _responseSubscription?.cancel();
      _responseSubscription = null;
      _responseController?.close();
      _responseController = null;
    } catch (e) {
      print('Error unloading model: $e');
    }
  }

  @override
  Stream<String> generateResponse(String prompt) {
    _responseController?.close();
    _responseController = StreamController<String>();

    // Start generation on native side
    _channel.invokeMethod('generateResponse', {'prompt': prompt}).catchError(
        (error) {
      _responseController?.addError(error);
    });

    // Listen to the response stream
    _responseSubscription?.cancel();
    _responseSubscription = _responseStream.receiveBroadcastStream().listen(
      (data) {
        if (data is String) {
          _responseController?.add(data);
        } else if (data is Map && data['type'] == 'complete') {
          _responseController?.close();
        } else if (data is Map && data['type'] == 'error') {
          _responseController?.addError(data['message'] ?? 'Unknown error');
        }
      },
      onError: (error) {
        _responseController?.addError(error);
      },
      onDone: () {
        _responseController?.close();
      },
    );

    return _responseController!.stream;
  }

  @override
  Future<void> stopGeneration() async {
    try {
      await _channel.invokeMethod('stopGeneration');
      await _responseSubscription?.cancel();
      _responseController?.close();
    } catch (e) {
      print('Error stopping generation: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getModelStats() async {
    try {
      final result = await _channel.invokeMethod<Map>('getModelStats');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      print('Error getting model stats: $e');
      return {};
    }
  }

  @override
  Future<Map<String, double>> getPerformanceMetrics() async {
    try {
      final result = await _channel.invokeMethod<Map>('getPerformanceMetrics');
      return Map<String, double>.from(result?.cast<String, double>() ?? {});
    } catch (e) {
      print('Error getting performance metrics: $e');
      return {};
    }
  }

  @override
  Future<bool> isModelLoaded() async {
    try {
      final result = await _channel.invokeMethod<bool>('isModelLoaded');
      return result ?? false;
    } catch (e) {
      print('Error checking if model is loaded: $e');
      return false;
    }
  }

  @override
  Future<String> getModelDisplayName() async {
    try {
      final result = await _channel.invokeMethod<String>('getModelDisplayName');
      return result ?? 'No Model Loaded';
    } catch (e) {
      print('Error getting model display name: $e');
      return 'No Model Loaded';
    }
  }
}
