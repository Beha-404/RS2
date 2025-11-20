import 'package:flutter/material.dart';

const yellow = Color(0xFFDDC03D);

class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Build or Choose Your Dream PC',
          style: TextStyle(
            color: yellow,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Whether you're gaming, editing, or\nstreaming — we've got you covered.",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}