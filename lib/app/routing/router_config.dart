import 'package:awesome_period_tracker/app/routing/routes.dart';
import 'package:awesome_period_tracker/data/repositories/auth_repository.dart';
import 'package:awesome_period_tracker/ui/features/home/home_cubit.dart';
import 'package:awesome_period_tracker/ui/features/home/home_screen.dart';
import 'package:awesome_period_tracker/ui/features/pin_login/pin_login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RouterConfig {
  @singleton
  GoRouter get instance {
    return GoRouter(
      observers: [
        // TODO Add observers
      ],
      redirect: (context, state) {
        final isLoggedIn = GetIt.I<AuthRepository>().isLoggedIn();
        final location = state.uri.toString();

        if (location == Routes.root && isLoggedIn ||
            location == Routes.pinLogin && isLoggedIn) {
          return Routes.home;
        }

        if (location == Routes.root && !isLoggedIn ||
            location == Routes.home && !isLoggedIn) {
          return Routes.pinLogin;
        }

        return null;
      },
      routes: [
        GoRoute(path: Routes.root, redirect: (context, state) => Routes.home),
        GoRoute(
          path: Routes.pinLogin,
          builder: (context, state) => const PinLoginScreen(),
        ),
        GoRoute(
          path: Routes.home,
          builder:
              (context, state) => BlocProvider(
                create: (_) => GetIt.I<HomeCubit>(),
                child: const HomeScreen(),
              ),
        ),
      ],
    );
  }
}
