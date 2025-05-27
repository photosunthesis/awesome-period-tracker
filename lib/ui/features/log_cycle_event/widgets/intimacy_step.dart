import 'package:awesome_period_tracker/domain/models/cycle_event.dart';
import 'package:awesome_period_tracker/ui/common_widgets/app_loader/app_loader.dart';
import 'package:awesome_period_tracker/ui/common_widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/ui/common_widgets/shadow/app_shadow.dart';
import 'package:awesome_period_tracker/ui/common_widgets/snackbars/app_snackbar.dart';
import 'package:awesome_period_tracker/ui/features/log_cycle_event/log_cycle_event_cubit.dart';
import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IntimacyStep extends StatefulWidget {
  const IntimacyStep({this.intimacyEvent, super.key});

  final CycleEvent? intimacyEvent;

  @override
  State<IntimacyStep> createState() => _IntimacyStepState();
}

class _IntimacyStepState extends State<IntimacyStep> {
  late final _cubit = context.read<LogCycleEventCubit>();

  var _didUseProtection = true;
  var _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.logIntimateActivityForToday,
              style: context.primaryTextTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            for (final value in [true, false]) _buildSelectionTile(value),
            const Spacer(),
            _buildSubmitButton(),
            if (widget.intimacyEvent != null) ...[
              const SizedBox(height: 4),
              _buildRemoveLogButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionTile(bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              value
                  ? context.l10n.usedProtection
                  : context.l10n.didNotUseProtection,
              style: context.primaryTextTheme.titleSmall,
            ),
            trailing: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child:
                  value == _didUseProtection
                      ? Icon(
                        Icons.check_rounded,
                        color: context.colorScheme.primary,
                        size: 24,
                      )
                      : const SizedBox.shrink(),
            ),
            onTap: () => setState(() => _didUseProtection = value),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AppShadow(
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : () => _onSubmit(),
        child:
            _isSubmitting
                ? AppLoader(color: context.colorScheme.surface, size: 30)
                : Text(context.l10n.logIntimacy),
      ),
    );
  }

  Widget _buildRemoveLogButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: Colors.transparent,
        foregroundColor: context.colorScheme.error,
      ),
      onPressed: () {
        if (!_isSubmitting) _removeIntimacy();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_rounded,
            color: context.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(context.l10n.removeLog),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      await _cubit.logIntimacy(_didUseProtection).then((_) {
        _cubit.clearCache();
        context
          ..showSnackbar(context.l10n.cycleEventLoggedSuccessfully)
          ..popNavigator(true);
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      context.showErrorSnackbar();
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _removeIntimacy() async {
    assert(widget.intimacyEvent != null);

    try {
      setState(() => _isSubmitting = true);
      await _cubit.removeEvent(widget.intimacyEvent!);
      _cubit.clearCache();
      context
        ..showSnackbar(context.l10n.cycleEventLoggedSuccessfully)
        ..popNavigator(true);
    } catch (e) {
      // ignore: use_build_context_synchronously
      context.showErrorSnackbar();
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
