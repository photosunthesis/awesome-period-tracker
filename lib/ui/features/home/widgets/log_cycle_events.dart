import 'package:awesome_period_tracker/domain/models/cycle_event_type.dart';
import 'package:awesome_period_tracker/utils/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';

class LogCycleEventTypes extends StatelessWidget {
  const LogCycleEventTypes({super.key});

  static const _types = [
    CycleEventType.period,
    CycleEventType.intimacy,
    CycleEventType.fertile,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final type in _types) ...[_buildButton(context, type)],
      ],
    );
  }

  Widget _buildButton(BuildContext context, CycleEventType type) {
    return IntrinsicWidth(
      child: Row(
        children: [
          type.icon,
          const SizedBox(width: 4),
          // Add extra space between the icon and the label if the type is a period
          if (type == CycleEventType.period) const SizedBox(width: 3),
          Text(
            type.label,
            style: context.primaryTextTheme.bodySmall?.copyWith(
              color: context.colorScheme.shadow.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }
}
