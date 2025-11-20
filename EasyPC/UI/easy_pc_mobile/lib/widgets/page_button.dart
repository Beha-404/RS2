import 'package:flutter/material.dart';

const yellow = Color(0xFFDDC03D);

class PageButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const PageButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: onTap == null ? Colors.white24 : yellow),
      label: Text(
        label,
        style: TextStyle(color: onTap == null ? Colors.white24 : yellow),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }
}