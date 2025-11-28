import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/gem.dart';

/// Gem widget - o'yin toshi
class GemWidget extends StatelessWidget {
  final Gem gem;
  final bool isSelected;
  final VoidCallback onTap;
  
  const GemWidget({
    super.key,
    required this.gem,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: gem.isMatched ? null : onTap,
      child: AnimatedContainer(
        duration: AppConstants.swapDuration,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
            width: isSelected ? 4 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.6),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            _getGemAsset(),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to colored container if image fails
              return Container(
                decoration: BoxDecoration(
                  color: _getFallbackColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFallbackIcon(),
                  color: Colors.white,
                  size: 24,
                ),
              );
            },
          ),
        ),
      )
          .animate(target: gem.isMatched ? 1 : 0)
          .scale(end: const Offset(0.1, 0.1), duration: AppConstants.matchDuration)
          .fadeOut(duration: AppConstants.matchDuration)
          .animate(target: gem.isFalling ? 1 : 0)
          .slideY(begin: -5, duration: AppConstants.fallDuration),
    );
  }
  
  String _getGemAsset() {
    switch (gem.type) {
      case GemType.lightning:
        return 'assets/images/el1_1.png';
      case GemType.wings:
        return 'assets/images/el3_1.png';
      case GemType.temple:
        return 'assets/images/el5_1.png';
      case GemType.lyre:
        return 'assets/images/el4_1.png';
      case GemType.red:
        return 'assets/images/el6_1.png';
      case GemType.blue:
        return 'assets/images/el1_1.png';
      case GemType.green:
        return 'assets/images/el2_1.png';
      case GemType.yellow:
        return 'assets/images/el3_1.png';
      case GemType.purple:
        return 'assets/images/el6_1.png';
      case GemType.cyan:
        return 'assets/images/el4_1.png';
    }
  }
  
  Color _getFallbackColor() {
    switch (gem.type) {
      case GemType.lightning:
        return const Color(0xFF00BFFF);
      case GemType.wings:
        return const Color(0xFFFFD700);
      case GemType.temple:
        return const Color(0xFFFF8C00);
      case GemType.lyre:
        return const Color(0xFF9370DB);
      case GemType.red:
        return const Color(0xFFFF0000);
      case GemType.blue:
        return const Color(0xFF0000FF);
      case GemType.green:
        return const Color(0xFF00FF00);
      case GemType.yellow:
        return const Color(0xFFFFFF00);
      case GemType.purple:
        return const Color(0xFF800080);
      case GemType.cyan:
        return const Color(0xFF00FFFF);
    }
  }
  
  IconData _getFallbackIcon() {
    switch (gem.type) {
      case GemType.lightning:
        return Icons.flash_on;
      case GemType.wings:
        return Icons.airplanemode_active;
      case GemType.temple:
        return Icons.account_balance;
      case GemType.lyre:
        return Icons.music_note;
      default:
        return Icons.circle;
    }
  }
}