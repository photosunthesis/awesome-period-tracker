import 'package:awesome_period_tracker/config/constants/strings.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event_type.dart';
import 'package:awesome_period_tracker/domain/models/log_event_step.dart';
import 'package:awesome_period_tracker/ui/common_widgets/app_loader/app_shimmer.dart';
import 'package:awesome_period_tracker/ui/common_widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/ui/features/home/home_cubit.dart';
import 'package:awesome_period_tracker/ui/features/log_cycle_event/log_cycle_event_bottom_sheet.dart';
import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/utils/extensions/string_extensions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SymptomsSection extends StatelessWidget {
  const SymptomsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return AppCard(
          isAnimated: true,
          child: InkWell(
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              final shouldRefreshHome =
                  await LogCycleEventBottomSheet.showCycleEventTypeBottomSheet<
                    bool?
                  >(
                    context,
                    step: LogEventStep.symptoms,
                    date: state.selectedDate,
                    cycleEventsForDate: state.forecast?.eventsForDate ?? [],
                  );

              if (shouldRefreshHome == true) {
                context.read<HomeCubit>().initialize(date: state.selectedDate);
              }
            },
            child: AppShimmer(
              isLoading: state.isLoading,
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton.keep(
                        child: Row(
                          children: [
                            Icon(
                              Icons.emergency,
                              size: 20,
                              color: context.colorScheme.shadow.withAlpha(102),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.symptoms,
                              style: context.primaryTextTheme.titleMedium,
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.add_rounded,
                              size: 20,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (state.isLoading)
                        _buildChips(
                          context,
                          const ['one', 'one two', 'three'], // Placeholder list
                        )
                      else if (state.forecast?.eventsForDate.isEmpty ?? false)
                        _buildNoSymptomsPlaceholder(context)
                      else
                        _buildSymptomsList(
                          context,
                          state.forecast?.eventsForDate ?? [],
                          state.symptoms,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSymptomsList(
    BuildContext context,
    List<CycleEvent> events,
    List<String> symptoms,
  ) {
    final symptomsEvent = events.firstWhereOrNull(
      (e) => e.type == CycleEventType.symptoms,
    );

    if (symptomsEvent == null) return _buildNoSymptomsPlaceholder(context);

    // Filter symptoms list to only include valid symptoms from the symptoms parameter
    final validSymptoms =
        symptomsEvent.additionalData!
            .split(Strings.symptomSeparator)
            .map((e) => e.toTitleCase())
            .where((symptom) => symptoms.contains(symptom))
            .toList();

    return _buildChips(context, validSymptoms);
  }

  Widget _buildChips(BuildContext context, List<String> labels) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final label in labels)
            Skeleton.leaf(
              child: Chip(
                label: Text(label),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                side: BorderSide(
                  color: context.colorScheme.onSurface.withAlpha(51),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoSymptomsPlaceholder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Center(
        child: Text(
          context.l10n.noSymptomsLogged,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurface.withAlpha(153),
          ),
        ),
      ),
    );
  }
}
