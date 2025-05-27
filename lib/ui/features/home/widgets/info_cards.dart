import 'package:awesome_period_tracker/domain/models/cycle_event_type.dart';
import 'package:awesome_period_tracker/domain/models/log_event_step.dart';
import 'package:awesome_period_tracker/domain/models/menstruation_phase.dart';
import 'package:awesome_period_tracker/ui/common_widgets/app_loader/app_shimmer.dart';
import 'package:awesome_period_tracker/ui/common_widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/ui/features/home/home_cubit.dart';
import 'package:awesome_period_tracker/ui/features/log_cycle_event/log_cycle_event_bottom_sheet.dart';
import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/utils/extensions/color_extensions.dart';
import 'package:awesome_period_tracker/utils/extensions/exception_extensions.dart';
import 'package:awesome_period_tracker/utils/extensions/string_extensions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

class InfoCards extends StatelessWidget {
  const InfoCards({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final forecast = state.forecast;

        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    context.l10n.cycleMetrics,
                    style: context.primaryTextTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildCard(
                      context,
                      isLoading: state.isLoading,
                      backgroundColor: context.colorScheme.secondaryFixed
                          .lighten(0.26),
                      iconText: context.l10n.cycleDay,
                      title:
                          forecast != null
                              ? context.l10n.dayN(forecast.dayOfCycle)
                              : context.l10n.veryShortGenericError,
                      subtitle:
                          forecast != null
                              ? context.l10n.currentlyInThePhasePhase(
                                forecast.phase.name,
                              )
                              : context.l10n.genericError,
                      icon: Icon(
                        Icons.expand_circle_down_outlined,
                        color: context.colorScheme.secondaryFixed,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCard(
                      context,
                      isLoading: state.isLoading,
                      backgroundColor: context.colorScheme.primary.lighten(
                        0.25,
                      ),
                      iconText: context.l10n.period,
                      title:
                          forecast != null
                              ? (forecast.daysUntilNextPeriod == 1
                                  ? context.l10n.inOneDay
                                  : forecast.daysUntilNextPeriod == 0
                                  ? context.l10n.today
                                  : context.l10n.inNDays(
                                    forecast.daysUntilNextPeriod,
                                  ))
                              : context.l10n.veryShortGenericError,
                      subtitle:
                          forecast != null
                              ? (forecast.eventsForDate.any(
                                    (v) => v.type == CycleEventType.period,
                                  )
                                  ? context.l10n.flowLevel(
                                    forecast.eventsForDate
                                            .firstWhere(
                                              (e) =>
                                                  e.type ==
                                                  CycleEventType.period,
                                            )
                                            .additionalData
                                            ?.toTitleCase() ??
                                        context.l10n.notSpecified.toTitleCase(),
                                  )
                                  : context.l10n.noPeriodLoggedForThisDay)
                              : context.l10n.genericError,
                      icon: Icon(
                        Icons.radio_button_checked,
                        color: context.colorScheme.primary,
                        size: 20,
                      ),
                      onTap: () async {
                        final shouldRefreshHome =
                            await LogCycleEventBottomSheet.showCycleEventTypeBottomSheet<
                              bool?
                            >(
                              context,
                              step: LogEventStep.periodFlow,
                              date: state.selectedDate,
                              cycleEventsForDate:
                                  state.forecast?.eventsForDate ?? [],
                            );

                        if (shouldRefreshHome == true) {
                          context.read<HomeCubit>().initialize(
                            date: state.selectedDate,
                          );
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildCard(
                      context,
                      isLoading: state.isLoading,
                      backgroundColor: context.colorScheme.tertiary.lighten(
                        0.28,
                      ),
                      iconText: context.l10n.fertileWindow,
                      title:
                          forecast != null
                              ? (forecast.phase == MenstruationPhase.ovulation
                                  ? context.l10n.today
                                  : context.l10n.inNDays(
                                    forecast.daysUntilNextFertileWindow,
                                  ))
                              : context.l10n.veryShortGenericError,
                      subtitle:
                          forecast != null
                              ? context.l10n.chancesOfGettingPregnant(
                                forecast.eventsForDate.any(
                                      (event) =>
                                          event.type == CycleEventType.fertile,
                                    )
                                    ? context.l10n.high
                                    : context.l10n.low,
                              )
                              : context.l10n.genericError,
                      icon: Icon(
                        Icons.adjust,
                        color: context.colorScheme.tertiary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCard(
                      context,
                      isLoading: state.isLoading,
                      backgroundColor: context.colorScheme.secondary.lighten(
                        0.15,
                      ),
                      iconText: context.l10n.intimacy,
                      title:
                          forecast != null
                              ? forecast.eventsForDate.any(
                                    (v) => v.type == CycleEventType.intimacy,
                                  )
                                  ? context.l10n.gotFreaky
                                  : context.l10n.noFreaky
                              : context.l10n.veryShortGenericError,
                      subtitle:
                          forecast != null
                              ? forecast.eventsForDate
                                      .firstWhereOrNull(
                                        (event) =>
                                            event.type ==
                                            CycleEventType.intimacy,
                                      )
                                      ?.additionalData ??
                                  context
                                      .l10n
                                      .noIntimateActivitiesLoggedForToday
                              : context.l10n.genericError,
                      icon: Icon(
                        Icons.favorite,
                        color: context.colorScheme.secondary,
                        size: 20,
                      ),
                      onTap: () async {
                        final shouldRefreshHome =
                            await LogCycleEventBottomSheet.showCycleEventTypeBottomSheet<
                              bool?
                            >(
                              context,
                              step: LogEventStep.intimacy,
                              date: state.selectedDate,
                              cycleEventsForDate: forecast?.eventsForDate ?? [],
                            );

                        if (shouldRefreshHome == true) {
                          context.read<HomeCubit>().initialize(
                            date: state.selectedDate,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            _buildErrorWidget(context, state),
          ],
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    bool isLoading = false,
    required String iconText,
    required String title,
    required String subtitle,
    required Widget icon,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    return Flexible(
      child: InkWell(
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          height: 140,
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            backgroundColor: backgroundColor,
            child: AppShimmer(
              isLoading: isLoading,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton.keep(
                      child: Row(
                        children: [
                          icon,
                          const SizedBox(width: 6),
                          Text(
                            iconText,
                            style: context.primaryTextTheme.titleMedium,
                          ),
                          const Spacer(),
                          if (onTap != null)
                            const Icon(
                              Icons.add_rounded,
                              size: 20,
                              color: Colors.black26,
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(title, style: context.primaryTextTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(subtitle, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, HomeState state) {
    if (state.error == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        color: context.colorScheme.surfaceContainer.withAlpha(190),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              state.error!.errorMessage,
              style: context.primaryTextTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onErrorContainer,
                shadows: [
                  Shadow(
                    color: context.colorScheme.surfaceContainer,
                    offset: const Offset(0, -4),
                    blurRadius: 12,
                  ),
                  Shadow(
                    color: context.colorScheme.surfaceContainer,
                    offset: const Offset(0, 0),
                    blurRadius: 12,
                  ),
                  Shadow(
                    color: context.colorScheme.surfaceContainer,
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
