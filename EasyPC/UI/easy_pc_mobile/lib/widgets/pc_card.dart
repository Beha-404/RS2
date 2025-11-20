import 'dart:convert';
import 'package:easy_pc/models/pc.dart';
import 'package:flutter/material.dart';

const yellow = Color(0xFFDDC03D);

class PcCard extends StatelessWidget {
  final PC pc;
  final VoidCallback onAddToCart;
  final VoidCallback onSeeDetails;

  const PcCard({
    super.key,
    required this.pc,
    required this.onAddToCart,
    required this.onSeeDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: yellow, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pc.name ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Expanded(child: _buildImage()),
                const SizedBox(height: 3),
                _buildStars(pc.averageRating ?? 0),
                const SizedBox(height: 3),
                Text(
                  'Price: ${pc.price}\$',
                  style: const TextStyle(
                    color: yellow,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                _buildAddToCartButton(),
                const SizedBox(height: 2),
                _buildSeeDetailsButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: pc.picture == null || pc.picture!.isEmpty
          ? Container(
              color: const Color(0xFF3A3A3A),
              child: const Center(
                child: Icon(Icons.desktop_windows, color: Colors.white54, size: 64),
              ),
            )
          : _buildBase64Image(pc.picture!),
    );
  }

  Widget _buildBase64Image(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFF3A3A3A),
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
          ),
        ),
      );
    } catch (e) {
      return Container(
        color: const Color(0xFF3A3A3A),
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
        ),
      );
    }
  }

  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating) {
          return const Icon(Icons.star, size: 18, color: yellow);
        } else {
          return const Icon(Icons.star_border, size: 18, color: yellow);
        }
      }),
    );
  }

  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onAddToCart,
        style: ElevatedButton.styleFrom(
          backgroundColor: yellow,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Add To Cart',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildSeeDetailsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onSeeDetails,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: yellow, width: 1.5),
          foregroundColor: yellow,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'See Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

}