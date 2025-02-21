import 'package:awesome_period_tracker/data/repositories/cycle_events_repository.dart';
import 'package:awesome_period_tracker/data/services/ai_insights_service.dart';
import 'package:awesome_period_tracker/data/services/forecast_service.dart';
import 'package:awesome_period_tracker/domain/models/forecast.dart';
import 'package:awesome_period_tracker/domain/models/insight.dart';
import 'package:awesome_period_tracker/utils/extensions/date_time_extensions.dart';
import 'package:dart_mappable/dart_mappable.dart';
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
  ) : super(HomeState.initial());

  final CycleEventsRepository _cycleEventsRepository;
  final ForecastService _forecastService;
  final AiInsightsService _insightsService;

  Future<void> initialize({
    DateTime? date,
    bool useCache = true,
  }) async {
    try {
      date ??= DateTime.now().withoutTime();

      emit(state.copyWith(isLoading: true, selectedDate: date));

      final events = await _cycleEventsRepository.get();

      final forecast =
          await _forecastService.createForecastForDateFromEvents(date, events);

      final insight = await _insightsService.getInsightForForecast(
        forecast,
        useCache: useCache,
        isPast: date.isBefore(DateTime.now()),
      );

      emit(state.copyWith(forecast: forecast, insight: insight));
    } on Exception catch (error) {
      emit(state.copyWith(error: error));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
