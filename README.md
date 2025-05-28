# LLM Chat Flutter

A Flutter application that simulates the LLMFarm experience, allowing you to test and interact with a demo version of the Pythia-410M language model.

## 🚀 Quick Start

### Option 1: Use the Launch Script (Windows)
```bash
run_demo.bat
```

### Option 2: Manual Commands
```bash
# Web (Chrome)
flutter run -d chrome

# Windows Desktop
flutter run -d windows

# macOS Desktop
flutter run -d macos

# Linux Desktop
flutter run -d linux
```

## Overview

This Flutter app recreates the core functionality of LLMFarm, providing:

- **Local LLM Simulation**: Simulates the Pythia-410M (410 million parameter) model
- **Streaming Chat Interface**: Real-time token-by-token response generation
- **Model Management**: Load/unload model simulation with progress indicators
- **Performance Metrics**: Displays tokens per second and other model statistics
- **Cross-Platform**: Runs on Web, Windows, macOS, and Linux
- **LLMFarm-inspired UI**: Similar interface design to the original iOS/macOS app

## Features

### 🤖 Simulated Pythia-410M Model
- **Model Size**: ~320MB (simulated)
- **Parameters**: 410 million
- **Architecture**: Pythia (GPT-NeoX based)
- **Quantization**: Q6_K (simulated)
- **Context Length**: 4096 tokens
- **Streaming Responses**: Token-by-token generation

### 💬 Enhanced Chat Interface
- **Real-time Streaming**: See responses generate word by word
- **Contextual Responses**: Recognizes keywords and provides relevant answers
- **Conversation Memory**: Maintains context throughout the chat
- **Message States**: Loading, predicting, completed, error states
- **Performance Metrics**: Tokens per second display
- **Demo Commands**: Built-in commands to explore AI capabilities

### 📊 Comprehensive Model Information
- **Architecture Details**: 24 layers, 1024 hidden size, 16 attention heads
- **Performance Metrics**: Real-time tokens/sec, memory, CPU/GPU usage
- **Status Tracking**: Loading state, prediction status, conversation turns
- **Training Information**: The Pile dataset, EleutherAI attribution

### 🎨 Modern User Interface
- **Material Design 3**: Modern Flutter UI components
- **Cross-Platform**: Consistent experience across all platforms
- **Responsive Layout**: Works on various screen sizes
- **Dark/Light Theme**: Automatic theme support
- **Smooth Animations**: Polished user experience

## Demo Commands

Try these commands to explore different AI capabilities:

### Basic Interactions
- `hello` - Get a friendly greeting from Pythia-410M
- `how are you` - Check the model's status
- `help` - Get assistance and guidance

### Capability Exploration
- `what can you do` - Learn about the model's capabilities
- `tell me about yourself` - Get detailed model information
- `demo` - Understand this demonstration

### Technical Discussions
- `python` - Discuss Python programming and AI development
- `ai` - Talk about artificial intelligence and machine learning
- `flutter` - Chat about Flutter development and cross-platform apps
- `llmfarm` - Learn about the LLMFarm framework

## Getting Started

### Prerequisites
- Flutter SDK (3.4.4 or later)
- Dart SDK
- Web browser (for web version)
- Platform-specific requirements for desktop

### Installation

1. **Clone or download the project**
   ```bash
   # If you have the source code
   cd LLMFarm
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # Web version (recommended for first try)
   flutter run -d chrome
   
   # Desktop version
   flutter run -d windows  # or macos, linux
   ```

### Platform Support

✅ **Web** - Runs in any modern browser  
✅ **Windows** - Native desktop application  
✅ **macOS** - Native desktop application  
✅ **Linux** - Native desktop application  

## Usage Guide

### Starting a Chat

1. **Launch the app** - You'll see the welcome screen with demo commands
2. **Load the model** - Click "Load Model" to simulate loading Pythia-410M
3. **Start chatting** - Type your message and press send
4. **Watch responses** - See the AI respond in real-time with streaming

### Exploring Features

