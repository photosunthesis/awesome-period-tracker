import 'package:awesome_period_tracker/config/clients/gemini_client.dart';
import 'package:awesome_period_tracker/domain/models/forecast.dart';
import 'package:awesome_period_tracker/domain/models/insight.dart';
import 'package:awesome_period_tracker/domain/models/menstruation_phase.dart';
import 'package:awesome_period_tracker/utils/extensions/date_time_extensions.dart';
import 'package:awesome_period_tracker/utils/extensions/string_extensions.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

@injectable
class AiInsightsService {
  const AiInsightsService(this._localStorage, this._geminiClient);

  final SharedPreferencesAsync _localStorage;
  final GeminiClient _geminiClient;

  // Cache keys generated here: http://bit.ly/random-strings-generator
  static const _insightStorageKeyPrefix = 'd6flbx32awBNM_';

  Future<Insight> getInsightForForecast(
    Forecast forecast, {
    bool useCache = true,
    bool isPast = false,
  }) async {
    final prefsKey = '$_insightStorageKeyPrefix${forecast.date.toYmdString()}';

    try {
      if (await _localStorage.containsKey(prefsKey) && useCache) {
        final cachedInsight = InsightMapper.fromJson(
          (await _localStorage.getString(prefsKey))!,
        );

        final isCacheValid = isSameDay(
          cachedInsight.date,
          forecast.date.toUtc(),
        );

        if (isCacheValid) return cachedInsight;
      }
    } catch (_) {
      // On exceptions, do nothing and generate new insight.
      // This is to prevent app crashes due to corrupted cache data.
    }

    final geminiInsight = await _generateInsights(
      forecast.dayOfCycle,
      forecast.averageCycleLength,
      forecast.phase,
      isPast,
    );

    final insight = Insight(
      insights: geminiInsight.removeEmojis().removeDoubleSpaces(),
      date: forecast.date.toUtc(),
      isPast: isPast,
    );

    await _localStorage.setString(prefsKey, insight.toJson());

    return insight;
  }

  Future<String> _generateInsights(
    int dayOfCycle,
    int averageCycleLength,
    MenstruationPhase phase,
    bool isPast,
  ) async {
    try {
      return await _geminiClient.generateContentFromText(
        prompt: _geminiPrompt(dayOfCycle, averageCycleLength, phase, isPast),
      );
    } catch (e) {
      return 'An error occurred while generating insights. :-(';
    }
  }

  String _geminiPrompt(
    int dayOfCycle,
    int averageCycleLength,
    MenstruationPhase phase,
    bool isPast,
  ) {
    String phaseInfo;
    String additionalInfo;

    switch (phase) {
      case MenstruationPhase.follicular:
        phaseInfo = 'follicular phase';
        additionalInfo =
            isPast
                ? 'Mention energy levels and mood changes experienced. Add an encouraging note about the body\'s natural renewal.'
                : 'Share tips for harnessing increased energy. Add a light-hearted comment about feeling refreshed.';
        break;
      case MenstruationPhase.ovulation:
        phaseInfo = 'ovulation phase';
        additionalInfo =
            isPast
                ? 'Discuss peak fertility signs experienced. Include a playful note about heightened confidence or charm.'
                : 'Highlight fertility window and energy peaks. Add a fun comment about feeling extra magnetic/freaky today.';
        break;
      case MenstruationPhase.luteal:
        phaseInfo = 'luteal phase';
        if (dayOfCycle > averageCycleLength) {
          additionalInfo =
              isPast
                  ? 'Describe late period symptoms experienced. Add a gentle reminder about cycle variations being normal.'
                  : 'Address common late period concerns. Include a light joke about being fashionably late.';
        } else {
          additionalInfo =
              isPast
                  ? 'Reflect on premenstrual changes experienced. Share a relatable observation about this phase.'
                  : 'Prepare for upcoming premenstrual changes. Add a gentle reminder about self-care with a touch of humor.';
        }
        break;
      case MenstruationPhase.menstruation:
        phaseInfo = 'menstruation phase';
        additionalInfo =
            isPast
                ? 'Acknowledge period experiences. Share a supportive note with a touch of period humor.'
                : 'Suggest comfort measures and self-care tips. Add an empathetic joke about period challenges.';
        break;
    }

    final timeContext = isPast ? 'past' : 'upcoming';
    final summaryOrAdvice =
        isPast
            ? 'Share insights about what likely happened'
            : 'Provide friendly advice and useful tips';

    return '''
You are a compassionate medical expert providing personalized menstrual cycle insights.

Task: Provide exactly 2-3 bullet points in markdown format about the menstrual cycle phase. Each point must be direct, concise, and include a subtle touch of humor. Your response will be shown directly to users without any modification, so include only the markdown bullet points - no other text, headers, or formatting.

Requirements:
- Keep response under 50 words
- Use 2-3 bullet points in markdown format
- Maintain professional yet warm and humorous tone
- No emojis or informal text markers
- Focus on evidence-based insights

Format each point as:
1. Current phase overview and validation
2. Actionable recommendation
3. (Optional) Encouraging perspective

Context: $timeContext menstrual cycle, day $dayOfCycle of $averageCycleLength-day cycle, $phaseInfo.
Additional context: $summaryOrAdvice, $additionalInfo.

Remember: Be factual, supportive, and gently encouraging while maintaining medical accuracy.
''';
  }
}
