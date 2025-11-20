import 'dart:convert';
import 'package:easy_pc/models/pc.dart';
import 'package:flutter/material.dart';

const yellow = Color(0xFFDDC03D);

class SuggestedPcsSection extends StatefulWidget {
  final List<PC> suggestedPcs;
  final Function(PC) onPcTap;

  const SuggestedPcsSection({
    super.key,
    required this.suggestedPcs,
    required this.onPcTap,
  });

  @override
  State<SuggestedPcsSection> createState() => _SuggestedPcsSectionState();
}

class _SuggestedPcsSectionState extends State<SuggestedPcsSection> {
  final ScrollController _scrollController = ScrollController();
  final double _itemWidth = 83.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - _itemWidth,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + _itemWidth,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.suggestedPcs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Suggested PC-s',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  itemCount: widget.suggestedPcs.length,
                  itemBuilder: (context, index) {
                    final pc = widget.suggestedPcs[index];
                    return _buildSuggestedPcCard(pc);
                  },
                ),
                // Left arrow
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A).withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _scrollLeft,
                        icon: const Icon(Icons.chevron_left, color: yellow),
                        iconSize: 28,
                      ),
                    ),
                  ),
                ),
                // Right arrow
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A).withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _scrollRight,
                        icon: const Icon(Icons.chevron_right, color: yellow),
                        iconSize: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedPcCard(PC pc) {
    return GestureDetector(
      onTap: () => widget.onPcTap(pc),
      child: Container(
        width: _itemWidth,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF3A4A5C),
                shape: BoxShape.circle,
                border: Border.all(color: yellow.withValues(alpha: 0.3), width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (pc.picture != null && pc.picture!.isNotEmpty)
                    ClipOval(
                      child: _buildBase64Image(pc.picture!),
                    )
                  else
                    _buildDefaultIcon(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: ${pc.price?.toStringAsFixed(0)}\$',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return const Icon(
      Icons.computer,
      color: yellow,
      size: 50,
    );
  }

  Widget _buildBase64Image(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildDefaultIcon(),
      );
    } catch (e) {
      return _buildDefaultIcon();
    }
  }
}
