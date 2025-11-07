import 'package:flutter/material.dart';

class AnimatedCard extends StatelessWidget {
  const AnimatedCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (_, scale, __) => Transform.scale(scale: scale, child: child),
    );
  }
}
