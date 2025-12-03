import 'package:easy_pc/models/build_wizard_state.dart';
import 'package:easy_pc/models/build_wizard_step.dart';
import 'package:easy_pc/models/pc_type.dart';
import 'package:easy_pc/services/build_wizard_service.dart';
import 'package:easy_pc/services/pc_type_service.dart';
import 'package:easy_pc/widgets/compatibility_card.dart';
import 'package:flutter/material.dart';

const yellow = Color(0xFFDDC03D);

class BuildWizardPage extends StatefulWidget {
  const BuildWizardPage({super.key});

  @override
  State<BuildWizardPage> createState() => _BuildWizardPageState();
}

class _BuildWizardPageState extends State<BuildWizardPage> {
  BuildWizardState _wizardState = BuildWizardState();
  List<BuildWizardStep> _steps = [];
  List<dynamic> _currentComponents = [];
  bool _isLoading = true;
  int? _selectedComponentId;
  final Map<String, String> _selectedComponentNames = {};

  @override
  void initState() {
    super.initState();
    _loadWizardSteps();
  }

  Future<void> _loadWizardSteps() async {
    try {
      final steps = await BuildWizardService.getWizardSteps();
      setState(() {
        _steps = steps;
        _isLoading = false;
      });
      _loadComponentsForCurrentStep();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading wizard: $e')),
        );
      }
    }
  }

  Future<void> _loadComponentsForCurrentStep() async {
    setState(() => _isLoading = true);
    try {
      if (_wizardState.currentStep == 1) {
        final pcTypes = await const PcTypeService().get();
        setState(() {
          _currentComponents = pcTypes.map((e) => {'id': e.id, 'name': e.name}).toList();
          _isLoading = false;
        });
      } else {
        final components = await BuildWizardService.getFilteredComponents(
          state: _wizardState,
          stepNumber: _wizardState.currentStep,
        );
        setState(() {
          _currentComponents = components;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading components: $e')),
        );
      }
    }
  }

  Future<void> _nextStep() async {
    if (_selectedComponentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a component')),
      );
      return;
    }

    // Store component name
    final selectedComponent = _currentComponents.firstWhere(
      (c) => c['id'] == _selectedComponentId,
      orElse: () => <String, Object?>{},
    );
    final stepKey = _steps[_wizardState.currentStep - 1].stepName;
    _selectedComponentNames[stepKey] = selectedComponent['name']?.toString() ?? 'Unknown';

    setState(() => _isLoading = true);
    try {
      final updatedState = await BuildWizardService.updateStep(
        state: _wizardState,
        stepNumber: _wizardState.currentStep,
        componentId: _selectedComponentId,
      );

      setState(() {
        _wizardState = updatedState;
        _selectedComponentId = null;
      });

      if (_wizardState.currentStep <= _steps.length) {
        await _loadComponentsForCurrentStep();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _previousStep() {
    if (_wizardState.currentStep > 1) {
      setState(() {
        _wizardState.currentStep--;
        _selectedComponentId = null;
      });
      _loadComponentsForCurrentStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _steps.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1F1F1F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF262626),
          title: const Text('Build Your PC'),
        ),
        body: const Center(child: CircularProgressIndicator(color: yellow)),
      );
    }

    if (_steps.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1F1F1F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF262626),
          title: const Text('Build Your PC'),
        ),
        body: const Center(child: Text('Failed to load wizard steps')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: _buildAppBar(),
      body: _wizardState.isComplete ? _buildSummary() : _buildWizardContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final progress = _wizardState.currentStep / _steps.length;
    return AppBar(
      backgroundColor: const Color(0xFF262626),
      iconTheme: const IconThemeData(color: yellow),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Build Your PC', style: TextStyle(fontSize: 18, color: yellow)),
          const SizedBox(height: 4),
          Text(
            'Step ${_wizardState.currentStep} of ${_steps.length}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[800],
          valueColor: const AlwaysStoppedAnimation<Color>(yellow),
        ),
      ),
    );
  }

  Widget _buildWizardContent() {
    return Column(
      children: [
        if (_wizardState.estimatedPrice != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF262626),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Price:',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  '\$${_wizardState.estimatedPrice}',
                  style: const TextStyle(
                    color: yellow,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: IndexedStack(
            index: _wizardState.currentStep - 1,
            children: _steps.map((step) => _buildStepPage(step)).toList(),
          ),
        ),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildStepPage(BuildWizardStep step) {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: yellow))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      step.stepName,
                      style: const TextStyle(
                        color: yellow,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your ${step.stepName.toLowerCase()}',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    if (_wizardState.compatibilityCheck != null) ...[
                      const SizedBox(height: 16),
                      CompatibilityCard(result: _wizardState.compatibilityCheck!),
                      const SizedBox(height: 16),
                    ],
                    if (_currentComponents.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 64),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline, size: 64, color: Colors.grey[600]),
                              const SizedBox(height: 16),
                              Text(
                                'No compatible components found',
                                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._currentComponents.map((component) {
                        final id = component['id'] as int?;
                        final name = component['name'] as String? ?? 'Unknown';
                        final price = component['price'] as int? ?? 0;
                        final showPrice = _wizardState.currentStep > 1;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: const Color(0xFF262626),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _selectedComponentId == id ? yellow : Colors.grey[800]!,
                              width: 2,
                            ),
                          ),
                          child: RadioListTile<int>(
                            value: id ?? 0,
                            groupValue: _selectedComponentId,
                            onChanged: (value) {
                              setState(() {
                                _selectedComponentId = value;
                              });
                            },
                            activeColor: yellow,
                            title: Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: showPrice ? Text(
                              '\$$price',
                              style: const TextStyle(
                                color: yellow,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ) : null,
                          ),
                        );
                      }).toList(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_wizardState.currentStep > 1)
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _previousStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: yellow,
                    side: const BorderSide(color: yellow),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Previous', style: TextStyle(fontSize: 16)),
                ),
              ),
            if (_wizardState.currentStep > 1) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: yellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _wizardState.currentStep < _steps.length ? 'Next' : 'Finish',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Build Summary',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: yellow,
            ),
          ),
          const SizedBox(height: 16),
          if (_wizardState.estimatedPrice != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [yellow.withOpacity(0.3), yellow.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: yellow, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_wizardState.estimatedPrice}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: yellow,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          if (_wizardState.compatibilityCheck != null) ...[
            CompatibilityCard(result: _wizardState.compatibilityCheck!),
            const SizedBox(height: 24),
          ],
          _buildSummaryCard('PC Type', _wizardState.pcTypeId, Icons.computer, 'PC Type'),
          _buildSummaryCard('Processor', _wizardState.processorId, Icons.memory, 'Processor'),
          _buildSummaryCard('Motherboard', _wizardState.motherboardId, Icons.developer_board, 'Motherboard'),
          _buildSummaryCard('RAM Memory', _wizardState.ramId, Icons.storage, 'RAM Memory'),
          _buildSummaryCard('Graphics Card', _wizardState.graphicsCardId, Icons.videogame_asset, 'Graphics Card'),
          _buildSummaryCard('Power Supply', _wizardState.powerSupplyId, Icons.power, 'Power Supply'),
          _buildSummaryCard('Case', _wizardState.caseId, Icons.inventory_2, 'Case'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _wizardState = BuildWizardState();
                      _selectedComponentId = null;
                      _currentComponents = [];
                      _selectedComponentNames.clear();
                    });
                    _loadComponentsForCurrentStep();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Start Over'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: yellow,
                    side: const BorderSide(color: yellow),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _wizardState.compatibilityCheck?.isCompatible == true
                      ? () => Navigator.pop(context, _wizardState)
                      : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, int? value, IconData icon, String stepKey) {
    final componentName = _selectedComponentNames[stepKey];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: value != null ? yellow : Colors.grey, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (componentName != null)
                  Text(
                    componentName,
                    style: const TextStyle(
                      color: yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  const Text(
                    'Not selected',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
