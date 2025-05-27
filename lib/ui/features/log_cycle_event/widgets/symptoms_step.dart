import 'package:awesome_period_tracker/domain/models/cycle_event.dart';
import 'package:awesome_period_tracker/domain/models/log_event_step.dart';
import 'package:awesome_period_tracker/ui/common_widgets/app_loader/app_loader.dart';
import 'package:awesome_period_tracker/ui/common_widgets/shadow/app_shadow.dart';
import 'package:awesome_period_tracker/ui/common_widgets/snackbars/app_snackbar.dart';
import 'package:awesome_period_tracker/ui/features/log_cycle_event/log_cycle_event_cubit.dart';
import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/utils/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SymptomsStep extends StatefulWidget {
  const SymptomsStep({this.symptomEvent, super.key});

  final CycleEvent? symptomEvent;

  @override
  State<SymptomsStep> createState() => _SymptomsStepState();
}

class _SymptomsStepState extends State<SymptomsStep> {
  late final _cubit = context.read<LogCycleEventCubit>();

  var _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _cubit.loadSymptoms(widget.symptomEvent?.additionalData ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.logSymptomsExperiencedToday,
              style: context.primaryTextTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSymptoms(),
            const Spacer(),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptoms() {
    return BlocBuilder<LogCycleEventCubit, LogCycleEventState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child:
              state.isLoadingSymptoms
                  ? const Center(child: AppLoader())
                  : _buildChips(
                    context,
                    state.symptoms,
                    state.selectedSymptoms,
                  ),
        );
      },
    );
  }

  Widget _buildChips(
    BuildContext context,
    List<String> symptoms,
    List<String> selected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        children: [
          for (final symptom in symptoms)
            _buildChip(
              symptom,
              selected.contains(symptom),
              () => _cubit.toggleSymptom(symptom),
            ),
          InkWell(
            onTap: () => _cubit.setStep(LogEventStep.addNewSymptom),
            child: AppShadow(
              shadowColor: context.colorScheme.shadow.withAlpha(15),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: context.colorScheme.onTertiary,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 18,
                      color: context.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      context.l10n.addSymptom,
                      style: TextStyle(color: context.colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String symptom, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: AppShadow(
        shadowColor: context.colorScheme.shadow.withAlpha(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color:
                isSelected
                    ? context.colorScheme.secondary
                    : context.colorScheme.onTertiary,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 18,
                  color: context.colorScheme.onTertiary,
                )
              else
                InkWell(
                  onTap: () => _cubit.removeSymptom(symptom),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              SizedBox(width: isSelected ? 2 : 4),
              Text(
                symptom.toTitleCase(),
                style: TextStyle(
                  color:
                      isSelected
                          ? context.colorScheme.onTertiary
                          : context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AppShadow(
      child: BlocBuilder<LogCycleEventCubit, LogCycleEventState>(
        builder: (context, state) {
          return ElevatedButton(
            onPressed:
                _isSubmitting && state.selectedSymptoms.isEmpty
                    ? null
                    : () async => _onSubmit(state.selectedSymptoms),
            child:
                _isSubmitting
                    ? AppLoader(color: context.colorScheme.surface, size: 30)
                    : Text(context.l10n.logSymptoms),
          );
        },
      ),
    );
  }

  Future<void> _onSubmit(List<String> selectedSymptoms) async {
    try {
      setState(() => _isSubmitting = true);
      await _cubit.logSymptoms(selectedSymptoms);
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
