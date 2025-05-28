import 'package:flutter/material.dart';

class ModelInfoPanel extends StatelessWidget {
  final Map<String, dynamic> stats;
  final Map<String, double> metrics;

  const ModelInfoPanel({super.key, required this.stats, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pythia-410M Model Information'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSection('Model Details', [
              _buildInfoRow('Name', stats['model_name'] ?? 'Unknown'),
              _buildInfoRow('Parameters', stats['parameters'] ?? 'Unknown'),
              _buildInfoRow('Architecture', stats['architecture'] ?? 'Unknown'),
              _buildInfoRow('Quantization', stats['quantization'] ?? 'Unknown'),
              _buildInfoRow('Size', stats['size'] ?? 'Unknown'),
              _buildInfoRow('Creator', stats['creator'] ?? 'Unknown'),
              _buildInfoRow(
                  'Training Data', stats['training_data'] ?? 'Unknown'),
            ]),
            const SizedBox(height: 16),
            _buildSection('Architecture Specs', [
              _buildInfoRow(
                  'Context Length', '${stats['context_length'] ?? 0}'),
              _buildInfoRow('Vocabulary Size', '${stats['vocab_size'] ?? 0}'),
              _buildInfoRow('Layers', '${stats['layers'] ?? 0}'),
              _buildInfoRow('Hidden Size', '${stats['hidden_size'] ?? 0}'),
              _buildInfoRow(
                  'Attention Heads', '${stats['attention_heads'] ?? 0}'),
            ]),
            const SizedBox(height: 16),
            _buildSection('Status', [
              _buildInfoRow(
                  'Loaded', stats['loaded'] == true ? '✅ Yes' : '❌ No'),
              _buildInfoRow(
                'Predicting',
                stats['predicting'] == true ? '🔄 Yes' : '⏸️ No',
              ),
              _buildInfoRow(
                'Conversation Turns',
                '${stats['conversation_turns'] ?? 0}',
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('Performance Metrics', [
              _buildInfoRow(
                'Tokens/sec',
                '${metrics['tokens_per_second']?.toStringAsFixed(1) ?? '0.0'}',
              ),
              _buildInfoRow(
                'Memory Usage',
                '${metrics['memory_usage']?.toStringAsFixed(1) ?? '0.0'} MB',
              ),
              _buildInfoRow(
                'CPU Usage',
                '${metrics['cpu_usage']?.toStringAsFixed(1) ?? '0.0'}%',
              ),
              _buildInfoRow(
                'GPU Usage',
                '${metrics['gpu_usage']?.toStringAsFixed(1) ?? '0.0'}%',
              ),
              _buildInfoRow(
                'Temperature',
                '${metrics['temperature']?.toStringAsFixed(2) ?? '0.0'}',
              ),
              _buildInfoRow(
                'Context Used',
                '${metrics['context_used']?.toStringAsFixed(0) ?? '0'} / ${metrics['max_context']?.toStringAsFixed(0) ?? '0'} tokens',
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('Demo Information', [
              _buildInfoRow('Framework', 'LLMFarm (Simulated)'),
              _buildInfoRow('Purpose', 'Educational Demo'),
              _buildInfoRow('Platform', 'Flutter Cross-Platform'),
              _buildInfoRow('Inference Type', 'Local (Simulated)'),
            ]),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}
