import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedSummaryCard extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final VoidCallback? onTap;

  const AnimatedSummaryCard({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: child,
      )
          .animate(delay: delay)
          .fadeIn(duration: 500.ms, curve: Curves.easeOut)
          .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut),
    );
  }
}
