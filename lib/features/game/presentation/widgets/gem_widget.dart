import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/gem.dart';

/// SUPER SIMPLE Gem Widget - NO fancy stuff, just WORKS!
class GemWidgetSimple extends StatelessWidget {
  final Gem gem;
  final bool isSelected;
  final VoidCallback onTap;

  const GemWidgetSimple({
    super.key,
    required this.gem,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: gem.isMatched ? null : onTap,
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: _getColor(),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.white24,
            width: isSelected ? 4 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.yellow,
              blurRadius: 10,
              spreadRadius: 2,
            )
          ]
              : null,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (gem.type) {
      case GemType.lightning:
        return Colors.blue;
      case GemType.wings:
        return Colors.amber;
      case GemType.temple:
        return Colors.red;
      case GemType.lyre:
        return Colors.purple;
      case GemType.red:
        return Colors.pink;
      case GemType.blue:
        return Colors.lightBlue;
      case GemType.green:
        return Colors.green;
      case GemType.yellow:
        return Colors.yellow;
      case GemType.purple:
        return Colors.deepPurple;
      case GemType.cyan:
        return Colors.cyan;
    }
  }
}