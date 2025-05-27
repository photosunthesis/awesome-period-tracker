import 'package:flutter_emoji/flutter_emoji.dart';

extension StringExtensions on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String camelToTitle() {
    if (isEmpty) return this;

    final result = replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
      (Match match) => ' ${match.group(0)}',
    );

    return result[0].toUpperCase() + result.substring(1);
  }

  String snakeToCamel() {
    return split('_').map((e) => e.capitalize()).join();
  }

  String camelToSnake() {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (Match match) => '_${match.group(0)?.toLowerCase()}',
    );
  }

  String removeEmojis() =>
      EmojiParser().unemojify(this).replaceAll(RegExp(r':\w+:'), '');

  String toTitleCase() {
    return split(' ')
        .map((word) => word.capitalize())
        .join(' ')
        .splitMapJoin(' i ', onMatch: (m) => ' I ', onNonMatch: (m) => m);
  }

  String removeDoubleSpaces() => replaceAll(RegExp(r'\s{2,}'), ' ');
}
