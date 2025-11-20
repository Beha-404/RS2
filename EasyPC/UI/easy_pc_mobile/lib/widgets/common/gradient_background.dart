import 'dart:math' as math;
import 'package:easy_pc/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final double angle;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.angle = 135,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? [
            AppColors.gradientStart,
            AppColors.gradientEnd,
          ],
          transform: GradientRotation(angle * math.pi / 180),
        ),
      ),
      child: child,
    );
  }
}