import 'package:awesome_period_tracker/domain/models/cycle_event.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event_type.dart';
import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/utils/extensions/color_extensions.dart';
import 'package:awesome_period_tracker/utils/extensions/date_time_extensions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  const Calendar({
    required this.cycleEvents,
    required this.onDaySelected,
    required this.selectedDate,
    super.key,
  });

  final List<CycleEvent> cycleEvents;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return TableCalendar<CycleEvent>(
      key: ValueKey(cycleEvents),
      firstDay: DateTime(DateTime.now().year - 10),
      lastDay: DateTime(DateTime.now().year + 10),
      focusedDay: selectedDate,
      eventLoader: _getEventsForDay,
      headerStyle: _headerStyle(context),
      onDaySelected: onDaySelected,
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      calendarBuilders: CalendarBuilders(
        markerBuilder: _markerBuilder,
        todayBuilder: _todayBuilder,
        selectedBuilder: _selectedBuilder,
        defaultBuilder: _defaultBuilder,
        outsideBuilder: _defaultBuilder,
      ),
      availableCalendarFormats: const {CalendarFormat.month: ''},
      pageAnimationEnabled: false,
      availableGestures: AvailableGestures.horizontalSwipe,
    );
  }

  HeaderStyle _headerStyle(BuildContext context) {
    return HeaderStyle(
      formatButtonVisible: false,
      titleCentered: true,
      titleTextStyle: context.primaryTextTheme.titleMedium!,
      leftChevronIcon: const Icon(
        Icons.chevron_left_rounded,
        size: 32,
        color: Colors.black54,
      ),
      rightChevronIcon: const Icon(
        Icons.chevron_right_rounded,
        size: 32,
        color: Colors.black54,
      ),
    );
  }

  Widget _markerBuilder(
    BuildContext context,
    DateTime date,
    List<CycleEvent> events,
  ) {
    if (events.any((e) => e.type == CycleEventType.intimacy)) {
      final useLightColor = events.any(
        (e) => e.type == CycleEventType.period && e.date.isSameDay(date),
      );

      return Positioned.fill(
        top: 22,
        child: Icon(
          Icons.favorite,
          color:
              useLightColor
                  ? context.colorScheme.primaryContainer
                  : context.colorScheme.error,
          size: 8,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _todayBuilder(
    BuildContext context,
    DateTime date,
    DateTime focusedDay,
  ) {
    final isTodayFocused = isSameDay(date, focusedDay);
    final events = _getEventsForDay(date).toList();
    final event = events.firstWhereOrNull(
      (event) =>
          event.type == CycleEventType.period ||
          event.type == CycleEventType.fertile,
    );

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:
              isTodayFocused
                  ? event?.type.color.darken(0.1) ??
                      context.colorScheme.shadow.withAlpha(89)
                  : Colors.transparent,
          width: 2.3,
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color:
              event?.type.color.withAlpha((event.isPrediction ? 89 : 255)) ??
              Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          date.day.toString(),
          style: TextStyle(
            color:
                event != null
                    ? event.isPrediction
                        ? event.type.color.darken(0.4)
                        : context.colorScheme.surface
                    : null,
          ),
        ),
      ),
    );
  }

  Widget _selectedBuilder(
    BuildContext context,
    DateTime date,
    DateTime focusedDay,
  ) {
    final events = _getEventsForDay(date).toList();

    // If the selected day is today, return a "today" widget
    if ((isSameDay(selectedDate, focusedDay) && date.isToday) ||
        events.isNotEmpty) {
      return _todayBuilder(context, date, focusedDay);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colorScheme.shadow.withAlpha(89),
          width: 2.3,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(5),
        alignment: Alignment.center,
        child: Text(date.day.toString()),
      ),
    );
  }

  Widget? _defaultBuilder(
    BuildContext context,
    DateTime date,
    DateTime focusedDay,
  ) {
    final events = _getEventsForDay(date).toList();

    if (events.isEmpty) return null;

    final event = events.firstWhereOrNull(
      (event) =>
          event.type == CycleEventType.period ||
          event.type == CycleEventType.fertile,
    );

    if (event == null) return null;

    final isOutsde = !date.isSameMonth(focusedDay);

    return Container(
      margin: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color:
            isOutsde
                ? context.colorScheme.shadow.withAlpha(10)
                : event.type.color.withAlpha(
                  event.isUncertainPrediction
                      ? 30
                      : event.isPrediction
                      ? 90
                      : 255,
                ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        date.day.toString(),
        style: TextStyle(
          color:
              isOutsde
                  ? context.colorScheme.shadow.withAlpha(120)
                  : event.isPrediction
                  ? event.type.color.darken(
                    event.isUncertainPrediction ? 0.5 : 0.4,
                  )
                  : context.colorScheme.surface,
        ),
      ),
    );
  }

  List<CycleEvent> _getEventsForDay(DateTime day) {
    return cycleEvents.where((event) {
      final eventDate = DateTime.utc(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      return eventDate.isAtSameMomentAs(day);
    }).toList();
  }
}
