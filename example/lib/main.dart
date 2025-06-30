import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_auto_fill_form/qr_auto_fill_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  final Map<String, TextEditingController> _fieldMap = {};
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final interestController = TextEditingController();
  String? qrData;

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
      key: 'numbers',
      controller: phoneController,
      required: true,
    );

    qrFormController.registerField(
      key: 'profession',
      controller: interestController,
      transform: (value) => value.toString().toUpperCase(),
    );
  }

  @override
  void dispose() {
    qrFormController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    interestController.dispose();
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
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: phoneController,
                label: 'License Number',
                icon: Icons.badge_outlined,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: interestController,
                label: 'Vehicle Model',
                icon: Icons.directions_car_outlined,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  launchQRFormScanner(
                    context: context,
                    controller: qrFormController,
                    onBeforeScan: () {},
                    format: QRDataFormat.json,
                    showConfirmation: true,
                    confirmTitle: "Auto-Fill",
                    confirmContent: "Use scanned data to fill the form?",
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                child: const Text("Scan & Auto Fill"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final data = qrFormController.generateQRData(
                    format: QRDataFormat.json,
                  );
                  setState(() {
                    qrData = data;
                  });
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                child: const Text("Generate Json"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final data = qrFormController.generateQRData(
                    format: QRDataFormat.keyValue,
                  );
                  setState(() {
                    qrData = data;
                  });
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),

                child: const Text("Generate KeyValue"),
              ),

              SizedBox(height: 10),

              if (qrData != null && qrData!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📌 Copy this QR string and use any package (e.g. `qr_flutter`) to render it as a QR code.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SelectableText(
                            qrData!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: qrData ?? ""),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'QR data copied to clipboard',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('Copy'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
