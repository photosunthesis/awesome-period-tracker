import 'package:awesome_period_tracker/config/environment/env.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

@injectable
class GeminiClient {
  GeminiClient(Env env)
      : _model =
            GenerativeModel(model: _modelIdentifier, apiKey: env.geminiApiKey);

  final GenerativeModel _model;

  static const _modelIdentifier = 'gemini-2.0-flash-thinking-exp-01-21';

  /// Generates AI content from a text prompt.
  ///
  /// Returns the generated text, or an empty string if generation fails.
  /// Safety settings are configured to allow all content types.
  Future<String> generateContentFromText({
    required String prompt,
  }) async {
    final response = await _model.generateContent(
      [Content.text(prompt)],
      safetySettings: [
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      ],
    );

    return response.text ?? '';
  }
}
