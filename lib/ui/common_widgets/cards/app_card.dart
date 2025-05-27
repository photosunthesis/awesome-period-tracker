import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.backgroundColor,
    this.boxShadow,
    this.border,
    this.isAnimated = false,
    super.key,
  });

  final Widget child;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: backgroundColor ?? context.colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      border: border,
      boxShadow:
          boxShadow ??
          [
            BoxShadow(
              color: context.colorScheme.shadow.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
    );

    if (isAnimated) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        decoration: decoration,
        child: child,
      );
    }

    return DecoratedBox(decoration: decoration, child: child);
  }
}
