import 'package:awesome_period_tracker/app/theme/app_themes.dart';
import 'package:awesome_period_tracker/app/theme/theme_mode_manager.dart';
import 'package:awesome_period_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility_temp_fork/flutter_keyboard_visibility_temp_fork.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<ThemeModeCubit>()..initialize(),
      child: BlocBuilder<ThemeModeCubit, ThemeMode>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Awesome Period Tracker',
            debugShowCheckedModeBanner: false,
            routerConfig: GetIt.I<GoRouter>(),
            theme: AppThemes.light,
            darkTheme: AppThemes.dark,
            themeMode: state,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder:
                (context, child) => KeyboardDismissOnTap(
                  dismissOnCapturedTaps: true,
                  child: child!,
                ),
          );
        },
      ),
    );
  }
}
