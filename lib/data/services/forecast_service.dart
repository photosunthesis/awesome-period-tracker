import 'package:awesome_period_tracker/config/environment/env.dart';
import 'package:awesome_period_tracker/data/repositories/cycle_prediction_repository.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event_type.dart';
import 'package:awesome_period_tracker/domain/models/forecast.dart';
import 'package:awesome_period_tracker/domain/models/menstruation_phase.dart';
import 'package:awesome_period_tracker/utils/extensions/date_time_extensions.dart';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';

@injectable
class ForecastService {
  const ForecastService(this._env, this._cyclePredictionRepository);

  final Env _env;
  final CyclePredictionRepository _cyclePredictionRepository;

  static const _defaultPeriodDaysLength = 5;
  static const _defaultCycleDaysLength = 28;

  Future<Forecast> createForecastForDateFromEvents(
    DateTime selectedDate,
    List<CycleEvent> events,
  ) async {
    events.sort((a, b) => a.date.compareTo(b.date));

    final endDate = selectedDate.add(const Duration(days: 365));
    final apiPrediction = await _cyclePredictionRepository.fetchPrediction(
      events,
    );

    final predictions = _generatePredictions(
      selectedDate,
      events,
      apiPrediction.predictedCycleStarts,
      endDate,
      apiPrediction.averageCycleLength,
      apiPrediction.averagePeriodLength,
    );

    final mergedEvents = _mergePredictionsWithActualEvents(events, predictions);

    final nextPeriod = mergedEvents.firstWhereOrNull(
      (e) => e.date.isAfter(selectedDate) && e.type == CycleEventType.period,
    );

    final isCurrentlyInPeriod = mergedEvents
        .where((e) => e.type == CycleEventType.period && !e.isPrediction)
        .any((e) => e.date.isSameDay(selectedDate));

    final daysUntilNextPeriod = _calculateDaysUntilNextPeriod(
      isCurrentlyInPeriod,
      nextPeriod,
      selectedDate,
    );

    final eventToday = mergedEvents.firstWhereOrNull(
      (e) => e.date.isSameDay(selectedDate),
    );

    final dayOfCycle = _getDayOfCurrentCycle(mergedEvents, selectedDate);

    final phase = _determineMenstruationPhase(
      dayOfCycle,
      daysUntilNextPeriod,
      isCurrentlyInPeriod,
      eventToday?.type == CycleEventType.fertile,
    );

    final eventsForDate =
        mergedEvents.where((e) => e.date.isSameDay(selectedDate)).toList();

    return Forecast(
      date: selectedDate,
      dayOfCycle: dayOfCycle,
      averageCycleLength: apiPrediction.averageCycleLength,
      averagePeriodLength: apiPrediction.averagePeriodLength,
      daysUntilNextPeriod: daysUntilNextPeriod,
      phase: phase,
      events: mergedEvents,
      eventsForDate: eventsForDate,
    );
  }

  int _calculateDaysUntilNextPeriod(
    bool isCurrentlyInPeriod,
    CycleEvent? nextPeriod,
    DateTime date,
  ) {
    return isCurrentlyInPeriod
        ? 0
        : (nextPeriod != null ? nextPeriod.date.difference(date).inDays : -1);
  }

  int _getDayOfCurrentCycle(List<CycleEvent> events, DateTime selectedDate) {
    if (events.isEmpty) return 1;

    final recentPeriods =
        events
            .where(
              (e) =>
                  e.type == CycleEventType.period &&
                  !e.date.isAfter(selectedDate),
            )
            .toList();

    if (recentPeriods.isEmpty) return 1;

    late DateTime periodStart;

    recentPeriods.sort((a, b) => b.date.compareTo(a.date));

    for (final period in recentPeriods) {
      final index = recentPeriods.indexOf(period);
      final previousPeriod = recentPeriods[index + 1];

      if (period.date.difference(previousPeriod.date).inDays > 1) {
        periodStart = period.date;
        break;
      }
    }

    return selectedDate.difference(periodStart).inDays + 1;
  }

  List<CycleEvent> _generatePredictions(
    DateTime selectedDate,
    List<CycleEvent> events,
    List<DateTime> predictedCycleStarts,
    DateTime endDate,
    int averageCycleLength,
    int averagePeriodLength,
  ) {
    final predictions = <CycleEvent>[];

    // Find the last actual period
    final lastActualPeriod =
        events
            .where((e) => e.type == CycleEventType.period && !e.isPrediction)
            .map((e) => e.date)
            .lastOrNull ??
        selectedDate;

    // Adjust predictions if period might be late
    final adjustedPredictedStarts = _adjustPredictedStarts(
      selectedDate,
      lastActualPeriod,
      predictedCycleStarts,
    );

    // Generate period predictions for future cycles using adjusted dates
    predictions.addAll(
      _generateFuturePeriodPredictions(
        lastActualPeriod,
        adjustedPredictedStarts,
        endDate,
        averagePeriodLength,
      ),
    );

    // Generate fertile window predictions
    predictions.addAll(
      _generateFertileWindowPredictions([...events, ...predictions]),
    );

    return predictions;
  }

