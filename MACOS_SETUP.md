# macOS Setup Guide for LLM Chat Flutter

## 🚀 Real LLM Inference on macOS

This guide will help you set up the LLM Chat Flutter app on macOS to get **actual AI responses** instead of simulated ones.

## Prerequisites

### 1. macOS Requirements
- **macOS 10.15 or later**
- **Apple Silicon (M1/M2/M3) recommended** for best performance
- **At least 8GB RAM** (16GB+ recommended for larger models)
- **10-50GB free storage** (depending on models you download)

### 2. Development Setup
```bash
# Install Flutter if not already installed
# Download from: https://flutter.dev/docs/get-started/install/macos

# Verify installation
flutter doctor

# Ensure you have Xcode installed
xcode-select --install
```

## 🔧 Project Setup

### 1. Clone and Navigate
```bash
git clone <your-repo>
cd LLMFarm/LLMFarm
```

### 2. Install Dependencies
```bash
# Get Flutter dependencies
flutter pub get

# For iOS dependencies (if needed)
cd ios && pod install && cd ..
```

### 3. Configure LLMFarm Core
The project includes LLMFarm core integration. Make sure the native dependencies are properly linked:

```bash
# Check if llmfarm_core is available
# The project should include it as a submodule or dependency
```

## 📱 Running the App

### 1. Check Available Devices
```bash
flutter devices
```

You should see:
- **macOS (desktop)** - for running as a native Mac app
- **iOS Simulator** - for testing iOS version

### 2. Run on macOS
```bash
# Run the native macOS app
flutter run -d macos

# For release build
flutter run -d macos --release
```

### 3. Run on iOS Simulator
```bash
# List available simulators
flutter emulators

# Run on iOS simulator
flutter run -d ios
```

## 🤖 Downloading Models

### 1. Create Models Directory
```bash
# Create the models directory
mkdir -p ~/Documents/models
```

### 2. Download GGUF Models
Download models from Hugging Face or other sources:

#### Quick Start Models (Recommended)
```bash
# TinyLlama 1.1B (Good for testing - ~600MB)
curl -L -o ~/Documents/models/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf \
  "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"

# Phi-3.5 Mini (3.8B parameters - ~2.2GB)
curl -L -o ~/Documents/models/Phi-3.5-mini-instruct-Q4_K_M.gguf \
  "https://huggingface.co/bartowski/Phi-3.5-mini-instruct-GGUF/resolve/main/Phi-3.5-mini-instruct-Q4_K_M.gguf"
```

#### Larger Models (If you have enough RAM/Storage)
```bash
# Llama 3.2 1B (Recommended - ~1.2GB)
curl -L -o ~/Documents/models/Llama-3.2-1B-Instruct-Q4_K_M.gguf \
  "https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf"

# Llama 3.2 3B (Better quality - ~3.6GB)
curl -L -o ~/Documents/models/Llama-3.2-3B-Instruct-Q4_K_M.gguf \
  "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf"
```

### 3. Verify Downloads
```bash
# Check downloaded models
ls -la ~/Documents/models/
```

## 🎯 Using Real LLM Inference

### 1. Launch the App
```bash
flutter run -d macos
```

### 2. Select a Real Model
1. Click **"Select Model"** in the app
2. Choose from **"All Models"** tab (not Demo)
3. Select a downloaded model (e.g., "Llama 3.2 1B")
4. Choose quantization level (Q4_K_M recommended)
5. Click **"Select"**

### 3. Load the Model
1. Click **"Load Model"** in the status bar
2. Wait for loading (may take 10-60 seconds)
3. Status should show **"✅ [Model Name] Ready"**

### 4. Chat with Real AI
1. Type your message in the chat input
2. Press Enter or click Send
3. Watch **real AI responses** stream in!

## 🔧 Troubleshooting

### Model Loading Issues
```bash
# Check if model file exists
ls -la ~/Documents/models/

# Check file permissions
chmod 644 ~/Documents/models/*.gguf

# Check available disk space
df -h
```

### Performance Optimization
- **Enable Metal GPU**: Models will automatically use Metal acceleration on Apple Silicon
- **Adjust Context Length**: Reduce for faster inference
- **Use Smaller Quantization**: Q4_K_M is good balance of quality/speed

### Memory Issues
- **Close other apps** before loading large models
- **Try smaller models** first (TinyLlama, Phi-3.5 Mini)
- **Reduce context length** in model config

## 📊 Performance Expectations

| Model | Size | RAM Usage | Speed (M1 Pro) | Quality |
|-------|------|-----------|----------------|---------|
| TinyLlama 1.1B | 600MB | 1GB | 40+ tok/s | Good |
| Phi-3.5 Mini | 2.2GB | 3GB | 25+ tok/s | Very Good |
| Llama 3.2 1B | 1.2GB | 2GB | 35+ tok/s | Very Good |
| Llama 3.2 3B | 3.6GB | 5GB | 15+ tok/s | Excellent |

## 🎮 Demo vs Real Mode

### Demo Mode (What you see on Windows/Web)
- ❌ Simulated responses
- ❌ No actual AI inference
- ✅ Interface testing only

### Real Mode (macOS/iOS with downloaded models)
- ✅ Actual LLM inference
- ✅ Real AI responses
- ✅ Streaming text generation
- ✅ Performance metrics
- ✅ Metal GPU acceleration

## 🎯 Next Steps

1. **Get a Mac** or access to one for development
2. **Download models** to ~/Documents/models/
3. **Run the app** with `flutter run -d macos`
4. **Select real models** for actual AI chat
5. **Enjoy real LLM responses!**

---

## 🔗 Resources

- [LLMFarm Core](https://github.com/guinmoon/llmfarm_core.swift)
- [Hugging Face GGUF Models](https://huggingface.co/models?library=gguf)
- [Flutter macOS Desktop](https://docs.flutter.dev/platform-integration/macos/building)
- [Metal Performance Shaders](https://developer.apple.com/metal/)

Happy AI chatting! 🤖✨ 