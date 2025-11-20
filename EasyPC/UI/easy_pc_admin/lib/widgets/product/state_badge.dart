import 'package:flutter/material.dart';

class StateBadge extends StatelessWidget {
  final String? state;

  const StateBadge({super.key, this.state});

  Color _getColor() {
    switch (state?.toLowerCase()) {
      case 'draft':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'hidden':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon() {
    switch (state?.toLowerCase()) {
      case 'draft':
        return Icons.edit_note;
      case 'active':
        return Icons.check_circle;
      case 'hidden':
        return Icons.visibility_off;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (state == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getColor(), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), size: 16, color: _getColor()),
          const SizedBox(width: 6),
          Text(
            state!.toUpperCase(),
            style: TextStyle(
              color: _getColor(),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
