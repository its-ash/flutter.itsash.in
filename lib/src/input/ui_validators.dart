import 'package:flutter/widgets.dart';

/// Ready-made, composable form validators.
///
/// Every validator except [required] lets empty values pass, so optional
/// fields stay valid until the user types something.
///
/// ```dart
/// validator: UiValidators.compose([UiValidators.required(), UiValidators.email()]),
/// ```
abstract final class UiValidators {
  static bool _isEmpty(Object? v) =>
      v == null || (v is String && v.trim().isEmpty) || (v is Iterable && v.isEmpty) || (v is Map && v.isEmpty);

  /// Fails when the value is null, a blank string, or an empty collection.
  static FormFieldValidator<T> required<T>({String? message}) =>
      (v) => _isEmpty(v) ? (message ?? 'This field is required') : null;

  /// Fails when the value is not a valid email address.
  static FormFieldValidator<String> email({String? message}) {
    final re = RegExp(r"^[\w.!#$%&'*+/=?^`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?(?:\.[A-Za-z0-9-]+)+$");
    return (v) => _isEmpty(v) || re.hasMatch(v!.trim()) ? null : (message ?? 'Enter a valid email address');
  }

  /// Fails when the text is shorter than [min] characters.
  static FormFieldValidator<String> minLength(int min, {String? message}) =>
      (v) => _isEmpty(v) || v!.length >= min ? null : (message ?? 'Use at least $min characters');

  /// Fails when the text is longer than [max] characters.
  static FormFieldValidator<String> maxLength(int max, {String? message}) =>
      (v) => _isEmpty(v) || v!.length <= max ? null : (message ?? 'Use at most $max characters');

  /// Fails when the text does not fully match [regex].
  static FormFieldValidator<String> pattern(RegExp regex, {String? message}) => (v) {
    if (_isEmpty(v)) return null;
    final m = regex.firstMatch(v!);
    return m != null && m.start == 0 && m.end == v.length ? null : (message ?? 'Invalid format');
  };

  /// Fails when the text is not a number, or is outside [min]..[max].
  static FormFieldValidator<String> numeric({num? min, num? max, bool integer = false, String? message}) => (v) {
    if (_isEmpty(v)) return null;
    final n = integer ? int.tryParse(v!.trim()) : num.tryParse(v!.trim());
    if (n == null) return message ?? (integer ? 'Enter a whole number' : 'Enter a number');
    if (min != null && n < min) return message ?? 'Must be at least $min';
    if (max != null && n > max) return message ?? 'Must be at most $max';
    return null;
  };

  /// Fails when the value differs from the one returned by [other]
  /// (e.g. a "confirm password" field).
  static FormFieldValidator<String> match(String? Function() other, {String? message}) =>
      (v) => (v ?? '') == (other() ?? '') ? null : (message ?? 'Values do not match');

  /// Runs [validators] in order and returns the first error.
  static FormFieldValidator<T> compose<T>(List<FormFieldValidator<T>> validators) => (v) {
    for (final validate in validators) {
      final error = validate(v);
      if (error != null) return error;
    }
    return null;
  };
}
