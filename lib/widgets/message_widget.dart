import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageWidget extends StatelessWidget {
  final Message message;

  const MessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final isSystem = message.sender == MessageSender.system;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  isUser
                      ? Colors.blue
                      : isSystem
                      ? Colors.grey[600]
                      : Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isUser ? Icons.person : Icons.smart_toy,
              color: Colors.white,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender name and status
                Row(
                  children: [
                    Text(
                      isUser ? 'You' : 'Pythia-410M',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusIndicator(),
                  ],
                ),

                const SizedBox(height: 4),

                // Message text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isUser
                            ? Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1)
                            : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.header.isNotEmpty) ...[
                        Text(
                          message.header,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      Text(
                        message.text,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),

                      if (message.state == MessageState.predicted &&
                          message.tokSec > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${message.tokSec.toStringAsFixed(1)} tokens/sec',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    switch (message.state) {
      case MessageState.predicting:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case MessageState.error:
        return Icon(Icons.error, size: 16, color: Colors.red[600]);
      case MessageState.predicted:
        return Icon(Icons.check_circle, size: 16, color: Colors.green[600]);
      default:
        return const SizedBox.shrink();
    }
  }
}
