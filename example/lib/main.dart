import 'package:flutter/material.dart';
import 'package:qr_auto_fill_form/qr_auto_fill_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Auto Fill Example',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const QRFormExamplePage(),
    );
  }
}

class QRFormExamplePage extends StatefulWidget {
  const QRFormExamplePage({super.key});

  @override
  State<QRFormExamplePage> createState() => _QRFormExamplePageState();
}

class _QRFormExamplePageState extends State<QRFormExamplePage> {
  final qrFormController = QRFormAutoFillController();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final licenseController = TextEditingController();
  final carController = TextEditingController();
  final dobController = TextEditingController();
  final membershipDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _registerFields();
  }

  void _registerFields() {
    qrFormController.registerField(
      key: 'name',
      controller: nameController,
      required: true,
    );

    qrFormController.registerField(
      key: 'email',
      controller: emailController,
      required: true,
    );

    qrFormController.registerField(
      key: 'license_no',
      controller: licenseController,
      required: true,
    );

    qrFormController.registerField(
      key: 'car',
      controller: carController,
      transform: (value) => value.toString().toUpperCase(),
    );
  }

  @override
  void dispose() {
    qrFormController.dispose();
    nameController.dispose();
    emailController.dispose();
    licenseController.dispose();
    carController.dispose();
    dobController.dispose();
    membershipDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Auto Fill Demo'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: emailController,
                label: 'Email Address',
                icon: Icons.email_outlined,
                isRequired: true,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: licenseController,
                label: 'License Number',
                icon: Icons.badge_outlined,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: carController,
                label: 'Vehicle Model',
                icon: Icons.directions_car_outlined,
              ),
              const SizedBox(height: 50),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text("Scan & Auto Fill"),
                onPressed: () {
                  launchQRFormScanner(
                    context: context,
                    controller: qrFormController,
                    onBeforeScan: () {},
                    showConfirmation: true,
                    confirmTitle: "Auto-Fill",
                    confirmContent: "Use scanned data to fill the form?",
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
      ),
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}
