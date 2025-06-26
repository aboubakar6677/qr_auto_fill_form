import 'package:flutter/material.dart';
import 'package:qr_auto_fill_form/qr_auto_fill_form.dart';

void main() {
  runApp(const QRExampleApp());
}

class QRExampleApp extends StatelessWidget {
  const QRExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Auto Fill Example',
      theme: ThemeData(primarySwatch: Colors.teal),
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

    qrFormController.registerField(key: 'dob', controller: dobController);

    qrFormController.registerField(
      key: 'membership_date',
      controller: membershipDateController,
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
      appBar: AppBar(
        title: const Text('QR Auto Fill Demo'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: QRScannerButton(
              
              controller: qrFormController,
              buttonText: "Scan to Autofill",
              icon: Icons.document_scanner_outlined,
              successMessage: 'Form data loaded from QR',
              errorMessage: 'Invalid QR format. Please try again.',
              showConfirmation: true,
              confirmationTitle: 'Confirm Auto-Fill',
              confirmationContent:
                  'Do you want to fill the form with this data?',
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue.shade800,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
                elevation: 1,
              ),
            ),
          ),
        ],
      ),
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
              const SizedBox(height: 16),
              _buildTextField(
                controller: dobController,
                label: 'Date of Birth',
                icon: Icons.cake_outlined,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: membershipDateController,
                label: 'Membership Date',
                icon: Icons.date_range_outlined,
                readOnly: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'SUBMIT FORM',
                  style: TextStyle(fontSize: 16),
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

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
