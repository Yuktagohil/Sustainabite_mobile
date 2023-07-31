import 'package:flutter/material.dart';

class ProductForm extends StatefulWidget {
  final Function(Map<String, dynamic> data) onSubmit;
  final bool customReminder;
  final Function(String? value) handleReminderChange;

  ProductForm({
    required this.onSubmit,
    required this.customReminder,
    required this.handleReminderChange,
  });

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  // ... (existing code)

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // ... (existing code)
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Map<String, dynamic> productData = {
                  'name': _productNameController.text,
                  'location': _selectedLocation!,
                  'expirationDate': _selectedExpirationDate!.toString(),
                  'reminder': _selectedReminder!,
                };
                widget.onSubmit(productData);
              }
            },
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
