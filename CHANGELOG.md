# Changelog

## [1.11.0] - 2025-05-15

### Changed

- Upgraded to Flutter 3.32.1! 🎉

## [1.10.3] - 2025-03-10

### Changed

- Upgraded to Flutter 3.29.2! 🎉

### Fixed

- Fixed small issue with logging a period event.

## [1.10.2] - 2025-03-07

### Changed

- Removed some unused plugins.

## [1.10.1] - 2025-03-03

### Changed

- Adjust bottom spacing when app is running in web.
- Removed mouse hover effects for cards.

## [1.10.0] - 2025-02-28

### Added

- Now supports web!

### Changed

- Swapped out `flutter_secure_storage` for `shared_preferences`.

### Fixed

- Fixed issue with determining menstruation phase for selected date in calendar.
- Fixed symptoms showing up even after being removed from the list.

## [1.9.0] - 2025-02-21

### Added

- Feature to permanently delete a symptom from the selection.

### Fixed

- Fixed issue with logging periods causing API errors.

### Changed

- Upgrade to Flutter 3.29! 🎉

## [1.8.0] - 2025-02-10

### Added

- Added push notifications to alert users before their next predicted period.

### Changed

- Improved AI insight accuracy and migrated to Gemini version 2.0-lite-flash for improved performance.

## [1.7.0] - 2025-01-16

### Changed

- Upgraded to Flutter v3.28.3.
- Upgraded Gemini to v2.0.

## [1.6.3] - 2025-01-15

### Changed

- Enhanced period logging accuracy. Now, when the first day of a period is logged, the app automatically logs the entire period duration (defaulting to 5 days) for that cycle. This replaces the previous method of logging only the first day and predicting the rest, which often led to inaccurate forecasts.

### Fixed

- Fixed issue where intimacy marker was not visible in the calendar on a period day because they had similar colors.
- Fixed issue with navigation bar color not being transparent on Android devices.

## [1.6.2] - 2025-01-13

### Fixed

- Fixed issue where predictions for period events that are currently happening were not being generated properly.
- Fixed small UI issues with buttons, shadows, and colors.

## [1.6.1] - 2025-01-12

### Fixed

- Fixed (again 😓) how cycle event predictions are generated.

## [1.6.0] - 2025-01-12

### Added

- Introduce "uncertain predictions" for period events when cycle lengths exceed 28 days, since most people's cycles are not perfectly regular.

### Fixed

- Fixed issue with 3-button navigation bar color for Android 15+ devices.
- Fixed issue with how errors are handled and displayed in the home screen.

## [1.5.6] - 2025-01-11

### Added

- Added button to go back to today's date in the calendar.

### Fixed

- Fixed issues with determining the current cycle day.
- Fixed issue where new predictions are made when selecting a date in the calendar.

## [1.5.5] - 2025-01-11

### Fixed

- Fixed issue with calendar not scrolling vertically.
- Fixed how fertile window predictions are generated.

## [1.5.4] - 2025-01-08

### Changed

- Small fix regarding the state management of the app.

## [1.5.3] - 2025-01-07

### Changed

- Updated splash screen background color.
- Reworked how predictions and AI-powered insights are generated.

### Fixed

- Fixed issues with iOS local storage.

## [1.5.2] - 2025-01-02

### Fixed

- Fixed issue with removing emojis from the AI-generated insights.
- Fixed prediction inaccuracies by adjusting forecasts when periods are delayed.

## [1.5.1] - 2025-01-02

### Changed

- Improved app architecture with cleaner code structure.
- Improved data privacy by making local storage more secure.
- Optimized API usage with smarter caching system.

## [1.5.0] - 2025-01-02

### Changed

- Upgraded to Flutter 3.29.0! 🎉
- Now using an external API for calculating cycle forecasts.

### Fixed

- Fixed cycle forecast errors due to unreliable on-device prediction logic.

## [1.4.1] - 2024-11-25

### Fixed

- Fixed issue with selecting dates in the calendar.

