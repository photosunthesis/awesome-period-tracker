import 'package:awesome_period_tracker/app/theme/app_assets.dart';
import 'package:awesome_period_tracker/app/theme/theme_mode_manager.dart';
import 'package:awesome_period_tracker/config/constants/ui_constants.dart';
import 'package:awesome_period_tracker/ui/common_widgets/cards/app_card.dart';
import 'package:awesome_period_tracker/ui/features/home/home_cubit.dart';
import 'package:awesome_period_tracker/ui/features/home/widgets/calendar.dart';
import 'package:awesome_period_tracker/ui/features/home/widgets/cycle_insights.dart';
import 'package:awesome_period_tracker/ui/features/home/widgets/info_cards.dart';
import 'package:awesome_period_tracker/ui/features/home/widgets/symptoms_section.dart';
import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:awesome_period_tracker/utils/extensions/date_time_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final _cubit = context.read<HomeCubit>();

  /// Set to `true` to show theme switcher in app bar.
  final _showThemeSwitcher = false;

  @override
  void initState() {
    super.initState();
    _cubit.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _cubit.initialize,
        child: CustomScrollView(
          slivers: [
            if (kIsWeb) const SliverToBoxAdapter(child: SizedBox(height: 10)),
            _buildAppBar(),
            _buildCalendarSection(),
            _buildCardsSection(),
            _buildSymptoms(),
            _buildCycleInsightsSection(),
            const SliverToBoxAdapter(
              child: SafeArea(
                child: kIsWeb ? SizedBox(height: 32) : SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: false,
      toolbarHeight: 40,
      automaticallyImplyLeading: false,
      flexibleSpace: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: AppBar(
            automaticallyImplyLeading: false,
            actions: _showThemeSwitcher ? [_buildThemeModeSwitcher()] : null,
            leading: _buildBackToTodayButton(),
            leadingWidth: 70,
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SvgPicture.asset(AppAssets.mainIconLong, height: 28),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackToTodayButton() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder:
          (context, state) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child:
                state.selectedDate.isToday
                    ? const SizedBox.shrink()
                    : TextButton(
                      onPressed: _cubit.initialize,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(top: 12),
                      ),
                      child: Text(
                        context.l10n.today,
                        style: context.primaryTextTheme.titleSmall?.copyWith(
                          color: context.colorScheme.onSurface.withAlpha(170),
                        ),
                      ),
                    ),
          ),
    );
  }

  Widget _buildThemeModeSwitcher() {
    return BlocBuilder<ThemeModeCubit, ThemeMode>(
      builder:
          (context, state) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: IconButton(
                icon: Icon(
                  state == ThemeMode.dark
                      ? Icons.brightness_7_rounded
                      : Icons.brightness_4_rounded,
                  color: context.colorScheme.onSurface.withAlpha(153),
                ),
                onPressed: GetIt.I<ThemeModeCubit>().toggleTheme,
              ),
            ),
          ),
    );
  }

  Widget _buildCalendarSection() {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: UiConstants.mobileWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
            child: AppCard(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder:
                    (context, state) => Calendar(
                      onDaySelected: (date, _) => _cubit.initialize(date: date),
                      selectedDate: state.selectedDate,
                      cycleEvents: state.forecast?.events ?? [],
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardsSection() {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: UiConstants.mobileWidth),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
            child: InfoCards(),
          ),
        ),
      ),
    );
  }

  Widget _buildSymptoms() {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: UiConstants.mobileWidth),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(8, 14, 8, 0),
            child: SymptomsSection(),
          ),
        ),
      ),
    );
  }

  Widget _buildCycleInsightsSection() {
    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: UiConstants.mobileWidth),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(8, 18, 8, 0),
            child: CycleInsights(),
          ),
        ),
      ),
    );
  }
}
