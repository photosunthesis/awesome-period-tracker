import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

enum AppSnackbarType { success, error }

abstract class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackbarType type = AppSnackbarType.success,
  }) {
    showToastWidget(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: type == AppSnackbarType.success
              ? context.colorScheme.tertiary
              : context.colorScheme.error,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message,
          style: context.primaryTextTheme.bodyMedium
              ?.copyWith(color: context.colorScheme.surfaceContainer),
        ),
      ),
      context: context,
      dismissOtherToast: true,
      position: const StyledToastPosition(align: Alignment.topCenter),
      animation: StyledToastAnimation.slideToBottomFade,
      reverseAnimation: StyledToastAnimation.slideToTopFade,
      duration: const Duration(seconds: 3),
      animDuration: const Duration(milliseconds: 250),
    );
  }
}

extension AppSnackbarExtension on BuildContext {
  void showSnackbar(
    String message, {
    AppSnackbarType type = AppSnackbarType.success,
  }) {
    AppSnackbar.show(this, message: message, type: type);
  }

  void showErrorSnackbar([String? message]) {
    AppSnackbar.show(
      this,
      message: message ?? l10n.anErrorOccurredWhileProcessingYourRequest,
      type: AppSnackbarType.error,
    );
  }
}
