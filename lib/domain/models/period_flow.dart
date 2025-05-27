import 'package:awesome_period_tracker/utils/extensions/string_extensions.dart';

enum PeriodFlow {
  noFlow,
  light,
  medium,
  heavy;

  String get title => name.camelToTitle();

  factory PeriodFlow.fromString(String string) => PeriodFlow.values.firstWhere(
    (flow) => flow.title == string.toLowerCase(),
  );
}
