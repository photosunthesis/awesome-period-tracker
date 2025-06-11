import 'dart:convert';

import 'package:awesome_period_tracker/config/clients/gemini_client.dart';
import 'package:awesome_period_tracker/domain/models/api_prediction.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event.dart';
import 'package:awesome_period_tracker/domain/models/cycle_event_type.dart';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class CyclePredictionRepository {
  const CyclePredictionRepository(this._localStorage, this._geminiClient);

  final SharedPreferencesAsync _localStorage;
  final GeminiClient _geminiClient;

  // Cache keys generated here: http://bit.ly/random-strings-generator
  static const _eventsStorageKey = 'ai9fK2mL8nXp';
  static const _apiPredictionStorageKey = 'vB7sE4wQ1rTy';

  Future<ApiPrediction> fetchPrediction(List<CycleEvent> events) async {
    final periodEvents = events
        .where((e) => e.type == CycleEventType.period)
        .sortedBy((e) => e.date);

    final cachedData = await _getFromCache(periodEvents);
    if (cachedData != null) return cachedData;

    final pastCycleData = _getPastCycleDataFromEvents(periodEvents);
    final currentDate = DateTime.now().toIso8601String().split('T')[0];
    final prompt = _buildPrompt(currentDate, pastCycleData);
    final response = await _geminiClient.generateContentFromText(
      prompt: prompt,
      useFastModel: true,
    );

    final apiPrediction = _parseGeminiResponse(response);
    await _saveToCache(periodEvents, apiPrediction);

    return apiPrediction;
  }

  ApiPrediction _parseGeminiResponse(String response) {
    try {
      final jsonMatch = RegExp(r'\{[^}]*\}').firstMatch(response);
      if (jsonMatch == null) throw const FormatException('No JSON found');

      final data = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

      return ApiPrediction(
        predictedCycleStarts:
            (data['predicted_cycle_starts'] as List)
                .map((e) => DateTime.parse(e as String))
                .toList(),
        averageCycleLength: data['average_cycle_length'] as int,
        averagePeriodLength: data['average_period_length'] as int,
      );
    } catch (e) {
      return ApiPrediction(
        predictedCycleStarts: _generateDefaultPredictions(),
        averageCycleLength: 28,
        averagePeriodLength: 5,
      );
    }
  }

  List<DateTime> _generateDefaultPredictions() {
    final now = DateTime.now();
    return [
      now.add(const Duration(days: 28)),
      now.add(const Duration(days: 56)),
      now.add(const Duration(days: 84)),
    ];
  }

  List<Map<String, dynamic>> _getPastCycleDataFromEvents(
    List<CycleEvent> events,
  ) {
    if (events.length < 2) return [];

    final cycles = <Map<String, dynamic>>[];

    for (int i = 0; i < events.length - 1; i++) {
      final cycleLength = events[i + 1].date.difference(events[i].date).inDays;
      if (cycleLength > 15 && cycleLength < 60) {
        // Valid cycle range
        cycles.add({
          'cycle_start_date': events[i].date.toIso8601String().split('T')[0],
          'cycle_length': cycleLength,
          'period_length': 5, // Default period length
        });
      }
    }

    return cycles;
  }

  Future<void> _saveToCache(
    List<CycleEvent> events,
    ApiPrediction apiPrediction,
  ) async {
    final eventsHash =
        events.map((e) => '${e.date.millisecondsSinceEpoch}').join();

    await Future.wait([
      _localStorage.setString(_eventsStorageKey, eventsHash),
      _localStorage.setString(_apiPredictionStorageKey, apiPrediction.toJson()),
    ]);
  }

  Future<ApiPrediction?> _getFromCache(List<CycleEvent> currentEvents) async {
    final cachedHash = await _localStorage.getString(_eventsStorageKey);
    final cachedPrediction = await _localStorage.getString(
      _apiPredictionStorageKey,
    );

    if (cachedHash == null || cachedPrediction == null) return null;

    final currentHash =
        currentEvents.map((e) => '${e.date.millisecondsSinceEpoch}').join();
    if (currentHash != cachedHash) return null;

    try {
      return ApiPredictionMapper.fromJson(cachedPrediction);
    } catch (e) {
      return null;
    }
  }

  String _buildPrompt(String currentDate, List<Map> pastCycleData) {
    final cycleDataJson = jsonEncode(pastCycleData);

    return '''
You are a menstrual cycle prediction AI. Based on the historical cycle data provided, predict future cycle information.

Current Date: $currentDate
Historical Cycle Data: $cycleDataJson

Please analyze the historical data and return predictions in this exact JSON format:
{
  "predicted_cycle_starts": ["2025-07-15", "2025-08-12", "2025-09-09"],
  "average_cycle_length": 28,
  "average_period_length": 5
}

Requirements:
- predicted_cycle_starts: Array of 3 future cycle start dates in YYYY-MM-DD format
- average_cycle_length: Integer representing average days between cycle starts
- average_period_length: Integer representing average period duration in days
- Base predictions on the patterns in the historical data
- If insufficient data, use typical values (28 day cycle, 5 day period)
- Only return the JSON object, no additional text
''';
  }
}
