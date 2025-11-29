import 'package:flutter/material.dart';
import '../../../../core/utils/audio_manager.dart';
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4B0082),
              Colors.black,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg_1.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

            // Dark overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(context),

                  // Inventory items
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _inventoryItems.length,
                      itemBuilder: (context, index) {
                        return _buildInventoryCard(_inventoryItems[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              SoundService().playClick();
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFFFFD700),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'INVENTORY',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade900.withOpacity(0.8),
            Colors.black.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Item image
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                item.icon,
                size: 60,
                color: const Color(0xFFFFD700),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Item name
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Item count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'x${item.count}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Item description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item.description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static final List<InventoryItem> _inventoryItems = [
    InventoryItem(
      name: 'Lightning',
      imagePath: 'assets/images/el1_1.png',
      icon: Icons.flash_on,
      count: 15,
      description: 'Thunder Strike ability',
    ),
    InventoryItem(
      name: 'Lyre',
      imagePath: 'assets/images/el4_1.png',
      icon: Icons.music_note,
      count: 8,
      description: 'Musical power boost',
    ),
    InventoryItem(
      name: 'Wings',
      imagePath: 'assets/images/el3_1.png',
      icon: Icons.airplanemode_active,
      count: 12,
      description: 'Sky Wings Dash',
    ),
    InventoryItem(
      name: 'Green Crystal',
      imagePath: 'assets/images/el2_1.png',
      icon: Icons.diamond,
      count: 45,
      description: 'Nature Gem power',
    ),
    InventoryItem(
      name: 'Red Crystal',
      imagePath: 'assets/images/el6_1.png',
      icon: Icons.diamond,
      count: 38,
      description: 'Fire Gem damage',
    ),
    InventoryItem(
      name: 'Temple Core',
      imagePath: 'assets/images/el5_1.png',
      icon: Icons.account_balance,
      count: 5,
      description: 'Temple core power',
    ),
  ];
}

class InventoryItem {
  final String name;
  final String imagePath;
  final IconData icon;
  final int count;
  final String description;

  InventoryItem({
    required this.name,
    required this.imagePath,
    required this.icon,
    required this.count,
    required this.description,
  });
}