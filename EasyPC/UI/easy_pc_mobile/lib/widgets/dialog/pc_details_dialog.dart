import 'dart:convert';
import 'package:easy_pc/models/pc.dart';
import 'package:easy_pc/pages/login_page.dart';
import 'package:easy_pc/providers/cart_provider.dart';
import 'package:easy_pc/providers/user_provider.dart';
import 'package:easy_pc/services/rating_service.dart';
import 'package:easy_pc/services/pc_service.dart';
import 'package:easy_pc/widgets/dialog/rate_pc_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const yellow = Color(0xFFDDC03D);

class PcDetailsDialog {
  static void show(
    BuildContext context,
    PC pc, {
    bool showRateButton = false,
    Function()? onRatingSubmitted,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: _PcDetailsContent(
          pc: pc,
          parentContext: context,
          showRateButton: showRateButton,
          onRatingSubmitted: onRatingSubmitted,
        ),
      ),
    );
  }
}

class _PcDetailsContent extends StatefulWidget {
  const _PcDetailsContent({
    required this.pc,
    required this.parentContext,
    this.showRateButton = false,
    this.onRatingSubmitted,
  });

  final PC pc;
  final BuildContext parentContext;
  final bool showRateButton;
  final Function()? onRatingSubmitted;

  @override
  State<_PcDetailsContent> createState() => _PcDetailsContentState();
}

class _PcDetailsContentState extends State<_PcDetailsContent> {
  bool _checkingRating = true;
  int? _existingRatingId;
  int? _existingRatingValue;
  PC? _currentPc;
  List<PC> _recommendations = [];
  bool _loadingRecommendations = true;

  @override
  void initState() {
    super.initState();
    _currentPc = widget.pc;
    if (widget.showRateButton) {
      _checkIfUserHasRated();
    } else {
      _checkingRating = false;
    }
    _loadRecommendations();
  }

  Future<void> _checkIfUserHasRated() async {
    final userProvider = Provider.of<UserProvider>(widget.parentContext, listen: false);

    if (userProvider.user == null || _currentPc?.id == null) {
      setState(() => _checkingRating = false);
      return;
    }

    try {
      final ratings = await RatingService().getUserPcRatings(
        userId: userProvider.user!.id!,
        pcId: _currentPc!.id!,
      );

      setState(() {
        if (ratings.isNotEmpty) {
          _existingRatingId = ratings.first.id;
          _existingRatingValue = ratings.first.ratingValue;
        } else {
          _existingRatingId = null;
          _existingRatingValue = null;
        }
        _checkingRating = false;
      });
    } catch (e) {
      setState(() => _checkingRating = false);
    }
  }