- **Model Info**: Click the info icon (ⓘ) to see detailed model specifications
- **Performance**: Watch real-time metrics during conversations
- **Demo Commands**: Try the suggested commands to see different response types
- **Stop Generation**: Use the stop button to halt responses mid-generation

## Architecture

### Models
- **`Message`**: Chat message data structure with states and metadata
- **`ChatConfig`**: Model configuration parameters and settings

### Services
- **`LLMService`**: Core LLM simulation service
  - Realistic model loading/unloading simulation
  - Contextual response generation with conversation memory
  - Performance metrics simulation
  - Enhanced demo commands and responses

### UI Components
- **`ChatScreen`**: Main chat interface with model status
- **`MessageWidget`**: Individual message display with status indicators
- **`ChatInput`**: Message input with send/stop controls
- **`ModelInfoPanel`**: Comprehensive model information dialog

## Technical Highlights

### Realistic Simulation
- **Token Timing**: 40-100ms per token (15-25 tokens/sec)
- **Memory Usage**: ~320MB base + realistic variations
- **CPU/GPU Usage**: Simulated realistic resource consumption
- **Context Tracking**: Maintains conversation history and context awareness

### Flutter Integration
- **Cross-Platform**: Single codebase for all platforms
- **Material Design 3**: Modern, responsive UI components
- **State Management**: Efficient state handling with StatefulWidget
- **Streaming UI**: Real-time updates during response generation

### Educational Value
- **LLM Concepts**: Demonstrates key language model concepts
- **Local AI Benefits**: Showcases on-device inference advantages
- **Framework Integration**: Shows how to integrate AI into Flutter apps
- **Performance Awareness**: Displays realistic performance characteristics

## Comparison with Real LLMFarm

| Feature | Real LLMFarm | Flutter Demo |
|---------|--------------|--------------|
| **Model Loading** | Actual Pythia-410M | Simulated |
| **Inference** | Real neural network | Contextual responses |
| **Performance** | Actual metrics | Realistic simulation |
| **Memory Usage** | Real 320MB | Simulated |
| **Streaming** | True token generation | Word-by-word simulation |
| **Platform** | iOS/macOS only | Cross-platform |
| **Purpose** | Production use | Educational demo |

## Development

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── message.dart         # Message data structure
│   └── chat_config.dart     # Configuration model
├── services/                # Business logic
│   └── llm_service.dart     # Enhanced LLM simulation
├── screens/                 # Main screens
│   └── chat_screen.dart     # Primary chat interface
└── widgets/                 # Reusable components
    ├── message_widget.dart   # Message display
    ├── chat_input.dart       # Input component
    └── model_info_panel.dart # Info dialog
```

### Building for Production

```bash
# Web
flutter build web

# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

### Testing

```bash
# Run all tests
flutter test

# Analyze code
flutter analyze
```

## Troubleshooting

### Common Issues

1. **Platform not supported**: Run `flutter create . --platforms=web,windows,macos,linux`
2. **Dependencies issues**: Run `flutter pub get`
3. **Build errors**: Run `flutter clean` then `flutter pub get`

### Performance

The demo is optimized for smooth performance across all platforms:
- Efficient state management
- Optimized rendering
- Realistic timing simulation
- Memory-conscious design

## Future Enhancements

Potential improvements:

- **Real LLM Integration**: Connect to actual local LLM APIs
- **Multiple Models**: Support for different model types
- **Advanced Features**: RAG, fine-tuning, custom prompts
- **Production Features**: Chat persistence, export, settings
- **Voice Input**: Speech-to-text integration
- **Image Support**: Multimodal capabilities

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgments

- **LLMFarm**: Original inspiration and design reference
- **EleutherAI**: Pythia model architecture and training
- **Flutter Team**: Excellent cross-platform framework
- **Material Design**: UI/UX guidelines and components

## Support

For questions or issues:

1. Check the [Issues](../../issues) page
2. Create a new issue with detailed description
3. Include Flutter version and platform information

---

**Note**: This is a demonstration app that simulates LLM functionality. For production use with real language models, consider integrating with actual LLM APIs or local inference engines.