  List<CycleEvent> _generateFertileWindowPredictions(List<CycleEvent> events) {
    final periodFirstDates = _findPeriodStartDates(events);
    final fertileWindowEvents = <CycleEvent>[];

    // Require at least two period dates to predict fertile windows
    if (periodFirstDates.length < 2) return fertileWindowEvents;

    for (int i = 0; i < periodFirstDates.length - 1; i++) {
      final nextPeriodStart = periodFirstDates[i + 1];

      // Predict ovulation 14 days before next period
      final ovulationDate = nextPeriodStart.subtract(const Duration(days: 14));

      // Fertile window is 5 days before and day of ovulation
      final fertileWindowStart = ovulationDate.subtract(
        const Duration(days: 5),
      );
      final fertileWindowEnd = ovulationDate;

      // Generate fertile window events
      var currentDate = fertileWindowStart;

      while (!currentDate.isAfter(fertileWindowEnd)) {
        fertileWindowEvents.add(
          CycleEvent(
            date: currentDate,
            type: CycleEventType.fertile,
            isPrediction: true,
            createdBy: _env.systemId,
          ),
        );
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }

    return fertileWindowEvents;
  }

  List<DateTime> _findPeriodStartDates(List<CycleEvent> events) {
    // Sort and deduplicate event dates
    final mergedEvents =
        events
            .where(
              (e) =>
                  e.type == CycleEventType.period && !e.isUncertainPrediction,
            )
            .map((e) => e.date.withoutTime())
            .toSet()
            .toList()
          ..sort((a, b) => a.compareTo(b));

    final periodStartDates = <DateTime>[];

    // Start with first date
    periodStartDates.add(mergedEvents.first);

    for (int eventIndex = 1; eventIndex < mergedEvents.length; eventIndex++) {
      final currentDate = mergedEvents[eventIndex];
      final previousStartDate = periodStartDates.last;

      // Check for potential new cycle start
      final daysSincePreviousStart =
          currentDate.difference(previousStartDate).inDays;

      if (daysSincePreviousStart > (_defaultCycleDaysLength)) {
        // Validate if this is truly a new cycle
        bool isNewCycle = true;

        for (
          int prevEventIndex = eventIndex - 1;
          prevEventIndex >= 0;
          prevEventIndex--
        ) {
          final previousDate = mergedEvents[prevEventIndex];
          final daysFromPrevious = currentDate.difference(previousDate).inDays;

          if (daysFromPrevious <= _defaultPeriodDaysLength) {
            isNewCycle = false;
            break;
          }

          if (daysFromPrevious > (_defaultCycleDaysLength)) break;
        }

        if (isNewCycle) periodStartDates.add(currentDate);
      }
    }

    return periodStartDates;
  }

  List<DateTime> _adjustPredictedStarts(
    DateTime selectedDate,
    DateTime lastActualPeriod,
    List<DateTime> predictedCycleStarts,
  ) {
    if (!selectedDate.isAfterToday) return predictedCycleStarts;

    final firstMissedPrediction =
        predictedCycleStarts.where((date) => date.isBefore(date)).lastOrNull;

    if (firstMissedPrediction == null ||
        !firstMissedPrediction.isAfter(lastActualPeriod)) {
      return predictedCycleStarts;
    }

    // If we have a missed prediction, shift all future predictions
    final daysToShift = selectedDate.difference(firstMissedPrediction).inDays;
    return predictedCycleStarts
        .map(
          (date) =>
              date.isAfter(lastActualPeriod)
                  ? date.add(Duration(days: daysToShift))
                  : date,
        )
        .toList();
  }

  List<CycleEvent> _generateFuturePeriodPredictions(
    DateTime lastActualPeriod,
    List<DateTime> adjustedPredictedStarts,
    DateTime endDate,
    int averagePeriodLength,
  ) {
    final predictions = <CycleEvent>[];

    for (final predictedStart in adjustedPredictedStarts) {
      if (predictedStart.isAfter(lastActualPeriod) &&
          predictedStart.isBefore(endDate)) {
        final previousPredictedStart =
            adjustedPredictedStarts
                .where((date) => date.isBefore(predictedStart))
                .lastOrNull;

        predictions.addAll(
          _generatePeriodEvents(
            predictedStart,
            averagePeriodLength,
            previousPredictedStart,
          ),
        );
      }
    }

    return predictions;
  }

  List<CycleEvent> _generatePeriodEvents(
    DateTime predictedStart,
    int averagePeriodLength,
    DateTime? previousPredictedStart,
  ) {
    final periodEvents = <CycleEvent>[];

    for (var i = 0; i < averagePeriodLength; i++) {
      final periodDate = predictedStart.add(Duration(days: i));
      periodEvents.add(
        CycleEvent(
          date: periodDate,
          type: CycleEventType.period,
          isPrediction: true,
          createdBy: _env.systemId,
        ),
      );
    }

    return periodEvents;
  }

  List<CycleEvent> _mergePredictionsWithActualEvents(
    List<CycleEvent> actualEvents,
    List<CycleEvent> predictions,
  ) {
    final mergedEvents = [...actualEvents];

    for (final prediction in predictions) {
      if (!mergedEvents.any(
        (e) =>
            e.date == prediction.date &&
            e.type == prediction.type &&
            e.isPrediction == prediction.isPrediction,
      )) {
        mergedEvents.add(prediction);
      }
    }

    return mergedEvents..sort((a, b) => a.date.compareTo(b.date));
  }

  MenstruationPhase _determineMenstruationPhase(
    int dayOfCycle,
    int daysUntilNextPeriod,
    bool isCurrentlyInPeriod,
    bool isFertile,
  ) {
    if (isCurrentlyInPeriod) return MenstruationPhase.menstruation;
    if (isFertile) return MenstruationPhase.ovulation;

    if (daysUntilNextPeriod >= 0 && daysUntilNextPeriod <= 2) {
      return MenstruationPhase.luteal;
    }

    final percentageUntilNextPeriod = (daysUntilNextPeriod / dayOfCycle) * 100;
    if (percentageUntilNextPeriod >= 75) return MenstruationPhase.follicular;
    if (percentageUntilNextPeriod >= 50) return MenstruationPhase.ovulation;

    return MenstruationPhase.luteal;
  }
}
