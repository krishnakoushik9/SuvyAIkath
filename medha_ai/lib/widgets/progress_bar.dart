import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        backgroundColor: Colors.black12,
        color: Colors.black,
      ),
    );
  }
}
