import 'package:flutter/material.dart';
import '../../../../core/utils/audio_manager.dart';


class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key}) : super(key: key);

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

                  // Currency display
                  _buildCurrencyBar(),

                  // Shop items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _shopItems.length,
                      itemBuilder: (context, index) {
                        return _buildShopCard(context, _shopItems[index]);
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
            'SHOP',
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

  Widget _buildCurrencyBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade900,
            Colors.purple.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCurrency(Icons.flash_on, '15,430'),
          Container(width: 1, height: 30, color: Colors.white30),
          _buildCurrency(Icons.diamond, '2,890'),
          Container(width: 1, height: 30, color: Colors.white30),
          _buildCurrency(Icons.stars, '12'),
        ],
      ),
    );
  }

  Widget _buildCurrency(IconData icon, String amount) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 24),
        const SizedBox(width: 8),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildShopCard(BuildContext context, ShopItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade800.withOpacity(0.8),
            Colors.black.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.color, width: 2),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Item icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [item.color.withOpacity(0.3), item.color.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: item.color, width: 2),
              ),
              child: Icon(
                item.icon,
                size: 40,
                color: item.color,
              ),
            ),

            const SizedBox(width: 16),

            // Item info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        item.currencyIcon,
                        color: item.color,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.price.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: item.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Buy button
            GestureDetector(
              onTap: () {
                SoundService().playClick();
                _showPurchaseDialog(context, item);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [item.color, item.color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Text(
                  'BUY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, ShopItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D1B4E),
        title: Text(
          item.name,
          style: const TextStyle(color: Color(0xFFFFD700)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 60, color: item.color),
            const SizedBox(height: 16),
            Text(
              item.description,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.currencyIcon, color: item.color),
                const SizedBox(width: 8),
                Text(
                  item.price.toString(),
                  style: TextStyle(
                    color: item.color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              SoundService().playClick();
              Navigator.pop(context);
              _showSuccessSnackbar(context, item.name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: item.color,
            ),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String itemName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName purchased!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static final List<ShopItem> _shopItems = [
    ShopItem(
      name: 'Energy Pack',
      description: '100 energy',
      icon: Icons.battery_charging_full,
      price: 500,
      currencyIcon: Icons.flash_on,
      color: Colors.blue,
    ),
    ShopItem(
      name: 'Lightning Pack',
      description: '10 lightning powers',
      icon: Icons.flash_on,
      price: 1000,
      currencyIcon: Icons.diamond,
      color: Colors.cyan,
    ),
    ShopItem(
      name: 'Wings Power',
      description: '5 wing dashes',
      icon: Icons.airplanemode_active,
      price: 750,
      currencyIcon: Icons.diamond,
      color: Colors.amber,
    ),
    ShopItem(
      name: 'Booster',
      description: '2x points for 1 hour',
      icon: Icons.stars,
      price: 2,
      currencyIcon: Icons.stars,
      color: Colors.purple,
    ),
    ShopItem(
      name: 'Crystal Pack',
      description: '50 mixed crystals',
      icon: Icons.diamond,
      price: 1500,
      currencyIcon: Icons.flash_on,
      color: Colors.green,
    ),
    ShopItem(
      name: 'Temple Core',
      description: '1 temple power',
      icon: Icons.account_balance,
      price: 5,
      currencyIcon: Icons.stars,
      color: Colors.orange,
    ),
    ShopItem(
      name: 'Mega Bundle',
      description: 'Everything 20% off',
      icon: Icons.shopping_bag,
      price: 5000,
      currencyIcon: Icons.diamond,
      color: Colors.red,
    ),
  ];
}

class ShopItem {
  final String name;
  final String description;
  final IconData icon;
  final int price;
  final IconData currencyIcon;
  final Color color;

  ShopItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.price,
    required this.currencyIcon,
    required this.color,
  });
}