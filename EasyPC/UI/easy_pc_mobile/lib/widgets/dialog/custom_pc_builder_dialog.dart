import 'package:easy_pc/models/case.dart';
import 'package:easy_pc/models/graphics_card.dart';
import 'package:easy_pc/models/motherboard.dart';
import 'package:easy_pc/models/pc_type.dart';
import 'package:easy_pc/models/power_supply.dart';
import 'package:easy_pc/models/processor.dart';
import 'package:easy_pc/models/ram.dart';
import 'package:easy_pc/providers/cart_provider.dart';
import 'package:easy_pc/providers/user_provider.dart';
import 'package:easy_pc/services/case_service.dart';
import 'package:easy_pc/services/graphics_card_service.dart';
import 'package:easy_pc/services/motherboard_service.dart';
import 'package:easy_pc/services/pc_service.dart';
import 'package:easy_pc/services/pc_type_service.dart';
import 'package:easy_pc/services/power_supply_service.dart';
import 'package:easy_pc/services/processor_service.dart';
import 'package:easy_pc/services/ram_service.dart';
import 'package:easy_pc/utils/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const yellow = Color(0xFFDDC03D);

class CustomPcBuilderDialog extends StatefulWidget {
  const CustomPcBuilderDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const CustomPcBuilderDialog(),
    );
  }

  @override
  State<CustomPcBuilderDialog> createState() => _CustomPcBuilderDialogState();
}

class _CustomPcBuilderDialogState extends State<CustomPcBuilderDialog> {
  List<Processor> _processors = [];
  List<GraphicsCard> _graphicsCards = [];
  List<Ram> _rams = [];
  List<MotherBoard> _motherboards = [];
  List<PowerSupply> _powerSupplies = [];
  List<Case> _cases = [];
  List<PcType> _pcTypes = [];

