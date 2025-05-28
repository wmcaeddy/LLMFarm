class ChatConfig {
  final String modelInference;
  final String model;
  final String title;
  final String icon;
  final bool useMetal;
  final bool mlock;
  final bool mmap;
  final String promptFormat;
  final String warmPrompt;
  final String reversePrompt;
  final int numberOfThreads;
  final int context;
  final int nBatch;
  final int nPredict;
  final double temp;
  final int repeatLastN;
  final double repeatPenalty;
  final int topK;
  final double topP;
  final int mirostat;
  final double mirostatEta;
  final double mirostatTau;
  final double tfsZ;
  final double typicalP;
  final String grammar;
  final bool addBosToken;
  final bool addEosToken;
  final bool parseSpecialTokens;
  final bool flashAttn;
  final bool saveLoadState;
  final String skipTokens;
  final String chatStyle;
  final int chunkSize;
  final int chunkOverlap;
  final int ragTop;
  final String currentModel;
  final String comparisonAlgorithm;
  final String chunkMethod;

  const ChatConfig({
    this.modelInference = "llama",
    this.model = "[DEMO].gguf",
    this.title = "Demo Chat",
    this.icon = "ava1",
    this.useMetal = true,
    this.mlock = false,
    this.mmap = true,
    this.promptFormat =
        "\n<|im_start|>user\n{{prompt}}<|im_end|>\n\n<|im_start|>assistant\n\n",
    this.warmPrompt = "\n\n\n",
    this.reversePrompt = "<|im_end|>",
    this.numberOfThreads = 0,
    this.context = 4096,
    this.nBatch = 512,
    this.nPredict = 0,
    this.temp = 0.35,
    this.repeatLastN = 64,
    this.repeatPenalty = 1.1,
    this.topK = 40,
    this.topP = 0.95,
    this.mirostat = 2,
    this.mirostatEta = 0.1,
    this.mirostatTau = 5.0,
    this.tfsZ = 1.0,
    this.typicalP = 1.0,
    this.grammar = "<None>",
    this.addBosToken = true,
    this.addEosToken = false,
    this.parseSpecialTokens = true,
    this.flashAttn = false,
    this.saveLoadState = true,
    this.skipTokens = "<|im_start|>",
    this.chatStyle = "docC",
    this.chunkSize = 256,
    this.chunkOverlap = 100,
    this.ragTop = 3,
    this.currentModel = "minilmMultiQA",
    this.comparisonAlgorithm = "dotproduct",
    this.chunkMethod = "recursive",
  });

  Map<String, dynamic> toJson() {
    return {
      'model_inference': modelInference,
      'model': model,
      'title': title,
      'icon': icon,
      'use_metal': useMetal,
      'mlock': mlock,
      'mmap': mmap,
      'prompt_format': promptFormat,
      'warm_prompt': warmPrompt,
      'reverse_prompt': reversePrompt,
      'numberOfThreads': numberOfThreads,
      'context': context,
      'n_batch': nBatch,
      'n_predict': nPredict,
      'temp': temp,
      'repeat_last_n': repeatLastN,
      'repeat_penalty': repeatPenalty,
      'top_k': topK,
      'top_p': topP,
      'mirostat': mirostat,
      'mirostat_eta': mirostatEta,
      'mirostat_tau': mirostatTau,
      'tfs_z': tfsZ,
      'typical_p': typicalP,
      'grammar': grammar,
      'add_bos_token': addBosToken,
      'add_eos_token': addEosToken,
      'parse_special_tokens': parseSpecialTokens,
      'flash_attn': flashAttn,
      'save_load_state': saveLoadState,
      'skip_tokens': skipTokens,
      'chat_style': chatStyle,
      'chunk_size': chunkSize,
      'chunk_overlap': chunkOverlap,
      'rag_top': ragTop,
      'current_model': currentModel,
      'comparison_algorithm': comparisonAlgorithm,
      'chunk_method': chunkMethod,
    };
  }

  factory ChatConfig.fromJson(Map<String, dynamic> json) {
    return ChatConfig(
      modelInference: json['model_inference'] ?? "llama",
      model: json['model'] ?? "[DEMO].gguf",
      title: json['title'] ?? "Demo Chat",
      icon: json['icon'] ?? "ava1",
      useMetal: json['use_metal'] ?? true,
      mlock: json['mlock'] ?? false,
      mmap: json['mmap'] ?? true,
      promptFormat:
          json['prompt_format'] ??
          "\n<|im_start|>user\n{{prompt}}<|im_end|>\n\n<|im_start|>assistant\n\n",
      warmPrompt: json['warm_prompt'] ?? "\n\n\n",
      reversePrompt: json['reverse_prompt'] ?? "<|im_end|>",
      numberOfThreads: json['numberOfThreads'] ?? 0,
      context: json['context'] ?? 4096,
      nBatch: json['n_batch'] ?? 512,
      nPredict: json['n_predict'] ?? 0,
      temp: (json['temp'] ?? 0.35).toDouble(),
      repeatLastN: json['repeat_last_n'] ?? 64,
      repeatPenalty: (json['repeat_penalty'] ?? 1.1).toDouble(),
      topK: json['top_k'] ?? 40,
      topP: (json['top_p'] ?? 0.95).toDouble(),
      mirostat: json['mirostat'] ?? 2,
      mirostatEta: (json['mirostat_eta'] ?? 0.1).toDouble(),
      mirostatTau: (json['mirostat_tau'] ?? 5.0).toDouble(),
      tfsZ: (json['tfs_z'] ?? 1.0).toDouble(),
      typicalP: (json['typical_p'] ?? 1.0).toDouble(),
      grammar: json['grammar'] ?? "<None>",
      addBosToken: json['add_bos_token'] ?? true,
      addEosToken: json['add_eos_token'] ?? false,
      parseSpecialTokens: json['parse_special_tokens'] ?? true,
      flashAttn: json['flash_attn'] ?? false,
      saveLoadState: json['save_load_state'] ?? true,
      skipTokens: json['skip_tokens'] ?? "<|im_start|>",
      chatStyle: json['chat_style'] ?? "docC",
      chunkSize: json['chunk_size'] ?? 256,
      chunkOverlap: json['chunk_overlap'] ?? 100,
      ragTop: json['rag_top'] ?? 3,
      currentModel: json['current_model'] ?? "minilmMultiQA",
      comparisonAlgorithm: json['comparison_algorithm'] ?? "dotproduct",
      chunkMethod: json['chunk_method'] ?? "recursive",
    );
  }
}
