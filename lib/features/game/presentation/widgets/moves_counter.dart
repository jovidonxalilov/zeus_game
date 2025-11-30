import 'package:flutter/material.dart';

class MovesCounter extends StatelessWidget {
  final int moves;

  const MovesCounter({Key? key, required this.moves}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLow = moves <= 5;
    final color = isLow ? Colors.red : Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.swap_horiz,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'MOVEMENTS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
              TweenAnimationBuilder<int>(
                duration: const Duration(milliseconds: 300),
                tween: IntTween(begin: moves + 1, end: moves),
                builder: (context, value, child) {
                  return Text(
                    value.toString(),
                    style: TextStyle(
                      color: color,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}