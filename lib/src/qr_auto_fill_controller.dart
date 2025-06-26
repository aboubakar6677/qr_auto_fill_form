// import 'package:flutter/material.dart';

// class QRFormAutoFillController {
//   final Map<String, TextEditingController> _fieldMap = {};

//   void registerField(String key, TextEditingController controller) {
//     _fieldMap[key] = controller;
//   }

//   void fillFromQRData(Map<String, dynamic> data) {
//     data.forEach((key, value) {
//       if (_fieldMap.containsKey(key)) {
//         _fieldMap[key]?.text = value?.toString() ?? '';
//       }
//     });
//   }
// }
import 'package:flutter/material.dart';

/// A controller for managing form auto-filling from QR code data
class QRFormAutoFillController {
  final Map<String, TextEditingController> _fieldMap = {};
  final Map<String, String Function(dynamic)> _transformers = {};
  final List<String> _requiredFields = [];
  bool _disposed = false;

  /// Registers a form field to be auto-filled
  void registerField({
    required String key,
    required TextEditingController controller,
    String Function(dynamic)? transform,
    bool required = false,
  }) {
    if (_disposed) {
      throw StateError('Cannot register fields after controller is disposed');
    }

    _fieldMap[key] = controller;
    if (transform != null) {
      _transformers[key] = transform;
    }
    if (required) {
      _requiredFields.add(key);
    }
  }

  /// Unregisters a form field
  void unregisterField(String key) {
    _fieldMap.remove(key);
    _transformers.remove(key);
    _requiredFields.remove(key);
  }

  /// Clears all registered fields
  void clearFields() {
    _fieldMap.clear();
    _transformers.clear();
    _requiredFields.clear();
  }

  /// Fills form data from QR code content
  void fillFromQRData(Map<String, dynamic> data) {
    if (_disposed) {
      throw StateError('Cannot fill fields after controller is disposed');
    }

    // Validate required fields
    for (final field in _requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        throw FormatException('Missing required field: $field');
      }
    }

    // Fill fields
    for (final entry in _fieldMap.entries) {
      final key = entry.key;
      final controller = entry.value;

      if (data.containsKey(key)) {
        final value = data[key];
        if (_transformers.containsKey(key)) {
          controller.text = _transformers[key]!(value);
        } else {
          controller.text = value?.toString() ?? '';
        }
      }
    }
  }

  /// Disposes the controller and clears all references
  void dispose() {
    _fieldMap.clear();
    _transformers.clear();
    _requiredFields.clear();
    _disposed = true;
  }
}
