# qr_auto_fill_form

[![pub package](https://img.shields.io/pub/v/qr_auto_fill_form.svg)](https://pub.dev/packages/qr_auto_fill_form)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub Repo stars](https://img.shields.io/github/stars/aboubakar6677/qr_auto_fill_form?style=social)](https://github.com/aboubakar6677/qr_auto_fill_form)

---

## ✨ Overview

`qr_auto_fill_form` is a customizable Flutter package that lets users scan QR codes and automatically populate form fields with the decoded data. Ideal for forms in onboarding, vehicle rental, check-ins, ID entry, or automated data collection workflows.

---

## 🚀 Features

- ✅ Full-screen, professional QR scanner screen
- ✅ Auto-fills text fields based on scanned QR JSON data
- ✅ Supports clearing fields before scan
- ✅ Optional confirmation dialog before applying scanned data
- ✅ Easy integration into existing forms
- ✅ Supports field-level transformations and validation hooks
- ✅ Works out-of-the-box with `TextEditingController`s

---

## 📦 Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  qr_auto_fill_form: ^1.0.0

Then run:
flutter pub get

💡 Usage
1. Register your form fields
final qrFormController = QRFormAutoFillController();

@override
void initState() {
  super.initState();

  qrFormController.registerField('name', nameController);
  qrFormController.registerField('email', emailController);
  qrFormController.registerField('license_no', licenseController);
  qrFormController.registerField('car', carController);
}

2. Trigger QR scan and auto-fill
ElevatedButton(
  onPressed: () {
    launchQRFormScanner(
      context: context,
      controller: qrFormController,
      onBeforeScan: () {
        nameController.clear();
        emailController.clear();
        licenseController.clear();
        carController.clear();
      },
      showConfirmation: true,
      confirmTitle: 'Auto-Fill Form',
      confirmContent: 'Do you want to use this scanned data?',
    );
  },
  child: const Text('Scan & Fill'),
);

🔄 Example QR JSON
Your QR code should encode a JSON object like:
{
  "name": "John Doe",
  "email": "john@example.com",
  "license_no": "LHR-789",
  "car": "ABC-123"
}

📁 Example Project
View the example here:
👉 example/lib/main.dart

cd example
flutter run

🔗 Links
📦 Pub.dev Package

🐙 GitHub Repository

🐞 Issue Tracker

📄 License
This project is licensed under the MIT License.
Copyright © 2024 Abou Bakar