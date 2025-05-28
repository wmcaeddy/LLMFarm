import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onStop;
  final bool isPredicting;
  final bool isModelLoaded;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onStop,
    required this.isPredicting,
    required this.isModelLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: isModelLoaded && !isPredicting,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSend(),
              decoration: InputDecoration(
                hintText:
                    isModelLoaded
                        ? 'Type your message...'
                        : 'Load model first...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: _buildActionButton(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (isPredicting) {
      return IconButton(
        onPressed: onStop,
        icon: const Icon(Icons.stop_circle),
        color: Colors.red[600],
        tooltip: 'Stop generation',
      );
    } else {
      return IconButton(
        onPressed:
            isModelLoaded && controller.text.trim().isNotEmpty
                ? _handleSend
                : null,
        icon: const Icon(Icons.send),
        tooltip: 'Send message',
      );
    }
  }

  void _handleSend() {
    if (controller.text.trim().isNotEmpty && isModelLoaded && !isPredicting) {
      onSend();
    }
  }
}
