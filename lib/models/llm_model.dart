class LLMModelVariant {
  final String url;
  final String fileName;
  final String size;
  final String quantization;

  const LLMModelVariant({
    required this.url,
    required this.fileName,
    required this.size,
    required this.quantization,
  });

  factory LLMModelVariant.fromJson(Map<String, dynamic> json) {
    return LLMModelVariant(
      url: json['url'] ?? '',
      fileName: json['file_name'] ?? '',
      size: json['size'] ?? '',
      quantization: json['Q'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'file_name': fileName,
      'size': size,
      'Q': quantization,
    };
  }
}

class LLMModel {
  final String name;
  final List<LLMModelVariant> variants;
  final String? description;
  final String? parameterCount;
  final String? architecture;

  const LLMModel({
    required this.name,
    required this.variants,
    this.description,
    this.parameterCount,
    this.architecture,
  });

  factory LLMModel.fromJson(Map<String, dynamic> json) {
    return LLMModel(
      name: json['name'] ?? '',
      variants: (json['models'] as List<dynamic>?)
              ?.map((variant) => LLMModelVariant.fromJson(variant))
              .toList() ??
          [],
      description: json['description'],
      parameterCount: json['parameter_count'],
      architecture: json['architecture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'models': variants.map((variant) => variant.toJson()).toList(),
      if (description != null) 'description': description,
      if (parameterCount != null) 'parameter_count': parameterCount,
      if (architecture != null) 'architecture': architecture,
    };
  }

  // Helper method to get recommended variant (usually Q4_K_M or Q5_K_M)
  LLMModelVariant? get recommendedVariant {
    // Look for Q4_K_M first (good balance of quality and size)
    final q4km = variants.where((v) => v.quantization == 'Q4_K_M').firstOrNull;
    if (q4km != null) return q4km;

    // Look for Q5_K_M (higher quality)
    final q5km = variants.where((v) => v.quantization == 'Q5_K_M').firstOrNull;
    if (q5km != null) return q5km;

    // Look for Q4_K_S (smaller size)
    final q4ks = variants.where((v) => v.quantization == 'Q4_K_S').firstOrNull;
    if (q4ks != null) return q4ks;

    // Fall back to first available variant
    return variants.isNotEmpty ? variants.first : null;
  }

  // Get model size category for UI display
  String get sizeCategory {
    if (name.contains('0.5B') ||
        name.contains('1B') ||
        name.contains('1.1B') ||
        name.contains('1.7B')) {
      return 'Small (1-2B)';
    } else if (name.contains('2B') || name.contains('2.7B')) {
      return 'Medium (2-3B)';
    } else if (name.contains('3B')) {
      return 'Large (3B)';
    } else if (name.contains('7B')) {
      return 'Extra Large (7B)';
    }
    return 'Unknown';
  }

  // Get appropriate prompt format based on model
  String get promptFormat {
    if (name.contains('Llama')) {
      if (name.contains('3.2')) {
        return "<|begin_of_text|><|start_header_id|>user<|end_header_id|>\n\n{{prompt}}<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n";
      } else {
        return "[INST] {{prompt}} [/INST]";
      }
    } else if (name.contains('Gemma')) {
      return "<start_of_turn>user\n{{prompt}}<end_of_turn>\n<start_of_turn>model\n";
    } else if (name.contains('Phi')) {
      return "<|user|>\n{{prompt}}<|end|>\n<|assistant|>\n";
    } else if (name.contains('Qwen')) {
      return "<|im_start|>system\nYou are Qwen, created by Alibaba Cloud. You are a helpful assistant.<|im_end|>\n<|im_start|>user\n{{prompt}}<|im_end|>\n<|im_start|>assistant\n";
    } else if (name.contains('ORCA')) {
      return "### User:\n{{prompt}}\n### Assistant:\n";
    } else if (name.contains('StableLM')) {
      return "<|user|>\n{{prompt}}<|endoftext|>\n<|assistant|>\n";
    }
    return "{{prompt}}"; // Default format
  }
}

// Extension to add firstOrNull method for older Dart versions
extension FirstWhereOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
