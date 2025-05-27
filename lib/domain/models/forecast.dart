import 'package:awesome_period_tracker/domain/models/cycle_event.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event_type.dart';
import 'package:awesome_period_tracker/domain/models/menstruation_phase.dart';

class Forecast {
  const Forecast({
    required this.date,
    required this.dayOfCycle,
    required this.daysUntilNextPeriod,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.phase,
    required this.events,
    required this.eventsForDate,
  });

  final DateTime date;
  final int dayOfCycle;
  final int daysUntilNextPeriod;
  final int averageCycleLength;
  final int averagePeriodLength;
  final MenstruationPhase phase;
  final List<CycleEvent> events;
  final List<CycleEvent> eventsForDate;

  DateTime get nextFertileWindowStartDate =>
      events
          .where((e) => e.date.isAfter(date))
          .firstWhere((e) => e.type == CycleEventType.fertile)
          .date;

  int get daysUntilNextFertileWindow =>
      nextFertileWindowStartDate.difference(date).inDays;
}
