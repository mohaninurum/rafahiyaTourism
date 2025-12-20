import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rafahiyatourism/const/color.dart';
class AddDocumentForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const AddDocumentForm({super.key, required this.onSave});

  @override
  State<AddDocumentForm> createState() => _AddDocumentFormState();
}

class _AddDocumentFormState extends State<AddDocumentForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _authorityController = TextEditingController();
  String _selectedDocumentType = 'Passport';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Document',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDocumentType,
              items: const [
                DropdownMenuItem(value: 'Passport', child: Text('Passport')),
                DropdownMenuItem(value: 'ID Card', child: Text('ID Card')),
                DropdownMenuItem(value: 'License', child: Text('License')),
                DropdownMenuItem(value: 'PAN Card', child: Text('PAN Card')),
                DropdownMenuItem(value: 'Aadhar Card', child: Text('Aadhar Card')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDocumentType = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Document Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Document Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter document number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name on Document',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _issueDateController,
              decoration: const InputDecoration(
                labelText: 'Issue Date (DD-MM-YYYY)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _expiryDateController,
              decoration: const InputDecoration(
                labelText: 'Expiry Date (DD-MM-YYYY)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _authorityController,
              decoration: const InputDecoration(
                labelText: 'Issuing Authority',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newDoc = {
                      'title': _selectedDocumentType,
                      'image': _getDefaultImageForType(_selectedDocumentType),
                      'number': _numberController.text,
                      'name': _nameController.text,
                      'issueDate': _issueDateController.text,
                      'expiryDate': _expiryDateController.text,
                      'authority': _authorityController.text,
                    };
                    widget.onSave(newDoc);
                  }
                },
                child: Text(
                  'Save Document',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDefaultImageForType(String type) {
    switch (type) {
      case 'Passport':
        return 'assets/images/passport.jpg';
      case 'ID Card':
        return 'assets/images/id_card.jpg';
      case 'License':
        return 'assets/images/license.jpg';
      case 'PAN Card':
        return 'assets/images/pan.jpg';
      case 'Aadhar Card':
        return 'assets/images/adhar.png';
      default:
        return 'assets/images/default.jpg';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    _nameController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
    _authorityController.dispose();
    super.dispose();
  }
}