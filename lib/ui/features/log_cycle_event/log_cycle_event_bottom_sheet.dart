import 'package:animations/animations.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event_type.dart';
import 'package:awesome_period_tracker/domain/models/log_event_step.dart';
import 'package:awesome_period_tracker/ui/features/log_cycle_event/log_cycle_event_cubit.dart';
import 'package:awesome_period_tracker/ui/features/log_cycle_event/widgets/add_new_symptom_step.dart';
import 'package:awesome_period_tracker/ui/features/log_cycle_event/widgets/intimacy_step.dart';
import 'package:awesome_period_tracker/ui/features/log_cycle_event/widgets/period_flow_step.dart';
import 'package:awesome_period_tracker/ui/features/log_cycle_event/widgets/symptoms_step.dart';
import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class LogCycleEventBottomSheet extends StatefulWidget {
  const LogCycleEventBottomSheet._({
    required this.date,
    required this.step,
    required this.cycleEventsForDate,
  });

  final DateTime date;
  final LogEventStep step;
  final List<CycleEvent> cycleEventsForDate;

  static Future<T?> showCycleEventTypeBottomSheet<T>(
    BuildContext context, {
    required LogEventStep step,
    required DateTime date,
    required List<CycleEvent> cycleEventsForDate,
  }) async {
    return showModalBottomSheet<T?>(
      context: context,
      scrollControlDisabledMaxHeightRatio: 0.9,
      isScrollControlled: true,
      barrierColor: context.colorScheme.shadow.withAlpha(140),
      builder:
          (context) => Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: BlocProvider(
              create: (_) => GetIt.I<LogCycleEventCubit>(),
              child: LogCycleEventBottomSheet._(
                date: date,
                step: step,
                cycleEventsForDate: cycleEventsForDate,
              ),
            ),
          ),
    );
  }

  @override
  State<StatefulWidget> createState() => _LogCycleEventBottomSheetState();
}

class _LogCycleEventBottomSheetState extends State<LogCycleEventBottomSheet> {
  late final _cubit = context.read<LogCycleEventCubit>();

  static const _webPadding = 24.0;

  @override
  void initState() {
    super.initState();
    _cubit
      ..setDate(widget.date)
      ..setStep(widget.step);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogCycleEventCubit, LogCycleEventState>(
      builder: (context, state) {
        final height =
            MediaQuery.of(context).size.height * state.step.heightFactor +
            (kIsWeb ? _webPadding : 0);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height,
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPill(),
              _buildBody(state.step),
              if (kIsWeb) const SizedBox(height: _webPadding),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPill() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: context.colorScheme.shadow.withAlpha(30),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildBody(LogEventStep step) {
    return Expanded(
      child: PageTransitionSwitcher(
        reverse: step != LogEventStep.addNewSymptom,
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            fillColor: Colors.transparent,
            child: child,
          );
        },
        child: switch (step) {
          LogEventStep.periodFlow => PeriodFlowStep(
            periodEvent: widget.cycleEventsForDate.firstWhereOrNull(
              (e) => e.type == CycleEventType.period && !e.isPrediction,
            ),
          ),
          LogEventStep.symptoms => SymptomsStep(
            symptomEvent: widget.cycleEventsForDate.firstWhereOrNull(
              (e) => e.type == CycleEventType.symptoms,
            ),
          ),
          LogEventStep.intimacy => IntimacyStep(
            intimacyEvent: widget.cycleEventsForDate.firstWhereOrNull(
              (e) => e.type == CycleEventType.intimacy && !e.isPrediction,
            ),
          ),
          LogEventStep.addNewSymptom => const AddNewSymptomStep(),
        },
      ),
    );
  }
}
