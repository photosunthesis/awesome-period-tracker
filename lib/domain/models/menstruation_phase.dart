import 'dart:math';

import 'package:awesome_period_tracker/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum MenstruationPhase {
  menstruation,
  follicular,
  ovulation,
  luteal;

  String get title => switch (this) {
    MenstruationPhase.menstruation => 'On Period',
    MenstruationPhase.follicular => 'Follicular',
    MenstruationPhase.ovulation => 'Fertile',
    MenstruationPhase.luteal => 'Luteal',
  };

  Color get color => switch (this) {
    MenstruationPhase.menstruation => AppColors.red,
    MenstruationPhase.follicular => AppColors.pink,
    MenstruationPhase.ovulation => AppColors.purple,
    MenstruationPhase.luteal => AppColors.orange,
  };

  Widget get icon => switch (this) {
    MenstruationPhase.menstruation => Icon(
      Icons.radio_button_checked,
      color: color,
      size: 22,
    ),
    MenstruationPhase.follicular => Transform.rotate(
      angle: pi,
      child: Icon(Icons.expand_circle_down_outlined, color: color, size: 22),
    ),
    MenstruationPhase.ovulation => Icon(Icons.adjust, color: color, size: 22),
    MenstruationPhase.luteal => Icon(
      Icons.expand_circle_down_outlined,
      color: color,
      size: 22,
    ),
  };

  MenstruationPhase get nextPhase => switch (this) {
    MenstruationPhase.menstruation => MenstruationPhase.follicular,
    MenstruationPhase.follicular => MenstruationPhase.ovulation,
    MenstruationPhase.ovulation => MenstruationPhase.luteal,
    MenstruationPhase.luteal => MenstruationPhase.menstruation,
  };
}
