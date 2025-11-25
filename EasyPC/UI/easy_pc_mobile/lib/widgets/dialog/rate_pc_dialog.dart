import 'package:easy_pc/models/pc.dart';
import 'package:easy_pc/providers/user_provider.dart';
import 'package:easy_pc/services/rating_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const yellow = Color(0xFFDDC03D);

class RatePcDialog {
  static Future<void> show(
    BuildContext context,
    PC pc, {
    int? existingRatingId,
    int? existingRatingValue,
    Function()? onRatingSubmitted,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: _RatePcDialogContent(
          pc: pc,
          parentContext: context,
          existingRatingId: existingRatingId,
          existingRatingValue: existingRatingValue,
          onRatingSubmitted: onRatingSubmitted,
        ),
      ),
    );
  }
}

class _RatePcDialogContent extends StatefulWidget {
  final PC pc;
  final BuildContext parentContext;
  final int? existingRatingId;
  final int? existingRatingValue;
  final Function()? onRatingSubmitted;

  const _RatePcDialogContent({
    required this.pc,
    required this.parentContext,
    this.existingRatingId,
    this.existingRatingValue,
    this.onRatingSubmitted,
  });

  @override
  State<_RatePcDialogContent> createState() => _RatePcDialogContentState();
}

class _RatePcDialogContentState extends State<_RatePcDialogContent> {
  int _selectedRating = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRatingValue != null) {
      _selectedRating = widget.existingRatingValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rate this PC',
                style: TextStyle(
                  color: yellow,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white70),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.pc.name ?? 'Unknown PC',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            widget.existingRatingValue != null
                ? 'Update your rating for this PC'
                : 'How would you rate this PC?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = starValue;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    _selectedRating >= starValue ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 42,
                  ),
                ),
              );
            }),
          ),
          if (_selectedRating > 0) ...[
            const SizedBox(height: 12),
            Text(
              _getRatingText(_selectedRating),
              style: TextStyle(
                color: yellow.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedRating > 0 && !_submitting
                      ? _submitRating
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  Future<void> _submitRating() async {
    setState(() => _submitting = true);

    final userProvider =
        Provider.of<UserProvider>(widget.parentContext, listen: false);

    if (userProvider.user == null || widget.pc.id == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        const SnackBar(
          content: Text('Unable to submit rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final username = userProvider.user?.username;
    final password = userProvider.password;

    if (username == null || password == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        const SnackBar(
          content: Text('Authentication required. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (widget.existingRatingId != null) {
        await RatingService().update(
          id: widget.existingRatingId!,
          ratingValue: _selectedRating,
          username: username,
          password: password,
        );
      } else {
        await RatingService().insert(
          userId: userProvider.user!.id!,
          pcId: widget.pc.id!,
          ratingValue: _selectedRating,
          username: username,
          password: password,
        );
      }

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Thank you for your rating!')),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      setState(() => _submitting = false);

      if (!mounted) return;

      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Text('Error submitting rating: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
