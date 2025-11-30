import 'package:flutter/material.dart';

enum PowerType {
  thunderStrike,  // Thunder Strike - column destroy
  chainLightning, // Chain Lightning - chain reaction
  skyWings,       // Sky Wings Dash - diagonal destroy
  wrathOfOlympus, // Wrath of Olympus - clear half board
}

class Power {
  final PowerType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int cost; // How many charges needed

  const Power({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.cost,
  });

  static const List<Power> allPowers = [
    Power(
      type: PowerType.thunderStrike,
      name: 'Thunder Strike',
      description: 'Destroys a single column',
      icon: Icons.flash_on,
      color: Color(0xFF00BFFF),
      cost: 3,
    ),

    Power(
      type: PowerType.chainLightning,
      name: 'Chain Lightning',
      description: 'Triggers a chain reaction',
      icon: Icons.electric_bolt,
      color: Color(0xFFFFD700),
      cost: 5,
    ),

    Power(
      type: PowerType.skyWings,
      name: 'Sky Wings Dash',
      description: 'Clears diagonally',
      icon: Icons.airplanemode_active,
      color: Color(0xFF9C27B0),
      cost: 4,
    ),

    Power(
      type: PowerType.wrathOfOlympus,
      name: 'Wrath of Olympus',
      description: 'Cleans half of the board',
      icon: Icons.auto_awesome,
      color: Color(0xFFFF6F00),
      cost: 10,
    ),
  ];

  static Power? getPowerByType(PowerType type) {
    return allPowers.firstWhere((p) => p.type == type);
  }
}

class PowerState {
  final Map<PowerType, int> charges;

  PowerState({Map<PowerType, int>? charges})
      : charges = charges ?? {
    PowerType.thunderStrike: 0,
    PowerType.chainLightning: 0,
    PowerType.skyWings: 0,
    PowerType.wrathOfOlympus: 0,
  };

  PowerState copyWith({Map<PowerType, int>? charges}) {
    return PowerState(
      charges: charges ?? Map.from(this.charges),
    );
  }

  void addCharge(PowerType type, int amount) {
    charges[type] = (charges[type] ?? 0) + amount;
  }

  void useCharge(PowerType type, int amount) {
    charges[type] = ((charges[type] ?? 0) - amount).clamp(0, 999);
  }

  bool canUsePower(PowerType type) {
    final power = Power.getPowerByType(type);
    if (power == null) return false;
    return (charges[type] ?? 0) >= power.cost;
  }

  int getCharges(PowerType type) {
    return charges[type] ?? 0;
  }
}