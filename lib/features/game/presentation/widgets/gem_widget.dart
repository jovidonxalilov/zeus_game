import 'package:flutter/material.dart';
import '../../domain/entities/gem.dart';

class GemWidget extends StatefulWidget {
  final Gem gem;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(Gem, DragUpdateDetails)? onDragUpdate;
  final Function(Gem)? onDragEnd;

  const GemWidget({
    Key? key,
    required this.gem,
    required this.isSelected,
    required this.onTap,
    this.onDragUpdate,
    this.onDragEnd,
  }) : super(key: key);

  @override
  State<GemWidget> createState() => _GemWidgetState();
}

class _GemWidgetState extends State<GemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(GemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gem.isMatched) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 1.0, end: 0.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: _buildGem(),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: child,
          ),
        );
      },
      child: _buildGem(),
    );
  }

  Widget _buildGem() {
    return GestureDetector(
      onTap: widget.gem.isMatched ? null : widget.onTap,
      onPanUpdate: widget.gem.isMatched ? null : (details) {
        widget.onDragUpdate?.call(widget.gem, details);
      },
      onPanEnd: widget.gem.isMatched ? null : (_) {
        widget.onDragEnd?.call(widget.gem);
      },
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.isSelected
                ? Colors.yellow
                : Colors.white.withOpacity(0.2),
            width: widget.isSelected ? 3 : 1,
          ),
          boxShadow: widget.isSelected
              ? [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.8),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            children: [
              // Gem image
              Positioned.fill(
                child: Image.asset(
                  _getGemImage(),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    // Fallback to color circle
                    return Container(
                      decoration: BoxDecoration(
                        color: widget.gem.color,
                        gradient: RadialGradient(
                          colors: [
                            widget.gem.color.withOpacity(0.9),
                            widget.gem.color,
                            widget.gem.color.withOpacity(0.7),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Shine overlay
              if (!widget.gem.isMatched)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5],
                        center: const Alignment(-0.3, -0.3),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGemImage() {
    switch (widget.gem.type) {
      case GemType.red:
        return 'assets/gems/gem_red.png';
      case GemType.blue:
        return 'assets/gems/gem_blue.png';
      case GemType.green:
        return 'assets/gems/gem_green.png';
      case GemType.cyan:
        return 'assets/gems/gem_cyan.png';
      case GemType.yellow:
        return 'assets/gems/gem_red.png'; // Reuse red
      case GemType.purple:
        return 'assets/gems/gem_blue.png'; // Reuse blue
    }
  }
}