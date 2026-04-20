import 'package:cloud_firestore/cloud_firestore.dart';

/// A utility class to robustly parse dates from Firestore data.
/// Handles both [Timestamp] objects and ISO 8601 [String]s.
class DateParser {
  /// Parses a value from Firestore into a [DateTime].
  /// Returns [defaultValue] (defaults to current time) if parsing fails.
  static DateTime parse(dynamic value, [DateTime? defaultValue]) {
    if (value == null) return defaultValue ?? DateTime.now();

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? defaultValue ?? DateTime.now();
    }

    // Attempt to handle numeric values (milliseconds since epoch) if any
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return defaultValue ?? DateTime.now();
  }

  /// Parses a value from Firestore into a [DateTime], allowing null.
  static DateTime? parseNullable(dynamic value) {
    if (value == null) return null;
    return parse(value);
  }
}
