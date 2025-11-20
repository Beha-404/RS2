import 'package:flutter/material.dart';

class StateActionButtons extends StatelessWidget {
  final List<String> allowedActions;
  final Function(String action) onActionPressed;

  const StateActionButtons({
    super.key,
    required this.allowedActions,
    required this.onActionPressed,
  });

  ButtonStyle _getButtonStyle(String action) {
    Color color;
    switch (action) {
      case 'Activate':
        color = Colors.green;
        break;
      case 'Hide':
        color = Colors.orange;
        break;
      case 'Edit':
        color = Colors.blue;
        break;
      case 'Update':
        color = Colors.blueAccent;
        break;
      default:
        color = Colors.grey;
    }

    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  IconData _getIcon(String action) {
    switch (action) {
      case 'Activate':
        return Icons.check_circle;
      case 'Hide':
        return Icons.visibility_off;
      case 'Edit':
        return Icons.edit;
      case 'Update':
        return Icons.save;
      default:
        return Icons.touch_app;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (allowedActions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allowedActions.map((action) {
        return ElevatedButton.icon(
          onPressed: () => onActionPressed(action),
          style: _getButtonStyle(action),
          icon: Icon(_getIcon(action), size: 18),
          label: Text(action),
        );
      }).toList(),
    );
  }
}
