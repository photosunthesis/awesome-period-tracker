import 'package:awesome_period_tracker/app/theme/app_colors.dart';
import 'package:awesome_period_tracker/utils/extensions/string_extensions.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

part 'cycle_event_type.mapper.dart';

@MappableEnum()
enum CycleEventType {
  period,
  symptoms,
  intimacy,
  fertile;

  String get label => name.capitalize();

  Color get color {
    return switch (this) {
      CycleEventType.period => AppColors.red,
      CycleEventType.intimacy => AppColors.pink,
      CycleEventType.fertile => AppColors.purple,
      CycleEventType.symptoms => AppColors.orange,
    };
  }

  Widget get icon {
    return switch (this) {
      CycleEventType.period => Icon(
        Icons.radio_button_checked,
        color: color,
        size: 24,
      ),
      CycleEventType.intimacy => Icon(Icons.favorite, color: color, size: 24),
      CycleEventType.fertile => Icon(Icons.adjust, color: color, size: 24),
      CycleEventType.symptoms => Icon(
        Icons.emergency_rounded,
        color: color,
        size: 24,
      ),
    };
  }
}
