import 'dart:convert';
import 'dart:io';
import 'package:desktop/models/manufacturer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CustomFormFieldBuilder {
  static String formatFieldLabel(String fieldKey) {
    String label = fieldKey
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim();
    
    if (label.toLowerCase().endsWith(' id')) {
      label = label.substring(0, label.length - 3);
    }
    
    return label
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  static Widget buildFormField({
    required String fieldKey,
    required Map<String, dynamic> model,
    required List<Manufacturer>? manufacturers,
    required void Function(String key, dynamic value) onChanged,
    List<dynamic>? componentOptions,
    bool isUpdate = false,
  }) {
    String label = formatFieldLabel(fieldKey);

    if (fieldKey.toLowerCase() == 'picture') {
      return _buildImagePicker(
        fieldKey: fieldKey,
        label: label,
        model: model,
        onChanged: onChanged,
        isUpdate: isUpdate,
      );
    }

    if (fieldKey.toLowerCase().contains('manufacturer')) {
      return _buildManufacturerDropdown(
        fieldKey: fieldKey,
        label: label,
        model: model,
        manufacturers: manufacturers,
        onChanged: onChanged,
      );
    }

    if (fieldKey.toLowerCase() == 'rating') {
      return _buildRatingPicker(
        fieldKey: fieldKey,
        label: label,
        model: model,
        onChanged: onChanged,
      );
    }

    if (_isPCComponentField(fieldKey) && componentOptions != null) {
      return _buildComponentDropdown(
        fieldKey: fieldKey,
        label: label,
        model: model,
        componentOptions: componentOptions,
        onChanged: onChanged,
      );
    }

    return _buildTextField(
      fieldKey: fieldKey,
      label: label,
      model: model,
      onChanged: onChanged,
    );
  }

  static bool _isPCComponentField(String fieldKey) {
    final pcComponentFields = [
      'processorId',
      'graphicsCardId',
      'ramId',
      'motherBoardId',
      'powerSupplyId',
      'caseId',
    ];
    return pcComponentFields.contains(fieldKey);
  }

  static Widget _buildManufacturerDropdown({
    required String fieldKey,
    required String label,
    required Map<String, dynamic> model,
    required List<Manufacturer>? manufacturers,
    required void Function(String key, dynamic value) onChanged,
  }) {
    final currentValue = model[fieldKey] is int && model[fieldKey] != 0
        ? model[fieldKey] as int
        : null;

    final isValueValid = manufacturers?.any((m) => m.id == currentValue) ?? false;
    final selectedValue = isValueValid ? currentValue : null;

    if (manufacturers == null || manufacturers.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              border: Border.all(color: const Color(0xFFFFCC00)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'No manufacturers available',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: selectedValue,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            hintText: 'Select $label',
            hintStyle: const TextStyle(color: Colors.white60),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFFFCC00)),
              borderRadius: BorderRadius.circular(6),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFFFCC00)),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFFFCC00)),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          dropdownColor: const Color(0xFF2A2A2A),
          style: const TextStyle(color: Colors.white),
          items: manufacturers
              .map(
                (manufacturer) => DropdownMenuItem<int>(
                  value: manufacturer.id,
                  child: Text(manufacturer.name ?? 'Unknown'),
                ),
              )
              .toList(),
          onChanged: (v) => onChanged(fieldKey, v ?? 0),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  static Widget _buildTextField({
    required String fieldKey,
    required String label,
    required Map<String, dynamic> model,
    required void Function(String key, dynamic value) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: model[fieldKey]?.toString() ?? '',
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFFFCC00)),
              borderRadius: BorderRadius.circular(6),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFFFCC00)),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFFFCC00)),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          keyboardType: fieldKey.toLowerCase().contains('price') ||
                  fieldKey.toLowerCase().endsWith('id')
              ? TextInputType.number
              : TextInputType.text,
          onChanged: (v) {
            if (fieldKey.toLowerCase().contains('price') ||
                fieldKey.toLowerCase().endsWith('id')) {
              onChanged(fieldKey, int.tryParse(v) ?? 0);
            } else {
              onChanged(fieldKey, v);
            }
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  static Widget _buildComponentDropdown({
    required String fieldKey,
    required String label,
    required Map<String, dynamic> model,
    required List<dynamic> componentOptions,
    required void Function(String key, dynamic value) onChanged,
  }) {
    final currentValue = model[fieldKey] is int && model[fieldKey] != 0
        ? model[fieldKey] as int
        : null;

    final isValueValid = componentOptions.any((c) {
      if (c is Map) return c['id'] == currentValue;
      return false;
    });
    final selectedValue = isValueValid ? currentValue : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: selectedValue,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            hintText: 'Select $label',
            hintStyle: const TextStyle(color: Colors.white60),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFFFCC00)),
              borderRadius: BorderRadius.circular(6),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFFFCC00)),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFFFCC00)),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          dropdownColor: const Color(0xFF2A2A2A),
          style: const TextStyle(color: Colors.white),
          items: componentOptions
              .where((component) => component is Map && component['id'] != null)
              .map((component) => DropdownMenuItem<int>(
                    value: component['id'] as int,
                    child: Text(component['name'] ?? 'Unknown'),
                  ))
              .toList(),
          onChanged: (v) => onChanged(fieldKey, v ?? 0),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  static Widget _buildRatingPicker({
    required String fieldKey,
    required String label,
    required Map<String, dynamic> model,
    required void Function(String key, dynamic value) onChanged,
  }) {
    final currentRating = (model[fieldKey] is int)
        ? model[fieldKey] as int
        : int.tryParse(model[fieldKey]?.toString() ?? '0') ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            border: Border.all(color: const Color(0xFFFFCC00)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isSelected = starValue <= currentRating;

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onChanged(fieldKey, starValue),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFCC00),
                      size: 36,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 24),
      ],
    );
  }

  static Widget _buildImagePicker({
    required String fieldKey,
    required String label,
    required Map<String, dynamic> model,
    required void Function(String key, dynamic value) onChanged,
    required bool isUpdate,
  }) {
    String? selectedImagePath;
    String? currentImageBase64 = model[fieldKey]?.toString();

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                border: Border.all(color: const Color(0xFFFFCC00)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  if (selectedImagePath != null || currentImageBase64 != null) ...[
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: selectedImagePath != null
                            ? Image.file(
                                File(selectedImagePath!),
                                fit: BoxFit.contain,
                              )
                            : currentImageBase64 != null && currentImageBase64.isNotEmpty
                                ? Image.memory(
                                    base64Decode(currentImageBase64),
                                    fit: BoxFit.contain,
                                  )
                                : const SizedBox(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC00),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                    ),
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        allowMultiple: false,
                      );

                      if (result != null && result.files.single.path != null) {
                        final file = File(result.files.single.path!);
                        final bytes = await file.readAsBytes();
                        final base64String = base64Encode(bytes);

                        setState(() {
                          selectedImagePath = result.files.single.path;
                        });

                        onChanged(fieldKey, base64String);
                      }
                    },
                    icon: Icon(
                      selectedImagePath != null || currentImageBase64 != null
                          ? Icons.edit
                          : Icons.add_photo_alternate,
                    ),
                    label: Text(
                      isUpdate
                          ? (selectedImagePath != null || currentImageBase64 != null
                              ? 'Change Picture'
                              : 'Update Picture')
                          : (selectedImagePath != null || currentImageBase64 != null
                              ? 'Change Picture'
                              : 'Add Picture'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (selectedImagePath != null || currentImageBase64 != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      selectedImagePath != null
                          ? 'Selected: ${selectedImagePath!.split('\\').last}'
                          : 'Current image',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}