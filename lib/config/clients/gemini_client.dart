import 'package:awesome_period_tracker/config/environment/env.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

@injectable
class GeminiClient {
  GeminiClient(Env env)
    : _defaultModel = GenerativeModel(
        model: _defaultModelIdentifier,
        apiKey: env.geminiApiKey,
        safetySettings: [
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        ],
      ),
      _fastModel = GenerativeModel(
        model: _fastModelIdentifier,
        apiKey: env.geminiApiKey,
        safetySettings: [
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        ],
      );

  final GenerativeModel _defaultModel;
  final GenerativeModel _fastModel;

  static const _defaultModelIdentifier = 'gemini-2.0-flash-lite-preview-02-05';
  static const _fastModelIdentifier = 'gemini-2.0-flash-lite';

  /// Generates AI content from a text prompt.
  ///
  /// Returns the generated text, or an empty string if generation fails.
  /// Safety settings are configured to allow all content types.
  ///
  /// [useFastModel] determines whether to use the fast model (true) or default model (false).
  Future<String> generateContentFromText({
    required String prompt,
    bool useFastModel = false,
  }) async {
    final model = useFastModel ? _fastModel : _defaultModel;
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }
}
