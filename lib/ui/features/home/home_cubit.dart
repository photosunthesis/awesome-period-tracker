import 'package:awesome_period_tracker/data/repositories/cycle_events_repository.dart';
import 'package:awesome_period_tracker/data/repositories/symptoms_repository.dart';
import 'package:awesome_period_tracker/data/services/ai_insights_service.dart';
import 'package:awesome_period_tracker/data/services/forecast_service.dart';
import 'package:awesome_period_tracker/domain/models/forecast.dart';
import 'package:awesome_period_tracker/domain/models/insight.dart';
import 'package:awesome_period_tracker/utils/extensions/date_time_extensions.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'home_state.dart';
part 'home_cubit.mapper.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(
    this._cycleEventsRepository,
    this._forecastService,
    this._insightsService,
    this._symptomsRepository,
    this._crashlytics,
  ) : super(HomeState.initial());

  final CycleEventsRepository _cycleEventsRepository;
  final ForecastService _forecastService;
  final AiInsightsService _insightsService;
  final SymptomsRepository _symptomsRepository;
  final FirebaseCrashlytics _crashlytics;

  Future<void> initialize({DateTime? date, bool useCache = true}) async {
    try {
      date ??= DateTime.now().withoutTime();

      emit(state.copyWith(isLoading: true, selectedDate: date));

      final events = await _cycleEventsRepository.get();

      final symptoms = await _symptomsRepository.get();

      final forecast = await _forecastService.createForecastForDateFromEvents(
        date,
        events,
      );

      final insight = await _insightsService.getInsightForForecast(
        forecast,
        useCache: useCache,
        isPast: date.isBefore(DateTime.now()),
      );

      emit(
        state.copyWith(
          forecast: forecast,
          insight: insight,
          symptoms: symptoms,
        ),
      );
    } on Exception catch (error, stackTrace) {
      _crashlytics.recordError(error, stackTrace);
      emit(state.copyWith(error: error));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
