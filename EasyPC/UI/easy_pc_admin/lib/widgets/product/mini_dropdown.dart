import 'package:flutter/material.dart';

class MiniDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String hint;
  final ValueChanged<T?>? onChanged;

  const MiniDropdown({
    super.key,
    this.value,
    required this.items,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<T>(
        initialValue: value == '' ? null : value,
        onChanged: onChanged,
        dropdownColor: const Color(0xFF1F1F1F),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white60),
          filled: true,
          fillColor: const Color(0xFF1F1F1F),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
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
        items: items
            .map(
              (e) => DropdownMenuItem<T>(
                value: e,
                child: Text(e?.toString() ?? ''),
              ),
            )
            .toList(),
      ),
    );
  }
}