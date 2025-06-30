## [1.1.1] - 2025-06-26

### ✨ New Features
- Added support for generating QR data from form fields.
  - Supports both JSON and key-value output formats.
  - Ideal for creating QR codes to share or scan later.
- Introduced `generateQRData()` method in `QRFormAutoFillController`.

### 🛠 Improvements
- Enhanced `_parseKeyValue` to support type parsing for `int`, `double`, and `bool`.
- Updated documentation and inline Dartdoc comments for better code understanding and pub score.
- Added example usage for QR generation and scanning.
- Added support for copying the generated QR string (manually via `Clipboard.setData` in example).

### ✅ Existing Highlights
- Full-screen QR scanner screen with custom UI.
- Auto-fills registered form fields from scanned QR content.
- Supports JSON and key-value formats.
- Optional confirmation dialog before applying scanned data.
- Field-level transformers and validation support.
- Clean integration with `TextEditingController`s.
