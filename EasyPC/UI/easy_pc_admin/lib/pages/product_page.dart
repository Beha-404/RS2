import 'package:desktop/models/case.dart';
import 'package:desktop/models/graphics_card.dart';
import 'package:desktop/models/manufacturer.dart';
import 'package:desktop/models/motherboard.dart';
import 'package:desktop/models/pc.dart';
import 'package:desktop/models/power_supply.dart';
import 'package:desktop/models/processor.dart';
import 'package:desktop/models/ram.dart';
import 'package:desktop/providers/user_provider.dart';
import 'package:desktop/services/case_service.dart';
import 'package:desktop/services/graphics_card_service.dart';
import 'package:desktop/services/manufacturer_service.dart';
import 'package:desktop/services/motherboard_service.dart';
import 'package:desktop/services/pc_service.dart';
import 'package:desktop/services/power_supply_service.dart';
import 'package:desktop/services/processor_service.dart';
import 'package:desktop/services/ram_service.dart';
import 'package:desktop/widgets/product/add_form_panel.dart';
import 'package:desktop/widgets/product/update_form_panel.dart';
import 'package:desktop/widgets/product/mini_dropdown.dart';
import 'package:desktop/widgets/product/state_badge.dart';
import 'package:desktop/widgets/product/state_action_buttons.dart';
import 'package:desktop/widgets/desktop_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {
  final _types = const [
    'Select Component',
    "Processor",
    "Graphics Card",
    "Power Supply",
    "Ram",
    "Case",
    "Motherboard",
    "PC",
  ];

  late final ProcessorService processorService;
  late final GraphicsCardService graphicsCardService;
  late final RamService ramService;
  late final PowerSupplyService powerSupplyService;
  late final CaseService caseService;
  late final MotherboardService motherboardService;
  late final ManufacturerService manufacturerService;
  late final PcService pcService;

  String _selectedType = 'Select Component';
  String _selectedAction = 'GET';
  List<dynamic>? _items;
  dynamic _newModel = {};
  dynamic _model = {};
  
  final Map<int, List<String>> _itemAllowedActions = {};
  
  int _currentPage = 1;
  final int _pageSize = 4;
  int _totalItems = 0;
  int get _totalPages => (_totalItems / _pageSize).ceil();

  AnimationController? _animationController;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    processorService = ProcessorService(userProvider: userProvider);
    graphicsCardService = GraphicsCardService(userProvider: userProvider);
    ramService = RamService(userProvider: userProvider);
    powerSupplyService = PowerSupplyService(userProvider: userProvider);
    caseService = CaseService(userProvider: userProvider);
    motherboardService = MotherboardService(userProvider: userProvider);
    manufacturerService = ManufacturerService(userProvider: userProvider);
    pcService = PcService(userProvider: userProvider);
    _initAnimation();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: Curves.easeInOut,
          ),
        );
  }

  void _onTypeChange(String type) async {
    setState(() {
      _items = null;
      _selectedType = type;
      _itemAllowedActions.clear();
      _currentPage = 1;
    });

    await _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _getItemsByType(_selectedType);

    if (_selectedType != 'Manufacturer') {
      for (final item in items) {
        final id = item.id as int?;
        if (id != null) {
          await _loadAllowedActions(id);
        }
      }
    }

    setState(() {
      _items = items;
      _totalItems = items.length;
      _selectedAction = 'GET';
    });
  }
  
  List<dynamic> get _paginatedItems {
    if (_items == null) return [];
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, _items!.length);
    return _items!.sublist(startIndex, endIndex);
  }
  
  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  Future<List<dynamic>> _getItemsByType(String type) async {
    switch (type) {
      case 'Graphics Card':
        return await graphicsCardService.get();
      case 'Processor':
        return await processorService.get();
      case 'Ram':
        return await ramService.get();
      case 'Power Supply':
        return await powerSupplyService.get();
      case 'Case':
        return await caseService.get();
      case 'Motherboard':
        return await motherboardService.get();
      case 'Manufacturer':
        return await manufacturerService.get();
      case 'PC':
        return await pcService.get();
      default:
        return [];
    }
  }

  void _onActionChange(String action) {
    setState(() {
      _selectedAction = action;
      if (action == 'ADD') {
        _newModel = _getEmptyModelByType(_selectedType);
        _animationController?.forward();
      } else if (action == 'GET') {
        _animationController?.reverse();
      }
    });
  }

  Map<String, dynamic> _getEmptyModelByType(String type) {
    switch (type) {
      case 'Graphics Card':
        return GraphicsCard.emptyMap();
      case 'Processor':
        return Processor.emptyMap();
      case 'Ram':
        return Ram.emptyMap();
      case 'Power Supply':
        return PowerSupply.emptyMap();
      case 'Case':
        return Case.emptyMap();
      case 'Motherboard':
        return MotherBoard.emptyMap();
      case 'Manufacturer':
        return Manufacturer.emptyMap();
      case 'PC':
        return PC.emptyMap();
      default:
        return {};
    }
  }

  void _setModel(Map<String, dynamic> m) async {
    setState(() {
      _model = Map.from(m);
      _newModel = Map.from(m);
      _selectedAction = 'UPDATE';
      _animationController?.forward();
    });

    final id = m['id'] as int?;
    if (id != null) {
      await _loadAllowedActions(id);
    }
  }

  Future<void> _loadAllowedActions(int id) async {
    if (_selectedType == 'Manufacturer') {
      return;
    }

    List<String> actions = [];
    switch (_selectedType) {
      case 'Processor':
        actions = await processorService.getAllowedActions(id);
        break;
      case 'Graphics Card':
        actions = await graphicsCardService.getAllowedActions(id);
        break;
      case 'Ram':
        actions = await ramService.getAllowedActions(id);
        break;
      case 'Power Supply':
        actions = await powerSupplyService.getAllowedActions(id);
        break;
      case 'Case':
        actions = await caseService.getAllowedActions(id);
        break;
      case 'Motherboard':
        actions = await motherboardService.getAllowedActions(id);
        break;
      case 'PC':
        actions = await pcService.getAllowedActions(id);
        break;
    }

    setState(() {
      _itemAllowedActions[id] = actions;
    });
  }

  Future<void> _handleStateAction(int id, String action) async {
    if (action == 'Update') {
      final item = _items?.firstWhere((x) => x.id == id);
      if (item != null) {
        _setModel(item.toMap());
      }
      return;
    }

    bool success = false;
    String? errorMessage;

    try {
      switch (_selectedType) {
        case 'Processor':
          switch (action) {
            case 'Activate':
              success = await processorService.activate(id);
              break;
            case 'Hide':
              success = await processorService.hide(id);
              break;
            case 'Edit':
              success = await processorService.edit(id);
              break;
          }
          break;
        case 'Graphics Card':
          switch (action) {
            case 'Activate':
              success = await graphicsCardService.activate(id);
              break;
            case 'Hide':
              success = await graphicsCardService.hide(id);
              break;
            case 'Edit':
              success = await graphicsCardService.edit(id);
              break;
          }
          break;
        case 'Ram':
          switch (action) {
            case 'Activate':
              success = await ramService.activate(id);
              break;
            case 'Hide':
              success = await ramService.hide(id);
              break;
            case 'Edit':
              success = await ramService.edit(id);
              break;
          }
          break;
        case 'Power Supply':
          switch (action) {
            case 'Activate':
              success = await powerSupplyService.activate(id);
              break;
            case 'Hide':
              success = await powerSupplyService.hide(id);
              break;
            case 'Edit':
              success = await powerSupplyService.edit(id);
              break;
          }
          break;
        case 'Case':
          switch (action) {
            case 'Activate':
              success = await caseService.activate(id);
              break;
            case 'Hide':
              success = await caseService.hide(id);
              break;
            case 'Edit':
              success = await caseService.edit(id);
              break;
          }
          break;
        case 'Motherboard':
          switch (action) {
            case 'Activate':
              success = await motherboardService.activate(id);
              break;
            case 'Hide':
              success = await motherboardService.hide(id);
              break;
            case 'Edit':
              success = await motherboardService.edit(id);
              break;
          }
          break;
        case 'PC':
          switch (action) {
            case 'Activate':
              success = await pcService.activate(id);
              break;
            case 'Hide':
              success = await pcService.hide(id);
              break;
            case 'Edit':
              success = await pcService.edit(id);
              break;
          }
          break;
      }
    } catch (e) {
      errorMessage = e.toString();
      success = false;
    }

    if (success) {
      await _loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action "$action" completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage != null 
              ? 'Action "$action" failed: $errorMessage' 
              : 'Action "$action" failed!'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _addItem() async {
    dynamic newEntity;
    bool success = false;
    String? errorMessage;
    
    try {
      switch (_selectedType) {
        case 'Graphics Card':
          newEntity = GraphicsCard.fromMap(_newModel);
          success = await graphicsCardService.insert(newEntity);
          break;
        case 'Processor':
          newEntity = Processor.fromMap(_newModel);
          success = await processorService.insert(newEntity);
          break;
        case 'Ram':
          newEntity = Ram.fromMap(_newModel);
          success = await ramService.insert(newEntity);
          break;
        case 'Power Supply':
          newEntity = PowerSupply.fromMap(_newModel);
          success = await powerSupplyService.insert(newEntity);
          break;
        case 'Case':
          newEntity = Case.fromMap(_newModel);
          success = await caseService.insert(newEntity);
          break;
        case 'Motherboard':
          newEntity = MotherBoard.fromMap(_newModel);
          success = await motherboardService.insert(newEntity);
          break;
        case 'Manufacturer':
          newEntity = Manufacturer.fromMap(_newModel);
          success = await manufacturerService.insert(newEntity);
          break;
        case 'PC':
          newEntity = PC.fromMap(_newModel);
          success = await pcService.insert(newEntity);
          break;
        default:
          break;
      }
    } catch (e) {
      errorMessage = e.toString();
      success = false;
    }
    
    if (success) {
      await _loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _closeForm();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage != null 
              ? 'Add failed: $errorMessage' 
              : 'Add failed!'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _updateItem() async {
    dynamic updatedEntity;
    bool success = false;
    String? errorMessage;

    final modelAsMap = Map<String, dynamic>.from(_newModel);

    try {
      switch (_selectedType) {
        case 'Graphics Card':
          updatedEntity = GraphicsCard.fromMap(modelAsMap);
          success = await graphicsCardService.update(updatedEntity);
          break;
        case 'Processor':
          updatedEntity = Processor.fromMap(modelAsMap);
          success = await processorService.update(updatedEntity);
          break;
        case 'Ram':
          updatedEntity = Ram.fromMap(modelAsMap);
          success = await ramService.update(updatedEntity);
          break;
        case 'Power Supply':
          updatedEntity = PowerSupply.fromMap(modelAsMap);
          success = await powerSupplyService.update(updatedEntity);
          break;
        case 'Case':
          updatedEntity = Case.fromMap(modelAsMap);
          success = await caseService.update(updatedEntity);
          break;
        case 'Motherboard':
          updatedEntity = MotherBoard.fromMap(modelAsMap);
          success = await motherboardService.update(updatedEntity);
          break;
        case 'Manufacturer':
          updatedEntity = Manufacturer.fromMap(modelAsMap);
          success = await manufacturerService.update(updatedEntity);
          break;
        case 'PC':
          updatedEntity = PC.fromMap(modelAsMap);
          success = await pcService.update(updatedEntity);
          break;
        default:
          break;
      }
    } catch (e) {
      errorMessage = e.toString();
      success = false;
    }

    if (success) {
      await _loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _closeForm();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage != null 
              ? 'Update failed: $errorMessage' 
              : 'Update failed!'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _closeForm() {
    _animationController?.reverse().then((_) {
      setState(() {
        _selectedAction = 'GET';
        _newModel = {};
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DesktopAppBar(currentPage: 'Products'),
      body: Stack(
        children: [
          _buildMainContent(),
          if (_selectedAction == 'ADD' || _selectedAction == 'UPDATE')
            _buildFormPanel(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Select Your Component',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFFFCC00),
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFFFFCC00),
                  size: 28,
                ),
                const SizedBox(height: 8),
                _buildDropdowns(),
                const SizedBox(height: 36),
                _buildItemsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdowns() {
    return Column(
      children: [
        MiniDropdown<String>(
          value: _selectedType,
          items: _types,
          hint: 'Component',
          onChanged: (v) => _onTypeChange(v ?? ''),
        ),
        const SizedBox(height: 12),
        if (_selectedAction != 'UPDATE')
          MiniDropdown<String>(
            value: _selectedAction,
            items: const ['GET', 'ADD'],
            hint: 'Action',
            onChanged: _selectedType == 'Select Component'
                ? null
                : (v) => _onActionChange(v ?? 'GET'),
          ),
      ],
    );
  }

  Widget _buildItemsList() {
    return Column(
      children: [
        Container(
          width: 700,
          height: 550,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF191919),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12)],
          ),
          child: _items?.isEmpty ?? true
              ? const Center(
                  child: Text(
                    'No items found',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: _paginatedItems.length,
                  itemBuilder: (context, index) {
                    final item = _paginatedItems[index];
                    return _buildListItem(item);
                  },
                ),
        ),
        if (_items != null && _items!.isNotEmpty && _totalPages > 1)
          _buildPaginationControls(),
      ],
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFCC00), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            color: _currentPage > 1 ? const Color(0xFFFFCC00) : Colors.grey,
          ),
          const SizedBox(width: 16),
          Text(
            'Page $_currentPage of $_totalPages',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($_totalItems items)',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _currentPage < _totalPages ? () => _goToPage(_currentPage + 1) : null,
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            color: _currentPage < _totalPages ? const Color(0xFFFFCC00) : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(dynamic item) {
    final itemId = item.id as int;
    final stateMachineSupported = _selectedType != 'Manufacturer';
    final itemState = item.toMap()['stateMachine'] as String?;
    final allowedActions = _itemAllowedActions[itemId] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFFCC00), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFFCC00)),
                      borderRadius: BorderRadius.circular(6),
                      color: const Color(0xFF2A2A2A),
                    ),
                    child: Center(
                      child: Text(
                        '${item.name}',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (stateMachineSupported) StateBadge(state: itemState),
              ],
            ),
            const SizedBox(height: 12),
            if (stateMachineSupported && allowedActions.isNotEmpty)
              StateActionButtons(
                allowedActions: allowedActions,
                onActionPressed: (action) => _handleStateAction(itemId, action),
              )
            else if (!stateMachineSupported)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton('Update', () => _setModel(item.toMap())),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFCC00),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  Widget _buildFormPanel() {
    if (_slideAnimation == null) return const SizedBox.shrink();

    final modelAsMap = Map<String, dynamic>.from(_newModel);

    return SlideTransition(
      position: _slideAnimation!,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 380,
          margin: const EdgeInsets.only(top: 100, bottom: 100, right: 80),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: _selectedAction == 'ADD'
              ? AddFormPanel(
                  onAdd: _addItem,
                  onClose: _closeForm,
                  model: modelAsMap,
                  componentType: _selectedType,
                  onChanged: (k, v) => setState(() => _newModel[k] = v),
                  manufacturerService: manufacturerService,
                )
              : UpdateFormPanel(
                  onUpdate: _updateItem,
                  onClose: _closeForm,
                  model: modelAsMap,
                  componentType: _selectedType,
                  onChanged: (k, v) => setState(() => _newModel[k] = v),
                  manufacturerService: manufacturerService,
                ),
        ),
      ),
    );
  }
}
