import 'package:flutter/material.dart';

import '../../domain/entities/power.dart';

class PowerBar extends StatelessWidget {
  final PowerState powerState;
  final Function(PowerType) onPowerTap;

  const PowerBar({
    Key? key,
    required this.powerState,
    required this.onPowerTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade900.withOpacity(0.8),
            Colors.black.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: Power.allPowers.map((power) {
          return _buildPowerButton(power);
        }).toList(),
      ),
    );
  }

  Widget _buildPowerButton(Power power) {
    final charges = powerState.getCharges(power.type);
    final canUse = powerState.canUsePower(power.type);

    return GestureDetector(
      onTap: canUse ? () => onPowerTap(power.type) : null,
      child: Container(
        width: 60,
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canUse
                ? [power.color.withOpacity(0.8), power.color]
                : [Colors.grey.shade800, Colors.grey.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canUse ? power.color : Colors.grey.shade700,
            width: 2,
          ),
          boxShadow: canUse
              ? [
            BoxShadow(
              color: power.color.withOpacity(0.5),
              blurRadius: 8,
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              power.icon,
              color: canUse ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$charges/${power.cost}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: canUse ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}