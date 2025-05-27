enum LogEventStep {
  periodFlow,
  intimacy,
  symptoms,
  addNewSymptom;

  double get heightFactor => switch (this) {
    LogEventStep.periodFlow => 0.55,
    LogEventStep.symptoms => 0.8,
    LogEventStep.addNewSymptom => 0.4,
    _ => 0.47,
  };
}
