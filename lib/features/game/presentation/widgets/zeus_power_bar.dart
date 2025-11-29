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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF8C00), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Energy bar - compact
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: const Color(0xFF00BFFF),
                size: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ZEUS ENERGIYASI',
                      style: const TextStyle(
                        color: Color(0xFF8B4513),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: energy / maxEnergy,
                        minHeight: 6,
                        backgroundColor: const Color(0xFF8B4513).withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00BFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$energy/$maxEnergy',
                style: const TextStyle(
                  color: Color(0xFF00BFFF),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Powers - compact
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

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: isEnabled
                  ? () {
                if (power == ZeusPower.thunderStrike) {
                  _showColumnSelector(context, power);
                } else if (power == ZeusPower.skyWingsDash) {
                  _showPositionSelector(context, power);
                } else {
                  onPowerUsed(power, null, null);
                }
              }
                  : null,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? const Color(0xFF8B4513).withOpacity(0.3)
                      : const Color(0xFF4B0082).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isEnabled
                        ? const Color(0xFF8B4513)
                        : const Color(0xFF4B0082),
                    width: 2,
                  ),
                  boxShadow: isEnabled
                      ? [
                    BoxShadow(
                      color: const Color(0xFF8B4513).withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                      : [],
                ),
                child: Icon(
                  icon,
                  color: isEnabled
                      ? const Color(0xFF8B4513)
                      : const Color(0xFF4B0082),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isEnabled
                    ? const Color(0xFF8B4513)
                    : const Color(0xFF4B0082),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '$cost⚡',
              style: TextStyle(
                color: isEnabled
                    ? const Color(0xFF00BFFF)
                    : const Color(0xFF4B0082),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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