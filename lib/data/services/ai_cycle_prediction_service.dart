import 'dart:convert';

import 'package:awesome_period_tracker/config/clients/gemini_client.dart';
import 'package:awesome_period_tracker/domain/models/api_prediction.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event_type.dart';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class AiCyclePredictionService {
  const AiCyclePredictionService(this._localStorage, this._geminiClient);

  final SharedPreferencesAsync _localStorage;
  final GeminiClient _geminiClient;

  // Cache keys generated here: http://bit.ly/random-strings-generator
  static const _eventsStorageKey = 'Q8aMaXIYXr7l';
  static const _apiPredictionStorageKey = 'yZ3fchYTsAjA';
  static const _predictionsToCreate = 6;

  Future<ApiPrediction> fetchPrediction(List<CycleEvent> events) async {
    final periodEvents = events
        .where((e) => e.type == CycleEventType.period)
        .sortedBy((e) => e.date);

    final cachedData = await _getFromCache(periodEvents);
    if (cachedData != null) return cachedData;

    final pastData =
        periodEvents
            .map(
              (e) => {
                'cycle_start_date': e.date.toIso8601String().split('T')[0],
              },
            )
            .toList();

    final response = await _geminiClient.generateContentFromText(
      prompt: _generatePrompt(pastData),
    );

    try {
      final cleanResponse = response
          .trim()
          .replaceAll(
            RegExp(r'[\u0000-\u001F\u007F-\u009F]'),
            '',
          ) // Remove control characters
          .replaceAll(RegExp(r'^[^{]*|[^}]*$'), ''); // Remove non-JSON text

      final data = jsonDecode(cleanResponse) as Map<String, dynamic>;
      final apiPrediction = ApiPrediction(
        predictedCycleStarts:
            (data['predicted_cycle_starts'] as List)
                .map((e) => DateTime.parse(e as String))
                .toList(),
        averageCycleLength: (data['average_cycle_length'] as num).round(),
        averagePeriodLength: (data['average_period_length'] as num).round(),
      );

      await _saveToCache(periodEvents, apiPrediction);
      return apiPrediction;
    } catch (e) {
      // Return default values if parsing fails
      return ApiPrediction(
        predictedCycleStarts: [DateTime.now().add(const Duration(days: 28))],
        averageCycleLength: 28,
        averagePeriodLength: 5,
      );
    }
  }

  Future<void> _saveToCache(
    List<CycleEvent> events,
    ApiPrediction apiPrediction,
  ) async {
    final eventsJson = jsonEncode(events.map((e) => e.toJson()).toList());

    await Future.wait([
      _localStorage.setString(_eventsStorageKey, eventsJson),
      _localStorage.setString(_apiPredictionStorageKey, apiPrediction.toJson()),
    ]);
  }

  Future<ApiPrediction?> _getFromCache(List<CycleEvent> currentEvents) async {
    final cachedEventsJson = await _localStorage.getString(_eventsStorageKey);
    final cachedApiResponseJson = await _localStorage.getString(
      _apiPredictionStorageKey,
    );

    if (cachedEventsJson == null || cachedApiResponseJson == null) return null;

    try {
      final currentEventsJson = jsonEncode(
        currentEvents.map((e) => e.toJson()).toList(),
      );

      if (currentEventsJson != cachedEventsJson) return null;

      return ApiPredictionMapper.fromJson(cachedApiResponseJson);
    } catch (e) {
      return null;
    }
  }

  String _generatePrompt(List<Map<String, dynamic>> pastData) {
    return '''
You are a medical expert specializing in menstrual cycle prediction.

Task: Analyze the provided menstrual cycle history and generate predictions in JSON format.

Past cycle data:
${jsonEncode(pastData)}

Requirements:
- Generate predictions for the next $_predictionsToCreate menstrual cycle start dates
- Determine the mean cycle duration between periods
- Calculate the typical length of menstrual flow
- Analyze cycle patterns to identify and factor in any irregularities or variations when making predictions - do not rely solely on average cycle length
- Format response using this specific JSON structure:
{
  "predicted_cycle_starts": ["YYYY-MM-DD", ...],
  "average_cycle_length": number,
  "average_period_length": number
}

Notes:
- Use scientific understanding of menstrual cycles
- Consider cycle patterns, variations, and irregularities
- Provide accurate predictions based on the provided data
- Use the provided cycle start dates as the basis for predictions
- Ensure dates are in ISO 8601 format (YYYY-MM-DD)
- Return ONLY the JSON object, no other text
''';
  }
}
