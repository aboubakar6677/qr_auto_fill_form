import 'dart:convert';

import 'package:flutter/material.dart';

enum QRDataFormat { json, keyValue }

typedef CustomQRParser = Map<String, dynamic> Function(String rawData);

class QRFormAutoFillController {
  final Map<String, TextEditingController> _fieldMap = {};
  final Map<String, String Function(dynamic)> _transformers = {};
  final List<String> _requiredFields = [];

  QRDataFormat defaultFormat;
  List<String> delimitedOrder;
  CustomQRParser? customParser;
  String delimiter;

  bool _disposed = false;

  QRFormAutoFillController({
    this.defaultFormat = QRDataFormat.json,
    this.delimitedOrder = const [],
    this.delimiter = '|',
    this.customParser,
  });

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

  void unregisterField(String key) {
    _fieldMap.remove(key);
    _transformers.remove(key);
    _requiredFields.remove(key);
  }

  void clearFields() {
    _fieldMap.clear();
    _transformers.clear();
    _requiredFields.clear();
  }

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

  void dispose() {
    _fieldMap.clear();
    _transformers.clear();
    _requiredFields.clear();
    _disposed = true;
  }

  void clearAll() {
    for (final controller in _fieldMap.values) {
      controller.clear();
    }
  }
}
