import 'package:desktop/models/compatibility_check_result.dart';
import 'package:desktop/services/compatibility_service.dart';
import 'package:desktop/services/processor_service.dart';
import 'package:desktop/services/motherboard_service.dart';
import 'package:desktop/services/ram_service.dart';
import 'package:desktop/services/graphics_card_service.dart';
import 'package:desktop/services/power_supply_service.dart';
import 'package:desktop/services/case_service.dart';
import 'package:desktop/widgets/compatibility_card.dart';
import 'package:desktop/widgets/desktop_app_bar.dart';
import 'package:flutter/material.dart';

class CompatibilityCheckerPage extends StatefulWidget {
  const CompatibilityCheckerPage({super.key});

  @override
  State<CompatibilityCheckerPage> createState() => _CompatibilityCheckerPageState();
}

class _CompatibilityCheckerPageState extends State<CompatibilityCheckerPage> {
  int? _selectedProcessorId;
  int? _selectedMotherboardId;
  int? _selectedRamId;
  int? _selectedGraphicsCardId;
  int? _selectedPowerSupplyId;
  int? _selectedCaseId;

  List<dynamic> _processors = [];
  List<dynamic> _motherboards = [];
  List<dynamic> _rams = [];
  List<dynamic> _graphicsCards = [];
  List<dynamic> _powerSupplies = [];
  List<dynamic> _cases = [];

  CompatibilityCheckResult? _result;
  bool _isLoading = false;
  bool _isLoadingComponents = true;

  @override
  void initState() {
    super.initState();
    _loadAllComponents();
  }

  Future<void> _loadAllComponents() async {
    setState(() => _isLoadingComponents = true);
    try {
      final processors = await const ProcessorService().get();
      final motherboards = await const MotherboardService().get();
      final rams = await const RamService().get();
      final graphicsCards = await const GraphicsCardService().get();
      final powerSupplies = await const PowerSupplyService().get();
      final cases = await const CaseService().get();

      setState(() {
        _processors = processors.map((e) => {'id': e.id, 'name': e.name, 'price': e.price}).toList();
        _motherboards = motherboards.map((e) => {'id': e.id, 'name': e.name, 'price': e.price}).toList();
        _rams = rams.map((e) => {'id': e.id, 'name': e.name, 'price': e.price}).toList();
        _graphicsCards = graphicsCards.map((e) => {'id': e.id, 'name': e.name, 'price': e.price}).toList();
        _powerSupplies = powerSupplies.map((e) => {'id': e.id, 'name': e.name, 'price': e.price}).toList();
        _cases = cases.map((e) => {'id': e.id, 'name': e.name, 'price': e.price}).toList();
        _isLoadingComponents = false;
      });
    } catch (e) {
      setState(() => _isLoadingComponents = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading components: $e')),
        );
      }
    }
  }

  Future<void> _checkCompatibility() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final result = await CompatibilityService.checkCompatibility(
        processorId: _selectedProcessorId,
        motherboardId: _selectedMotherboardId,
        ramId: _selectedRamId,
        graphicsCardId: _selectedGraphicsCardId,
        powerSupplyId: _selectedPowerSupplyId,
        caseId: _selectedCaseId,
      );

      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking compatibility: $e')),
        );
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedProcessorId = null;
      _selectedMotherboardId = null;
      _selectedRamId = null;
      _selectedGraphicsCardId = null;
      _selectedPowerSupplyId = null;
      _selectedCaseId = null;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingComponents) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const DesktopAppBar(currentPage: 'Compatibility'),
      backgroundColor: const Color(0xFF2F2626),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildComponentSelection(),
          ),
          Expanded(
            flex: 3,
            child: _buildResultPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentSelection() {
    return Container(
      color: const Color(0xFF2B2727),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Components',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFCC00),
              ),
            ),
            const SizedBox(height: 24),
            _buildDropdown('Processor', _processors, _selectedProcessorId, (val) {
              setState(() => _selectedProcessorId = val);
            }),
            const SizedBox(height: 16),
            _buildDropdown('Motherboard', _motherboards, _selectedMotherboardId, (val) {
              setState(() => _selectedMotherboardId = val);
            }),
            const SizedBox(height: 16),
            _buildDropdown('RAM', _rams, _selectedRamId, (val) {
              setState(() => _selectedRamId = val);
            }),
            const SizedBox(height: 16),
            _buildDropdown('Graphics Card', _graphicsCards, _selectedGraphicsCardId, (val) {
              setState(() => _selectedGraphicsCardId = val);
            }),
            const SizedBox(height: 16),
            _buildDropdown('Power Supply', _powerSupplies, _selectedPowerSupplyId, (val) {
              setState(() => _selectedPowerSupplyId = val);
            }),
            const SizedBox(height: 16),
            _buildDropdown('Case', _cases, _selectedCaseId, (val) {
              setState(() => _selectedCaseId = val);
            }),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkCompatibility,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 24),
                          SizedBox(width: 12),
                          Text('Check Compatibility', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _clearSelection,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFCC00),
                  side: const BorderSide(color: Color(0xFFFFCC00)),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Clear All', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<dynamic> items,
    int? selectedValue,
    void Function(int?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFCC00),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3A3535),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF4A4444)),
          ),
          child: DropdownButtonFormField<int>(
            value: selectedValue,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFF3A3535),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: const Color(0xFF3A3535),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            hint: Text('Select $label', style: const TextStyle(color: Colors.grey)),
            items: items.map((item) {
              return DropdownMenuItem<int>(
                value: item['id'] as int,
                child: Text(item['name'] as String),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildResultPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: _result == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.computer,
                    size: 120,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select components and check compatibility',
                    style: TextStyle(fontSize: 20, color: Colors.grey[500]),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: CompatibilityCard(result: _result!),
              ),
      ),
    );
  }
}
