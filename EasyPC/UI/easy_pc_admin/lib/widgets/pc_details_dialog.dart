import 'package:desktop/models/pc.dart';
import 'package:flutter/material.dart';

const yellow = Color(0xFFFFCC00);

class PcDetailsDialog {
  static void show(BuildContext context, PC pc) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 800,
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(dialogContext, pc),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainInfo(pc),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Components'),
                      const SizedBox(height: 16),
                      _buildComponentCard(
                        'Processor',
                        pc.processor?.name ?? 'N/A',
                        [
                          'Socket: ${pc.processor?.socket ?? 'N/A'}',
                          'Cores: ${pc.processor?.coreCount ?? 'N/A'}',
                          'Threads: ${pc.processor?.threadCount ?? 'N/A'}',
                          'Price: \$${pc.processor?.price ?? 0}',
                        ],
                        Icons.memory,
                      ),
                      const SizedBox(height: 12),
                      _buildComponentCard(
                        'Graphics Card',
                        pc.graphicsCard?.name ?? 'N/A',
                        [
                          'VRAM: ${pc.graphicsCard?.vram ?? 'N/A'}',
                          'Price: \$${pc.graphicsCard?.price ?? 0}',
                        ],
                        Icons.videogame_asset,
                      ),
                      const SizedBox(height: 12),
                      _buildComponentCard(
                        'RAM',
                        pc.ram?.name ?? 'N/A',
                        [
                          'Speed: ${pc.ram?.speed ?? 'N/A'}',
                          'Price: \$${pc.ram?.price ?? 0}',
                        ],
                        Icons.storage,
                      ),
                      const SizedBox(height: 12),
                      _buildComponentCard(
                        'Motherboard',
                        pc.motherboard?.name ?? 'N/A',
                        [
                          'Socket: ${pc.motherboard?.socket ?? 'N/A'}',
                          'Price: \$${pc.motherboard?.price ?? 0}',
                        ],
                        Icons.developer_board,
                      ),
                      const SizedBox(height: 12),
                      _buildComponentCard(
                        'Power Supply',
                        pc.powerSupply?.name ?? 'N/A',
                        [
                          'Power: ${pc.powerSupply?.power ?? 'N/A'}',
                          'Price: \$${pc.powerSupply?.price ?? 0}',
                        ],
                        Icons.power,
                      ),
                      const SizedBox(height: 12),
                      _buildComponentCard(
                        'Case',
                        pc.cases?.name ?? 'N/A',
                        [
                          'Form Factor: ${pc.cases?.formFactor ?? 'N/A'}',
                          'Price: \$${pc.cases?.price ?? 0}',
                        ],
                        Icons.computer,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildHeader(BuildContext context, PC pc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1F1F1F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.computer, color: yellow, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pc.name ?? 'PC Details',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (pc.pcType != null)
                  Text(
                    pc.pcType!.name ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white70, size: 28),
          ),
        ],
      ),
    );
  }

  static Widget _buildMainInfo(PC pc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: yellow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.attach_money, color: yellow, size: 32),
                  const SizedBox(width: 4),
                  Text(
                    pc.price != null ? '${pc.price}' : 'N/A',
                    style: const TextStyle(
                      color: yellow,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (pc.rating != null && pc.rating! > 0)
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index < (pc.rating ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${pc.rating ?? 0}/5)',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: yellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: yellow,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static Widget _buildComponentCard(
    String title,
    String name,
    List<String> specs,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: yellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: yellow, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: yellow.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...specs.map(
            (spec) => Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: yellow.withOpacity(0.6),
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    spec,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