  Future<void> _loadRecommendations() async {
    if (_currentPc?.id == null) {
      setState(() => _loadingRecommendations = false);
      return;
    }

    try {
      final recommendations = await PcService().getRecommendations(_currentPc!.id!);
      setState(() {
        _recommendations = recommendations;
        _loadingRecommendations = false;
      });
    } catch (e) {
      setState(() => _loadingRecommendations = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: yellow.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainInfo(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Components'),
                  const SizedBox(height: 12),
                  _buildComponentCard(
                    'Processor',
                    _currentPc!.processor?.name ?? 'N/A',
                    [
                      'Socket: ${_currentPc!.processor?.socket ?? 'N/A'}',
                      'Cores: ${_currentPc!.processor?.coreCount ?? 'N/A'}',
                      'Threads: ${_currentPc!.processor?.threadCount ?? 'N/A'}',
                      'Price: \$${_currentPc!.processor?.price ?? 0}',
                    ],
                    Icons.memory,
                  ),
                  const SizedBox(height: 10),
                  _buildComponentCard(
                    'Graphics Card',
                    _currentPc!.graphicsCard?.name ?? 'N/A',
                    [
                      'VRAM: ${_currentPc!.graphicsCard?.vram ?? 'N/A'}',
                      'Price: \$${_currentPc!.graphicsCard?.price ?? 0}',
                    ],
                    Icons.videogame_asset,
                  ),
                  const SizedBox(height: 10),
                  _buildComponentCard('RAM', _currentPc!.ram?.name ?? 'N/A', [
                    'Speed: ${_currentPc!.ram?.speed ?? 'N/A'}',
                    'Price: \$${_currentPc!.ram?.price ?? 0}',
                  ], Icons.storage),
                  const SizedBox(height: 10),
                  _buildComponentCard(
                    'Motherboard',
                    _currentPc!.motherboard?.name ?? 'N/A',
                    [
                      'Socket: ${_currentPc!.motherboard?.socket ?? 'N/A'}',
                      'Price: \$${_currentPc!.motherboard?.price ?? 0}',
                    ],
                    Icons.developer_board,
                  ),
                  const SizedBox(height: 10),
                  _buildComponentCard(
                    'Power Supply',
                    _currentPc!.powerSupply?.name ?? 'N/A',
                    [
                      'Power: ${_currentPc!.powerSupply?.power ?? 'N/A'}',
                      'Price: \$${_currentPc!.powerSupply?.price ?? 0}',
                    ],
                    Icons.power,
                  ),
                  const SizedBox(height: 10),
                  _buildComponentCard('Case', _currentPc!.cases?.name ?? 'N/A', [
                    'Form Factor: ${_currentPc!.cases?.formFactor ?? 'N/A'}',
                    'Price: \$${_currentPc!.cases?.price ?? 0}',
                  ], Icons.computer),
                  const SizedBox(height: 20),
                  if (_loadingRecommendations) ...[
                    _buildSectionTitle('Similar PCs'),
                    const SizedBox(height: 12),
                    const Center(
                      child: CircularProgressIndicator(color: yellow),
                    ),
                    const SizedBox(height: 20),
                  ] else if (_recommendations.isNotEmpty) ...[
                    _buildSectionTitle('Similar PCs'),
                    const SizedBox(height: 12),
                    _buildRecommendations(),
                    const SizedBox(height: 20),
                  ],
                  if (!widget.showRateButton) _buildAddToCartButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(color: yellow.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.computer, color: yellow, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentPc!.name ?? 'PC Details',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_currentPc!.pcType != null)
                  Text(
                    _currentPc!.pcType!.name ?? 'N/A',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: yellow),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: yellow.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.attach_money, color: yellow, size: 24),
                  const SizedBox(width: 4),
                  Text(
                    _currentPc!.price != null ? '${_currentPc!.price}' : 'N/A',
                    style: const TextStyle(
                      color: yellow,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_currentPc!.averageRating != null || widget.showRateButton) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          index < (_currentPc!.averageRating ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_currentPc!.averageRating ?? 0}/5)',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.showRateButton && !_checkingRating)
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await RatePcDialog.show(
                          context,
                          _currentPc!,
                          existingRatingId: _existingRatingId,
                          existingRatingValue: _existingRatingValue,
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          widget.onRatingSubmitted?.call();
                        }
                      },
                      icon: Icon(
                        _existingRatingValue != null ? Icons.edit : Icons.star,
                        size: 16,
                      ),
                      label: Text(
                        _existingRatingValue != null
                            ? 'Edit ($_existingRatingValue★)'
                            : 'Rate',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: yellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: yellow,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildComponentCard(
    String title,
    String name,
    List<String> specs,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: yellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: yellow, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: yellow.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...specs.map(
            (spec) => Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: yellow.withValues(alpha: 0.6),
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    spec,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recommendations.length,
        itemBuilder: (context, index) {
          final pc = _recommendations[index];
          return _buildRecommendationCard(pc);
        },
      ),
    );
  }

  Widget _buildRecommendationCard(PC pc) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        PcDetailsDialog.show(widget.parentContext, pc);
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: yellow.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 80,
                width: double.infinity,
                child: _buildRecommendationImage(pc),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pc.name ?? 'N/A',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (pc.pcType != null)
              Text(
                pc.pcType!.name ?? '',
                style: TextStyle(
                  color: yellow.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (pc.averageRating != null)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '${pc.averageRating?.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                Text(
                  '\$${pc.price ?? 0}',
                  style: const TextStyle(
                    color: yellow,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationImage(PC pc) {
    if (pc.picture == null || pc.picture!.isEmpty) {
      return Container(
        color: const Color(0xFF3A3A3A),
        child: const Center(
          child: Icon(Icons.computer, color: Colors.white54, size: 40),
        ),
      );
    }

    try {
      final bytes = base64Decode(pc.picture!);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFF3A3A3A),
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
          ),
        ),
      );
    } catch (e) {
      return Container(
        color: const Color(0xFF3A3A3A),
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
        ),
      );
    }
  }

  Widget _buildAddToCartButton(BuildContext dialogContext) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          final userProvider = Provider.of<UserProvider>(
            widget.parentContext,
            listen: false,
          );

          if (userProvider.user == null) {
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(widget.parentContext).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.warning, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please login or register to add items to cart',
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.grey[850],
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                action: SnackBarAction(
                  label: 'LOGIN',
                  textColor: yellow,
                  onPressed: () {
                    Navigator.of(widget.parentContext).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),
              ),
            );
            return;
          }
          final cartProvider = Provider.of<CartProvider>(
            widget.parentContext,
            listen: false,
          );

          cartProvider.addItem(
            _currentPc!.id!,
            _currentPc!.name ?? "Unknown name",
            _currentPc!.price ?? 0,
            _currentPc!.picture,
          );
          ScaffoldMessenger.of(widget.parentContext).clearSnackBars();
          ScaffoldMessenger.of(widget.parentContext).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${_currentPc!.name} added to cart')),
                ],
              ),
              backgroundColor: Colors.grey[850],
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.pop(dialogContext);
        },
        icon: const Icon(Icons.shopping_cart, color: Colors.black, size: 22),
        label: const Text(
          'ADD TO CART',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: yellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
