/// Defines the environment configuration interface for the application.
///
/// This abstract interface class defines the contract for environment configurations.
/// Each environment should implement this interface with its specific values.
///
/// Uses the abbreviated name `Env` instead of `Environment` to avoid naming conflicts
/// with third-party packages.
abstract interface class Env {
  /// Firebase authentication email address.
  abstract final String loginEmail;

  /// API key for Gemini services.
  abstract final String geminiApiKey;

  /// Unique system identifier.
  abstract final String systemId;

  /// API key for Womens Health services.
  ///
  /// More info: https://rapidapi.com/datafenix-datafenix-default/api/womens-health-menstrual-cycle-phase-predictions-insights
  abstract final String cyclePhaseApiKey;

  /// API URL for Womens Health services.
  ///
  /// More info: https://rapidapi.com/datafenix-datafenix-default/api/womens-health-menstrual-cycle-phase-predictions-insights
  abstract final String cyclePhaseApiUrl;
}
