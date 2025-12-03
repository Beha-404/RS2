import 'package:desktop/models/compatibility_check_result.dart';
import 'package:flutter/material.dart';

class CompatibilityCard extends StatelessWidget {
  final CompatibilityCheckResult result;

  const CompatibilityCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: result.isCompatible 
          ? const Color(0xFF2D4A2C) 
          : const Color(0xFF4A2C2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: result.isCompatible 
              ? const Color(0xFF4CAF50) 
              : const Color(0xFFF44336),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.isCompatible ? Icons.check_circle : Icons.error,
                  color: result.isCompatible ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.isCompatible ? 'Compatible' : 'Incompatible',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: result.isCompatible ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                        ),
                      ),
                      Text(
                        'Compatibility Score: ${result.compatibilityScore}/100',
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                _buildScoreCircle(result.compatibilityScore),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    'Estimated: ${result.estimatedWattage}W',
                    Icons.power,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    'Recommended: ${result.recommendedPsuWattage}W',
                    Icons.electric_bolt,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            if (result.performanceBottleneck != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.performanceBottleneck!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (result.issues.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Issues:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...result.issues.map((issue) => _buildIssueItem(issue)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(int score) {
    Color color;
    if (score >= 80) {
      color = Colors.green;
    } else if (score >= 60) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 3),
      ),
      child: Center(
        child: Text(
          '$score',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3535),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueItem(issue) {
    Color severityColor;
    IconData severityIcon;

    switch (issue.severity.toLowerCase()) {
      case 'error':
        severityColor = const Color(0xFFF44336);
        severityIcon = Icons.error;
        break;
      case 'warning':
        severityColor = const Color(0xFFFF9800);
        severityIcon = Icons.warning;
        break;
      default:
        severityColor = const Color(0xFF2196F3);
        severityIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3535),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(severityIcon, color: severityColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  issue.component,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: severityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            issue.issue,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.lightbulb, size: 16, color: Color(0xFFFFCC00)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  issue.suggestion,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
