import 'dart:convert';

import 'package:flutter/material.dart';

/// Format of raw QR string data.
///
/// - [json]: JSON-encoded string like `{"name": "John"}`
/// - [keyValue]: Key-value format like `name=John;email=john@example.com`

enum QRDataFormat { json, keyValue }

/// A typedef for providing a custom parser function for QR raw string input.
/// Should return a Map of key-value pairs that match registered field keys.
typedef CustomQRParser = Map<String, dynamic> Function(String rawData);

/// Controller to auto-fill registered text fields using parsed QR data.
///
/// Supports multiple formats including JSON, key-value, and custom parsers.

class QRFormAutoFillController {
  final Map<String, TextEditingController> _fieldMap = {};
  final Map<String, String Function(dynamic)> _transformers = {};
  final List<String> _requiredFields = [];

  QRDataFormat defaultFormat;
  List<String> delimitedOrder;
  CustomQRParser? customParser;
  String delimiter;

  bool _disposed = false;

  /// Creates a [QRFormAutoFillController] with optional QR format config,
  /// a custom parser, field order (for delimited values), and delimiter.
  QRFormAutoFillController({
    this.defaultFormat = QRDataFormat.json,
    this.delimitedOrder = const [],
    this.delimiter = '|',
    this.customParser,
  });

  /// Registers a form field with a [TextEditingController] under a specific key.
  ///
  /// [transform] allows you to convert raw values (e.g., to uppercase, format dates).
  /// [required] ensures that this field must exist in parsed QR data.
  void registerField({
    required String key,
    required TextEditingController controller,
    String Function(dynamic)? transform,
    bool required = false,
  }) {
    _fieldMap[key] = controller;
    if (transform != null) _transformers[key] = transform;
    if (required) _requiredFields.add(key);
  }

  /// Unregisters a form field and removes its transformer and required flag (if set).
  void unregisterField(String key) {
    _fieldMap.remove(key);
    _transformers.remove(key);
    _requiredFields.remove(key);
  }

  /// Clears all registered fields, transformers, and required keys.
  /// Does not clear field values in UI — use [clearAll] for that.
  void clearFields() {
    _fieldMap.clear();
    _transformers.clear();
    _requiredFields.clear();
  }

  /// Generates a string representation of registered fields
  /// in either JSON or key-value format, suitable for QR generation.
  ///
  /// [format] determines the output style.
  /// Returns a formatted string like:
  /// - JSON: {"name":"John","email":"abc@example.com" }
  /// - Key-Value: name=John;email=abc@example.com
  String generateQRData({QRDataFormat format = QRDataFormat.json}) {
    final data = <String, dynamic>{};

    for (final entry in _fieldMap.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty) data[entry.key] = value;
    }

    switch (format) {
      case QRDataFormat.json:
        return json.encode(data);
      case QRDataFormat.keyValue:
        return data.entries.map((e) => '${e.key}=${e.value}').join(';');
    }
  }

  /// Parses raw QR string and fills all registered fields if matching keys exist.
  ///
  /// Throws [FormatException] if a required field is missing.
  /// You may override the default format using [format].
  void fillFromRawQRData(String raw, {QRDataFormat? format}) {
    if (_disposed) throw StateError('Controller has been disposed');

    final parsed = _parse(raw, format ?? defaultFormat);

    // Check required
    for (final field in _requiredFields) {
      if (!parsed.containsKey(field) || parsed[field] == null) {
        throw FormatException('Missing required field: $field');
      }
    }

    // Fill fields
    for (final entry in _fieldMap.entries) {
      final key = entry.key;
      final controller = entry.value;

      if (parsed.containsKey(key)) {
        final rawValue = parsed[key];
        controller.text = _transformers.containsKey(key)
            ? _transformers[key]!(rawValue)
            : rawValue?.toString() ?? '';
      }
    }
  }

  Map<String, dynamic> _parse(String raw, QRDataFormat format) {
    switch (format) {
      case QRDataFormat.json:
        return _parseJSON(raw);
      case QRDataFormat.keyValue:
        return _parseKeyValue(raw);
    }
  }

  Map<String, dynamic> _parseJSON(String raw) {
    try {
      // Fix common relaxed JSON: convert single quotes to double quotes
      String normalized = raw
          .replaceAllMapped(RegExp(r"'([^']*)'"), (match) => '"${match[1]}"')
          .replaceAll("'", '"');

      final parsed = json.decode(normalized);
      if (parsed is! Map<String, dynamic>) {
        throw FormatException('Not a valid JSON map');
      }
      return parsed;
    } catch (e) {
      throw FormatException('Invalid JSON: $e');
    }
  }

  Map<String, dynamic> _parseKeyValue(String raw) {
    final map = <String, dynamic>{};
    final pairs = raw.split(';');
    for (final pair in pairs) {
      final kv = pair.split('=');
      if (kv.length == 2) {
        map[kv[0].trim()] = kv[1].trim();
      }
    }
    return map;
  }

  /// Disposes the controller by clearing internal maps and marking it inactive.
  void dispose() {
    _fieldMap.clear();
    _transformers.clear();
    _requiredFields.clear();
    _disposed = true;
  }

  /// Clears text in all currently registered.
  void clearAll() {
    for (final controller in _fieldMap.values) {
      controller.clear();
    }
  }
}
