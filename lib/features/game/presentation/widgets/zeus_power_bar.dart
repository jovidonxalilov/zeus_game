import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_theme.dart';

/// Zeus power bar widget
class ZeusPowerBar extends StatelessWidget {
  final int energy;
  final int maxEnergy;
  final Function(ZeusPower power, int? row, int? col) onPowerUsed;
  
  const ZeusPowerBar({
    super.key,
    required this.energy,
    required this.maxEnergy,
    required this.onPowerUsed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.goldenBorder,
      child: Column(
        children: [
          // Energy bar
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: AppConstants.electricBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zeus Energiyasi',
                      style: TextStyle(
                        color: AppConstants.primaryGold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: energy / maxEnergy,
                        minHeight: 10,
                        backgroundColor: AppConstants.darkPurple.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppConstants.electricBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$energy/$maxEnergy',
                style: TextStyle(
                  color: AppConstants.electricBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Powers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPowerButton(
                context: context,
                power: ZeusPower.thunderStrike,
                icon: Icons.flash_on,
                label: 'Chaqmoq',
                cost: AppConstants.thunderStrikeCost,
              ),
              _buildPowerButton(
                context: context,
                power: ZeusPower.chainLightning,
                icon: Icons.electric_bolt,
                label: 'Zanjir',
                cost: AppConstants.chainLightningCost,
              ),
              _buildPowerButton(
                context: context,
                power: ZeusPower.skyWingsDash,
                icon: Icons.airplanemode_active,
                label: 'Qanotlar',
                cost: AppConstants.skyWingsCost,
              ),
              _buildPowerButton(
                context: context,
                power: ZeusPower.wrathOfOlympus,
                icon: Icons.whatshot,
                label: 'G\'azab',
                cost: AppConstants.wrathOfOlympusCost,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, duration: 500.ms);
  }
  
  Widget _buildPowerButton({
    required BuildContext context,
    required ZeusPower power,
    required IconData icon,
    required String label,
    required int cost,
  }) {
    final isEnabled = energy >= cost;
    
    return Column(
      children: [
        GestureDetector(
          onTap: isEnabled
              ? () {
                  if (power == ZeusPower.thunderStrike) {
                    // Need to select column
                    _showColumnSelector(context, power);
                  } else if (power == ZeusPower.skyWingsDash) {
                    // Need to select position
                    _showPositionSelector(context, power);
                  } else {
                    // Direct use
                    onPowerUsed(power, null, null);
                  }
                }
              : null,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isEnabled
                  ? AppConstants.primaryGold.withOpacity(0.2)
                  : AppConstants.darkPurple.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEnabled
                    ? AppConstants.primaryGold
                    : AppConstants.darkPurple,
                width: 2,
              ),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: AppConstants.primaryGold.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isEnabled
                  ? AppConstants.primaryGold
                  : AppConstants.darkPurple,
              size: 32,
            ),
          ).animate(target: isEnabled ? 1 : 0).shimmer(duration: 2.seconds),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isEnabled ? Colors.white : Colors.white38,
            fontSize: 10,
          ),
        ),
        Text(
          '$cost⚡',
          style: TextStyle(
            color: isEnabled
                ? AppConstants.electricBlue
                : AppConstants.darkPurple,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  void _showColumnSelector(BuildContext context, ZeusPower power) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.darkPurple,
        title: Text(
          'Ustunni tanlang',
          style: TextStyle(color: AppConstants.primaryGold),
        ),
        content: SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppConstants.gridColumns,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: AppConstants.gridColumns,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  onPowerUsed(power, null, index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppConstants.primaryGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppConstants.primaryGold, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: AppConstants.primaryGold,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  void _showPositionSelector(BuildContext context, ZeusPower power) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.darkPurple,
        title: Text(
          'Joyni tanlang',
          style: TextStyle(color: AppConstants.primaryGold),
        ),
        content: const Text(
          'O\'yin maydonida joyni tanlang',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Bekor qilish'),
          ),
        ],
      ),
    );
  }
}
