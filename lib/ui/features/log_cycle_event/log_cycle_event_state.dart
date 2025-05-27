part of 'log_cycle_event_cubit.dart';

@MappableClass()
class LogCycleEventState with LogCycleEventStateMappable {
  const LogCycleEventState({
    required this.step,
    required this.date,
    this.symptoms = const [],
    this.selectedSymptoms = const [],
    this.isLoading = false,
    this.isLoadingSymptoms = false,
  });

  /// Default state with the step set to [LogEventStep.periodFlow].
  factory LogCycleEventState.initial() => LogCycleEventState(
    step: LogEventStep.periodFlow,
    date: DateTime.now().withoutTime(),
  );

  final LogEventStep step;
  final DateTime date;
  final bool isLoading;

  /// Used when logging symptoms
  final bool isLoadingSymptoms;
  final List<String> symptoms;
  final List<String> selectedSymptoms;
}
