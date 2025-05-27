import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';

class AppShadow extends StatelessWidget {
  const AppShadow({required this.child, this.shadowColor, super.key});

  final Widget child;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? context.colorScheme.shadow.withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
