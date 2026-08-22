/// App-wide constants used throughout the application.
///
/// This file contains configuration values, sizing constants,
/// and other static values that should be consistent across the app.
library;

/// Application metadata and configuration
abstract class AppConstants {
  /// Application name
  static const String appName = 'Kylie Gym';

  /// Application version (synced with pubspec.yaml)
  static const String version = '1.0.0';
}

/// API and network related constants
abstract class ApiConstants {
  /// Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Connection timeout duration
  static const Duration connectionTimeout = Duration(seconds: 10);
}

/// UI spacing and sizing constants
abstract class Spacing {
  /// Extra small spacing (4.0)
  static const double xs = 4.0;

  /// Small spacing (8.0)
  static const double sm = 8.0;

  /// Medium spacing (16.0)
  static const double md = 16.0;

  /// Large spacing (24.0)
  static const double lg = 24.0;

  /// Extra large spacing (32.0)
  static const double xl = 32.0;

  /// Double extra large spacing (48.0)
  static const double xxl = 48.0;
}

/// Border radius constants
abstract class Radii {
  /// Small radius (4.0)
  static const double sm = 4.0;

  /// Medium radius (8.0)
  static const double md = 8.0;

  /// Large radius (12.0)
  static const double lg = 12.0;

  /// Extra large radius (16.0)
  static const double xl = 16.0;

  /// Circular radius (999.0)
  static const double circular = 999.0;
}

/// Animation duration constants
abstract class Durations {
  /// Fast animation (150ms)
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal animation (300ms)
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow animation (500ms)
  static const Duration slow = Duration(milliseconds: 500);
}

/// Pagination constants
abstract class Pagination {
  /// Default page size for list queries
  static const int defaultPageSize = 20;

  /// Page size for the members list
  static const int membersPageSize = defaultPageSize;

  /// Max results for member picker / quick search dialogs
  static const int memberPickerSearchLimit = 25;

  /// Maximum page size allowed
  static const int maxPageSize = 100;
}

