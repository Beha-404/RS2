import 'package:desktop/models/manufacturer.dart';
import 'package:desktop/services/manufacturer_service.dart';
import 'package:desktop/services/motherboard_service.dart';
import 'package:desktop/services/processor_service.dart';
import 'package:desktop/services/graphics_card_service.dart';
import 'package:desktop/services/ram_service.dart';
import 'package:desktop/services/power_supply_service.dart';
import 'package:desktop/services/case_service.dart';
import 'package:desktop/utils/form_field_builder.dart';
import 'package:flutter/material.dart';

class UpdateFormPanel extends StatefulWidget {
  final VoidCallback onUpdate;
  final VoidCallback onClose;
  final Map<String, dynamic> model;
  final String componentType;
  final void Function(String key, dynamic value) onChanged;
  final ManufacturerService manufacturerService;

  const UpdateFormPanel({
    super.key,
    required this.onUpdate,
    required this.onClose,
    required this.model,
    required this.componentType,
    required this.onChanged,
    required this.manufacturerService,
  });

  @override
  State<UpdateFormPanel> createState() => _UpdateFormPanelState();
}

class _UpdateFormPanelState extends State<UpdateFormPanel> {
  List<Manufacturer>? _manufacturers;
  bool _isLoading = true;

  Map<String, List<dynamic>> _pcComponents = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (widget.componentType == 'PC') {
        await _loadPCComponents();
      } else {
        final componentTypeMapping = _mapComponentType(widget.componentType);
        final manufacturers = await widget.manufacturerService.getByComponentType(componentTypeMapping);
        setState(() {
          _manufacturers = manufacturers;
        });
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPCComponents() async {
    final processors = await ProcessorService().get();
    final graphicsCards = await GraphicsCardService().get();
    final rams = await RamService().get();
    final motherboards = await MotherboardService().get();
    final powerSupplies = await PowerSupplyService().get();
    final cases = await CaseService().get();

    _pcComponents = {
      'processorId': processors.map((e) => e.toMap()).toList(),
      'graphicsCardId': graphicsCards.map((e) => e.toMap()).toList(),
      'ramId': rams.map((e) => e.toMap()).toList(),
      'motherBoardId': motherboards.map((e) => e.toMap()).toList(),
      'powerSupplyId': powerSupplies.map((e) => e.toMap()).toList(),
      'caseId': cases.map((e) => e.toMap()).toList(),
    };
  }

  String _mapComponentType(String componentType) {
    switch (componentType) {
      case 'Graphics Card':
        return 'GPU';
      case 'Processor':
        return 'CPU';
      case 'Ram':
        return 'RAM';
      case 'Power Supply':
        return 'PSU';
      case 'Case':
        return 'CASE';
      case 'Motherboard':
        return 'MOTHERBOARD';
      case 'PC':
        return 'PC';
      default:
        return componentType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = widget.model.keys.where((key) => key != 'id').toList();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Update ${widget.componentType.toUpperCase()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFFCC00),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: fields.map((fieldKey) {
                        return CustomFormFieldBuilder.buildFormField(
                          fieldKey: fieldKey,
                          model: widget.model,
                          manufacturers: _manufacturers,
                          onChanged: widget.onChanged,
                          componentOptions: _pcComponents[fieldKey],
                          isUpdate: true,
                        );
                      }).toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: widget.onUpdate,
                  child: const Text(
                    'UPDATE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: widget.onClose,
                  child: const Text(
                    'CLOSE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}