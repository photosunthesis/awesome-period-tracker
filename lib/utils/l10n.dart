import 'package:awesome_period_tracker/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// A getter that provides access to localized strings through [AppLocalizations].
///
/// Uses the [GoRouter] instance to get the current [BuildContext] and
/// extracts the [AppLocalizations] instance.
final l10n =
    AppLocalizations.of(
      GetIt.I<GoRouter>().routerDelegate.navigatorKey.currentState!.context,
    )!;
