import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: context.colorScheme.shadow,
        padding: EdgeInsets.zero,
      ),
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () {
        if (onPressed != null) {
          return onPressed!.call();
        }

        context.pop();
      },
    );
  }
}
