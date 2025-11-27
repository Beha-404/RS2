import 'package:easy_pc/models/manufacturer.dart';
import 'package:easy_pc/models/pc_type.dart';
import 'package:easy_pc/pages/login_page.dart';
import 'package:easy_pc/providers/user_provider.dart';
import 'package:easy_pc/services/manufacturer_service.dart';
import 'package:easy_pc/services/pc_type_service.dart';
import 'package:easy_pc/widgets/dialog/custom_pc_builder_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const yellow = Color(0xFFDDC03D);

class FilterDialog extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const FilterDialog({super.key, this.initialFilters});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  int? _selectedCpuManufacturerId;
  int? _selectedGpuManufacturerId;
  int? _selectedRamManufacturerId;
  int? _selectedMotherboardManufacturerId;
  int? _selectedPsuManufacturerId;
  int? _selectedCaseManufacturerId;
  int? _selectedPcTypeId;
  
  double _minPrice = 0;
  double _maxPrice = 5000;
  
  RangeValues _priceRange = const RangeValues(0, 5000);

  List<Manufacturer> _cpuManufacturers = [];
  List<Manufacturer> _gpuManufacturers = [];
  List<Manufacturer> _ramManufacturers = [];
  List<Manufacturer> _motherboardManufacturers = [];
  List<Manufacturer> _psuManufacturers = [];
  List<Manufacturer> _caseManufacturers = [];
  List<PcType> _pcTypes = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadManufacturers();
    _loadInitialFilters();
  }

  void _loadInitialFilters() {
    if (widget.initialFilters != null) {
      setState(() {
        _selectedCpuManufacturerId = widget.initialFilters!['cpuManufacturerId'];
        _selectedGpuManufacturerId = widget.initialFilters!['gpuManufacturerId'];
        _selectedRamManufacturerId = widget.initialFilters!['ramManufacturerId'];
        _selectedMotherboardManufacturerId = widget.initialFilters!['motherboardManufacturerId'];
        _selectedPsuManufacturerId = widget.initialFilters!['psuManufacturerId'];
        _selectedCaseManufacturerId = widget.initialFilters!['caseManufacturerId'];
        _selectedPcTypeId = widget.initialFilters!['pcTypeId'];
        
        if (widget.initialFilters!['minPrice'] != null) {
          _priceRange = RangeValues(
            widget.initialFilters!['minPrice'].toDouble(),
            widget.initialFilters!['maxPrice']?.toDouble() ?? 5000,
          );
        }
      });
    }
  }

  Future<void> _loadManufacturers() async {
    setState(() => _loading = true);
    try {
      final manufacturerService = ManufacturerService();
      final pcTypeService = PcTypeService();
      
      final results = await Future.wait([
        manufacturerService.getByComponentType('CPU'),
        manufacturerService.getByComponentType('GPU'),
        manufacturerService.getByComponentType('RAM'),
        manufacturerService.getByComponentType('MOTHERBOARD'),
        manufacturerService.getByComponentType('PSU'),
        manufacturerService.getByComponentType('CASE'),
        pcTypeService.get(),
      ]);

      print('Loaded manufacturers: $results');

      setState(() {
        _cpuManufacturers = results[0] as List<Manufacturer>;
        _gpuManufacturers = results[1] as List<Manufacturer>;
        _ramManufacturers = results[2] as List<Manufacturer>;
        _motherboardManufacturers = results[3] as List<Manufacturer>;
        _psuManufacturers = results[4] as List<Manufacturer>;
        _caseManufacturers = results[5] as List<Manufacturer>;
        _pcTypes = results[6] as List<PcType>;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading filters: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700, maxWidth: 400),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: yellow),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPcTypeDropdown(
                        'Category',
                        _pcTypes,
                        _selectedPcTypeId,
                        (value) => setState(() => _selectedPcTypeId = value),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        'CPU',
                        _cpuManufacturers,
                        _selectedCpuManufacturerId,
                        (value) => setState(() => _selectedCpuManufacturerId = value),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        'GPU',
                        _gpuManufacturers,
                        _selectedGpuManufacturerId,
                        (value) => setState(() => _selectedGpuManufacturerId = value),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        'RAM',
                        _ramManufacturers,
                        _selectedRamManufacturerId,
                        (value) => setState(() => _selectedRamManufacturerId = value),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        'Motherboard',
                        _motherboardManufacturers,
                        _selectedMotherboardManufacturerId,
                        (value) => setState(() => _selectedMotherboardManufacturerId = value),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        'Power Supply',
                        _psuManufacturers,
                        _selectedPsuManufacturerId,
                        (value) => setState(() => _selectedPsuManufacturerId = value),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        'Case',
                        _caseManufacturers,
                        _selectedCaseManufacturerId,
                        (value) => setState(() => _selectedCaseManufacturerId = value),
                      ),
                      const SizedBox(height: 24),
                      _buildBudgetSlider(),
                      const SizedBox(height: 24),
                      _buildButtons(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filter PCs',
          style: TextStyle(
            color: yellow,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: yellow),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<Manufacturer> manufacturers,
    int? selectedValue,
    Function(int?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: yellow,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: yellow.withValues(alpha: 0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedValue,
              hint: const Text(
                'Any',
                style: TextStyle(color: Colors.white70),
              ),
              isExpanded: true,
              dropdownColor: const Color(0xFF2A2A2A),
              icon: const Icon(Icons.arrow_drop_down, color: yellow),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text(
                    'Any',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ...manufacturers.map((manufacturer) {
                  return DropdownMenuItem<int>(
                    value: manufacturer.id,
                    child: Text(
                      manufacturer.name ?? 'Unknown',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPcTypeDropdown(
    String label,
    List<PcType> pcTypes,
    int? selectedValue,
    Function(int?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: yellow,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: yellow.withValues(alpha: 0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedValue,
              hint: const Text(
                'Any',
                style: TextStyle(color: Colors.white70),
              ),
              isExpanded: true,
              dropdownColor: const Color(0xFF2A2A2A),
              icon: const Icon(Icons.arrow_drop_down, color: yellow),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text(
                    'Any',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ...pcTypes.map((pcType) {
                  return DropdownMenuItem<int>(
                    value: pcType.id,
                    child: Text(
                      pcType.name ?? 'Unknown',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget',
          style: TextStyle(
            color: yellow,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 5000,
          divisions: 5000,
          activeColor: yellow,
          inactiveColor: Colors.white24,
          labels: RangeLabels(
            '\$${_priceRange.start.round()}',
            '\$${_priceRange.end.round()}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${_priceRange.start.round()}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              '\$${_priceRange.end.round()}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: yellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _resetFilters,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showCustomPcBuilder(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: yellow.withValues(alpha: 0.2),
              foregroundColor: yellow,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: yellow),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Build Your Own PC',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _applyFilters() {
    final filters = <String, dynamic>{
      'pcTypeId': _selectedPcTypeId,
      'cpuManufacturerId': _selectedCpuManufacturerId,
      'gpuManufacturerId': _selectedGpuManufacturerId,
      'ramManufacturerId': _selectedRamManufacturerId,
      'motherboardManufacturerId': _selectedMotherboardManufacturerId,
      'psuManufacturerId': _selectedPsuManufacturerId,
      'caseManufacturerId': _selectedCaseManufacturerId,
      'minPrice': _priceRange.start.round(),
      'maxPrice': _priceRange.end.round(),
    };
    
    Navigator.pop(context, filters);
  }

  void _resetFilters() {
    setState(() {
      _selectedPcTypeId = null;
      _selectedCpuManufacturerId = null;
      _selectedGpuManufacturerId = null;
      _selectedRamManufacturerId = null;
      _selectedMotherboardManufacturerId = null;
      _selectedPsuManufacturerId = null;
      _selectedCaseManufacturerId = null;
      _priceRange = const RangeValues(0, 5000);
    });
  }

  void _showCustomPcBuilder(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Please login or register to build a custom PC'),
              ),
            ],
          ),
          backgroundColor: Colors.grey[850],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    
    CustomPcBuilderDialog.show(context);
  }
}