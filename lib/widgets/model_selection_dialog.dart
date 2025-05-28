import 'package:flutter/material.dart';
import '../models/llm_model.dart';
import '../services/model_service.dart';

class ModelSelectionDialog extends StatefulWidget {
  final LLMModel? currentModel;
  final Function(LLMModel, LLMModelVariant) onModelSelected;

  const ModelSelectionDialog({
    super.key,
    this.currentModel,
    required this.onModelSelected,
  });

  @override
  State<ModelSelectionDialog> createState() => _ModelSelectionDialogState();
}

class _ModelSelectionDialogState extends State<ModelSelectionDialog>
    with TickerProviderStateMixin {
  final ModelService _modelService = ModelService();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  LLMModel? _selectedModel;
  LLMModelVariant? _selectedVariant;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedModel = widget.currentModel;
    _selectedVariant = widget.currentModel?.recommendedVariant;
    _initializeModels();
  }

  Future<void> _initializeModels() async {
    if (!_modelService.isLoaded) {
      await _modelService.loadAvailableModels();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<LLMModel> _getFilteredModels() {
    if (_searchQuery.isEmpty) {
      switch (_tabController.index) {
        case 0:
          return _modelService.getRecommendedModels();
        case 1:
          return _modelService.availableModels;
        case 2:
          return _modelService.availableModels
              .where((model) => model.sizeCategory.contains('Small'))
              .toList();
        default:
          return _modelService.availableModels;
      }
    } else {
      return _modelService.searchModels(_searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.smart_toy, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Select Language Model',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search models...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Tabs
            TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              tabs: const [
                Tab(icon: Icon(Icons.star), text: 'Recommended'),
                Tab(icon: Icon(Icons.list), text: 'All Models'),
                Tab(icon: Icon(Icons.memory), text: 'Lightweight'),
              ],
            ),
            const SizedBox(height: 16),

            // Models list
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildModelsList(_getFilteredModels()),
                  _buildModelsList(_getFilteredModels()),
                  _buildModelsList(_getFilteredModels()),
                ],
              ),
            ),

            // Bottom section
            if (_selectedModel != null) ...[
              const Divider(),
              _buildSelectedModelInfo(),
              const SizedBox(height: 16),
            ],

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedModel != null && _selectedVariant != null
                      ? () {
                          widget.onModelSelected(
                              _selectedModel!, _selectedVariant!);
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Select Model'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelsList(List<LLMModel> models) {
    if (models.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No models found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: models.length,
      itemBuilder: (context, index) {
        final model = models[index];
        final isSelected = _selectedModel?.name == model.name;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                model.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              model.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (model.description != null)
                  Text(model.description!, maxLines: 2),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildChip(model.sizeCategory, Colors.blue),
                    const SizedBox(width: 4),
                    if (model.parameterCount != null)
                      _buildChip(
                          '${model.parameterCount} params', Colors.green),
                    const SizedBox(width: 4),
                    _buildChip(
                        '${model.variants.length} variants', Colors.orange),
                  ],
                ),
              ],
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.radio_button_unchecked),
            onTap: () {
              setState(() {
                _selectedModel = model;
                _selectedVariant = model.recommendedVariant;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSelectedModelInfo() {
    if (_selectedModel == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected: ${_selectedModel!.name}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (_selectedModel!.description != null)
            Text(_selectedModel!.description!),
          const SizedBox(height: 12),

          // Variant selection
          if (_selectedModel!.variants.length > 1) ...[
            const Text(
              'Choose Quantization:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _selectedModel!.variants.map((variant) {
                final isSelected =
                    _selectedVariant?.quantization == variant.quantization;
                return FilterChip(
                  label: Text('${variant.quantization} (${variant.size})'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedVariant = variant;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ] else if (_selectedModel!.variants.isNotEmpty) ...[
            Text(
              'Quantization: ${_selectedModel!.variants.first.quantization} (${_selectedModel!.variants.first.size})',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
