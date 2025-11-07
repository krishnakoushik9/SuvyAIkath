import 'package:flutter/material.dart';

class MicAnimation extends StatefulWidget {
  const MicAnimation({super.key, this.active = false});
  final bool active;

  @override
  State<MicAnimation> createState() => _MicAnimationState();
}

class _MicAnimationState extends State<MicAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.9,
      upperBound: 1.05,
    );
    if (widget.active) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant MicAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_c.isAnimating) _c.repeat(reverse: true);
    if (!widget.active && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      child: const Icon(Icons.mic),
    );
  }
}
