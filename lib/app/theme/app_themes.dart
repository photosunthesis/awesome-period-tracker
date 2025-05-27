import 'package:awesome_period_tracker/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppThemes {
  static ThemeData get light => _lightTheme;
  static ThemeData get dark => _darkTheme;
}

const _lightColorScheme = ColorScheme.light(
  primary: AppColors.red,
  primaryContainer: AppColors.bgPalePink,
  secondary: AppColors.pink,
  secondaryContainer: AppColors.bgPaleBlue,
  secondaryFixed: AppColors.orange,
  tertiary: AppColors.purple,
  tertiaryContainer: AppColors.bgLightGray,
  surface: AppColors.bgWhite,
  surfaceContainer: AppColors.bgPalePink,
  error: Color(0xFFF66279),
  onPrimary: AppColors.bgWhite,
  onSecondary: AppColors.black,
  onTertiary: AppColors.bgWhite,
  onSurface: AppColors.black,
  onError: Color.fromARGB(255, 43, 23, 23),
  shadow: AppColors.shadow,
);

final _darkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: AppColors.red,
  // TODO: Set dark theme
);

final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _darkColorScheme.surfaceContainer,
  colorScheme: _darkColorScheme,
  textTheme: _textTheme(_darkColorScheme),
  primaryTextTheme: _primaryTextTheme(_textTheme(_darkColorScheme)),
  appBarTheme: _appBarTheme(
    _darkColorScheme,
    _primaryTextTheme(_textTheme(_darkColorScheme)),
  ),
  elevatedButtonTheme: _elevatedButtonTheme(
    _darkColorScheme,
    _primaryTextTheme(_textTheme(_darkColorScheme)),
  ),
  iconButtonTheme: _iconButtonTheme(_darkColorScheme),
  textButtonTheme: _textButtonTheme(_darkColorScheme),
  inputDecorationTheme: _inputDecorationTheme(
    _darkColorScheme,
    _textTheme(_darkColorScheme),
  ),
);

final _lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: _lightColorScheme.surfaceContainer,
  colorScheme: _lightColorScheme,
  textTheme: _textTheme(_lightColorScheme),
  primaryTextTheme: _primaryTextTheme(_textTheme(_lightColorScheme)),
  appBarTheme: _appBarTheme(
    _lightColorScheme,
    _primaryTextTheme(_textTheme(_lightColorScheme)),
  ),
  elevatedButtonTheme: _elevatedButtonTheme(
    _lightColorScheme,
    _primaryTextTheme(_textTheme(_lightColorScheme)),
  ),
  iconButtonTheme: _iconButtonTheme(_lightColorScheme),
  textButtonTheme: _textButtonTheme(_lightColorScheme),
  inputDecorationTheme: _inputDecorationTheme(
    _lightColorScheme,
    _textTheme(_darkColorScheme),
  ),
);

TextTheme _textTheme(ColorScheme colorScheme) =>
    GoogleFonts.dmSansTextTheme().apply(
      displayColor: colorScheme.onSecondary,
      bodyColor: colorScheme.onSecondary,
    );

TextTheme _primaryTextTheme(TextTheme baseTextTheme) =>
    GoogleFonts.dmSansTextTheme().copyWith(
      displayLarge: baseTextTheme.displayLarge!.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      displayMedium: baseTextTheme.displayMedium!.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      displaySmall: baseTextTheme.displaySmall!.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      headlineLarge: baseTextTheme.headlineLarge!.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      headlineMedium: baseTextTheme.headlineMedium!.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      headlineSmall: baseTextTheme.headlineSmall!.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      titleSmall: baseTextTheme.titleSmall!.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      labelLarge: baseTextTheme.labelLarge!.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      labelMedium: baseTextTheme.labelMedium!.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
      labelSmall: baseTextTheme.labelSmall!.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
    );

AppBarTheme _appBarTheme(ColorScheme colorScheme, TextTheme primaryTextTheme) =>
    AppBarTheme(
      backgroundColor: colorScheme.surfaceContainer,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: primaryTextTheme.titleLarge,
    );

ElevatedButtonThemeData _elevatedButtonTheme(
  ColorScheme colorScheme,
  TextTheme primaryTextTheme,
) => ElevatedButtonThemeData(
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return colorScheme.tertiary.withAlpha(200);
      }
      return colorScheme.tertiary;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return colorScheme.onSurface.withAlpha(31);
      }
      return colorScheme.onPrimary;
    }),
    elevation: WidgetStateProperty.all(0),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    textStyle: WidgetStateProperty.all(primaryTextTheme.labelLarge),
    minimumSize: WidgetStateProperty.all(const Size(double.infinity, 48)),
  ),
);

IconButtonThemeData _iconButtonTheme(ColorScheme colorScheme) =>
    IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(colorScheme.primary),
        overlayColor: WidgetStateProperty.all(
          colorScheme.primary.withAlpha(31),
        ),
      ),
    );

TextButtonThemeData _textButtonTheme(
  ColorScheme colorScheme,
) => TextButtonThemeData(
  style: ButtonStyle(
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return colorScheme.tertiary.withAlpha(31);
      }
      return colorScheme.tertiary;
    }),
    overlayColor: WidgetStateProperty.all(colorScheme.primary.withAlpha(31)),
    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 8)),
  ),
);

InputDecorationTheme _inputDecorationTheme(
  ColorScheme colorScheme,
  TextTheme textTheme,
) => InputDecorationTheme(
  filled: true,
  fillColor: colorScheme.onPrimary,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide.none,
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: colorScheme.error, width: 2),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: colorScheme.error, width: 2),
  ),
  hintStyle: textTheme.bodyLarge?.copyWith(
    color: colorScheme.onSurface.withAlpha(100),
  ),
  errorStyle: textTheme.bodySmall?.copyWith(color: colorScheme.error),
  suffixIconColor: colorScheme.onSurface.withAlpha(100),
);