  Processor? _selectedProcessor;
  GraphicsCard? _selectedGraphicsCard;
  Ram? _selectedRam;
  MotherBoard? _selectedMotherboard;
  PowerSupply? _selectedPowerSupply;
  Case? _selectedCase;
  PcType? _selectedPcType;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadComponents();
  }

  Future<void> _loadComponents() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ProcessorService().getAll(),
        GraphicsCardService().getAll(),
        RamService().getAll(),
        MotherboardService().getAll(),
        PowerSupplyService().getAll(),
        CaseService().getAll(),
        PcTypeService().get(),
      ]);

      setState(() {
        _processors = results[0] as List<Processor>;
        _graphicsCards = results[1] as List<GraphicsCard>;
        _rams = results[2] as List<Ram>;
        _motherboards = results[3] as List<MotherBoard>;
        _powerSupplies = results[4] as List<PowerSupply>;
        _cases = results[5] as List<Case>;
        _pcTypes = results[6] as List<PcType>;
        
        // Set default PC type to first one if available
        if (_pcTypes.isNotEmpty) {
          _selectedPcType = _pcTypes.first;
        }
        
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading components: $e')),
        );
      }
    }
  }

  int get totalPrice {
    int total = 0;
    if (_selectedProcessor != null) total += _selectedProcessor!.price ?? 0;
    if (_selectedGraphicsCard != null) total += _selectedGraphicsCard!.price ?? 0;
    if (_selectedRam != null) total += _selectedRam!.price ?? 0;
    if (_selectedMotherboard != null) total += _selectedMotherboard!.price ?? 0;
    if (_selectedPowerSupply != null) total += _selectedPowerSupply!.price ?? 0;
    if (_selectedCase != null) total += _selectedCase!.price ?? 0;
    return total;
  }

  bool get isComplete {
    return _selectedPcType != null &&
        _selectedProcessor != null &&
        _selectedGraphicsCard != null &&
        _selectedRam != null &&
        _selectedMotherboard != null &&
        _selectedPowerSupply != null &&
        _selectedCase != null;
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
                      _buildPcTypeDropdown(),
                      const SizedBox(height: 16),
                      _buildComponentDropdown<Processor>(
                        'Processor',
                        _processors,
                        _selectedProcessor,
                        (value) => setState(() => _selectedProcessor = value),
                        (p) => p.name ?? 'Unknown',
                        (p) => '\$${p.price ?? 0}',
                      ),
                      const SizedBox(height: 16),
                      _buildComponentDropdown<GraphicsCard>(
                        'Graphics Card',
                        _graphicsCards,
                        _selectedGraphicsCard,
                        (value) => setState(() => _selectedGraphicsCard = value),
                        (g) => g.name ?? 'Unknown',
                        (g) => '\$${g.price ?? 0}',
                      ),
                      const SizedBox(height: 16),
                      _buildComponentDropdown<Ram>(
                        'RAM',
                        _rams,
                        _selectedRam,
                        (value) => setState(() => _selectedRam = value),
                        (r) => r.name ?? 'Unknown',
                        (r) => '\$${r.price ?? 0}',
                      ),
                      const SizedBox(height: 16),
                      _buildComponentDropdown<MotherBoard>(
                        'Motherboard',
                        _motherboards,
                        _selectedMotherboard,
                        (value) => setState(() => _selectedMotherboard = value),
                        (m) => m.name ?? 'Unknown',
                        (m) => '\$${m.price ?? 0}',
                      ),
                      const SizedBox(height: 16),
                      _buildComponentDropdown<PowerSupply>(
                        'Power Supply',
                        _powerSupplies,
                        _selectedPowerSupply,
                        (value) => setState(() => _selectedPowerSupply = value),
                        (p) => p.name ?? 'Unknown',
                        (p) => '\$${p.price ?? 0}',
                      ),
                      const SizedBox(height: 16),
                      _buildComponentDropdown<Case>(
                        'Case',
                        _cases,
                        _selectedCase,
                        (value) => setState(() => _selectedCase = value),
                        (c) => c.name ?? 'Unknown',
                        (c) => '\$${c.price ?? 0}',
                      ),
                      const SizedBox(height: 24),
                      _buildPriceDisplay(),
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
          'Build Custom PC',
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

  Widget _buildPcTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: const [
              Text(
                'PC Type',
                style: TextStyle(
                  color: yellow,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedPcType == null
                  ? Colors.red.withValues(alpha: 0.5)
                  : yellow.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PcType>(
              value: _selectedPcType,
              hint: const Text(
                'Select PC type',
                style: TextStyle(color: Colors.white54),
              ),
              isExpanded: true,
              dropdownColor: const Color(0xFF2A2A2A),
              icon: const Icon(Icons.arrow_drop_down, color: yellow),
              items: _pcTypes.map((pcType) {
                return DropdownMenuItem<PcType>(
                  value: pcType,
                  child: Text(
                    pcType.name ?? 'Unknown',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedPcType = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComponentDropdown<T>(
    String label,
    List<T> items,
    T? selectedValue,
    Function(T?) onChanged,
    String Function(T) getName,
    String Function(T) getPrice,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: yellow,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectedValue == null
                  ? Colors.red.withValues(alpha: 0.5)
                  : yellow.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: selectedValue,
              hint: const Text(
                'Select component',
                style: TextStyle(color: Colors.white54),
              ),
              isExpanded: true,
              dropdownColor: const Color(0xFF2A2A2A),
              icon: const Icon(Icons.arrow_drop_down, color: yellow),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          getName(item),
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        getPrice(item),
                        style: const TextStyle(
                          color: yellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: yellow.withValues(alpha: 0.5), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Price:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '\$$totalPrice',
            style: const TextStyle(
              color: yellow,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _resetComponents,
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
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isComplete ? _addToCart : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isComplete ? yellow : Colors.grey,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Add to Cart',
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

  void _resetComponents() {
    setState(() {
      _selectedPcType = _pcTypes.isNotEmpty ? _pcTypes.first : null;
      _selectedProcessor = null;
      _selectedGraphicsCard = null;
      _selectedRam = null;
      _selectedMotherboard = null;
      _selectedPowerSupply = null;
      _selectedCase = null;
    });
  }

  void _addToCart() async {
    if (!isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select all components'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: yellow),
      ),
    );

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final username = userProvider.user?.username;
      final password = userProvider.password;

      if (username == null || password == null) {
        if (mounted) Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication error. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final headers = AuthHelper.getAuthHeadersFromCredentials(username, password);
      
      final customPcName = 'Custom PC - ${_selectedProcessor!.name}';
      
      // Create PC data for backend
      final pcData = {
        'name': customPcName,
        'pcTypeId': _selectedPcType!.id,
        'processorId': _selectedProcessor!.id,
        'ramId': _selectedRam!.id,
        'caseId': _selectedCase!.id,
        'motherBoardId': _selectedMotherboard!.id,
        'psuId': _selectedPowerSupply!.id,
        'graphicsCardId': _selectedGraphicsCard!.id,
      };

      // Create PC in database
      final createdPc = await PcService().insertCustomPc(pcData, headers: headers);

      if (createdPc == null || createdPc.id == null) {
        throw Exception('Failed to create custom PC');
      }

      if (mounted) Navigator.pop(context); // Close loading dialog

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      cartProvider.addItem(
        createdPc.id!,
        customPcName,
        totalPrice,
        null, // Custom PCs don't have a picture
      );

      if (mounted) Navigator.pop(context); // Close builder dialog
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Custom PC added to cart - \$$totalPrice')),
              ],
            ),
            backgroundColor: Colors.grey[850],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create custom PC: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