## [1.4.0] - 2024-11-25

### Changed

- Upgraded to Flutter 3.24.5! 🎉
- Reworked state management and dependency injection. Not using Riverpod anymore!

## [1.3.4] - 2024-10-22

### Fixed

- Fixed issue with removing intimacy events.

## [1.3.3] - 2024-10-10

### Fixed

- Fixed incorrect calculation of cycle day.

## [1.3.2] - 2024-10-09

### Fixed

- Fixed incorrect insight data being displayed.
- Minor tweaks to the insight prompt.

## [1.3.1] - 2024-09-19

### Changed

- Upgraded to Flutter 3.24.3! 🎉
- Reworked symptoms. Now you can create new symptoms!

## [1.3.0] - 2024-09-19

### Changed

- Upgraded to Flutter 3.24.3! 🎉
- Reworked symptoms. Now you can create new symptoms!

## [1.2.0] - 2024-08-08

### Added

- Feature to log remove a cycle event.

### Changed

- Upgraded to Flutter 3.24! 🎉

## [1.1.3] - 2024-08-05

### Changed

- Changed some labels for the info cards.
- Removed unnecessary `cycleEventsProvider`.

## [1.1.2] - 2024-08-02

### Fixed

- Fixed issue where logging cycle events would be logged to the current date instead of the selected date.

## [1.1.1] - 2024-08-02

### Added

- Feature to clear cached data when installing a new version.

### Changed

- Updated app icon and splash screen.
- Redesigned the "cycle metrics" section.

## [1.1.0] - 2024-08-01

### Added

- Feature to show details for a selected date within the calendar.

### Changed

- Updated app icon and colors.

## [1.0.11] - 2024-07-30

### Fixed

- Rework how forecasts are generated.

## [1.0.10] - 2024-07-30

### Fixed

- Fixed issue with calendar date being highlighted incorrectly when date is outside the current month.
- Fixed issue with forecast when logging symptoms/intimacy.

## [1.0.9] - 2024-07-29]

### Added

- When logging the first period event for the new cycle, predictions for that cycle become actual events, and the next cycle's predictions are generated based on the new data.

### Fixed

- Fixed issue with forecasts not updating correctly when new cycle events are logged.

## [1.0.8] - 2024-07-26

### Fixed

- Fixed issue with the insights and predictions when logging new cycle events.

## [1.0.7] - 2024-07-24

### Added

- Feature to log intimate activities.

### Changed

- Updated calendar marker colors for cycle events.
- Changed the label for the "Other symptoms" textfield.

### Fixed

- Fixed issue where generated predictions didn't account for other types of cycle events.

## [1.0.6] - 2024-07-23

### Changed

- Redesigned calendar markers for cycle events.
- Improved the accuracy of insights generated by Gemini.
- Refined how the fertile window predictions are calculated.

## [1.0.5] - 2024-07-22

### Fixed

- Fixed a bug with how insights were generated and cached.

## [1.0.4] - 2024-07-22

### Changed

- Instead of using one prompt to generate insights, Gemini now uses multiple prompts to provide more accurate insights.

### Fixed

- Fixed how the fertile window predictions are generated.

## [1.0.3] - 2024-07-22

### Changed

- Refined the Gemini prompt for better and more accurate insights.
- Overhauled how predictions are generated to improve both code readability and forecast precision.

## [1.0.2] - 2024-07-19

### Added

- Feature to predict and show ovulation dates on the calendar.

### Changed

- Improved Gemini insights for better accuracy and personalization.
- Temporarily disabled logging of ovulation and sexual activity (not yet supported).

## [1.0.1] - 2024-07-19

### Added

- Feature to log menstrual periods.
- Feature to log symptoms experienced during the menstrual cycle.

## [1.0.0] - 2024-07-17

### Added

- Initial release. 🎉
- Ability to view calendar and cycle events, including periods, fertile windows, and symptoms.
- Feature to view cycle insights, powered by Gemini, offering personalized insights.
