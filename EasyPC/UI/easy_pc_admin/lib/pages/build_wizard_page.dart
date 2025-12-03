import 'package:desktop/models/build_wizard_state.dart';
import 'package:desktop/models/build_wizard_step.dart';
import 'package:desktop/services/build_wizard_service.dart';
import 'package:desktop/services/pc_service.dart';
import 'package:desktop/services/pc_type_service.dart';
import 'package:desktop/providers/user_provider.dart';
import 'package:desktop/widgets/compatibility_card.dart';
import 'package:desktop/widgets/desktop_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Build Wizard')),
        body: const Center(child: Text('Failed to load wizard steps')),
      );
    }

    final currentStepInfo = _steps.firstWhere(
      (s) => s.stepNumber == _wizardState.currentStep,
      orElse: () => _steps.first,
    );

    return Scaffold(
      appBar: const DesktopAppBar(currentPage: 'Build Wizard'),
      backgroundColor: const Color(0xFF2F2626),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: _wizardState.isComplete
                ? _buildSummary()
                : _buildStepContent(currentStepInfo),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = _wizardState.currentStep / _steps.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2B2727),
        border: Border(
          bottom: BorderSide(color: Color(0xFF3A3535), width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFCC00).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFCC00), width: 1),
                          ),
                          child: Text(
                            'Step ${_wizardState.currentStep} of ${_steps.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Color(0xFFFFCC00),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${(progress * 100).toInt()}% Complete',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFF3A3535),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFCC00)),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (_wizardState.estimatedPrice != null) ...[
                const SizedBox(width: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3A3535),
                        const Color(0xFF2F2626),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFCC00), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_wizardState.estimatedPrice}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFCC00),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildWizardStep step) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.stepName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose from available components',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                if (_selectedComponentId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCC00).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFCC00), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFFFFCC00), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Component Selected',
                          style: TextStyle(
                            color: Color(0xFFFFCC00),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (_wizardState.compatibilityCheck != null) ...[
              CompatibilityCard(result: _wizardState.compatibilityCheck!),
              const SizedBox(height: 24),
            ],
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Color(0xFFFFCC00)),
                    ),
                  )
                : _buildComponentTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentTable() {
    if (_currentComponents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.info_outline, size: 64, color: Colors.grey[600]),
              const SizedBox(height: 16),
              Text(
                'No compatible components found',
                style: TextStyle(fontSize: 18, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2B2727),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3A3535)),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          ..._currentComponents.asMap().entries.map((entry) {
            final index = entry.key;
            final component = entry.value;
            return _buildTableRow(component, index);
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    final isFirstStep = _wizardState.currentStep == 1;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF3A3535),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 50),
          Expanded(
            flex: isFirstStep ? 5 : 3,
            child: const Text(
              'Name',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFCC00),
                fontSize: 14,
              ),
            ),
          ),
          if (!isFirstStep)
            const Expanded(
              flex: 2,
              child: Text(
                'Price',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFCC00),
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> component, int index) {
    final id = component['id'] as int;
    final name = component['name'] as String;
    final price = component['price'] as int?;
    final isSelected = _selectedComponentId == id;
    final isEven = index.isEven;
    final isFirstStep = _wizardState.currentStep == 1;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedComponentId = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFCC00).withOpacity(0.1)
              : (isEven ? const Color(0xFF2F2626) : const Color(0xFF2B2727)),
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFF3A3535),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: isSelected
                  ? const Icon(Icons.radio_button_checked, color: Color(0xFFFFCC00), size: 24)
                  : const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 24),
            ),
            Expanded(
              flex: isFirstStep ? 5 : 3,
              child: Text(
                name,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFFCC00) : Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
            if (!isFirstStep)
              Expanded(
                flex: 2,
                child: Text(
                  price != null ? '\$${price.toString()}' : 'N/A',
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFFFCC00) : Colors.grey[300],
                    fontSize: 14,
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Build Summary',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFCC00), Color(0xFFFFDD33)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFCC00).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.black, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '\$${_wizardState.estimatedPrice ?? 0}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_wizardState.compatibilityCheck != null) ...[
            CompatibilityCard(result: _wizardState.compatibilityCheck!),
            const SizedBox(height: 24),
          ],
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2B2727),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3A3535)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3A3535),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Component',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFCC00),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'ID',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFCC00),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSummaryTableRow('PC Type', _wizardState.pcTypeId, 0),
                _buildSummaryTableRow('Processor', _wizardState.processorId, 1),
                _buildSummaryTableRow('Motherboard', _wizardState.motherboardId, 2),
                _buildSummaryTableRow('RAM Memory', _wizardState.ramId, 3),
                _buildSummaryTableRow('Graphics Card', _wizardState.graphicsCardId, 4),
                _buildSummaryTableRow('Power Supply', _wizardState.powerSupplyId, 5),
                _buildSummaryTableRow('Case', _wizardState.caseId, 6),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _wizardState = BuildWizardState();
                      _selectedComponentId = null;
                      _currentComponents = [];
                    });
                    _loadComponentsForCurrentStep();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Start Over'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A3535),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size(0, 50),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _wizardState.compatibilityCheck?.isCompatible == true
                      ? _saveBuild
                      : null,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Build Configuration'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF3A3535),
                    disabledForegroundColor: Colors.grey,
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size(0, 50),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTableRow(String label, int? value, int index) {
    final isEven = index.isEven;
    final stepNumber = _getStepNumberForComponent(label);
    final canNavigate = stepNumber != null && value != null;
    final issueType = _getIssueType(label);
    final hasError = issueType == 'error';
    final hasInfo = issueType == 'info';
    final hasWarning = issueType == 'warning';
    
    Color getBorderColor() {
      if (hasError) return Colors.red;
      if (hasWarning) return Colors.orange;
      if (hasInfo) return Colors.blue;
      return Colors.transparent;
    }
    
    Color getBackgroundColor() {
      if (hasError) return const Color(0xFF4A2C2C).withOpacity(0.3);
      if (hasWarning) return const Color(0xFF4A3C2C).withOpacity(0.3);
      if (hasInfo) return const Color(0xFF2C3A4A).withOpacity(0.3);
      return isEven ? const Color(0xFF2F2626) : const Color(0xFF2B2727);
    }
    
    Color getIconColor() {
      if (hasError) return Colors.red;
      if (hasWarning) return Colors.orange;
      if (hasInfo) return Colors.blue;
      return value != null ? const Color(0xFFFFCC00) : Colors.grey;
    }
    
    Color getTextColor() {
      if (hasError) return Colors.red.shade300;
      if (hasWarning) return Colors.orange.shade300;
      if (hasInfo) return Colors.blue.shade300;
      return Colors.white;
    }
    
    return InkWell(
      onTap: canNavigate ? () => _navigateToStep(stepNumber) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          border: Border(
            left: BorderSide(
              color: getBorderColor(),
              width: (hasError || hasWarning || hasInfo) ? 3 : 0,
            ),
            bottom: const BorderSide(
              color: Color(0xFF3A3535),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(
                    _getComponentIcon(label),
                    color: getIconColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: getTextColor(),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (hasError) ...[
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Critical issue - Click to fix',
                      child: Icon(
                        Icons.error,
                        color: Colors.red.shade400,
                        size: 18,
                      ),
                    ),
                  ] else if (hasWarning) ...[
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Warning - Consider changing',
                      child: Icon(
                        Icons.warning,
                        color: Colors.orange.shade400,
                        size: 18,
                      ),
                    ),
                  ] else if (hasInfo) ...[
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Info - Optional improvement',
                      child: Icon(
                        Icons.info,
                        color: Colors.blue.shade400,
                        size: 18,
                      ),
                    ),
                  ] else if (canNavigate) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.edit,
                      color: Color(0xFFFFCC00),
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                value != null ? '#$value' : 'Not selected',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: hasError 
                      ? Colors.red.shade300
                      : hasWarning
                          ? Colors.orange.shade300
                          : hasInfo
                              ? Colors.blue.shade300
                              : (value != null ? const Color(0xFFFFCC00) : Colors.grey),
                  fontSize: 14,
                  fontWeight: value != null ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getIssueType(String componentLabel) {
    if (_wizardState.compatibilityCheck == null) return null;
    
    final issues = _wizardState.compatibilityCheck!.issues;
    
    for (var issue in issues) {
      final component = issue.component.toLowerCase();
      final issueText = issue.issue.toLowerCase();
      final label = componentLabel.toLowerCase();
      final severity = issue.severity.toLowerCase();
      
      bool matches = false;
      
      if (label.contains('motherboard') && 
          (component.contains('motherboard') || issueText.contains('motherboard'))) {
        matches = true;
      }
      if (label.contains('case') && 
          (component.contains('case') || issueText.contains('case'))) {
        matches = true;
      }
      if (label.contains('processor') && 
          (component.contains('processor') || issueText.contains('socket'))) {
        matches = true;
      }
      if (label.contains('power') && 
          (component.contains('power') || issueText.contains('power'))) {
        matches = true;
      }
      if (label.contains('graphics') && 
          (component.contains('graphics') || issueText.contains('bottleneck'))) {
        matches = true;
      }
      
      if (matches) {
        if (severity == 'error') return 'error';
        if (severity == 'warning') return 'warning';
        if (severity == 'info') return 'info';
      }
    }
    
    return null;
  }

  int? _getStepNumberForComponent(String componentName) {
    switch (componentName) {
      case 'PC Type':
        return 1;
      case 'Processor':
        return 2;
      case 'Motherboard':
        return 3;
      case 'RAM Memory':
        return 4;
      case 'Graphics Card':
        return 5;
      case 'Power Supply':
        return 6;
      case 'Case':
        return 7;
      default:
        return null;
    }
  }

  Future<void> _navigateToStep(int stepNumber) async {
    setState(() {
      _wizardState.currentStep = stepNumber;
      _selectedComponentId = null;
      
      switch (stepNumber) {
        case 1:
          _wizardState.pcTypeId = null;
          _wizardState.processorId = null;
          _wizardState.motherboardId = null;
          _wizardState.ramId = null;
          _wizardState.graphicsCardId = null;
          _wizardState.powerSupplyId = null;
          _wizardState.caseId = null;
          break;
        case 2:
          _wizardState.processorId = null;
          _wizardState.motherboardId = null;
          _wizardState.ramId = null;
          _wizardState.graphicsCardId = null;
          _wizardState.powerSupplyId = null;
          _wizardState.caseId = null;
          break;
        case 3:
          _wizardState.motherboardId = null;
          _wizardState.ramId = null;
          _wizardState.graphicsCardId = null;
          _wizardState.powerSupplyId = null;
          _wizardState.caseId = null;
          break;
        case 4:
          _wizardState.ramId = null;
          _wizardState.graphicsCardId = null;
          _wizardState.powerSupplyId = null;
          _wizardState.caseId = null;
          break;
        case 5:
          _wizardState.graphicsCardId = null;
          _wizardState.powerSupplyId = null;
          _wizardState.caseId = null;
          break;
        case 6:
          _wizardState.powerSupplyId = null;
          _wizardState.caseId = null;
          break;
        case 7:
          _wizardState.caseId = null;
          break;
      }
      
      _isLoading = true;
    });
    
    await _loadComponentsForCurrentStep();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigated to Step $stepNumber - Choose a different component'),
          backgroundColor: const Color(0xFFFFCC00),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  IconData _getComponentIcon(String componentName) {
    switch (componentName) {
      case 'PC Type':
        return Icons.computer;
      case 'Processor':
        return Icons.memory;
      case 'Motherboard':
        return Icons.developer_board;
      case 'RAM Memory':
        return Icons.storage;
      case 'Graphics Card':
        return Icons.videogame_asset;
      case 'Power Supply':
        return Icons.power;
      case 'Case':
        return Icons.inventory_2;
      default:
        return Icons.hardware;
    }
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF2B2727),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_wizardState.currentStep > 1 && !_wizardState.isComplete)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFCC00),
                  side: const BorderSide(color: Color(0xFFFFCC00)),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back),
                    SizedBox(width: 8),
                    Text('Previous', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          if (_wizardState.currentStep > 1 && !_wizardState.isComplete)
            const SizedBox(width: 16),
          if (!_wizardState.isComplete)
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _wizardState.currentStep < _steps.length ? 'Next' : 'Finish',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveBuild() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      final pcService = PcService(userProvider: userProvider);

      final pcData = {
        'name': 'Custom Build ${DateTime.now().millisecondsSinceEpoch}',
        'pcTypeId': _wizardState.pcTypeId,
        'processorId': _wizardState.processorId,
        'ramId': _wizardState.ramId,
        'caseId': _wizardState.caseId,
        'motherBoardId': _wizardState.motherboardId,
        'powerSupplyId': _wizardState.powerSupplyId,
        'graphicsCardId': _wizardState.graphicsCardId,
      };

      await pcService.insertCustomPc(pcData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Build saved to database successfully!'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 3),
          ),
        );

        setState(() {
          _wizardState = BuildWizardState();
          _selectedComponentId = null;
          _currentComponents = [];
        });

        await _loadComponentsForCurrentStep();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save build: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
