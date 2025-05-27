import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PinInputField extends StatelessWidget {
  const PinInputField({
    required this.controller,
    required this.validator,
    required this.onCompleted,
    super.key,
  });

  final TextEditingController controller;
  final String? Function(String?) validator;
  final void Function(String) onCompleted;

  PinTheme _defaultPinTheme(BuildContext context) => PinTheme(
    padding: const EdgeInsets.all(14),
    textStyle: context.primaryTextTheme.titleLarge,
    decoration: BoxDecoration(
      color: context.colorScheme.onPrimary,
      borderRadius: BorderRadius.circular(8),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Pinput(
        pinputAutovalidateMode: PinputAutovalidateMode.disabled,
        length: 6,
        validator: validator,
        onCompleted: onCompleted,
        autofocus: !kIsWeb,
        showCursor: true,
        obscureText: true,
        defaultPinTheme: _defaultPinTheme(context),
        errorPinTheme: _defaultPinTheme(context).copyWith(
          decoration: BoxDecoration(
            border: Border.all(color: context.colorScheme.error, width: 2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        errorBuilder: (errorText, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(
                errorText!,
                style: context.primaryTextTheme.titleSmall?.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
